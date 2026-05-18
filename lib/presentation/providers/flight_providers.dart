import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/flight_model.dart';
import '../../data/repositories/flight_repository.dart';

// ─────────────────────────────────────────────────────────────────────
// SEARCH PARAMETERS — Holds the search inputs from Home screen
// ─────────────────────────────────────────────────────────────────────
class FlightSearchParams {
  final String from;
  final String to;
  final int passengers;
  final String sortBy;

  const FlightSearchParams({
    this.from = 'CGK',
    this.to = 'NRT',
    this.passengers = 1,
    this.sortBy = 'price_asc',
  });

  FlightSearchParams copyWith({
    String? from,
    String? to,
    int? passengers,
    String? sortBy,
  }) {
    return FlightSearchParams(
      from: from ?? this.from,
      to: to ?? this.to,
      passengers: passengers ?? this.passengers,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  // Required for FutureProvider.family caching to work properly
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlightSearchParams &&
          from == other.from &&
          to == other.to &&
          passengers == other.passengers &&
          sortBy == other.sortBy;

  @override
  int get hashCode =>
      from.hashCode ^ to.hashCode ^ passengers.hashCode ^ sortBy.hashCode;
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
    passengers: params.passengers,
    sortBy: params.sortBy,
  );
});

// ─────────────────────────────────────────────────────────────────────
// 3. FLIGHT DETAILS — Fetches detailed flight info by ID
// ─────────────────────────────────────────────────────────────────────
final flightDetailsProvider =
    FutureProvider.autoDispose.family<FlightDetailsModel, int>(
  (ref, flightId) async {
    final repo = ref.watch(flightRepositoryProvider);
    return repo.getFlightDetails(flightId);
  },
);

// ─────────────────────────────────────────────────────────────────────
// 4. AIRPORTS — Cached on first fetch, reused across screens
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
// 5. AIRLINES & AIRCRAFT — For filter dropdowns
// ─────────────────────────────────────────────────────────────────────
final airlinesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(flightRepositoryProvider);
  return repo.getAirlines();
});

final aircraftTypesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(flightRepositoryProvider);
  return repo.getAircraftTypes();
});