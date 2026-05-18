import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/flight_model.dart';
import '../../data/repositories/flight_repository.dart';
import '../../core/services/preferences_service.dart';

// ─────────────────────────────────────────────────────────────────────
// SEARCH PARAMETERS
// ─────────────────────────────────────────────────────────────────────
class FlightSearchParams {
  final String from;
  final String fromCity;
  final String to;
  final String toCity;
  final int passengers;
  final String sortBy;
  final String date;

  // Advanced filters
  final String filterAirline;
  final double filterPriceMin;
  final double filterPriceMax;
  final int filterStops;        // -1 = any, 0 = direct, 1+ = stops
  final String filterAircraftType;

  const FlightSearchParams({
    this.from = '',
    this.fromCity = '',
    this.to = '',
    this.toCity = '',
    this.passengers = 1,
    this.sortBy = 'price_asc',
    this.date = '',
    this.filterAirline = '',
    this.filterPriceMin = 0,
    this.filterPriceMax = 0,
    this.filterStops = -1,
    this.filterAircraftType = '',
  });

  FlightSearchParams copyWith({
    String? from,
    String? fromCity,
    String? to,
    String? toCity,
    int? passengers,
    String? sortBy,
    String? date,
    String? filterAirline,
    double? filterPriceMin,
    double? filterPriceMax,
    int? filterStops,
    String? filterAircraftType,
  }) {
    return FlightSearchParams(
      from: from ?? this.from,
      fromCity: fromCity ?? this.fromCity,
      to: to ?? this.to,
      toCity: toCity ?? this.toCity,
      passengers: passengers ?? this.passengers,
      sortBy: sortBy ?? this.sortBy,
      date: date ?? this.date,
      filterAirline: filterAirline ?? this.filterAirline,
      filterPriceMin: filterPriceMin ?? this.filterPriceMin,
      filterPriceMax: filterPriceMax ?? this.filterPriceMax,
      filterStops: filterStops ?? this.filterStops,
      filterAircraftType: filterAircraftType ?? this.filterAircraftType,
    );
  }

  bool get hasActiveFilters =>
      filterAirline.isNotEmpty ||
      filterPriceMin > 0 ||
      filterPriceMax > 0 ||
      filterStops >= 0 ||
      filterAircraftType.isNotEmpty;

  int get activeFilterCount {
    int count = 0;
    if (filterAirline.isNotEmpty) count++;
    if (filterPriceMin > 0 || filterPriceMax > 0) count++;
    if (filterStops >= 0) count++;
    if (filterAircraftType.isNotEmpty) count++;
    return count;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlightSearchParams &&
          from == other.from &&
          fromCity == other.fromCity &&
          to == other.to &&
          toCity == other.toCity &&
          passengers == other.passengers &&
          sortBy == other.sortBy &&
          date == other.date &&
          filterAirline == other.filterAirline &&
          filterPriceMin == other.filterPriceMin &&
          filterPriceMax == other.filterPriceMax &&
          filterStops == other.filterStops &&
          filterAircraftType == other.filterAircraftType;

  @override
  int get hashCode =>
      from.hashCode ^
      fromCity.hashCode ^
      to.hashCode ^
      toCity.hashCode ^
      passengers.hashCode ^
      sortBy.hashCode ^
      date.hashCode ^
      filterAirline.hashCode ^
      filterPriceMin.hashCode ^
      filterPriceMax.hashCode ^
      filterStops.hashCode ^
      filterAircraftType.hashCode;
}

// ─────────────────────────────────────────────────────────────────────
// 1. SEARCH PARAMS — initialised from saved preferences
// ─────────────────────────────────────────────────────────────────────
final searchParamsProvider = StateProvider<FlightSearchParams>((ref) {
  final p = ref.watch(preferencesServiceProvider);
  return FlightSearchParams(
    from: p.lastFrom,
    fromCity: p.lastFromCity,
    to: p.lastTo,
    toCity: p.lastToCity,
    passengers: p.lastPassengers,
  );
});

// ─────────────────────────────────────────────────────────────────────
// 2. FLIGHT SEARCH RESULTS — page 1, driven by search params
// ─────────────────────────────────────────────────────────────────────
final flightSearchProvider =
    FutureProvider.autoDispose<FlightSearchResponse>((ref) async {
  final params = ref.watch(searchParamsProvider);
  final repo = ref.watch(flightRepositoryProvider);
  return repo.searchFlights(
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
    page: 1,
  );
});

// ─────────────────────────────────────────────────────────────────────
// 3. POPULAR FLIGHTS — cached home-screen showcase (CGK → NRT)
// ─────────────────────────────────────────────────────────────────────
final popularFlightsProvider =
    FutureProvider<FlightSearchResponse>((ref) async {
  final repo = ref.watch(flightRepositoryProvider);
  return repo.searchFlights(
    from: 'CGK',
    to: 'NRT',
    passengers: 1,
    sortBy: 'price_asc',
    limit: 5,
  );
});

// ─────────────────────────────────────────────────────────────────────
// 4. FLIGHT DETAILS
// ─────────────────────────────────────────────────────────────────────
final flightDetailsProvider =
    FutureProvider.autoDispose.family<FlightDetailsModel, int>(
  (ref, flightId) async {
    final repo = ref.watch(flightRepositoryProvider);
    return repo.getFlightDetails(flightId);
  },
);

// ─────────────────────────────────────────────────────────────────────
// 5. AIRPORTS
// ─────────────────────────────────────────────────────────────────────
final departureAirportsProvider =
    FutureProvider<List<AirportModel>>((ref) async {
  return ref.watch(flightRepositoryProvider).getDepartureAirports();
});

final arrivalAirportsProvider =
    FutureProvider<List<AirportModel>>((ref) async {
  return ref.watch(flightRepositoryProvider).getArrivalAirports();
});

// ─────────────────────────────────────────────────────────────────────
// 6. AIRLINES & AIRCRAFT — for filter dropdowns
// ─────────────────────────────────────────────────────────────────────
final airlinesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(flightRepositoryProvider).getAirlines();
});

final aircraftTypesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(flightRepositoryProvider).getAircraftTypes();
});
