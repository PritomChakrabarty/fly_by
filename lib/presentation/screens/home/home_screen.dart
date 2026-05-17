import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/flight_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<FlightModel> _savedTrips = const [
    FlightModel(
      airline: 'Citilink',
      airlineLogo: '',
      departureTime: '07:47',
      arrivalTime: '14:30',
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
    ),
    FlightModel(
      airline: 'Citilink',
      airlineLogo: '',
      departureTime: '07:47',
      arrivalTime: '14:30',
      departureCode: 'CGK',
      departureCity: 'Jakarta',
      arrivalCode: 'NRT',
      arrivalCity: 'Tokyo',
      duration: '7h 15m',
      date: 'Jan 20, 2025',
      price: 321,
      flightId: 'ID3242114',
      terminal: '2A',
      gate: '19',
      flightClass: 'Economy',
      passengers: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Full screen gradient — blue at top → light at bottom
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B82F6), // strong blue at top
              Color(0xFF60A5FA), // mid blue
              Color(0xFFBFDBFE), // light blue
              Color(0xFFF1F5F9), // off-white
              Color(0xFFF1F5F9), // off-white continues
            ],
            stops: [0.0, 0.15, 0.30, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 28),
                      _buildSearchCard(context),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildSavedTrips(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Plan your trip',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              'https://i.pravatar.cc/150?img=47',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white24,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── SEARCH CARD ───────────────────────────────────────────────────
  Widget _buildSearchCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FROM / TO with swap button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('From'),
                        const SizedBox(height: 6),
                        Text(
                          'Jakarta (CGK)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0A0A0A),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFEEF0F3)),
                        const SizedBox(height: 14),
                        _label('To'),
                        const SizedBox(height: 6),
                        Text(
                          'Tokyo (NRT)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0A0A0A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFFE5E7EB), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      size: 22,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: const Color(0xFFEEF0F3)),
              const SizedBox(height: 16),
              // Departure & Amount
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Departure'),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Tue, 2 Apr',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A0A0A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Amount'),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '3 people',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A0A0A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 22,
                              color: Color(0xFF374151),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              // Search button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.push('/results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A0A0A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    'Search flights',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9CA3AF),
          letterSpacing: 0.2,
        ),
      );

  // ── SAVED TRIPS ───────────────────────────────────────────────────
  Widget _buildSavedTrips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved trips',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
              Text(
                'See more',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24, right: 8),
            itemCount: _savedTrips.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _SavedTripCard(flight: _savedTrips[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// SAVED TRIP CARD — Citilink centered, plane icon with dashed line
// ─────────────────────────────────────────────────────────────────────
class _SavedTripCard extends StatelessWidget {
  final FlightModel flight;
  const _SavedTripCard({required this.flight});

  @override
Widget build(BuildContext context) {
  return Container(
    width: 320,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipPath(
      clipper: _TicketShapeClipper(),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered Citilink
            Center(
              child: Text(
                flight.airline,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Times row with plane icon and dashed line
            Row(
              children: [
                Text(
                  flight.departureTime,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: CustomPaint(
                          size: const Size(double.infinity, 1),
                          painter: _DashedLinePainter(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        color: Colors.white,
                        child: const Icon(
                          Icons.flight_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  flight.arrivalTime,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // City codes + duration
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: flight.departureCode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                      TextSpan(
                        text: ' (${flight.departureCity})',
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
                      flight.duration,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: flight.arrivalCode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                      TextSpan(
                        text: ' (${flight.arrivalCity})',
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
            // Straight dashed divider line
            CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashedLinePainter(),
            ),
            const SizedBox(height: 14),

            // Date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateCol(flight.date),
                _dateCol(flight.date),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _dateCol(String date) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'DATE',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9CA3AF),
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        date,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0A0A0A),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────
// TICKET SHAPE CLIPPER — Creates semicircle cutouts on both sides
// ─────────────────────────────────────────────────────────────────────
class _TicketShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cornerRadius = 20.0;
    const notchRadius = 10.0;
    // Y position of the notches — aligns with the dashed divider line
    // Card has top content (~110px) + dashed line area, then date section
    final notchY = size.height - 70;

    final path = Path();

    // Start: top-left after corner
    path.moveTo(cornerRadius, 0);
    // Top edge
    path.lineTo(size.width - cornerRadius, 0);
    // Top-right corner
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    // Right edge down to notch
    path.lineTo(size.width, notchY - notchRadius);
    // Right notch (semicircle cutout going INTO the card)
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    // Continue right edge down
    path.lineTo(size.width, size.height - cornerRadius);
    // Bottom-right corner
    path.quadraticBezierTo(
        size.width, size.height, size.width - cornerRadius, size.height);
    // Bottom edge
    path.lineTo(cornerRadius, size.height);
    // Bottom-left corner
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    // Left edge up to notch
    path.lineTo(0, notchY + notchRadius);
    // Left notch (semicircle cutout going INTO the card)
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    // Continue left edge up
    path.lineTo(0, cornerRadius);
    // Top-left corner
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────
// DASHED LINE PAINTER for the flight route
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
