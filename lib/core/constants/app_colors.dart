import 'package:flutter/material.dart';

class AppColors {
  // Brand / Primary Colors
  static const Color primary = Color(0xFF00796B); // Deep Teal
  static const Color primaryDark = Color(0xFF004D40); // Dark Teal
  static const Color primaryLight = Color(0xFFE0F2F1); // Light Mint Tint
  static const Color accent = Color(0xFF00A88F); // Vibrant Teal Accent

  // Secondary & Functional Colors
  static const Color success = Color(0xFF2E7D32); // Green for Taken
  static const Color error = Color(0xFFD32F2F); // Red for Missed / Alert
  static const Color warning = Color(0xFFF57C00); // Orange for Due Soon
  static const Color info = Color(0xFF0288D1); // Blue

  // Neutral Palette
  static const Color background = Color(0xFFF7F9FB); // Off-white canvas
  static const Color surface = Color(0xFFFFFFFF); // Card / Sheet white
  static const Color textPrimary = Color(0xFF1C1C1E); // Dark charcoal
  static const Color textSecondary = Color(0xFF757575); // Medium gray
  static const Color textLight = Color(0xFF9E9E9E); // Light gray
  static const Color border = Color(0xFFE0E0E0); // Divider & border

  // Custom Status Badges
  static const Color badgeTakenBg = Color(0xFFE8F5E9);
  static const Color badgeTakenText = Color(0xFF2E7D32);

  static const Color badgeMissedBg = Color(0xFFFFEBEE);
  static const Color badgeMissedText = Color(0xFFC62828);

  static const Color badgeUpcomingBg = Color(0xFFFFF8E1);
  static const Color badgeUpcomingText = Color(0xFFF57F17);

  // Dark Theme Alternates
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}
