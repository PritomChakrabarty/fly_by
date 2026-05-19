import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../data/models/flight_model.dart';
import '../../../data/repositories/flight_repository.dart';
import '../../providers/flight_providers.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/app_painters.dart';
import '../../widgets/common_widgets.dart';
import '../../../core/utils/responsive.dart';

const List<Map<String, String>> _sortOptions = [
  {'label': 'Lowest Price', 'sort': 'price_asc'},
  {'label': 'Highest Price', 'sort': 'price_desc'},
  {'label': 'Shortest', 'sort': 'duration_asc'},
  {'label': 'Earliest', 'sort': 'departure_asc'},
];

class FlightResultScreen extends ConsumerStatefulWidget {
  const FlightResultScreen({super.key});

  @override
  ConsumerState<FlightResultScreen> createState() => _FlightResultScreenState();
}

class _FlightResultScreenState extends ConsumerState<FlightResultScreen> {
  final _scrollController = ScrollController();

  final List<FlightModel> _allFlights = [];
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final params = ref.read(searchParamsProvider);
      final repo = ref.read(flightRepositoryProvider);
      final nextPage = _currentPage + 1;
      final response = await repo.searchFlights(
        from: params.from,
        to: params.to,
        date: params.date,
        passengers: params.passengers,
        sortBy: params.sortBy,
        airline: params.filterAirline,
        priceMin: params.filterPriceMin,
        priceMax: params.filterPriceMax,
        stops: params.filterStops,
        aircraftType: params.filterAircraftType,
        page: nextPage,
      );
      if (mounted) {
        setState(() {
          _allFlights.addAll(response.flights);
          _currentPage = nextPage;
          _hasMore = response.pagination.hasNextPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
        final msg =
            e is AppException ? e.message : 'Failed to load more flights.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            msg,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ));
      }
    }
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(searchParamsProvider);
    final flightsAsync = ref.watch(flightSearchProvider);

    ref.listen(flightSearchProvider, (_, next) {
      next.whenData((response) {
        setState(() {
          _allFlights
            ..clear()
            ..addAll(response.flights);
          _currentPage = 1;
          _hasMore = response.pagination.hasNextPage;
        });
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const OfflineBanner(),
                _buildHeader(context, params),
                const SizedBox(height: 16),
                _buildSortChips(ref, params),
                const SizedBox(height: 20),
                Expanded(
                  child: flightsAsync.when(
                    loading: () => _buildSkeletonList(),
                    error: (err, _) => _buildErrorState(err),
                    data: (page1) {
                      final display =
                          _allFlights.isNotEmpty ? _allFlights : page1.flights;
                      if (display.isEmpty) return _buildEmptyState();
                      return RefreshIndicator(
                        color: const Color(0xFF2563EB),
                        onRefresh: () async {
                          ref.invalidate(flightSearchProvider);
                          await ref.read(flightSearchProvider.future);
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: display.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == display.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF2563EB),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _FlightCard(flight: display[index]),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openFilters,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: params.hasActiveFilters
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFDBEAFE),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF2563EB).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.filter_alt_outlined,
                        size: 26,
                        color: params.hasActiveFilters
                            ? Colors.white
                            : const Color(0xFF2563EB),
                      ),
                    ),
                    if (params.activeFilterCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEF4444),
                          ),
                          child: Center(
                            child: Text(
                              '${params.activeFilterCount}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FlightSearchParams params) {
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
                'Flight result',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ),
          ),
          CircularIconButton(
            icon: Icons.more_vert_rounded,
            onTap: () {
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortChips(WidgetRef ref, FlightSearchParams params) {
    return SizedBox(
      height: 42,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(_sortOptions.length, (index) {
            final isActive = _sortOptions[index]['sort'] == params.sortBy;
            return Padding(
              padding: EdgeInsets.only(
                right: index < _sortOptions.length - 1 ? 10 : 0,
              ),
              child: GestureDetector(
                onTap: () {
                  ref.read(searchParamsProvider.notifier).state =
                      params.copyWith(sortBy: _sortOptions[index]['sort']);
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
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    _sortOptions[index]['label']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF0A0A0A),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: FlightCardSkeleton(),
      ),
    );
  }

  Widget _buildErrorState(Object err) => ErrorStateWidget(
        error: err,
        title: 'Something went wrong',
        onRetry: () => ref.invalidate(flightSearchProvider),
      );

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
              'Try different search criteria or adjust filters',
              textAlign: TextAlign.center,
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

  String _fmtDate(String date) {
    try {
      final d = DateTime.parse(date);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
    } catch (_) {
      return date;
    }
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  String _airline = '';
  double _priceMin = 0;
  double _priceMax = 0;
  int _stops = -1;
  String _aircraftType = '';

  static const double _kMaxPrice = 2000;

  @override
  void initState() {
    super.initState();
    final p = ref.read(searchParamsProvider);
    _airline = p.filterAirline;
    _priceMin = p.filterPriceMin;
    _priceMax = p.filterPriceMax == 0 ? _kMaxPrice : p.filterPriceMax;
    _stops = p.filterStops;
    _aircraftType = p.filterAircraftType;
  }

  void _apply() {
    final current = ref.read(searchParamsProvider);
    ref.read(searchParamsProvider.notifier).state = current.copyWith(
      filterAirline: _airline,
      filterPriceMin: _priceMin,
      filterPriceMax: _priceMax >= _kMaxPrice ? 0 : _priceMax,
      filterStops: _stops,
      filterAircraftType: _aircraftType,
    );
    Navigator.of(context).pop();
  }

  void _reset() {
    final current = ref.read(searchParamsProvider);
    ref.read(searchParamsProvider.notifier).state = current.copyWith(
      filterAirline: '',
      filterPriceMin: 0,
      filterPriceMax: 0,
      filterStops: -1,
      filterAircraftType: '',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final airlinesAsync = ref.watch(airlinesProvider);
    final aircraftAsync = ref.watch(aircraftTypesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const ModalHandle(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                    TextButton(
                      onPressed: _reset,
                      child: Text(
                        'Reset all',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  children: [
                    _sectionLabel('Airline'),
                    const SizedBox(height: 10),
                    airlinesAsync.when(
                      loading: () => const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Color(0xFF2563EB),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      error: (_, __) => const SizedBox(),
                      data: (airlines) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: airlines.map((a) {
                          final isActive = _airline == a;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _airline = isActive ? '' : a),
                            child: _Chip(label: a, active: isActive),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _sectionLabel('Price Range'),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_priceMin.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        Text(
                          _priceMax >= _kMaxPrice
                              ? '\$${_kMaxPrice.toInt()}+'
                              : '\$${_priceMax.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF2563EB),
                        inactiveTrackColor: const Color(0xFFDBEAFE),
                        thumbColor: const Color(0xFF2563EB),
                        overlayColor:
                            const Color(0xFF2563EB).withValues(alpha: 0.12),
                        trackHeight: 3,
                      ),
                      child: RangeSlider(
                        values: RangeValues(_priceMin, _priceMax),
                        min: 0,
                        max: _kMaxPrice,
                        divisions: 200,
                        onChanged: (v) => setState(() {
                          _priceMin = v.start;
                          _priceMax = v.end;
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _sectionLabel('Stops'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _stops = -1),
                          child: _Chip(label: 'Any', active: _stops == -1),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _stops = 0),
                          child: _Chip(label: 'Direct', active: _stops == 0),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _stops = 1),
                          child: _Chip(label: '1 Stop', active: _stops == 1),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _stops = 2),
                          child: _Chip(label: '2+ Stops', active: _stops == 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _sectionLabel('Aircraft Type'),
                    const SizedBox(height: 10),
                    aircraftAsync.when(
                      loading: () => const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Color(0xFF2563EB),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      error: (_, __) => const SizedBox(),
                      data: (types) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: types.map((t) {
                          final isActive = _aircraftType == t;
                          return GestureDetector(
                            onTap: () => setState(
                              () => _aircraftType = isActive ? '' : t,
                            ),
                            child: _Chip(label: t, active: isActive),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0A0A0A),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;

  const _Chip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFF374151),
        ),
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final FlightModel flight;
  const _FlightCard({required this.flight});

  String get _iata => flight.flightNumber.length >= 2
      ? flight.flightNumber.substring(0, 2)
      : '';

  Widget get _logoFallback => Center(
        child: Text(
          flight.airlineName.isNotEmpty
              ? flight.airlineName[0].toUpperCase()
              : 'âœˆ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF374151),
          ),
        ),
      );

  Color get _logoBg {
    final name = flight.airlineName.toLowerCase();
    if (name.contains('citilink')) return const Color(0xFFDCFCE7);
    if (name.contains('catty')) return const Color(0xFFFEE2E2);
    if (name.contains('lion')) return const Color(0xFFFEE2E2);
    if (name.contains('garuda')) return const Color(0xFFDBEAFE);
    if (name.contains('bird')) return const Color(0xFFDBEAFE);
    if (name.contains('airasia')) return const Color(0xFFFEE2E2);
    if (name.contains('japan')) return const Color(0xFFFEE2E2);
    if (name.contains('singapore')) return const Color(0xFFDBEAFE);
    if (name.contains('malaysia')) return const Color(0xFFDCFCE7);
    if (name.contains('thai')) return const Color(0xFFFEF3C7);
    if (name.contains('spicejet')) return const Color(0xFFFEE2E2);
    if (name.contains('indigo')) return const Color(0xFFDBEAFE);
    if (name.contains('air india')) return const Color(0xFFFEE2E2);
    return const Color(0xFFE5E7EB);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipPath(
        clipper: AppTicketClipper(notchFromBottom: 85),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _logoBg,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipOval(
                      child: _iata.isNotEmpty
                          ? Image.network(
                              'https://www.gstatic.com/flights/airline_logos/70px/$_iata.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : const SizedBox.shrink(),
                              errorBuilder: (_, __, ___) => _logoFallback,
                            )
                          : _logoFallback,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.airlineName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0A0A0A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (flight.flightNumber.isNotEmpty)
                          Text(
                            flight.flightNumber,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                  ),
                  StopsBadge(stops: flight.stops),
                ],
              ),
              const SizedBox(height: 10),
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
                          fontSize: 14,
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
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF),
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
                          fontSize: 14,
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
                ],
              ),
              const SizedBox(height: 25),
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: AppDashedLinePainter(),
              ),
              const SizedBox(height: 18),
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
                    onPressed: () => context.push('/details', extra: flight.id),
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
                      'View Details',
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
