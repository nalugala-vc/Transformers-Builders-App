"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.confirmPasswordResetOtp = exports.requestPasswordResetOtp = void 0;
const admin = __importStar(require("firebase-admin"));
const crypto_1 = require("crypto");
const firestore_1 = require("firebase-admin/firestore");
const params_1 = require("firebase-functions/params");
const https_1 = require("firebase-functions/v2/https");
const email_1 = require("./email");
admin.initializeApp();
const resendApiKey = (0, params_1.defineSecret)("RESEND_API_KEY");
const otpPepper = (0, params_1.defineSecret)("OTP_PEPPER");
const emailFrom = (0, params_1.defineSecret)("EMAIL_FROM");
const OTP_COLLECTION = "password_reset_otps";
const OTP_TTL_MS = 15 * 60 * 1000;
const MAX_SENDS_PER_HOUR = 5;
const MAX_VERIFY_ATTEMPTS = 5;
const REGION = "us-central1";
function normalizeEmail(email) {
    return email.trim().toLowerCase();
}
function docIdForEmail(email) {
    return (0, crypto_1.createHash)("sha256").update(normalizeEmail(email)).digest("hex");
}
function hashOtp(code, pepper) {
    return (0, crypto_1.createHash)("sha256").update(`${pepper}:${code}`).digest("hex");
}
function generateOtp() {
    return (0, crypto_1.randomInt)(0, 1_000_000).toString().padStart(6, "0");
}
function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
function pruneSendTimestamps(timestamps, now) {
    const oneHourAgo = now - 60 * 60 * 1000;
    return timestamps.filter((value) => value > oneHourAgo);
}
exports.requestPasswordResetOtp = (0, https_1.onCall)({ secrets: [resendApiKey, otpPepper, emailFrom], region: REGION }, async (request) => {
    const rawEmail = request.data?.email;
    if (typeof rawEmail !== "string" || !isValidEmail(rawEmail)) {
        throw new https_1.HttpsError("invalid-argument", "A valid email is required.");
    }
    const email = normalizeEmail(rawEmail);
    const now = Date.now();
    const db = admin.firestore();
    const docRef = db.collection(OTP_COLLECTION).doc(docIdForEmail(email));
    let userExists = false;
    try {
        await admin.auth().getUserByEmail(email);
        userExists = true;
    }
    catch (error) {
        const code = error.code;
        if (code !== "auth/user-not-found") {
            throw new https_1.HttpsError("internal", "Could not process request.");
        }
    }
    if (!userExists) {
        return { success: true };
    }
    const snap = await docRef.get();
    const existing = snap.data();
    const recentSendTimestamps = pruneSendTimestamps(existing?.recentSendTimestamps ?? [], now);
    if (recentSendTimestamps.length >= MAX_SENDS_PER_HOUR) {
        throw new https_1.HttpsError("resource-exhausted", "Too many reset requests. Try again in about an hour.");
    }
    const code = generateOtp();
    const codeHash = hashOtp(code, otpPepper.value());
    recentSendTimestamps.push(now);
    await docRef.set({
        email,
        codeHash,
        expiresAt: firestore_1.Timestamp.fromMillis(now + OTP_TTL_MS),
        attemptCount: 0,
        recentSendTimestamps,
    });
    await (0, email_1.sendPasswordResetOtpEmail)({
        to: email,
        code,
        resendApiKey: resendApiKey.value(),
        from: emailFrom.value(),
    });
    if (process.env.FUNCTIONS_EMULATOR === "true") {
        console.log(`[DEV] Password reset OTP for ${email}: ${code}`);
    }
    return { success: true };
});
exports.confirmPasswordResetOtp = (0, https_1.onCall)({ secrets: [otpPepper], region: REGION }, async (request) => {
    const rawEmail = request.data?.email;
    const rawCode = request.data?.code;
    const rawPassword = request.data?.newPassword;
    if (typeof rawEmail !== "string" || !isValidEmail(rawEmail)) {
        throw new https_1.HttpsError("invalid-argument", "A valid email is required.");
    }
    if (typeof rawCode !== "string" || !/^\d{6}$/.test(rawCode.trim())) {
        throw new https_1.HttpsError("invalid-argument", "Enter the 6-digit code.");
    }
    if (typeof rawPassword !== "string" || rawPassword.length < 8) {
        throw new https_1.HttpsError("invalid-argument", "Password must be at least 8 characters.");
    }
    const email = normalizeEmail(rawEmail);
    const code = rawCode.trim();
    const db = admin.firestore();
    const docRef = db.collection(OTP_COLLECTION).doc(docIdForEmail(email));
    const snap = await docRef.get();
    if (!snap.exists) {
        throw new https_1.HttpsError("permission-denied", "Invalid or expired code. Request a new one.");
    }
    const data = snap.data();
    const now = Date.now();
    if (data.expiresAt.toMillis() < now) {
        await docRef.delete();
        throw new https_1.HttpsError("permission-denied", "This code has expired. Request a new one.");
    }
    if (data.attemptCount >= MAX_VERIFY_ATTEMPTS) {
        await docRef.delete();
        throw new https_1.HttpsError("permission-denied", "Too many attempts. Request a new code.");
    }
    const expectedHash = hashOtp(code, otpPepper.value());
    if (expectedHash !== data.codeHash) {
        await docRef.update({ attemptCount: firestore_1.FieldValue.increment(1) });
        throw new https_1.HttpsError("permission-denied", "Invalid code. Try again.");
    }
    let uid;
    try {
        const user = await admin.auth().getUserByEmail(email);
        uid = user.uid;
    }
    catch {
        await docRef.delete();
        throw new https_1.HttpsError("permission-denied", "Invalid or expired code. Request a new one.");
    }
    await admin.auth().updateUser(uid, { password: rawPassword });
    await docRef.delete();
    return { success: true };
});
//# sourceMappingURL=index.js.map