import 'package:get_it/get_it.dart';

import 'service_locator.dart';

final getItInstance = GetIt.I;

class Injector {
  Future<void> init() async {
    await setupServiceLocator();
  }
}

final injector = Injector();
