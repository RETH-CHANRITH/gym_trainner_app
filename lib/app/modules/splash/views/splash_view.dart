import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/splash_controller.dart';
import '../../../../config/glass_ui.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: kInk, body: _SplashBody());
  }
}

// ─── Stateful body for all animations ────────────────────────────────────────
class _SplashBody extends StatefulWidget {
  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final AnimationController _loadCtrl;
  late final AnimationController _fadeCtrl;
  late final AnimationController _spinCtrl;
  late final AnimationController _bounceCtrl;

  late final Animation<double> _ring1Scale;
  late final Animation<double> _ring2Scale;
  late final Animation<double> _ring1Opacity;
  late final Animation<double> _ring2Opacity;
  late final Animation<double> _loadBar;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _ring1Scale = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
    _ring2Scale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _ring1Opacity = Tween<double>(
      begin: 0.7,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
    _ring2Opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _ringCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();
    _loadBar = CurvedAnimation(parent: _loadCtrl, curve: Curves.easeInOut);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..repeat();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _loadCtrl.dispose();
    _fadeCtrl.dispose();
    _spinCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Liquid glass background
        Positioned.fill(child: liquidBackground()),
        // Vivid orbs
        Positioned(
          top: -120,
          left: -100,
          child: GlowOrb(color: kNeon, radius: 300),
        ),
        Positioned(
          bottom: -140,
          right: -80,
          child: GlowOrb(color: kSky, radius: 260),
        ),
        Positioned(
          top: 360,
          left: -60,
          child: GlowOrb(color: kLilac, radius: 160),
        ),

        // Main centered content
        FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rings + logo
                SizedBox(
                  width: 210,
                  height: 210,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      AnimatedBuilder(
                        animation: _ringCtrl,
                        builder:
                            (_, __) => Opacity(
                              opacity: _ring2Opacity.value,
                              child: Container(
                                width: 210 * _ring2Scale.value,
                                height: 210 * _ring2Scale.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kNeon, width: 1.5),
                                ),
                              ),
                            ),
                      ),
                      // Inner ring
                      AnimatedBuilder(
                        animation: _ringCtrl,
                        builder:
                            (_, __) => Opacity(
                              opacity: _ring1Opacity.value,
                              child: Container(
                                width: 168 * _ring1Scale.value,
                                height: 168 * _ring1Scale.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kNeon, width: 2),
                                ),
                              ),
                            ),
                      ),
                      // Spinning icon card (CD effect)
                      RotationTransition(
                        turns: _spinCtrl,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.22),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kNeon.withOpacity(0.55),
                                    blurRadius: 60,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [Colors.white, kNeon],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: const Icon(
                                  Icons.fitness_center_rounded,
                                  size: 54,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // App name – gradient shader
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [Colors.white, kNeon],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                  child: Text(
                    'GYMTRAINER',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 62,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                Text(
                  'YOUR FITNESS JOURNEY STARTS HERE',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: kMuted,
                    letterSpacing: 2.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated runner track (bottom)
        Positioned(
          bottom: 44,
          left: 40,
          right: 40,
          child: AnimatedBuilder(
            animation: Listenable.merge([_loadBar, _bounceCtrl]),
            builder: (_, __) {
              final progress = _loadBar.value;
              // Running step: quick rise (0–30%), quick land (30–60%), ground pause (60–100%)
              final t = _bounceCtrl.value;
              final stepFactor = t < 0.30
                  ? t / 0.30
                  : t < 0.60
                  ? 1.0 - (t - 0.30) / 0.30
                  : 0.0;
              final bounce = stepFactor * 7.0;
              return SizedBox(
                height: 48,
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final trackW = constraints.maxWidth;
                    const iconSize = 30.0;
                    final runnerX = progress * (trackW - iconSize);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Full track line
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Neon trail behind runner
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            height: 2,
                            width: (runnerX + iconSize / 2).clamp(
                              0,
                              trackW,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kNeon, kSky],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Neon glow dot at runner feet
                        Positioned(
                          bottom: -3,
                          left: runnerX + iconSize / 2 - 5,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kNeon.withOpacity(0.6),
                              boxShadow: [
                                BoxShadow(
                                  color: kNeon.withOpacity(0.8),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Running figure
                        Positioned(
                          bottom: 4 + bounce,
                          left: runnerX,
                          child: Transform.rotate(
                            angle: -0.18, // lean forward
                            child: ShaderMask(
                              shaderCallback:
                                  (bounds) => const LinearGradient(
                                    colors: [Colors.white, kNeon],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ).createShader(bounds),
                              child: const Icon(
                                Icons.directions_run_rounded,
                                size: iconSize,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
