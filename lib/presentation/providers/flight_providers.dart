import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/flight_model.dart';
import '../../data/repositories/flight_repository.dart';

// ─────────────────────────────────────────────────────────────────────
// SEARCH PARAMETERS — Holds the search inputs from Home screen
// ─────────────────────────────────────────────────────────────────────
class FlightSearchParams {
  final String from;
  final String fromCity;
  final String to;
  final String toCity;
  final int passengers;
  final String sortBy;
  final String date; // YYYY-MM-DD, empty = no date filter

  const FlightSearchParams({
    this.from = 'CGK',
    this.fromCity = 'Jakarta',
    this.to = 'NRT',
    this.toCity = 'Tokyo',
    this.passengers = 1,
    this.sortBy = 'price_asc',
    this.date = '',
  });

  FlightSearchParams copyWith({
    String? from,
    String? fromCity,
    String? to,
    String? toCity,
    int? passengers,
    String? sortBy,
    String? date,
  }) {
    return FlightSearchParams(
      from: from ?? this.from,
      fromCity: fromCity ?? this.fromCity,
      to: to ?? this.to,
      toCity: toCity ?? this.toCity,
      passengers: passengers ?? this.passengers,
      sortBy: sortBy ?? this.sortBy,
      date: date ?? this.date,
    );
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
          date == other.date;

  @override
  int get hashCode =>
      from.hashCode ^
      fromCity.hashCode ^
      to.hashCode ^
      toCity.hashCode ^
      passengers.hashCode ^
      sortBy.hashCode ^
      date.hashCode;
}

// ─────────────────────────────────────────────────────────────────────
// 1. SEARCH PARAMS STATE — Updated by Home screen, watched by Results
// ─────────────────────────────────────────────────────────────────────
final searchParamsProvider = StateProvider<FlightSearchParams>(
  (ref) => const FlightSearchParams(),
);

// ─────────────────────────────────────────────────────────────────────
// 2. FLIGHT SEARCH RESULTS — Fetches flights based on search params
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
  );
});

// ─────────────────────────────────────────────────────────────────────
// 3. POPULAR FLIGHTS — Cached home-screen flights (CGK → NRT default)
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
// 4. FLIGHT DETAILS — Fetches detailed flight info by ID
// ─────────────────────────────────────────────────────────────────────
final flightDetailsProvider =
    FutureProvider.autoDispose.family<FlightDetailsModel, int>(
  (ref, flightId) async {
    final repo = ref.watch(flightRepositoryProvider);
    return repo.getFlightDetails(flightId);
  },
);

// ─────────────────────────────────────────────────────────────────────
// 5. AIRPORTS — Cached on first fetch, reused across screens
// ─────────────────────────────────────────────────────────────────────
final departureAirportsProvider =
    FutureProvider<List<AirportModel>>((ref) async {
  final repo = ref.watch(flightRepositoryProvider);
  return repo.getDepartureAirports();
});

final arrivalAirportsProvider =
    FutureProvider<List<AirportModel>>((ref) async {
  final repo = ref.watch(flightRepositoryProvider);
  return repo.getArrivalAirports();
});

// ─────────────────────────────────────────────────────────────────────
// 6. AIRLINES & AIRCRAFT — For filter dropdowns
// ─────────────────────────────────────────────────────────────────────
final airlinesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(flightRepositoryProvider);
  return repo.getAirlines();
});

final aircraftTypesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(flightRepositoryProvider);
  return repo.getAircraftTypes();
});
