import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/theme/app_pallete.dart';

/// Visual theme for each KPI tile — keeps the carousel varied and upbeat.
enum AdminKpiVariant {
  raised,
  members,
}

/// Branded KPI tile for the admin dashboard carousel.
class AdminKpiCard extends StatelessWidget {
  const AdminKpiCard({
    super.key,
    required this.label,
    required this.heroValue,
    required this.deltaText,
    required this.icon,
    required this.variant,
    this.deltaPositive = true,
    this.onTap,
  });

  final String label;
  final String heroValue;
  final String deltaText;
  final IconData icon;
  final AdminKpiVariant variant;
  final bool deltaPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = _themeFor(variant);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Base gradient
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: theme.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Soft decorative blobs — adds depth without feeling flat/dark
                Positioned(
                  top: -28,
                  right: -20,
                  child: _Blob(size: 110, color: theme.blobColor),
                ),
                Positioned(
                  bottom: -36,
                  left: -24,
                  child: _Blob(size: 90, color: theme.blobColor.withValues(alpha: 0.55)),
                ),
                Positioned(
                  top: 48,
                  right: 36,
                  child: _Blob(size: 36, color: AppPallete.tcWhite.withValues(alpha: 0.08)),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppPallete.tcWhite.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppPallete.tcWhite.withValues(alpha: 0.28),
                                width: 1,
                              ),
                            ),
                            child: Icon(icon, color: AppPallete.tcWhite, size: 20),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppPallete.tcWhite.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppPallete.tcWhite.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppPallete.tcWhite.withValues(alpha: 0.88),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        heroValue,
                        style: GoogleFonts.dmSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppPallete.tcWhite,
                          height: 1.05,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      _DeltaPill(
                        text: deltaText,
                        positive: deltaPositive,
                        accent: theme.deltaAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _KpiTheme _themeFor(AdminKpiVariant v) => switch (v) {
        AdminKpiVariant.raised => const _KpiTheme(
              gradientColors: [
                Color(0xFF2563EB),
                Color(0xFF4F46E5),
              ],
              shadowColor: Color(0xFF3B82F6),
              blobColor: Color(0xFF93C5FD),
              deltaAccent: AppPallete.successGreen,
            ),
        AdminKpiVariant.members => const _KpiTheme(
              gradientColors: [
                Color(0xFF0D9488),
                Color(0xFF0891B2),
              ],
              shadowColor: Color(0xFF14B8A6),
              blobColor: Color(0xFF5EEAD4),
              deltaAccent: Color(0xFFA7F3D0),
            ),
      };
}

class _KpiTheme {
  const _KpiTheme({
    required this.gradientColors,
    required this.shadowColor,
    required this.blobColor,
    required this.deltaAccent,
  });

  final List<Color> gradientColors;
  final Color shadowColor;
  final Color blobColor;
  final Color deltaAccent;
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({
    required this.text,
    required this.positive,
    required this.accent,
  });

  final String text;
  final bool positive;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bg = positive
        ? accent.withValues(alpha: 0.22)
        : AppPallete.errorRed.withValues(alpha: 0.22);
    final fg = positive ? accent : const Color(0xFFFCA5A5);
    final trendIcon = positive
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, size: 14, color: fg),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
