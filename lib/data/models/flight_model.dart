// ─────────────────────────────────────────────────────────────────────
// FLIGHT MODEL — Parses API response
// ─────────────────────────────────────────────────────────────────────
class FlightModel {
  final int id;
  final String airlineName;
  final String airlineLogo;
  final String flightNumber;
  final String departureTime;
  final String departureCode;
  final String departureCity;
  final String arrivalTime;
  final String arrivalCode;
  final String arrivalCity;
  final String duration;
  final double price;
  final String currency;
  final String aircraftType;
  final int stops;

  // Optional fields (only present in flight details)
  final String? flightId;
  final String? terminal;
  final String? gate;
  final String? flightClass;

  const FlightModel({
    required this.id,
    required this.airlineName,
    required this.airlineLogo,
    required this.flightNumber,
    required this.departureTime,
    required this.departureCode,
    required this.departureCity,
    required this.arrivalTime,
    required this.arrivalCode,
    required this.arrivalCity,
    required this.duration,
    required this.price,
    required this.currency,
    required this.aircraftType,
    required this.stops,
    this.flightId,
    this.terminal,
    this.gate,
    this.flightClass,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    final dep   = json['departure'] as Map<String, dynamic>? ?? {};
    final arr   = json['arrival']   as Map<String, dynamic>? ?? {};
    final price = json['price']     as Map<String, dynamic>? ?? {};

    return FlightModel(
      id:             (json['id'] ?? 0) as int,
      airlineName:    json['airline_name']  ?? '',
      airlineLogo:    json['airline_logo']  ?? '',
      flightNumber:   json['flight_number'] ?? '',
      departureTime:  _formatTime(dep['time'] ?? ''),
      departureCode:  dep['airport_code']   ?? '',
      departureCity:  dep['city']           ?? '',
      arrivalTime:    _formatTime(arr['time'] ?? ''),
      arrivalCode:    arr['airport_code']   ?? '',
      arrivalCity:    arr['city']           ?? '',
      duration:       json['duration']      ?? '',
      price:          (price['amount']   ?? 0).toDouble(),
      currency:       price['currency']  ?? 'USD',
      aircraftType:   json['aircraft_type'] ?? '',
      stops:          (json['stops'] ?? 0) as int,
      flightId:       json['flight_id'],
      terminal:       json['terminal'],
      gate:           json['gate'],
      flightClass:    json['class'],
    );
  }

  // API returns "09:15:00" — convert to "09:15"
  static String _formatTime(String time) {
    if (time.isEmpty) return '';
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }
}

// ─────────────────────────────────────────────────────────────────────
// PASSENGER MODEL
// ─────────────────────────────────────────────────────────────────────
class PassengerModel {
  final int passengerNumber;
  final String title;
  final String name;
  final String seat;
  final String profilePicture;

  const PassengerModel({
    required this.passengerNumber,
    required this.title,
    required this.name,
    required this.seat,
    required this.profilePicture,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      passengerNumber: (json['passenger_number'] ?? 0) as int,
      title:           json['title']           ?? '',
      name:            json['name']            ?? '',
      seat:            json['seat']            ?? '',
      profilePicture:  json['profile_picture'] ?? '',
    );
  }

  String get fullName => title.isEmpty ? name : '$title $name';
}

// ─────────────────────────────────────────────────────────────────────
// FLIGHT DETAILS MODEL — Flight + Passengers + Booking Info
// ─────────────────────────────────────────────────────────────────────
class FlightDetailsModel {
  final FlightModel flight;
  final List<PassengerModel> passengers;
  final String bookingReference;
  final String bookingDate;
  final String barcode; // SVG string

  const FlightDetailsModel({
    required this.flight,
    required this.passengers,
    required this.bookingReference,
    required this.bookingDate,
    required this.barcode,
  });

  factory FlightDetailsModel.fromJson(Map<String, dynamic> json) {
    final flightDetails = json['flight_details'] as Map<String, dynamic>? ?? {};
    final passengersList = (json['passengers'] as List<dynamic>? ?? [])
        .map((p) => PassengerModel.fromJson(p as Map<String, dynamic>))
        .toList();
    final bookingInfo = json['booking_info'] as Map<String, dynamic>? ?? {};

    return FlightDetailsModel(
      flight:           FlightModel.fromJson(flightDetails),
      passengers:       passengersList,
      bookingReference: bookingInfo['booking_reference'] ?? '',
      bookingDate:      bookingInfo['booking_date']      ?? '',
      barcode:          bookingInfo['barcode']           ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// PAGINATION MODEL
// ─────────────────────────────────────────────────────────────────────
class PaginationModel {
  final int total;
  final int totalPages;
  final int currentPage;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationModel({
    required this.total,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total:        (json['total']        ?? 0) as int,
      totalPages:   (json['totalPages']   ?? 0) as int,
      currentPage:  (json['currentPage']  ?? 1) as int,
      limit:        (json['limit']        ?? 10) as int,
      hasNextPage:   json['hasNextPage']  ?? false,
      hasPrevPage:   json['hasPrevPage']  ?? false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// SEARCH RESPONSE — Flights list + pagination
// ─────────────────────────────────────────────────────────────────────
class FlightSearchResponse {
  final List<FlightModel> flights;
  final PaginationModel pagination;

  const FlightSearchResponse({
    required this.flights,
    required this.pagination,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final flightsList = (data['flights'] as List<dynamic>? ?? [])
        .map((f) => FlightModel.fromJson(f as Map<String, dynamic>))
        .toList();

    return FlightSearchResponse(
      flights:    flightsList,
      pagination: PaginationModel.fromJson(
        data['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}