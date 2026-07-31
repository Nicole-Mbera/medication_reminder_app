import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle headingLarge(
    BuildContext context, {
    double fontScale = 1.0,
  }) => TextStyle(
    fontSize: 24 * fontScale,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle headingMedium(
    BuildContext context, {
    double fontScale = 1.0,
  }) => TextStyle(
    fontSize: 20 * fontScale,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle headingSmall(
    BuildContext context, {
    double fontScale = 1.0,
  }) => TextStyle(
    fontSize: 16 * fontScale,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyLarge(BuildContext context, {double fontScale = 1.0}) =>
      TextStyle(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle bodyMedium(BuildContext context, {double fontScale = 1.0}) =>
      TextStyle(
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle bodySmall(BuildContext context, {double fontScale = 1.0}) =>
      TextStyle(
        fontSize: 12 * fontScale,
        fontWeight: FontWeight.normal,
        color: AppColors.textLight,
      );

  static TextStyle buttonText(BuildContext context, {double fontScale = 1.0}) =>
      TextStyle(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle badgeText(
    BuildContext context, {
    double fontScale = 1.0,
    Color? color,
  }) => TextStyle(
    fontSize: 12 * fontScale,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.primary,
  );
}
