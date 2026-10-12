import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixa/core/app_state/app_state_cubit.dart';
import 'package:fixa/core/di/service_locator.dart';
import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/core/theme/app_theme.dart';

class FixaApp extends StatelessWidget {
  const FixaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppStateCubit>.value(
      value: getIt<AppStateCubit>(),
      child: MaterialApp.router(
        title: 'AMASS',
        debugShowCheckedModeBanner: false,
        theme: customAppTheme.lightTheme(context),
        darkTheme: customAppTheme.darkTheme(context),
        themeMode: ThemeMode.light,
        routerConfig: AppRoutes.router(),
      ),
    );
  }
}
