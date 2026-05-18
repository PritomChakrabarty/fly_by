import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/flight_model.dart';
import '../../providers/flight_providers.dart';

class FlightDetailsScreen extends ConsumerWidget {
  final int? flightId;
  const FlightDetailsScreen({super.key, this.flightId});

  Color _logoBg(String airline) {
    final a = airline.toLowerCase();
    if (a.contains('citilink')) return const Color(0xFFDCFCE7);
    if (a.contains('catty'))    return const Color(0xFFFEE2E2);
    if (a.contains('lion'))     return const Color(0xFFFEE2E2);
    if (a.contains('garuda'))   return const Color(0xFFDBEAFE);
    if (a.contains('bird'))     return const Color(0xFFDBEAFE);
    if (a.contains('airasia'))  return const Color(0xFFFEE2E2);
    if (a.contains('japan'))    return const Color(0xFFFEE2E2);
    if (a.contains('singapore'))return const Color(0xFFDBEAFE);
    if (a.contains('malaysia')) return const Color(0xFFDCFCE7);
    if (a.contains('thai'))     return const Color(0xFFFEF3C7);
    return const Color(0xFFE5E7EB);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If no flightId was passed, show error
    if (flightId == null) {
      return _buildErrorScreen(context, 'Flight ID not found');
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
                // ⏳ LOADING
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2563EB),
                  ),
                ),
                // ❌ ERROR
                error: (err, _) => _buildErrorState(context, ref, err),
                // ✅ SUCCESS
                data: (details) => _buildContent(context, details),
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
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16, color: Color(0xFF0A0A0A),
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

  // ── MAIN CONTENT (when data loaded) ───────────────────────────────
  Widget _buildContent(BuildContext context, FlightDetailsModel details) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFlightInfoCard(details.flight),
                const SizedBox(height: 16),
                _buildPassengersCard(details),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: _buildDownloadButton(context),
        ),
      ],
    );
  }

  // ── FLIGHT INFO CARD ──────────────────────────────────────────────
  Widget _buildFlightInfoCard(FlightModel f) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
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
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _logoBg(f.airlineName),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipOval(
                      child: () {
                        final iata = f.flightNumber.length >= 2
                            ? f.flightNumber.substring(0, 2)
                            : '';
                        final fallback = Center(
                          child: Text(
                            f.airlineName.isNotEmpty
                                ? f.airlineName[0].toUpperCase()
                                : '✈',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        );
                        if (iata.isEmpty) return fallback;
                        return Image.network(
                          'https://www.gstatic.com/flights/airline_logos/70px/$iata.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : const SizedBox.shrink(),
                          errorBuilder: (_, __, ___) => fallback,
                        );
                      }(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      f.airlineName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A0A0A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    f.flightId ?? f.flightNumber,
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
                      'TERMINAL',
                      f.terminal ?? '-',
                      CrossAxisAlignment.start,
                    ),
                  ),
                  Expanded(
                    child: _detailColumn(
                      'GATE',
                      f.gate ?? '-',
                      CrossAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: _detailColumn(
                      'Class',
                      f.flightClass ?? '-',
                      CrossAxisAlignment.end,
                    ),
                  ),
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
  Widget _buildPassengersCard(FlightDetailsModel details) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
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
              // Build dynamic passenger rows from API
              ..._buildPassengerRows(details.passengers),
              const SizedBox(height: 18),
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(),
              ),
              const SizedBox(height: 18),
              // Render SVG barcode from API
              SizedBox(
                width: double.infinity,
                height: 70,
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
              if (details.bookingReference.isNotEmpty) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    details.bookingReference,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Generate passenger rows with dashed separators between them
  List<Widget> _buildPassengerRows(List<PassengerModel> passengers) {
    if (passengers.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'No passenger information available',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ];
    }

    final widgets = <Widget>[];
    for (int i = 0; i < passengers.length; i++) {
      widgets.add(_passengerRow(passengers[i]));
      if (i < passengers.length - 1) {
        widgets.add(const SizedBox(height: 12));
        widgets.add(CustomPaint(
          size: const Size(double.infinity, 1),
          painter: _DashedLinePainter(),
        ));
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
  }

  Widget _passengerRow(PassengerModel p) {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipOval(
            child: p.profilePicture.isNotEmpty
                ? Image.network(
                    p.profilePicture,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : Container(color: Colors.grey.shade200),
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade300),
                  )
                : Container(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PASSENGER ${p.passengerNumber}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                p.fullName,
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
              p.seat,
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

  // ── DOWNLOAD BUTTON ───────────────────────────────────────────────
  Widget _buildDownloadButton(BuildContext context) {
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

  // ── ERROR STATES ──────────────────────────────────────────────────
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load flight details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.invalidate(flightDetailsProvider(flightId!)),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
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

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Center(
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
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
// TICKET CLIPPER
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
// FALLBACK BARCODE PAINTER (if API returns empty barcode)
// ─────────────────────────────────────────────────────────────────────
class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0A0A0A);
    final pattern = [
      2.0, 1.0, 3.0, 1.0, 2.0, 1.5, 1.0, 2.5, 1.0, 3.0,
      1.5, 1.0, 2.0, 1.0, 2.5, 1.0, 3.0, 1.5, 2.0, 1.0,
      1.0, 2.0, 1.5, 3.0, 1.0, 2.5, 1.0, 1.5, 2.0, 1.0,
    ];

    double x = 0;
    int i = 0;
    while (x < size.width) {
      final barWidth = pattern[i % pattern.length];
      const gap = 1.5;

      if (i % 2 == 0) {
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