import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/flight_model.dart';

class FlightDetailsScreen extends StatelessWidget {
  final FlightModel? flight;
  const FlightDetailsScreen({super.key, this.flight});

  // Fallback flight in case nothing was passed
  static const FlightModel _fallback = FlightModel(
    airline: 'Citilink Airline',
    airlineLogo: 'assets/icons/citilink_logo.webp',
    departureTime: '01:30 AM',
    arrivalTime: '01:30 AM',
    departureCode: 'CGK',
    departureCity: 'Jakarta',
    arrivalCode: 'NRT',
    arrivalCity: 'Tokyo',
    duration: '7h 15m',
    date: 'Jan 20, 2025',
    price: 321,
    flightId: 'ID3242113',
    terminal: '2A',
    gate: '19',
    flightClass: 'Economy',
    passengers: [],
  );

  // Logo bg color per airline
  Color _logoBg(String airline) {
    final a = airline.toLowerCase();
    if (a.contains('citilink')) return const Color(0xFFDCFCE7);
    if (a.contains('catty')) return const Color(0xFFFEE2E2);
    return const Color(0xFFDBEAFE);
  }

  @override
  Widget build(BuildContext context) {
    final f = flight ?? _fallback;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            // ⬇️ Scrollable cards section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFlightInfoCard(f),
                    const SizedBox(height: 16),
                    _buildPassengersCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // ⬇️ FIXED button at the bottom (outside scroll view)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _buildDownloadButton(context, f),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF0A0A0A),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Your flight details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── FLIGHT INFO CARD ──────────────────────────────────────────────
  Widget _buildFlightInfoCard(FlightModel f) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _TicketClipper(notchFromBottom: 75),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Airline logo + name + ID
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _logoBg(f.airline),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipOval(
                      child: Image.asset(
                        f.airlineLogo,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.flight, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      f.airline,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                  Text(
                    f.flightId,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Times row
              Row(
                children: [
                  Text(
                    f.departureTime,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: CustomPaint(
                            size: const Size(double.infinity, 1),
                            painter: _DashedLinePainter(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          color: Colors.white,
                          child: const Icon(
                            Icons.flight_rounded,
                            size: 18,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    f.arrivalTime,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Codes + duration
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: f.departureCode,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0A0A0A),
                          ),
                        ),
                        TextSpan(
                          text: ' (${f.departureCity})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        f.duration,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: f.arrivalCode,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0A0A0A),
                          ),
                        ),
                        TextSpan(
                          text: ' (${f.arrivalCity})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(),
              ),
              const SizedBox(height: 18),
              // Terminal | Gate | Class
              Row(
                children: [
                  Expanded(
                      child: _detailColumn(
                          'TERMINAL', f.terminal, CrossAxisAlignment.start)),
                  Expanded(
                      child: _detailColumn(
                          'GATE', f.gate, CrossAxisAlignment.center)),
                  Expanded(
                      child: _detailColumn(
                          'Class', f.flightClass, CrossAxisAlignment.end)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailColumn(String label, String value, CrossAxisAlignment align) {
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
        ),
      ],
    );
  }

  // ── PASSENGERS CARD ───────────────────────────────────────────────
  Widget _buildPassengersCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _TicketClipper(notchFromBottom: 100),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Passengers Info',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
              const SizedBox(height: 16),
              _passengerRow(
                avatarUrl: 'https://i.pravatar.cc/150?img=12',
                label: 'PASSENGER 1',
                name: 'Mr. Budiarti Rohman',
                seat: '3A',
              ),
              const SizedBox(height: 12),
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(),
              ),
              const SizedBox(height: 12),
              _passengerRow(
                avatarUrl: 'https://i.pravatar.cc/150?img=47',
                label: 'PASSENGER 2',
                name: 'Mrs. Samantha William',
                seat: '3B',
              ),
              const SizedBox(height: 18),
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: CustomPaint(
                  painter: _BarcodePainter(),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passengerRow({
    required String avatarUrl,
    required String label,
    required String name,
    required String seat,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipOval(
            child: Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey.shade300),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 2),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'SEAT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              seat,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A0A0A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context, FlightModel f) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Boarding pass saved successfully!',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A0A0A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Text(
          'Download & Save pass',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// DASHED LINE PAINTER
// ─────────────────────────────────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashGap = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────
// TICKET CLIPPER — Customizable notch position
// ─────────────────────────────────────────────────────────────────────
class _TicketClipper extends CustomClipper<Path> {
  final double notchFromBottom;
  const _TicketClipper({required this.notchFromBottom});

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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────
// BARCODE PAINTER — fills full width with varied bars
// ─────────────────────────────────────────────────────────────────────
class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0A0A0A);

    // Pattern of bar widths (will repeat to fill width)
    final pattern = [
      2.0,
      1.0,
      3.0,
      1.0,
      2.0,
      1.5,
      1.0,
      2.5,
      1.0,
      3.0,
      1.5,
      1.0,
      2.0,
      1.0,
      2.5,
      1.0,
      3.0,
      1.5,
      2.0,
      1.0,
      1.0,
      2.0,
      1.5,
      3.0,
      1.0,
      2.5,
      1.0,
      1.5,
      2.0,
      1.0
    ];

    double x = 0;
    int i = 0;
    while (x < size.width) {
      final barWidth = pattern[i % pattern.length];
      final gap = 1.5;

      // Draw bar (only every other index for alternating bar/gap)
      if (i % 2 == 0) {
        // Make sure we don't draw past the right edge
        final drawWidth =
            (x + barWidth > size.width) ? size.width - x : barWidth;
        canvas.drawRect(
          Rect.fromLTWH(x, 0, drawWidth, size.height),
          paint,
        );
      }

      x += barWidth + gap;
      i++;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
