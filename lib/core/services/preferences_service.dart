import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

class PreferencesService {
  static const _keyFrom       = 'search_from';
  static const _keyFromCity   = 'search_from_city';
  static const _keyTo         = 'search_to';
  static const _keyToCity     = 'search_to_city';
  static const _keyPassengers = 'search_passengers';

  final SharedPreferences _prefs;
  PreferencesService(this._prefs);

  String get lastFrom       => _prefs.getString(_keyFrom)     ?? '';
  String get lastFromCity   => _prefs.getString(_keyFromCity) ?? '';
  String get lastTo         => _prefs.getString(_keyTo)       ?? '';
  String get lastToCity     => _prefs.getString(_keyToCity)   ?? '';
  bool   get hasPassengers  => _prefs.containsKey(_keyPassengers);
  int    get lastPassengers => _prefs.getInt(_keyPassengers)  ?? 1;

  Future<void> saveSearch({
    required String from,
    required String fromCity,
    required String to,
    required String toCity,
    required int passengers,
  }) async {
    await Future.wait([
      _prefs.setString(_keyFrom, from),
      _prefs.setString(_keyFromCity, fromCity),
      _prefs.setString(_keyTo, to),
      _prefs.setString(_keyToCity, toCity),
      _prefs.setInt(_keyPassengers, passengers),
    ]);
  }
}

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService(ref.watch(sharedPreferencesProvider));
});
