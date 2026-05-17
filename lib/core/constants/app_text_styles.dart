import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
  static TextStyle heading2 = GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle heading3 = GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static TextStyle labelBlue = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
  static TextStyle price = GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}