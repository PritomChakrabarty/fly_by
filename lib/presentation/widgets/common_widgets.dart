import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/exceptions/app_exception.dart';

class ModalHandle extends StatelessWidget {
  const ModalHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.iconSize = 16,
    this.iconColor = const Color(0xFF0A0A0A),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}

class InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment align;

  const InfoCell(
    this.label,
    this.value, {
    super.key,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0A0A0A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final Object error;
  final String title;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.error,
    required this.title,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isOffline = error is OfflineException;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 64,
              color: isOffline
                  ? const Color(0xFFF97316)
                  : const Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              isOffline ? 'No Internet Connection' : title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StopsBadge extends StatelessWidget {
  final int stops;
  const StopsBadge({super.key, required this.stops});

  @override
  Widget build(BuildContext context) {
    final isDirect = stops == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDirect
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isDirect ? 'Direct' : '$stops ${stops == 1 ? 'stop' : 'stops'}',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDirect
              ? const Color(0xFF15803D)
              : const Color(0xFF92400E),
        ),
      ),
    );
  }
}
