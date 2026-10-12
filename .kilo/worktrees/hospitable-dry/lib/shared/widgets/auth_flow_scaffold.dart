import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'app_asset_icon.dart';
import 'app_button.dart';

class AuthFlowScaffold extends StatelessWidget {
  const AuthFlowScaffold({
    super.key,
    this.title,
    required this.child,
    required this.buttonLabel,
    this.onButtonPressed,
    this.footerContent,
  });

  final String? title;
  final Widget child;
  final String buttonLabel;
  final VoidCallback? onButtonPressed;
  final Widget? footerContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth.clamp(
              0.0,
              AppSpacing.authHeroWidth,
            );

            return Column(
              children: [
                Center(
                  child: Container(
                    width: contentWidth,
                    height: 104,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.divider, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.authHeroHorizontalPadding,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: const Offset(0, -4),
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const AppAssetIcon(
                            assetPath: 'assets/icons/arrow-left.svg',
                            width: 24,
                            height: 24,
                          ),
                          color: AppColors.ink,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null) ...[
                              Text(
                                title!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            child,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.authHeroHorizontalPadding,
                    AppSpacing.md,
                    AppSpacing.authHeroHorizontalPadding,
                    AppSpacing.md,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (footerContent != null) ...[
                        footerContent!,
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      AppButton(
                        label: buttonLabel,
                        onPressed: onButtonPressed,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
