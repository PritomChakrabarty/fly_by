import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/flight_model.dart';
import '../../providers/flight_providers.dart';
import '../../widgets/app_painters.dart';
import '../../widgets/common_widgets.dart';
import '../../../core/utils/responsive.dart';

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
                'Boarding Pass',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ),
          ),
          CircularIconButton(
            icon: Icons.download_rounded,
            iconSize: 20,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Boarding pass saved successfully!',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                ),
                backgroundColor: const Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                            : 'âœˆ',
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
                                        : 'âœˆ',
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

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                        Column(
                          children: [
                            Image.asset(
                              'assets/icons/flyby_plane_icon.png',
                              width: context.r(78),
                              height: context.r(58),
                              fit: BoxFit.contain,
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

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InfoCell(
                                  'PASSENGER',
                                  passenger?.fullName ?? '-',
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: const Color(0xFFE2E8F0)),
                              Expanded(
                                child: InfoCell(
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
                          Row(
                            children: [
                              Expanded(
                                child: InfoCell('CLASS', f.flightClass ?? '-'),
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: const Color(0xFFE2E8F0)),
                              Expanded(
                                child: InfoCell(
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
                                child: InfoCell(
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
                              child: InfoCell(
                                  'DATE', _formatDate(details.bookingDate)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: const Color(0xFFF1F5F9)),
                    CustomPaint(
                      size: const Size(double.infinity, 1),
                      painter: AppDashedLinePainter(dashWidth: 6.0, dashGap: 4.0, strokeWidth: 1.5, startPadding: 20),
                    ),
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

              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InfoCell('BOOKING REF', details.bookingReference),
                        InfoCell(
                          'PASSENGERS',
                          '${details.passengers.length}',
                          align: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 80,
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

