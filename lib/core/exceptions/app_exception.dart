abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(
      [super.message = 'Connection failed. Please check your internet.']);
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException() : super('Request timed out. Please try again.');
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class OfflineException extends AppException {
  const OfflineException()
      : super('You are offline. Please check your internet connection.');
}

class ParseException extends AppException {
  const ParseException(
      [super.message = 'Failed to process the server response.']);
}
