import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight_model.dart';
import '../services/api_service.dart';
import '../../core/exceptions/app_exception.dart';

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
    try {
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
          if (stops >= 0) 'stops': stops,
          'aircraft_type': aircraftType,
        },
      });
      return FlightSearchResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('[Repository] searchFlights parse error: $e');
      throw const ParseException();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 2. GET FLIGHT DETAILS BY ID
  // ─────────────────────────────────────────────────────────────────
  Future<FlightDetailsModel> getFlightDetails(int id) async {
    try {
      final response = await _api.post('/flight', body: {'id': id});
      final data = response.data['data'] as Map<String, dynamic>;
      return FlightDetailsModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('[Repository] getFlightDetails parse error: $e');
      throw const ParseException();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 3. GET DEPARTURE AIRPORTS
  // ─────────────────────────────────────────────────────────────────
  Future<List<AirportModel>> getDepartureAirports({
    String search = '',
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _api.post('/airports/from', body: {
        'search': search,
        'page': page,
        'limit': limit,
      });
      return (response.data['data']['airports'] as List<dynamic>? ?? [])
          .map((a) => AirportModel.fromJson(a as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('[Repository] getDepartureAirports parse error: $e');
      throw const ParseException();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 4. GET ARRIVAL AIRPORTS
  // ─────────────────────────────────────────────────────────────────
  Future<List<AirportModel>> getArrivalAirports({
    String search = '',
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _api.post('/airports/to', body: {
        'search': search,
        'page': page,
        'limit': limit,
      });
      return (response.data['data']['airports'] as List<dynamic>? ?? [])
          .map((a) => AirportModel.fromJson(a as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('[Repository] getArrivalAirports parse error: $e');
      throw const ParseException();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 5. GET AIRLINES
  // ─────────────────────────────────────────────────────────────────
  Future<List<String>> getAirlines({
    String search = '',
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _api.post('/airlines', body: {
        'search': search,
        'page': page,
        'limit': limit,
      });
      return (response.data['data']['airlines'] as List<dynamic>? ?? [])
          .map((a) => (a['airline'] ?? '').toString())
          .where((name) => name.isNotEmpty)
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('[Repository] getAirlines parse error: $e');
      throw const ParseException();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // 6. GET AIRCRAFT TYPES
  // ─────────────────────────────────────────────────────────────────
  Future<List<String>> getAircraftTypes({
    String search = '',
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _api.post('/aircraft-types', body: {
        'search': search,
        'page': page,
        'limit': limit,
      });
      return (response.data['data']['aircraft_types'] as List<dynamic>? ?? [])
          .map((a) => (a['aircraft'] ?? '').toString())
          .where((name) => name.isNotEmpty)
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      debugPrint('[Repository] getAircraftTypes parse error: $e');
      throw const ParseException();
    }
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

  factory AirportModel.fromJson(Map<String, dynamic> json) => AirportModel(
        airportCode: json['airport_code'] ?? '',
        city: json['city'] ?? '',
        flightCount: (json['flight_count'] ?? 0) as int,
      );

  String get displayName => '$city ($airportCode)';
}

final flightRepositoryProvider = Provider<FlightRepository>((ref) {
  return FlightRepository(ref.watch(apiServiceProvider));
});
