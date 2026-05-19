import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/flight_model.dart';
import '../../../data/repositories/flight_repository.dart';
import '../../providers/flight_providers.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/app_painters.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          const SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
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
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OfflineBanner(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        context.w(24), context.h(16), context.w(24), 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _TopBar(),
                        SizedBox(height: context.h(22)),
                        const _SearchCard(),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(18)),
                  const _PopularFlightsSection(),
                  SizedBox(height: context.h(32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            fontSize: context.sp(28),
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        Container(
          width: context.w(48),
          height: context.w(48),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
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

class _SearchCard extends ConsumerStatefulWidget {
  const _SearchCard();

  @override
  ConsumerState<_SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends ConsumerState<_SearchCard> {
  bool _showErrors = false;

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

  Future<void> _pickPassengers() async {
    int count = ref.read(searchParamsProvider).passengers;
    final outerCtx = context;

    await showModalBottomSheet(
      context: outerCtx,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(outerCtx.r(24))),
          ),
          padding: EdgeInsets.fromLTRB(
              outerCtx.w(24), outerCtx.h(12), outerCtx.w(24), outerCtx.h(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ModalHandle(),
              SizedBox(height: outerCtx.h(20)),
              Text(
                'Number of Passengers',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: outerCtx.sp(17),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
              SizedBox(height: outerCtx.h(28)),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: outerCtx.w(36)),
                    child: Text(
                      '$count',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: outerCtx.sp(40),
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
              SizedBox(height: outerCtx.h(32)),
              SizedBox(
                width: double.infinity,
                height: outerCtx.h(52),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(searchParamsProvider.notifier).state =
                        ref.read(searchParamsProvider).copyWith(passengers: count);
                    Navigator.pop(modalCtx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A0A0A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(outerCtx.r(28)),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: outerCtx.sp(15),
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
        width: context.w(44),
        height: context.w(44),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          color: Colors.white,
        ),
        child: Icon(icon, size: context.r(20), color: const Color(0xFF0A0A0A)),
      ),
    );
  }

  void _swapAirports() {
    final p = ref.read(searchParamsProvider);
    ref.read(searchParamsProvider.notifier).state = p.copyWith(
      from: p.to,
      fromCity: p.toCity,
      to: p.from,
      toCity: p.fromCity,
    );
  }

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
      borderRadius: BorderRadius.circular(context.r(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(context.r(24)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
              context.w(20), context.h(22), context.w(20), context.h(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _pickFromAirport,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('From'),
                              SizedBox(height: context.h(10)),
                              Text(
                                fromEmpty
                                    ? 'Select departure airport'
                                    : fromDisplay,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: context.sp(17),
                                  fontWeight: FontWeight.w600,
                                  color: fromEmpty
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF0A0A0A),
                                ),
                              ),
                              if (_showErrors && fromEmpty) ...[
                                SizedBox(height: context.h(4)),
                                Text(
                                  'Please select a departure airport',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: context.sp(11),
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: context.h(14)),
                        Container(height: 1, color: const Color(0xFFD1D5DB)),
                        SizedBox(height: context.h(14)),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _pickToAirport,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('To'),
                              SizedBox(height: context.h(10)),
                              Text(
                                toEmpty
                                    ? 'Select arrival airport'
                                    : toDisplay,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: context.sp(17),
                                  fontWeight: FontWeight.w600,
                                  color: toEmpty
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF0A0A0A),
                                ),
                              ),
                              if (_showErrors && toEmpty) ...[
                                SizedBox(height: context.h(4)),
                                Text(
                                  'Please select an arrival airport',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: context.sp(11),
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
                  SizedBox(width: context.w(12)),
                  GestureDetector(
                    onTap: _swapAirports,
                    child: Container(
                      width: context.w(42),
                      height: context.w(42),
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
                      child: Icon(
                        Icons.swap_vert_rounded,
                        size: context.r(22),
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(16)),
              Container(height: 1, color: const Color(0xFFD1D5DB)),
              SizedBox(height: context.h(16)),
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
                          SizedBox(height: context.h(10)),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  dateText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: context.sp(15),
                                    fontWeight: FontWeight.w600,
                                    color: dateEmpty
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF0A0A0A),
                                  ),
                                ),
                              ),
                              SizedBox(width: context.w(10)),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: context.r(18),
                                color: const Color(0xFF9CA3AF),
                              ),
                            ],
                          ),
                          if (_showErrors && dateEmpty) ...[
                            SizedBox(height: context.h(4)),
                            Text(
                              'Please select a departure date',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: context.sp(11),
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                          SizedBox(height: context.h(15)),
                          Container(height: 1, color: const Color(0xFFD1D5DB)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(16)),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _pickPassengers,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Amount'),
                          SizedBox(height: context.h(8)),
                          Row(
                            children: [
                              Text(
                                passengerText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: context.sp(15),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0A0A0A),
                                ),
                              ),
                              SizedBox(width: context.w(4)),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: context.r(22),
                                color: const Color(0xFF374151),
                              ),
                            ],
                          ),
                          SizedBox(height: context.h(16)),
                          Container(height: 1, color: const Color(0xFFD1D5DB)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(18)),
              SizedBox(
                width: double.infinity,
                height: context.h(54),
                child: ElevatedButton(
                  onPressed: () async {
                    if (fromEmpty || toEmpty || dateEmpty) {
                      setState(() => _showErrors = true);
                      return;
                    }
                    final params = ref.read(searchParamsProvider);
                    await ref.read(preferencesServiceProvider).saveSearch(
                      from: params.from,
                      fromCity: params.fromCity,
                      to: params.to,
                      toCity: params.toCity,
                      passengers: params.passengers,
                    );
                    if (!mounted) return;
                    this.context.push('/results');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A0A0A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(32)),
                    ),
                  ),
                  child: Text(
                    'Search flights',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: context.sp(16),
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
          fontSize: context.sp(11),
          fontWeight: FontWeight.w400,
          color: const Color(0xFF9CA3AF),
          letterSpacing: 0.2,
        ),
      );
}

class _AirportSheet extends ConsumerStatefulWidget {
  final String type;
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
    _debounce = Timer(const Duration(milliseconds: 400), () => _fetch(query));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(context.r(24))),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.h(12)),
              child: const ModalHandle(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  context.w(20), 0, context.w(20), context.h(12)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.type == 'from' ? 'From where?' : 'Where to?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  context.w(20), 0, context.w(20), context.h(8)),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(context.r(12)),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  autofocus: true,
                  style: GoogleFonts.plusJakartaSans(fontSize: context.sp(14)),
                  decoration: InputDecoration(
                    hintText: 'Search airports...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF9CA3AF),
                      fontSize: context.sp(14),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.w(16),
                      vertical: context.h(14),
                    ),
                  ),
                ),
              ),
            ),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: context.w(12)),
                          itemCount: _airports.length,
                          itemBuilder: (_, i) {
                            final airport = _airports[i];
                            return ListTile(
                              onTap: () => Navigator.of(context).pop(airport),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(context.r(12)),
                              ),
                              leading: Container(
                                width: context.w(40),
                                height: context.w(40),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius:
                                      BorderRadius.circular(context.r(10)),
                                ),
                                child: Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: context.r(20),
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              title: Text(
                                airport.city,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: context.sp(15),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0A0A0A),
                                ),
                              ),
                              subtitle: Text(
                                airport.airportCode,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: context.sp(12),
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                              trailing: Text(
                                '${airport.flightCount} flights',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: context.sp(11),
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

class _PopularFlightsSection extends ConsumerWidget {
  const _PopularFlightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flightsAsync = ref.watch(popularFlightsProvider);
    final listHeight = context.h(240);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(26)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved trips',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: context.sp(18),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/results'),
                child: Text(
                  'See more',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(14)),
        flightsAsync.when(
          loading: () => SizedBox(
            height: listHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                  left: context.w(24), right: context.w(8)),
              itemCount: 3,
              itemBuilder: (_, __) => Padding(
                padding: EdgeInsets.only(right: context.w(14)),
                child: const PopularFlightSkeleton(),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (response) {
            if (response.flights.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: listHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                    left: context.w(24), right: context.w(8)),
                itemCount: response.flights.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: EdgeInsets.only(right: context.w(14)),
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

class _PopularFlightCard extends StatelessWidget {
  final FlightModel flight;
  const _PopularFlightCard({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(320),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipPath(
        clipper: AppTicketClipper(notchFromBottom: 75),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
              context.w(16), context.h(14), context.w(16), context.h(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                child: Text(
                  flight.airlineName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: context.sp(24),
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF16A34A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: context.h(6)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        flight.departureTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: flight.departureCode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A0A0A),
                              ),
                            ),
                            TextSpan(
                              text: ' (${flight.departureCity})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/flyby_plane_icon.png',
                          width: context.r(58),
                          height: context.r(58),
                          fit: BoxFit.contain,
                        ),
                        Text(
                          flight.duration,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: context.sp(12),
                            color: const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        flight.arrivalTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: flight.arrivalCode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A0A0A),
                              ),
                            ),
                            TextSpan(
                              text: ' (${flight.arrivalCity})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: context.h(33)),
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: AppDashedLinePainter(),
              ),
              SizedBox(height: context.h(14)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRICE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(10),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: context.h(3)),
                      Text(
                        '\$${flight.price.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(14),
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
                          fontSize: context.sp(10),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: context.h(3)),
                      Text(
                        flight.stops == 0
                            ? 'Direct'
                            : '${flight.stops} stop${flight.stops > 1 ? 's' : ''}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(12),
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
