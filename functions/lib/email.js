"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendPasswordResetOtpEmail = sendPasswordResetOtpEmail;
const resend_1 = require("resend");
async function sendPasswordResetOtpEmail(params) {
    const resend = new resend_1.Resend(params.resendApiKey);
    const { error } = await resend.emails.send({
        from: params.from,
        to: params.to,
        subject: "Your Transformers Builders password reset code",
        html: [
            "<div style=\"font-family:Helvetica,Arial,sans-serif;max-width:480px;margin:0 auto;color:#111827\">",
            "<h2 style=\"color:#2D5BE3\">Password reset</h2>",
            "<p style=\"font-size:15px;line-height:1.5;color:#4B5563\">",
            "Use this 6-digit code in the app to reset your password. It expires in 15 minutes.",
            "</p>",
            `<p style="font-size:32px;font-weight:700;letter-spacing:6px;margin:24px 0">${params.code}</p>`,
            "<p style=\"font-size:13px;color:#6B7280\">",
            "If you did not request this, you can ignore this email.",
            "</p>",
            "</div>",
        ].join(""),
    });
    if (error) {
        throw new Error(`Resend error: ${error.message}`);
    }
}
//# sourceMappingURL=email.js.map