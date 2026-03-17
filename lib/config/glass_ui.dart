import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Shared glass design tokens ─────────────────────────────────────────────────
const Color kInk = Color(0xFF07010E);
const Color kNeon = Color(0xFFC8FF33);
const Color kSky = Color(0xFF38C9FF);
const Color kCoral = Color(0xFFFF4F4F);
const Color kLilac = Color(0xFFAB7EFF);
const Color kPink = Color(0xFFFF55E8);
const Color kMuted = Color(0xFF8484A0);
const double kGlassBlurSigma = 14;
const double kAppBarBlurSigma = 16;

// ── Rich gradient background ───────────────────────────────────────────────────
/// Place as Positioned.fill at the bottom of every screen Stack.
Widget liquidBackground() => Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A0330), Color(0xFF03071C), Color(0xFF011525)],
      stops: [0.0, 0.5, 1.0],
    ),
  ),
);

// ── Glow orb ──────────────────────────────────────────────────────────────────
class GlowOrb extends StatelessWidget {
  final Color color;
  final double radius;
  const GlowOrb({super.key, required this.color, required this.radius});
  @override
  Widget build(BuildContext context) => Container(
    width: radius * 2,
    height: radius * 2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color.withOpacity(0.65),
          color.withOpacity(0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
        radius: 0.65,
      ),
    ),
  );
}

// ── Grid painter ──────────────────────────────────────────────────────────────
class AppGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(AppGridPainter _) => false;
}

// ── Liquid glass decoration ────────────────────────────────────────────────────
BoxDecoration glassDecoration({
  double radius = 20,
  bool selected = false,
  Color accent = kNeon,
  Color? glowColor,
}) {
  final glow = glowColor ?? accent;
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:
          selected
              ? [accent.withOpacity(0.42), accent.withOpacity(0.10)]
              : [
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.04),
              ],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color:
          selected ? accent.withOpacity(0.85) : Colors.white.withOpacity(0.32),
      width: selected ? 1.5 : 1.0,
    ),
    boxShadow: [
      if (selected)
        BoxShadow(
          color: glow.withOpacity(0.40),
          blurRadius: 20,
          spreadRadius: -4,
        ),
      BoxShadow(
        color: Colors.black.withOpacity(0.30),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

// ── Liquid tile widget (blur + glass decoration all-in-one) ───────────────────
class LiquidTile extends StatelessWidget {
  final Widget child;
  final bool selected;
  final Color accent;
  final double radius;
  final EdgeInsetsGeometry padding;

  const LiquidTile({
    super.key,
    required this.child,
    this.selected = false,
    this.accent = kNeon,
    this.radius = 20,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: kGlassBlurSigma,
          sigmaY: kGlassBlurSigma,
        ),
        child: Container(
          padding: padding,
          decoration: glassDecoration(
            selected: selected,
            accent: accent,
            radius: radius,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Glass text field decoration ───────────────────────────────────────────────
InputDecoration glassFieldDecoration({
  required String hint,
  IconData? icon,
  Color accent = kNeon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: kMuted, fontSize: 14),
    prefixIcon: icon != null ? Icon(icon, color: kMuted, size: 20) : null,
    filled: true,
    fillColor: Colors.white.withOpacity(0.09),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.30)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.30)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: accent, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  );
}

// ── Liquid pill CTA button ─────────────────────────────────────────────────────
Widget neonButton({
  required String label,
  required VoidCallback onPressed,
  Widget? child,
  Color accent = kNeon,
}) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, Color.alphaBlend(Colors.white38, accent)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.50),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accent.withOpacity(0.20),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child:
            child ??
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
      ),
    ),
  );
}

// ── Liquid glass AppBar ───────────────────────────────────────────────────────
PreferredSizeWidget glassAppBar({required String title, VoidCallback? onBack}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(64),
    child: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: kAppBarBlurSigma,
          sigmaY: kAppBarBlurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.14),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.15),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (onBack != null)
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.22),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (onBack != null) const SizedBox(width: 38),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
