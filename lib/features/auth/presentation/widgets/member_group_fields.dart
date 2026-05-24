import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/l10n/member_group_l10n.dart';
import '../../../member/domain/models/member_group.dart';
import 'auth_dropdown_field.dart';

/// Demographic (required) + optional ministry dropdowns.
class MemberGroupFields extends StatelessWidget {
  const MemberGroupFields({
    super.key,
    required this.demographicGroupId,
    required this.ministryGroupId,
    required this.onDemographicChanged,
    required this.onMinistryChanged,
    this.demographicError,
    this.ministryError,
    this.enabled = true,
    this.ministryOptional = true,
  });

  final String? demographicGroupId;
  final String? ministryGroupId;
  final ValueChanged<String?> onDemographicChanged;
  final ValueChanged<String?> onMinistryChanged;
  final String? demographicError;
  final String? ministryError;
  final bool enabled;
  final bool ministryOptional;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthDropdownField<MemberGroup>(
          label: l10n.demographicGroup,
          value: MemberGroups.findDemographicById(demographicGroupId),
          items: MemberGroups.demographics,
          itemLabel: (g) => g.localizedLabel(l10n),
          hint: l10n.demographicHint,
          errorText: demographicError,
          enabled: enabled,
          onChanged: (g) => onDemographicChanged(g?.id),
        ),
        const SizedBox(height: 16),
        AuthDropdownField<MemberGroup>(
          label: ministryOptional ? l10n.ministryOptional : l10n.ministry,
          value: MemberGroups.findMinistryById(ministryGroupId) ??
              (ministryOptional
                  ? MemberGroup(
                      id: '',
                      label: l10n.ministryNone,
                      category: MemberGroupCategory.ministry,
                    )
                  : null),
          items: [
            if (ministryOptional)
              MemberGroup(
                id: '',
                label: l10n.ministryNone,
                category: MemberGroupCategory.ministry,
              ),
            ...MemberGroups.ministries,
          ],
          itemLabel: (g) =>
              g.id.isEmpty ? l10n.ministryNone : g.localizedLabel(l10n),
          hint: ministryOptional ? null : l10n.demographicHint,
          errorText: ministryError,
          enabled: enabled,
          onChanged: (g) {
            final id = g?.id;
            onMinistryChanged(id == null || id.isEmpty ? null : id);
          },
        ),
      ],
    );
  }
}
