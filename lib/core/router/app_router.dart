import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/flight_model.dart';
import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/flight_result/flight_result_screen.dart';
import '../../presentation/screens/flight_details/flight_details_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, state) => const MainShell(),
      ),
      GoRoute(
        path: '/results',
        builder: (ctx, state) => const FlightResultScreen(),
      ),
      GoRoute(
        path: '/details',
        builder: (ctx, state) {
          final flightId = state.extra as int?;
          return FlightDetailsScreen(flightId: flightId);
        },
      ),
    ],
  );
});
