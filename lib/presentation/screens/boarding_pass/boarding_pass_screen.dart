import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/flight_model.dart';
import '../../providers/flight_providers.dart';

class BoardingPassScreen extends ConsumerWidget {
  final int? flightId;
  const BoardingPassScreen({super.key, this.flightId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (flightId == null) {
      return _errorScaffold(context, 'Flight ID not found');
    }
    final detailsAsync = ref.watch(flightDetailsProvider(flightId!));
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: detailsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                ),
                error: (err, _) => Center(
                  child: Text(
                    err.toString(),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: const Color(0xFF6B7280)),
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (details) => _buildPass(context, details),
              ),
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
                    color: Colors.black.withValues(alpha: 0.05),
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
                'Boarding Pass',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Boarding pass saved successfully!',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: const Color(0xFF16A34A),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.download_rounded,
                size: 20,
                color: Color(0xFF0A0A0A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FULL BOARDING PASS ────────────────────────────────────────────
  Widget _buildPass(BuildContext context, FlightDetailsModel details) {
    final f = details.flight;
    final passenger =
        details.passengers.isNotEmpty ? details.passengers.first : null;
    final iata =
        f.flightNumber.length >= 2 ? f.flightNumber.substring(0, 2) : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // ── TOP SECTION ───────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Airline row + badge
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: iata.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'https://www.gstatic.com/flights/airline_logos/70px/$iata.png',
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (_, child, p) =>
                                        p == null ? child : const SizedBox.shrink(),
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        f.airlineName.isNotEmpty
                                            ? f.airlineName[0].toUpperCase()
                                            : '✈',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    f.airlineName.isNotEmpty
                                        ? f.airlineName[0].toUpperCase()
                                        : '✈',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.airlineName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0A0A0A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                f.flightNumber,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'BOARDING PASS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15803D),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Route: large airport codes + times
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Departure
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.departureCode,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0A0A0A),
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f.departureCity,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                f.departureTime,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Center: flight icon + duration
                        Column(
                          children: [
                            const Icon(
                              Icons.flight_rounded,
                              size: 28,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              f.duration,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Arrival
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                f.arrivalCode,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0A0A0A),
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f.arrivalCity,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                f.arrivalTime,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Info grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Passenger + Seat
                          Row(
                            children: [
                              Expanded(
                                child: _cell(
                                  'PASSENGER',
                                  passenger?.fullName ?? '-',
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: const Color(0xFFE2E8F0)),
                              Expanded(
                                child: _cell(
                                  'SEAT',
                                  passenger?.seat ?? '-',
                                  align: CrossAxisAlignment.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(height: 1, color: const Color(0xFFE2E8F0)),
                          const SizedBox(height: 12),
                          // Class + Terminal + Gate
                          Row(
                            children: [
                              Expanded(
                                child: _cell('CLASS', f.flightClass ?? '-'),
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: const Color(0xFFE2E8F0)),
                              Expanded(
                                child: _cell(
                                  'TERMINAL',
                                  f.terminal ?? '-',
                                  align: CrossAxisAlignment.center,
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: const Color(0xFFE2E8F0)),
                              Expanded(
                                child: _cell(
                                  'GATE',
                                  f.gate ?? '-',
                                  align: CrossAxisAlignment.end,
                                ),
                              ),
                            ],
                          ),
                          if (details.bookingDate.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                                height: 1, color: const Color(0xFFE2E8F0)),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _cell(
                                  'DATE', _formatDate(details.bookingDate)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── PERFORATED DIVIDER ────────────────────────────
              SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: const Color(0xFFF1F5F9)),
                    CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: _PerforationPainter(),
                    ),
                    // Half-circle notches on each side
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── BOTTOM STUB (barcode section) ─────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cell('BOOKING REF', details.bookingReference),
                        _cell(
                          'PASSENGERS',
                          '${details.passengers.length}',
                          align: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Barcode
                    SizedBox(
                      width: double.infinity,
                      height: 80,
                      child: details.barcode.isNotEmpty
                          ? SvgPicture.string(
                              details.barcode,
                              fit: BoxFit.contain,
                            )
                          : CustomPaint(
                              painter: _BarcodePainter(),
                              size: Size.infinite,
                            ),
                    ),
                    const SizedBox(height: 8),
                    if (details.bookingReference.isNotEmpty)
                      Text(
                        details.bookingReference,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
                          letterSpacing: 2,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(String label, String value,
      {CrossAxisAlignment align = CrossAxisAlignment.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9CA3AF),
              letterSpacing: 0.8,
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
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  Widget _errorScaffold(BuildContext context, String msg) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Center(
                child: Text(msg,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: const Color(0xFF6B7280))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// PERFORATED DIVIDER PAINTER
// ─────────────────────────────────────────────────────────────────────
class _PerforationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashGap = 4.0;
    double startX = 20;
    while (startX < size.width - 20) {
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
// FALLBACK BARCODE PAINTER
// ─────────────────────────────────────────────────────────────────────
class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0A0A0A);
    final pattern = [
      2.0, 1.0, 3.0, 1.0, 2.0, 1.5, 1.0, 2.5, 1.0, 3.0,
      1.5, 1.0, 2.0, 1.0, 2.5, 1.0, 3.0, 1.5, 2.0, 1.0,
    ];
    double x = 0;
    int i = 0;
    while (x < size.width) {
      final barWidth = pattern[i % pattern.length];
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
  bool shouldRepaint(_) => false;
}
