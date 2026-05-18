import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/flight_model.dart';
import '../../providers/flight_providers.dart';

// Filter chip state (local UI state)
final selectedFilterProvider = StateProvider<int>((ref) => 0);

class FlightResultScreen extends ConsumerWidget {
  const FlightResultScreen({super.key});

  // Filter chips with their corresponding API sort values
  static const List<Map<String, String>> _filters = [
    {'label': 'Lowest to Highest', 'sort': 'price_asc'},
    {'label': 'Highest to Lowest', 'sort': 'price_desc'},
    {'label': 'Shortest Duration', 'sort': 'duration_asc'},
    {'label': 'Earliest Departure', 'sort': 'departure_asc'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final flightsAsync = ref.watch(flightSearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildFilterChips(ref, selectedFilter),
                const SizedBox(height: 20),
                Expanded(
                  child: flightsAsync.when(
                    // ⏳ LOADING STATE
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    // ❌ ERROR STATE
                    error: (err, _) => _buildErrorState(context, ref, err),
                    // ✅ SUCCESS STATE
                    data: (response) {
                      if (response.flights.isEmpty) {
                        return _buildEmptyState();
                      }
                      return RefreshIndicator(
                        color: const Color(0xFF2563EB),
                        onRefresh: () async {
                          ref.invalidate(flightSearchProvider);
                          await ref.read(flightSearchProvider.future);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                          itemCount: response.flights.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _FlightCard(flight: response.flights[index]),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Floating filter FAB
            Positioned(
              bottom: 24,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Advanced filters coming soon!',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                      backgroundColor: const Color(0xFF2563EB),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDBEAFE),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.20),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.filter_alt_outlined,
                    size: 26,
                    color: Color(0xFF2563EB),
                  ),
                ),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0A0A0A)),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Flight result',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ),
          ),
          Container(
            width: 40, height: 40,
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
            child: const Icon(Icons.more_vert_rounded,
                size: 20, color: Color(0xFF0A0A0A)),
          ),
        ],
      ),
    );
  }

  // ── FILTER CHIPS ──────────────────────────────────────────────────
  Widget _buildFilterChips(WidgetRef ref, int selected) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isActive = index == selected;
          return GestureDetector(
            onTap: () {
              // Update local filter state
              ref.read(selectedFilterProvider.notifier).state = index;
              // Update API sort param — this triggers a re-fetch automatically
              final currentParams = ref.read(searchParamsProvider);
              ref.read(searchParamsProvider.notifier).state =
                  currentParams.copyWith(sortBy: _filters[index]['sort']);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF2563EB) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _filters[index]['label']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF0A0A0A),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── ERROR STATE ───────────────────────────────────────────────────
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
              'Something went wrong',
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
              onPressed: () => ref.invalidate(flightSearchProvider),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
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

  // ── EMPTY STATE ───────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flight_takeoff_rounded,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              'No flights found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different search criteria',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// FLIGHT CARD — Real API data
// ─────────────────────────────────────────────────────────────────────
class _FlightCard extends StatelessWidget {
  final FlightModel flight;
  const _FlightCard({required this.flight});

  Color get _logoBg {
    final name = flight.airlineName.toLowerCase();
    if (name.contains('citilink'))   return const Color(0xFFDCFCE7);
    if (name.contains('catty'))      return const Color(0xFFFEE2E2);
    if (name.contains('lion'))       return const Color(0xFFFEE2E2);
    if (name.contains('garuda'))     return const Color(0xFFDBEAFE);
    if (name.contains('bird'))       return const Color(0xFFDBEAFE);
    if (name.contains('airasia'))    return const Color(0xFFFEE2E2);
    if (name.contains('japan'))      return const Color(0xFFFEE2E2);
    if (name.contains('singapore'))  return const Color(0xFFDBEAFE);
    if (name.contains('malaysia'))   return const Color(0xFFDCFCE7);
    if (name.contains('thai'))       return const Color(0xFFFEF3C7);
    return const Color(0xFFE5E7EB);
  }

  @override
  Widget build(BuildContext context) {
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
        clipper: _FlightCardClipper(),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Airline header — logo + name
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _logoBg,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipOval(
                      child: flight.airlineLogo.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: flight.airlineLogo,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => const SizedBox(),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.flight,
                                size: 18,
                                color: Color(0xFF6B7280),
                              ),
                            )
                          : const Icon(Icons.flight,
                              size: 18, color: Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      flight.airlineName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A0A0A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Times row
              Row(
                children: [
                  Text(
                    flight.departureTime,
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
                    flight.arrivalTime,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // City codes + duration
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: flight.departureCode,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
                          text: flight.arrivalCode,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(),
              ),
              const SizedBox(height: 18),
              // Price + Select flight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${flight.price.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '/person',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        context.push('/details', extra: flight.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A0A0A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Select flight',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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
}

// ─────────────────────────────────────────────────────────────────────
// CLIPPERS & PAINTERS
// ─────────────────────────────────────────────────────────────────────
class _FlightCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cornerRadius = 20.0;
    const notchRadius = 10.0;
    final notchY = size.height - 85;

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