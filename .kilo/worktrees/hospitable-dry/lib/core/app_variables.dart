import 'dart:async';

// import 'package:clapmi/legacy_lib/features/app/data/models/user_model.dart';
// import 'package:clapmi/legacy_lib/features/user/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> sectionNavigatorKey =
    GlobalKey<NavigatorState>();

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

StatefulNavigationShell? theStatefulNavigationShell;

final List<String> globalVideoUrls = [];
StreamController<double> progressUpdate = StreamController<double>.broadcast();
final ValueNotifier<bool> shellBottomNavVisible = ValueNotifier<bool>(true);

void clearGlobalLists() {
  globalVideoUrls.clear();
}
