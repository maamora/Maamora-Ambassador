import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../maamora_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SKELETONS — shimmer placeholders. Never show raw empty containers while
/// loading (leaderboard, earnings, history…).
/// ─────────────────────────────────────────────────────────────────────────────

class MaamoraShimmerBox extends StatelessWidget {
  const MaamoraShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MaamoraColors.surfaceLow,
      highlightColor: const Color(0xFFFFFFFF),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: MaamoraColors.surfaceLow,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: MaamoraColors.border),
        ),
      ),
    );
  }
}

/// Skeleton card used for list placeholders (rows with avatar + 2 lines).
class MaamoraSkeletonRow extends StatelessWidget {
  const MaamoraSkeletonRow({
    super.key,
    this.avatarSize = 46,
    this.trailing = true,
    this.radius = MaamoraRadius.card,
  });

  final double avatarSize;
  final bool trailing;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MaamoraColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: MaamoraColors.border),
      ),
      child: Row(
        children: [
          MaamoraShimmerBox(
            width: avatarSize,
            height: avatarSize,
            radius: avatarSize / 2,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaamoraShimmerBox(height: 14, radius: 7),
                const SizedBox(height: 10),
                MaamoraShimmerBox(width: 110, height: 11, radius: 6),
              ],
            ),
          ),
          if (trailing) ...[
            const SizedBox(width: 10),
            MaamoraShimmerBox(width: 40, height: 18, radius: 6),
          ],
        ],
      ),
    );
  }
}

/// Vertical stack of skeleton rows — pass [count].
class MaamoraSkeletonList extends StatelessWidget {
  const MaamoraSkeletonList({
    super.key,
    this.count = 4,
    this.avatarSize = 46,
    this.trailing = true,
  });

  final int count;
  final double avatarSize;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => MaamoraSkeletonRow(avatarSize: avatarSize, trailing: trailing),
      ),
    );
  }
}

/// Skeleton for a hero/balance card.
class MaamoraSkeletonHero extends StatelessWidget {
  const MaamoraSkeletonHero({super.key, this.height = 140});

  final double height;

  @override
  Widget build(BuildContext context) {
    return MaamoraShimmerBox(height: height, radius: 22);
  }
}
