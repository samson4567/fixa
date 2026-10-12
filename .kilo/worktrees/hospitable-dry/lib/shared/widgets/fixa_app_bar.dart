import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class FixaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FixaAppBar({super.key, this.title = AppConstants.appName});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
