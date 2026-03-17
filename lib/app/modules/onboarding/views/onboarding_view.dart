import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/onboarding_controller.dart';
import '../../../../config/glass_ui.dart' show liquidBackground, GlowOrb, kNeon, kSky, kLilac, kPink, kInk, kMuted;

// ── Local tokens ─────────────────────────────────────────────────────────────
const _ink = kInk;
const _neon = kNeon;
const _blue = kSky;
const _pink = kPink;
const _muted = kMuted;
const _glass = Color(0x18FFFFFF);
const _glassBorder = Color(0x30FFFFFF);

// ── Page definitions ──────────────────────────────────────────────────────────
final _pages = [
  _PageData(
    accent: _neon,
    gradientEnd: _neon,
    icon: Icons.sports_gymnastics_rounded,
    chips: ['Certified Pro', '4.9 ⭐ Rating'],
    badge: '🎯  Personalised',
    titleLines: ['Find Your', 'Perfect', 'Trainer'],
    subtitle:
        'Connect with certified fitness experts tailored to your goals and schedule.',
    step: '01',
    ctaLabel: 'Next',
  ),
  _PageData(
    accent: _blue,
    gradientEnd: _blue,
    icon: Icons.calendar_today_rounded,
    chips: ['Today 6:00 PM', 'Confirmed ✓'],
    badge: '📆  Smart Booking',
    titleLines: ['Book', 'Sessions', 'Easily'],
    subtitle:
        'Schedule one-on-one training sessions anytime, anywhere with just a few taps.',
    step: '02',
    ctaLabel: 'Next',
  ),
  _PageData(
    accent: _pink,
    gradientEnd: _pink,
    icon: Icons.trending_up_rounded,
    chips: ['+12% Strength', '🔥 Week Streak'],
    badge: '📊  Analytics',
    titleLines: ['Track Your', 'Gains &', 'Grow'],
    subtitle:
        'Visualise every rep, every streak, every milestone as you crush your goals.',
    step: '03',
    ctaLabel: 'Get Started',
  ),
];

// ── Root view ─────────────────────────────────────────────────────────────────
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ink,
      body: Stack(
        children: [
          // Liquid glass background
          Positioned.fill(child: liquidBackground()),

          // Page swiper – fills entire screen
          PageView.builder(
            controller: controller.pageController,
            itemCount: _pages.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (_, i) => _OnboardingPage(page: _pages[i], index: i),
          ),
        ],
      ),
    );
  }
}

// ── Per-page stateful widget ───────────────────────────────────────────────────
class _OnboardingPage extends StatefulWidget {
  final _PageData page;
  final int index;
  const _OnboardingPage({required this.page, required this.index});

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _spinCtrl;
  late final Animation<double> _chip1;
  late final Animation<double> _chip2;
  late final Animation<double> _shimmer;

  OnboardingController get ctrl => Get.find<OnboardingController>();

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _chip1 = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _chip2 = Tween<double>(
      begin: -4,
      end: 8,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmer = CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut);

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _shimmerCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.page;
    final size = MediaQuery.of(context).size;
    final topH = size.height * 0.48;

