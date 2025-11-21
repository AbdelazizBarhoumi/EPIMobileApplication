// ============================================================================
// APP COLORS - Color Palette Configuration
// ============================================================================
import 'package:flutter/material.dart';

/// Centralized color constants for the EPI application
/// MODIFY: Update colors to match your brand guidelines
class AppColors {
  // Primary Colors
  static final Color primary = Colors.red[900]!;
  static final Color primaryLight = Colors.red[400]!;
  static final Color primaryLighter = Colors.red[100]!;
  static final Color primaryDark = Colors.red[900]!;

  // Accent Colors
  static const Color accent = Colors.amber;
  static final Color accentDark = Colors.amber[800]!;

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static final Color grey = Colors.grey[500]!;
  static final Color greyLight = Colors.grey[350]!;
  static final Color greyDark = Colors.grey[600]!;

  // Status Colors
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;
  static const Color info = Colors.blue;

  // Background Colors
  static final Color background = Colors.grey[50]!;
  static final Color cardBackground = Colors.white;

  // Text Colors
  static final Color textPrimary = Colors.red[900]!;
  static final Color textSecondary = Colors.grey[600]!;
  static const Color textWhite = Colors.white;
}

