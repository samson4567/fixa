import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static final _connectivity = Connectivity();

  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (_) {
      return false;
    }
  }
}
