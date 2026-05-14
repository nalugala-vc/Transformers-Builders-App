import 'package:flutter/material.dart';

import '../../core/utils/theme/app_sizes.dart';

/// Dev/reference screen listing spacing tokens and current layout class.
class ResponsiveSizesScreen extends StatelessWidget {
  const ResponsiveSizesScreen({super.key});

  static const List<({String name, double value})> _tokens = [
    (name: 's0', value: AppSizes.s0),
    (name: 's2', value: AppSizes.s2),
    (name: 's4', value: AppSizes.s4),
    (name: 's6', value: AppSizes.s6),
    (name: 's8', value: AppSizes.s8),
    (name: 's10', value: AppSizes.s10),
    (name: 's12', value: AppSizes.s12),
    (name: 's14', value: AppSizes.s14),
    (name: 's16', value: AppSizes.s16),
    (name: 's18', value: AppSizes.s18),
    (name: 's20', value: AppSizes.s20),
    (name: 's24', value: AppSizes.s24),
    (name: 's28', value: AppSizes.s28),
    (name: 's32', value: AppSizes.s32),
    (name: 's36', value: AppSizes.s36),
    (name: 's40', value: AppSizes.s40),
    (name: 's44', value: AppSizes.s44),
    (name: 's48', value: AppSizes.s48),
    (name: 's56', value: AppSizes.s56),
    (name: 's64', value: AppSizes.s64),
    (name: 's72', value: AppSizes.s72),
    (name: 's80', value: AppSizes.s80),
    (name: 's96', value: AppSizes.s96),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final layoutClass = context.layoutSizeClass;
    final padding = context.responsivePagePadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive sizes'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(padding, padding, padding, padding + AppSizes.s24),
        children: [
          Text('Layout', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.s8),
          _InfoRow(label: 'Width × height', value: '${mq.size.width.toStringAsFixed(0)} × ${mq.size.height.toStringAsFixed(0)}'),
          _InfoRow(label: 'Size class', value: layoutClass.name),
          _InfoRow(
            label: 'Breakpoints',
            value: '< ${AppBreakpoints.compactMax} compact · '
                '< ${AppBreakpoints.mediumMax} medium · else expanded',
          ),
          _InfoRow(label: 'responsivePagePadding', value: padding.toStringAsFixed(0)),
          _InfoRow(
            label: 'Scaled (s20 baseline)',
            value: 'h20 = ${context.scaled.h20.toStringAsFixed(1)} px · '
                'f20 = ${context.scaled.f20.toStringAsFixed(1)} px '
                '(fixed s20 = ${AppSizes.s20})',
          ),
          const SizedBox(height: AppSizes.s24),
          Text('Spacing scale (logical px)', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.s8),
          ..._tokens.map((t) => _SizeSwatch(name: t.name, logicalPx: t.value)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _SizeSwatch extends StatelessWidget {
  const _SizeSwatch({required this.name, required this.logicalPx});

  final String name;
  final double logicalPx;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final side = logicalPx.clamp(0.0, 96.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s10),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: side == 0 ? 1 : side,
                height: side == 0 ? 1 : side,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.s4),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Text(
              '$name  ·  ${logicalPx.toStringAsFixed(0)} px',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