    return Stack(
      children: [
        // ── Top visual half ───────────────────────────────────────────────
        SizedBox(
          height: topH,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient vivid orbs
              GlowOrb(color: p.accent, radius: 200),
              Positioned(
                top: -30,
                left: -40,
                child: GlowOrb(color: p.accent == _blue ? kLilac : _blue, radius: 130),
              ),
              Positioned(
                bottom: -20,
                right: -30,
                child: GlowOrb(color: p.accent == _neon ? kLilac : _neon, radius: 100),
              ),

              // Geometric circle outlines
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: p.accent.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: p.accent.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),

              // Main icon card
              RotationTransition(
                  turns: _spinCtrl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.22),
                              p.accent.withOpacity(0.10),
                            ],
                          ),
                          border: Border.all(color: _glassBorder, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: p.accent.withOpacity(0.45),
                              blurRadius: 50,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                                colors: [Colors.white, p.accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                          child: Icon(p.icon, size: 62, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

              // Floating chip 1 (top-left)
              Positioned(
                top: topH * 0.14,
                left: size.width * 0.06,
                child: AnimatedBuilder(
                  animation: _chip1,
                  builder:
                      (_, __) => Transform.translate(
                        offset: Offset(0, _chip1.value),
                        child: _GlassChip(label: p.chips[0], accent: p.accent),
                      ),
                ),
              ),

              // Floating chip 2 (bottom-right)
              Positioned(
                bottom: topH * 0.12,
                right: size.width * 0.06,
                child: AnimatedBuilder(
                  animation: _chip2,
                  builder:
                      (_, __) => Transform.translate(
                        offset: Offset(0, _chip2.value),
                        child: _GlassChip(label: p.chips[1], accent: p.accent),
                      ),
                ),
              ),
            ],
          ),
        ),

        // Dark gradient fade from visual to text area
        Positioned(
          top: topH - 80,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, _ink],
              ),
            ),
          ),
        ),

        // ── Bottom text half ──────────────────────────────────────────────
        Positioned(
          top: topH - 20,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: _ink,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                _GlassBadge(label: p.badge, accent: p.accent),
                const SizedBox(height: 16),

                // Bebas Neue title with gradient
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [Colors.white, p.gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                  child: Text(
                    p.titleLines.join('\n'),
                    style: GoogleFonts.bebasNeue(
                      fontSize: 52,
                      color: Colors.white,
                      height: 1.05,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Subtitle
                Text(
                  p.subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: _muted,
                    height: 1.65,
                  ),
                ),

                const SizedBox(height: 24),

                // Dot indicators + step counter row
                Obx(() {
                  final cur = ctrl.currentPage.value;
                  return Row(
                    children: [
                      // Dots
                      Row(
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            width: i == cur ? 24 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color:
                                  i == cur
                                      ? _pages[cur].accent
                                      : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Step counter
                      Text(
                        '${_pages[cur].step} / 03',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 14,
                          color: _muted,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 16),

                // CTA button with shimmer
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                p.accent == _pink
                                    ? [_pink, Color(0xFFFF9BEC)]
                                    : p.accent == _blue
                                    ? [_blue, Color(0xFF90E8FF)]
                                    : [_neon, Color(0xFF90FF65)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: ctrl.nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            p.ctaLabel,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Shimmer sweep overlay
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _shimmer,
                        builder: (_, __) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Align(
                              alignment: Alignment(
                                -1.5 + (_shimmer.value * 3.0),
                                0,
                              ),
                              child: Container(
                                width: 60,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.22),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ── Skip link top-right ──────────────────────────────────────────
        Positioned(
          top: 52,
          right: 24,
          child: Obx(
            () => ctrl.currentPage.value < _pages.length - 1
                ? GestureDetector(
                    onTap: ctrl.skip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _muted,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      ],
    );
  }
}

// ── Frosted glass chip ────────────────────────────────────────────────────────
class _GlassChip extends StatelessWidget {
  final String label;
  final Color accent;
  const _GlassChip({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _glass,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: accent.withOpacity(0.35), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Frosted glass badge ───────────────────────────────────────────────────────
class _GlassBadge extends StatelessWidget {
  final String label;
  final Color accent;
  const _GlassBadge({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.3), width: 1),
          ),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Page data model ───────────────────────────────────────────────────────────
class _PageData {
  final Color accent;
  final Color gradientEnd;
  final IconData icon;
  final List<String> chips;
  final String badge;
  final List<String> titleLines;
  final String subtitle;
  final String step;
  final String ctaLabel;

  const _PageData({
    required this.accent,
    required this.gradientEnd,
    required this.icon,
    required this.chips,
    required this.badge,

    required this.titleLines,
    required this.subtitle,
    required this.step,
    required this.ctaLabel,
  });
}
