class FlightModel {
  final String airline;
  final String airlineLogo;
  final String departureTime;
  final String arrivalTime;
  final String departureCode;
  final String departureCity;
  final String arrivalCode;
  final String arrivalCity;
  final String duration;
  final String date;
  final double price;
  final String flightId;
  final String terminal;
  final String gate;
  final String flightClass;
  final List<PassengerModel> passengers;

  const FlightModel({
    required this.airline,
    required this.airlineLogo,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureCode,
    required this.departureCity,
    required this.arrivalCode,
    required this.arrivalCity,
    required this.duration,
    required this.date,
    required this.price,
    required this.flightId,
    required this.terminal,
    required this.gate,
    required this.flightClass,
    required this.passengers,
  });
}

class PassengerModel {
  final String name;
  final String seat;
  final String avatarUrl;

  const PassengerModel({
    required this.name,
    required this.seat,
    required this.avatarUrl,
  });
}