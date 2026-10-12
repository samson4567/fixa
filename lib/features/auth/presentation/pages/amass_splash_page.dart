import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_typography.dart';

class AmassSplashPage extends StatefulWidget {
  const AmassSplashPage({super.key});

  @override
  State<AmassSplashPage> createState() => _AmassSplashPageState();
}

class _AmassSplashPageState extends State<AmassSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _roll;
  late final Animation<double> _wordmark;
  bool _navigationScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _roll = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.74, curve: Curves.easeOutCubic),
    );
    _wordmark = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.82, curve: Curves.easeOutBack),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_navigationScheduled) return;
    _navigationScheduled = true;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.value = 1;
      _openWelcomeAfter(const Duration(milliseconds: 900));
    } else {
      _controller.forward();
      _openWelcomeAfter(const Duration(seconds: 4));
    }
  }

  Future<void> _openWelcomeAfter(Duration delay) async {
    await Future<void>.delayed(delay);
    if (mounted) context.go(AppRoutes.authWelcome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final landingProgress = ((_controller.value - 0.68) / 0.32).clamp(
              0.0,
              1.0,
            );
            final bounce = -18 * math.sin(math.pi * landingProgress);
            final pinOffset = -180 * (1 - _roll.value);
            final pinRotation = _roll.value * math.pi * 4;

            return SizedBox(
              width: 292,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 15,
                    bottom: 12,
                    child: Opacity(
                      opacity: (0.2 * landingProgress).clamp(0.0, 0.2),
                      child: Transform.scale(
                        scaleX: 0.65 + (landingProgress * 0.35),
                        child: Container(
                          width: 52,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF0000),
                            borderRadius: BorderRadius.circular(99),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55EF0000),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 9,
                    child: Transform.translate(
                      offset: Offset(pinOffset, bounce),
                      child: Transform.rotate(
                        angle: pinRotation,
                        child: Image.asset(
                          'assets/icons/AMASS  4.png',
                          width: 62,
                          height: 76,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 76,
                    child: Opacity(
                      opacity: _wordmark.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(24 * (1 - _wordmark.value), 0),
                        child: Transform.scale(
                          scale: 0.92 + (_wordmark.value * 0.08),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'AMASS',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 43,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -2.5,
                              color: Color(0xFF151719),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
