import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/flight_model.dart';
import '../../../data/repositories/flight_repository.dart';
import '../../providers/flight_providers.dart';

// ─────────────────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
              Color(0xFFBFDBFE),
              Color(0xFFF1F5F9),
              Color(0xFFF1F5F9),
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
                      const _TopBar(),
                      const SizedBox(height: 28),
                      const _SearchCard(),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const _PopularFlightsSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black.withValues(alpha:0.12),
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
}

// ─────────────────────────────────────────────────────────────────────
// SEARCH CARD — fully interactive, reads/writes searchParamsProvider
// ─────────────────────────────────────────────────────────────────────
class _SearchCard extends ConsumerStatefulWidget {
  const _SearchCard();

  @override
  ConsumerState<_SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends ConsumerState<_SearchCard> {
  bool _showErrors = false;

  // ── Airport picker ───────────────────────────────────────────────
  Future<void> _pickFromAirport() async {
    final result = await showModalBottomSheet<AirportModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AirportSheet(type: 'from'),
    );
    if (!mounted || result == null) return;
    ref.read(searchParamsProvider.notifier).state =
        ref.read(searchParamsProvider).copyWith(
          from: result.airportCode,
          fromCity: result.city,
        );
  }

  Future<void> _pickToAirport() async {
    final result = await showModalBottomSheet<AirportModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AirportSheet(type: 'to'),
    );
    if (!mounted || result == null) return;
    ref.read(searchParamsProvider.notifier).state =
        ref.read(searchParamsProvider).copyWith(
          to: result.airportCode,
          toCity: result.city,
        );
  }

  // ── Date picker ──────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final params = ref.read(searchParamsProvider);
    var initial = DateTime.now().add(const Duration(days: 1));
    if (params.date.isNotEmpty) {
      try {
        initial = DateTime.parse(params.date);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
        ),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    final formatted =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    ref.read(searchParamsProvider.notifier).state =
        ref.read(searchParamsProvider).copyWith(date: formatted);
  }

  // ── Passenger picker ─────────────────────────────────────────────
  Future<void> _pickPassengers() async {
    int count = ref.read(searchParamsProvider).passengers;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Number of Passengers',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _counterBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (count > 1) setModalState(() => count--);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      '$count',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                  _counterBtn(
                    icon: Icons.add,
                    onTap: () {
                      if (count < 9) setModalState(() => count++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(searchParamsProvider.notifier).state =
                        ref.read(searchParamsProvider).copyWith(passengers: count);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A0A0A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
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

  Widget _counterBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          color: Colors.white,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF0A0A0A)),
      ),
    );
  }

  // ── Swap airports ────────────────────────────────────────────────
  void _swapAirports() {
    final p = ref.read(searchParamsProvider);
    ref.read(searchParamsProvider.notifier).state = p.copyWith(
      from: p.to,
      fromCity: p.toCity,
      to: p.from,
      toCity: p.fromCity,
    );
  }

  // ── Date formatter ───────────────────────────────────────────────
  String _formatDate(String date) {
    if (date.isEmpty) return 'Select date';
    try {
      final d = DateTime.parse(date);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(searchParamsProvider);

    final fromDisplay = params.fromCity.isNotEmpty
        ? '${params.fromCity} (${params.from})'
        : params.from;
    final toDisplay = params.toCity.isNotEmpty
        ? '${params.toCity} (${params.to})'
        : params.to;
    final fromEmpty = params.from.isEmpty;
    final toEmpty = params.to.isEmpty;
    final dateEmpty = params.date.isEmpty;
    final passengerText =
        '${params.passengers} ${params.passengers == 1 ? 'person' : 'people'}';
    final dateText = _formatDate(params.date);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha:0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── FROM / TO ────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FROM
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _pickFromAirport,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('From'),
                              const SizedBox(height: 6),
                              Text(
                                fromEmpty ? 'Select departure airport' : fromDisplay,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: fromEmpty
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF0A0A0A),
                                ),
                              ),
                              if (_showErrors && fromEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Please select a departure airport',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFD1D5DB)),
                        const SizedBox(height: 14),
                        // TO
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _pickToAirport,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('To'),
                              const SizedBox(height: 6),
                              Text(
                                toEmpty ? 'Select arrival airport' : toDisplay,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: toEmpty
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF0A0A0A),
                                ),
                              ),
                              if (_showErrors && toEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Please select an arrival airport',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Swap button
                  GestureDetector(
                    onTap: _swapAirports,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFE5E7EB), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.06),
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: const Color(0xFFD1D5DB)),
              const SizedBox(height: 16),
              // ── DEPARTURE & AMOUNT ───────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pickDate,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Departure'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  dateText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: dateEmpty
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF0A0A0A),
                                  ),
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
                          if (_showErrors && dateEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Please select a departure date',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(height: 1, color: const Color(0xFFD1D5DB)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pickPassengers,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Travellers'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                passengerText,
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
                          const SizedBox(height: 12),
                          Container(height: 1, color: const Color(0xFFD1D5DB)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── SEARCH BUTTON ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (fromEmpty || toEmpty || dateEmpty) {
                      setState(() => _showErrors = true);
                      return;
                    }
                    context.push('/results');
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
}

// ─────────────────────────────────────────────────────────────────────
// AIRPORT SEARCH BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────
class _AirportSheet extends ConsumerStatefulWidget {
  final String type; // 'from' | 'to'
  const _AirportSheet({required this.type});

  @override
  ConsumerState<_AirportSheet> createState() => _AirportSheetState();
}

class _AirportSheetState extends ConsumerState<_AirportSheet> {
  final _controller = TextEditingController();
  List<AirportModel> _airports = [];
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetch('');
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetch(String query) async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(flightRepositoryProvider);
      final list = widget.type == 'from'
          ? await repo.getDepartureAirports(search: query)
          : await repo.getArrivalAirports(search: query);
      if (mounted) setState(() { _airports = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 400), () => _fetch(query));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.type == 'from' ? 'From where?' : 'Where to?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  autofocus: true,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search airports...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            // List
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    )
                  : _airports.isEmpty
                      ? Center(
                          child: Text(
                            'No airports found',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _airports.length,
                          itemBuilder: (_, i) {
                            final airport = _airports[i];
                            return ListTile(
                              onTap: () =>
                                  Navigator.of(context).pop(airport),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: 20,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              title: Text(
                                airport.city,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0A0A0A),
                                ),
                              ),
                              subtitle: Text(
                                airport.airportCode,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                              trailing: Text(
                                '${airport.flightCount} flights',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// POPULAR FLIGHTS SECTION
// ─────────────────────────────────────────────────────────────────────
class _PopularFlightsSection extends ConsumerWidget {
  const _PopularFlightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flightsAsync = ref.watch(popularFlightsProvider);

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
              GestureDetector(
                onTap: () => context.push('/results'),
                child: Text(
                  'See more',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        flightsAsync.when(
          loading: () => const SizedBox(
            height: 185,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            ),
          ),
          error: (_, __) => const SizedBox(height: 0),
          data: (response) {
            if (response.flights.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 185,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24, right: 8),
                itemCount: response.flights.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: _PopularFlightCard(flight: response.flights[i]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// POPULAR FLIGHT CARD — Ticket shape with live API data
// ─────────────────────────────────────────────────────────────────────
class _PopularFlightCard extends StatelessWidget {
  final FlightModel flight;
  const _PopularFlightCard({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
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
              // Airline name
              Center(
                child: Text(
                  flight.airlineName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF16A34A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              // Times row
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
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
              // Codes + duration
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
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(),
              ),
              const SizedBox(height: 14),
              // Price & stops
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRICE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '\$${flight.price.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'STOPS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        flight.stops == 0
                            ? 'Direct'
                            : '${flight.stops} stop${flight.stops > 1 ? 's' : ''}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                    ],
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
// TICKET SHAPE CLIPPER
// ─────────────────────────────────────────────────────────────────────
class _TicketShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cornerRadius = 20.0;
    const notchRadius = 10.0;
    final notchY = size.height - 60;

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
