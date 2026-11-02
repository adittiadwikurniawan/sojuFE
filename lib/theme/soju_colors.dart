import 'package:flutter/material.dart';

/// Design tokens hasil ekstrak dari file Figma "UI/UX Soju".
/// Onboarding screens menggunakan style: putih, aksen biru #1969FF,
/// teks #191C1E / #424655, chips abu-abu, aksen hijau & amber.
class SojuColors {
  SojuColors._();

  // Brand blue
  static const Color primary = Color(0xFF1969FF);
  static const Color primaryDark = Color(0xFF0051D2);
  static const Color primaryLight = Color(0xFFDBE1FF); // pill "Didukung AI"
  static const Color primarySoft = Color(0xFFDCE1FF);
  static const Color primaryBlueGradientEnd = Color(0xFF0054D8);
  static const Color purpleSoft = Color(0xFF8FA7FE);

  // Ink / text
  static const Color ink = Color(0xFF191C1E);
  static const Color inkSoft = Color(0xFF424655);
  static const Color inkOnBluePill = Color(0xFF00184A);

  // Green (success / cash-flow)
  static const Color green = Color(0xFF00855C);
  static const Color greenDark = Color(0xFF006948);
  static const Color greenLight = Color(0xFF85F8C4);
  static const Color greenOnLight = Color(0xFF002114);

  // Amber / warning
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberCircle = Color(0xFFFBBF24);
  static const Color amberSoft = Color(0xFFFEF3C7);
  static const Color amberDark = Color(0xFFB45309);
  static const Color amberBrown = Color(0xFF92400E);
  static const Color orangeLine = Color(0xFFFF7900);

  // Neutral chips / backgrounds
  static const Color chip = Color(0xFFECEEF0);
  static const Color chipSoft = Color(0xFFF2F4F6);
  static const Color border = Color(0xFFE6E8EA);
  static const Color dotInactive = Color(0xFFC2C6D8);
  static const Color glass = Color(0xFFE0E3E5);

  // Rose (danger-ish / soft highlight)
  static const Color roseSoft = Color(0xFFFFDAD6);
  static const Color roseDark = Color(0xFF93000A);

  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color gradientTop = Color(0xFFDBE1FF);
  static const Color gradientBottom = Color(0xFFDCE1FF);
  static const Color gradientGreen = Color(0xFF85F8C4);
  static const Color gradientPurple = Color(0xFF8FA7FE);
}

/// Gradien kartu ilustrasi agar mirip Figma (LinearGradient antar aksen).
LinearGradient sojuCardGradient() {
  return const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCDD8FF),
      Color(0xFFEAF0FF),
      Color(0xFFD9FFEC),
    ],
  );
}