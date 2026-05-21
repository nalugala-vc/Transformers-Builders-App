import 'package:flutter/material.dart';

import '../../../../../core/utils/theme/app_sizes.dart';
import '../../member_assets.dart';
import 'illustration_rings_backdrop.dart';

/// Contribution asset with soft concentric blue rings behind it.
class ContributionIllustration extends StatelessWidget {
  const ContributionIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final imageHeight = context.scaled.h(88);

    return IllustrationRingsBackdrop(
      child: Image.asset(
        MemberAssets.contribution,
        height: imageHeight,
        fit: BoxFit.contain,
      ),
    );
  }
}
