import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:fixa/core/di/service_locator.dart';
import 'package:fixa/core/routing/app_routes.dart';
import 'package:fixa/core/theme/app_colors.dart';
import 'package:fixa/core/theme/app_typography.dart';
import 'package:fixa/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fixa/shared/widgets/app_loading_overlay.dart';

class SubscriptionCallbackPage extends StatelessWidget {
  const SubscriptionCallbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubscriptionCubit>(
      create: (_) => getIt<SubscriptionCubit>()..confirmSubscription(),
      child: const _SubscriptionCallbackView(),
    );
  }
}

class _SubscriptionCallbackView extends StatelessWidget {
  const _SubscriptionCallbackView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        if (state.isBusy) {
          AppLoadingOverlay.show(
            context,
            title: 'Confirming your payment',
            subtitle: 'Refreshing your subscription',
          );
        } else {
          AppLoadingOverlay.hide();
        }
      },
      builder: (context, state) {
        final subscription = state.subscription;
        final isActive = subscription?.isActive == true;
        final title = isActive
            ? 'Subscription activated'
            : subscription != null
            ? 'Payment is being confirmed'
            : 'Unable to confirm subscription';
        final message = isActive
            ? 'Rental listings are now unlocked for your account.'
            : subscription != null
            ? 'Your subscription is ${subscription.status}. We will update access once payment is confirmed.'
            : state.errorMessage ??
                  'Please return shortly and check Manage Subscription.';

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isActive ? Icons.check_rounded : Icons.schedule_rounded,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.authFieldTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTypography.authBody,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () => context.go(AppRoutes.dashboard),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Return to Fixa'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
