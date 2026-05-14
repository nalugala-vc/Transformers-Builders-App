import 'package:flutter/material.dart';

class AppPallete {
  // Brand — sampled from the Transformers' Chapel logo & UI mockups
  static const Color tcBlue = Color(0xFF1E3A8A);       // Primary deep blue (splash, headers, sidebar)
  static const Color tcBlueDark = Color(0xFF0F2A6B);   // Darker blue for gradients & pressed states
  static const Color tcBlueLight = Color(0xFF6366F1);  // Indigo/violet accent (titles like "Admin Login", "Set Your Contribution Target")
  static const Color tcRed = Color(0xFFDC2626);        // Primary red CTA (Login, Pay Now, Set Target, Contribute)
  static const Color tcRedDark = Color(0xFFB91C1C);    // Red pressed/hover state
  static const Color tcWhite = Color(0xFFFFFFFF);

  // Status
  static const Color successGreen = Color(0xFF16A34A); // "+12.5% this week", successful contribution tick
  static const Color errorRed = Color(0xFFEF4444);     // Failed transaction icon
  static const Color infoBlue = Color(0xFF3B82F6);     // Notification bell, info icons
  static const Color warningAmber = Color(0xFFF59E0B); // Reserved for goal-edit flags & warnings

  // Neutrals
  static const Color textPrimary = Color(0xFF111827);  // Main body text
  static const Color textSecondary = Color(0xFF4B5563);// Subtitles, helper text
  static const Color textMuted = Color(0xFF6B7280);    // Captions, footer text, "+24 this week" style
  static const Color border = Color(0xFFE5E7EB);       // Card borders, dividers
  static const Color cardBg = Color(0xFFF9FAFB);       // Member card background
  static const Color scaffoldBg = Color(0xFFF3F4F6);   // Page background (light grey behind cards)
  static const Color splashLightBlue = Color(0xFFE0F2FE); // Splash scaffold (soft sky blue)
  static const Color inputFill = Color(0xFFF3F4F6);    // Input field fills (email/password boxes)

  // Progress bar fills
  static const Color progressTrack = Color(0xFFE5E7EB); // Empty portion of progress bars
  static const Color progressFill = Color(0xFFDC2626);  // Red fill (church-wide progress)
  static const Color progressFillBlue = Color(0xFF6366F1); // Indigo fill (member contribution progress)
}