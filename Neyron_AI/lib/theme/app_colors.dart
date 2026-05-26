import 'package:flutter/material.dart';

/// Neyron AI rang palitrasi — "Tea House at Night".
/// DESIGN.md ga qarang. Pure black/white va untinted greylar taqiqlangan.
class AppColors {
  // Tonal qatlamlar — xona, stol, lampa soyasi
  static const Color cosmicDeep = Color(0xFF0A1628);
  static const Color cosmicMid = Color(0xFF1A2942);
  static const Color cosmicLight = Color(0xFF2D3E5C);

  // Aksentlar
  static const Color neuronGreen = Color(0xFF00E5A0);
  static const Color plasmaYellow = Color(0xFFFFD93D);
  static const Color accentRed = Color(0xFFFF4757);
  static const Color pureWhite = Color(0xFFF7F9FC);

  // Personaj toni (Character-Tone Lock) — Professor va shogirdi Maryam
  static const Color professorWarmth = Color(0xFFE8A87C);

  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cosmicDeep, cosmicMid],
  );

  // O'yin kontentidagi ranglar (Stroop, color recognition).
  // Faqat o'yin maydonida ishlatiladi — UI chrome'da emas.
  static const Color gameRed = Color(0xFFE54B4B);
  static const Color gameBlue = Color(0xFF4B8FE5);
  static const Color gameGreen = Color(0xFF4BC97A);
  static const Color gameYellow = Color(0xFFE5C84B);
}
