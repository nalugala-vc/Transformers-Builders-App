import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthDropdownField<MemberGroup>(
          label: 'Demographic group',
          value: MemberGroups.findDemographicById(demographicGroupId),
          items: MemberGroups.demographics,
          itemLabel: (g) => g.label,
          hint: 'e.g. Women, Men, Youth',
          errorText: demographicError,
          enabled: enabled,
          onChanged: (g) => onDemographicChanged(g?.id),
        ),
        const SizedBox(height: 16),
        AuthDropdownField<MemberGroup>(
          label: ministryOptional ? 'Ministry (optional)' : 'Ministry',
          value: MemberGroups.findMinistryById(ministryGroupId) ??
              (ministryOptional ? MemberGroups.noMinistry : null),
          items: [
            if (ministryOptional) MemberGroups.noMinistry,
            ...MemberGroups.ministries,
          ],
          itemLabel: (g) => g.label,
          hint: ministryOptional ? null : 'e.g. Choir, Ushers',
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
