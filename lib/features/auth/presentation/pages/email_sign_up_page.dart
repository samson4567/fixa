import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/shared/widgets/auth_field_section.dart';
import 'package:fixa/shared/widgets/auth_flow_scaffold.dart';

class EmailSignUpPage extends StatefulWidget {
  const EmailSignUpPage({super.key});

  @override
  State<EmailSignUpPage> createState() => _EmailSignUpPageState();
}

class _EmailSignUpPageState extends State<EmailSignUpPage> {
  late final TextEditingController _emailController;

  bool get _hasEmail => _emailController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController()..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowScaffold(
      buttonLabel: 'Continue',
      onButtonPressed: _hasEmail
          ? () => context.push(
              Uri(
                path: AppRoutes.phoneSignIn,
                queryParameters: {'email': _emailController.text.trim()},
              ).toString(),
            )
          : null,
      child: AuthFieldSection(
        title: 'Sign up with Email',
        controller: _emailController,
        hintText: 'Enter Email',
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}
