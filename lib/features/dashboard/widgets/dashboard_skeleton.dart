import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../shared/design/app_tokens.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../../shared/widgets/responsive.dart';

/// Loading state that mirrors the real layout, so the page does not jump when
/// the data arrives.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('common_loading'),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: ResponsiveBody(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppSkeleton(width: 180, height: 26),
                ),
                SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppSkeleton(width: 240, height: 14),
                ),
                SizedBox(height: AppSpacing.xl),
                AppSkeleton(
                    width: double.infinity, height: 132, radius: AppRadius.xl),
                SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(child: AppSkeleton(height: 88, radius: AppRadius.md)),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(child: AppSkeleton(height: 88, radius: AppRadius.md)),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(child: AppSkeleton(height: 88, radius: AppRadius.md)),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                AppSkeleton(
                    width: double.infinity, height: 120, radius: AppRadius.lg),
                SizedBox(height: AppSpacing.lg),
                AppSkeleton(
                    width: double.infinity, height: 54, radius: AppRadius.md),
                SizedBox(height: AppSpacing.xl),
                AppSkeletonList(count: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
