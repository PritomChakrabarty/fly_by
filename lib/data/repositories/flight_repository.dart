import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight_model.dart';
import '../services/api_service.dart';

class FlightRepository {
  final ApiService _api;
  FlightRepository(this._api);

  // ─────────────────────────────────────────────────────────────────
  // 1. SEARCH FLIGHTS
  // ─────────────────────────────────────────────────────────────────
  Future<FlightSearchResponse> searchFlights({
    String from = '',
    String to = '',
    String date = '',
    int passengers = 1,
    String sortBy = 'price_asc',
    String airline = '',
    double priceMin = 0,
    double priceMax = 0,
    int stops = 0,
    String aircraftType = '',
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _api.post('/search', body: {
      'from': from,
      'to': to,
      if (date.isNotEmpty) 'date': date,
      'passengers': passengers,
      'sort_by': sortBy,
      'page': page,
      'limit': limit,
      'filters': {
        'airline': airline,
        'price_min': priceMin,
        'price_max': priceMax,
        'stops': stops,
        'aircraft_type': aircraftType,
      },
    });

    return FlightSearchResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // ─────────────────────────────────────────────────────────────────
  // 2. GET FLIGHT DETAILS BY ID
  // ─────────────────────────────────────────────────────────────────
  Future<FlightDetailsModel> getFlightDetails(int id) async {
    final response = await _api.post('/flight', body: {'id': id});
    final data = response.data['data'] as Map<String, dynamic>;
    return FlightDetailsModel.fromJson(data);
  }

  // ─────────────────────────────────────────────────────────────────
  // 3. GET DEPARTURE AIRPORTS
  // ─────────────────────────────────────────────────────────────────
  Future<List<AirportModel>> getDepartureAirports({
    String search = '',
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _api.post('/airports/from', body: {
      'search': search,
      'page': page,
      'limit': limit,
    });
    final list = (response.data['data']['airports'] as List<dynamic>? ?? [])
        .map((a) => AirportModel.fromJson(a as Map<String, dynamic>))
        .toList();
    return list;
  }

  // ─────────────────────────────────────────────────────────────────
  // 4. GET ARRIVAL AIRPORTS
  // ─────────────────────────────────────────────────────────────────
  Future<List<AirportModel>> getArrivalAirports({
    String search = '',
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _api.post('/airports/to', body: {
      'search': search,
      'page': page,
      'limit': limit,
    });
    final list = (response.data['data']['airports'] as List<dynamic>? ?? [])
        .map((a) => AirportModel.fromJson(a as Map<String, dynamic>))
        .toList();
    return list;
  }

  // ─────────────────────────────────────────────────────────────────
  // 5. GET AIRLINES
  // ─────────────────────────────────────────────────────────────────
  Future<List<String>> getAirlines({
    String search = '',
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _api.post('/airlines', body: {
      'search': search,
      'page': page,
      'limit': limit,
    });
    final list = (response.data['data']['airlines'] as List<dynamic>? ?? [])
        .map((a) => (a['airline'] ?? '').toString())
        .where((name) => name.isNotEmpty)
        .toList();
    return list;
  }

  // ─────────────────────────────────────────────────────────────────
  // 6. GET AIRCRAFT TYPES
  // ─────────────────────────────────────────────────────────────────
  Future<List<String>> getAircraftTypes({
    String search = '',
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _api.post('/aircraft-types', body: {
      'search': search,
      'page': page,
      'limit': limit,
    });
    final list = (response.data['data']['aircraft_types'] as List<dynamic>? ?? [])
        .map((a) => (a['aircraft'] ?? '').toString())
        .where((name) => name.isNotEmpty)
        .toList();
    return list;
  }
}

// ─────────────────────────────────────────────────────────────────────
// AIRPORT MODEL
// ─────────────────────────────────────────────────────────────────────
class AirportModel {
  final String airportCode;
  final String city;
  final int flightCount;

  const AirportModel({
    required this.airportCode,
    required this.city,
    required this.flightCount,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) {
    return AirportModel(
      airportCode: json['airport_code'] ?? '',
      city:        json['city']         ?? '',
      flightCount: (json['flight_count'] ?? 0) as int,
    );
  }

  /// Display string like "Jakarta (CGK)"
  String get displayName => '$city ($airportCode)';
}

// ─────────────────────────────────────────────────────────────────────
// Riverpod provider for the Repository
// ─────────────────────────────────────────────────────────────────────
final flightRepositoryProvider = Provider<FlightRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return FlightRepository(api);
});