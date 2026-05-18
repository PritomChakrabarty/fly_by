import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────
// DASHED LINE PAINTER
// Used in flight cards, boarding pass perforations, and detail separators.
// ─────────────────────────────────────────────────────────────────────
class AppDashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;
  final double startPadding;

  const AppDashedLinePainter({
    this.color = const Color(0xFFCBD5E1),
    this.dashWidth = 3.0,
    this.dashGap = 3.0,
    this.strokeWidth = 1.0,
    this.startPadding = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    double x = startPadding;
    while (x < size.width - startPadding) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashWidth, size.height / 2),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(AppDashedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashGap != dashGap ||
      oldDelegate.strokeWidth != strokeWidth;
}

// ─────────────────────────────────────────────────────────────────────
// TICKET CLIPPER
// Rounded rect with semicircular notches on both sides.
// notchFromBottom: distance of the notch centre from the card bottom.
// ─────────────────────────────────────────────────────────────────────
class AppTicketClipper extends CustomClipper<Path> {
  final double notchFromBottom;
  const AppTicketClipper({required this.notchFromBottom});

  @override
  Path getClip(Size size) {
    const cornerRadius = 20.0;
    const notchRadius = 10.0;
    final notchY = size.height - notchFromBottom;

    final path = Path();
    path.moveTo(cornerRadius, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, notchY - notchRadius);
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.lineTo(0, notchY + notchRadius);
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(AppTicketClipper oldClipper) =>
      oldClipper.notchFromBottom != notchFromBottom;
}

// ─────────────────────────────────────────────────────────────────────
// BARCODE PAINTER
// Fallback barcode drawn when the API returns no SVG barcode.
// ─────────────────────────────────────────────────────────────────────
class AppBarcodePainter extends CustomPainter {
  static const _pattern = [
    2.0, 1.0, 3.0, 1.0, 2.0, 1.5, 1.0, 2.5, 1.0, 3.0,
    1.5, 1.0, 2.0, 1.0, 2.5, 1.0, 3.0, 1.5, 2.0, 1.0,
    1.0, 2.0, 1.5, 3.0, 1.0, 2.5, 1.0, 1.5, 2.0, 1.0,
  ];

  const AppBarcodePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0A0A0A);
    double x = 0;
    int i = 0;
    while (x < size.width) {
      final barWidth = _pattern[i % _pattern.length];
      if (i % 2 == 0) {
        final drawWidth =
            (x + barWidth > size.width) ? size.width - x : barWidth;
        canvas.drawRect(Rect.fromLTWH(x, 0, drawWidth, size.height), paint);
      }
      x += barWidth + 1.5;
      i++;
    }
  }

  @override
  bool shouldRepaint(AppBarcodePainter oldDelegate) => false;
}
