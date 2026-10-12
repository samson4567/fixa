import 'package:flutter/material.dart';

import 'package:fixa/app/fixa_app.dart';
import 'package:fixa/core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const FixaApp());
}
