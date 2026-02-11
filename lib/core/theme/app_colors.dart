import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ──────────────────────────────────────────
  // Brand Colors
  // ──────────────────────────────────────────
  static const Color primary = Color(0xFF0095F6); // Instagram Blue
  static const Color secondary = Color(0xFF00376B);
  static const Color accent = Color(0xFFFF3040); // Heart / Like Red
  static const Color error = Color(0xFFED4956);

  // Instagram Gradient (for stories ring, logo, etc.)
  static const List<Color> instagramGradient = [
    Color(0xFFFBAA47), // Yellow
    Color(0xFFD91A46), // Red
    Color(0xFFA60F93), // Purple
  ];

  static const LinearGradient storyRingGradient = LinearGradient(
    colors: [
      Color(0xFFFBAA47),
      Color(0xFFD91A46),
      Color(0xFFA60F93),
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // ──────────────────────────────────────────
  // Light Theme Colors
  // ──────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightInputBackground = Color(0xFFFAFAFA);
  static const Color lightBorder = Color(0xFFDBDBDB);
  static const Color lightTextPrimary = Color(0xFF262626);
  static const Color lightTextSecondary = Color(0xFF8E8E8E);
  static const Color lightDivider = Color(0xFFEFEFEF);

  // ──────────────────────────────────────────
  // Dark Theme Colors
  // ──────────────────────────────────────────
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkInputBackground = Color(0xFF262626);
  static const Color darkBorder = Color(0xFF363636);
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFA8A8A8);
  static const Color darkDivider = Color(0xFF262626);

  // ──────────────────────────────────────────
  // Verification Badge
  // ──────────────────────────────────────────
  static const Color verified = Color(0xFF0095F6);
}
