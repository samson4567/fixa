import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/features/auth/presentation/cubit/register_initiate_cubit.dart';
import 'package:fixa/shared/widgets/app_loading_overlay.dart';
import 'package:fixa/shared/widgets/auth_field_section.dart';
import 'package:fixa/shared/widgets/auth_flow_scaffold.dart';

class PhoneSignInPage extends StatefulWidget {
  const PhoneSignInPage({super.key, this.email});

  final String? email;

  @override
  State<PhoneSignInPage> createState() => _PhoneSignInPageState();
}

class _PhoneSignInPageState extends State<PhoneSignInPage> {
  late final TextEditingController _phoneController;

  bool get _hasPhone {
    final value = _phoneController.text.trim();
    final normalized = value.startsWith('+234')
        ? value.substring(4).trim()
        : value;
    return normalized.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '+234')
      ..selection = const TextSelection.collapsed(offset: 4)
      ..addListener(_handleChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterInitiateCubit, RegisterInitiateState>(
      listener: (context, state) {
        if (state.status == RegisterInitiateStatus.loading) {
          AppLoadingOverlay.show(
            context,
            title: 'Creating your account',
            subtitle: 'Checking your details',
          );
          return;
        }

        AppLoadingOverlay.hide();
        if (state.status != RegisterInitiateStatus.success ||
            state.result == null) {
          return;
        }

        context.push(
          AppRoutes.verificationCode,
          extra: {
            'email': widget.email,
            'phone': _phoneController.text.trim(),
            'sessionToken': state.result!.sessionToken,
          },
        );
      },
      builder: (context, state) {
        final hasEmail = widget.email?.trim().isNotEmpty ?? false;
        final canSubmit = _hasPhone && hasEmail && !state.isLoading;

        return AuthFlowScaffold(
          buttonLabel: state.isLoading ? 'Loading...' : 'Continue',
          onButtonPressed: canSubmit
              ? () => context.read<RegisterInitiateCubit>().registerInitiate(
                  email: widget.email!.trim(),
                  phone: _phoneController.text.trim(),
                )
              : null,
          child: AuthFieldSection(
            title: 'Enter your phone number',
            controller: _phoneController,
            hintText: 'User number',
            keyboardType: TextInputType.phone,
            errorMessage: state.errorMessage,
            onChanged: (_) =>
                context.read<RegisterInitiateCubit>().clearError(),
          ),
        );
      },
    );
  }
}
