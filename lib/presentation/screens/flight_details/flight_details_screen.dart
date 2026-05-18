import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/flight_model.dart';
import '../../providers/flight_providers.dart';
import '../../widgets/app_painters.dart';
import '../../widgets/common_widgets.dart';

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
          CircularIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => context.pop(),
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
        clipper: AppTicketClipper(notchFromBottom: 75),
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
                            painter: AppDashedLinePainter(),
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
                painter: AppDashedLinePainter(),
              ),
              const SizedBox(height: 18),
              // Terminal | Gate | Class
              Row(
                children: [
                  Expanded(child: InfoCell('TERMINAL', f.terminal ?? '-')),
                  Expanded(
                    child: InfoCell(
                      'GATE',
                      f.gate ?? '-',
                      align: CrossAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: InfoCell(
                      'CLASS',
                      f.flightClass ?? '-',
                      align: CrossAxisAlignment.end,
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
        clipper: AppTicketClipper(notchFromBottom: 100),
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
                painter: AppDashedLinePainter(),
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
                        painter: AppBarcodePainter(),
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
          painter: AppDashedLinePainter(),
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
        onPressed: () => context.push('/boarding-pass', extra: flightId),
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
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object err) =>
      ErrorStateWidget(
        error: err,
        title: 'Could not load flight details',
        onRetry: () => ref.invalidate(flightDetailsProvider(flightId!)),
      );

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

