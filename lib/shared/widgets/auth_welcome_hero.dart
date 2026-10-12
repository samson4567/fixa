import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class AuthWelcomeHero extends StatefulWidget {
  const AuthWelcomeHero({super.key});

  @override
  State<AuthWelcomeHero> createState() => _AuthWelcomeHeroState();
}

class _AuthWelcomeHeroState extends State<AuthWelcomeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 6, end: -24).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.authHeroWidth,
      height: AppSpacing.authHeroHeight + 43,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.authHeroHorizontalPadding,
          43,
          AppSpacing.authHeroHorizontalPadding,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              child: Image.asset(
                'assets/icons/AMASS  4.png',
                width: 208,
                height: 287,
                fit: BoxFit.contain,
              ),
              builder: (context, child) {
                final offset = MediaQuery.disableAnimationsOf(context)
                    ? 0.0
                    : _bounceAnimation.value;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: child,
                );
              },
            ),
            const SizedBox(height: AppSpacing.authActionsGap),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Register or sign up to get started on AMASS',
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                style: AppTypography.authSubtitle.copyWith(
                  color: AppColors.ink.withValues(alpha: 0.82),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
