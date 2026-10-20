import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/l10n/locale_provider.dart';
import '../../core/services/ambassador_state_provider.dart';
import '../navigation/app_routes.dart';
import '../theme/app_colors.dart';

/// Maamora navbar, shared by every signed-in page.
///
/// Same look as the main Maamora site header, without search and cart:
///   [Maamora]  ········  [language ▾]  [(W) name]
///
/// Pushed pages (create group, rules, admin details...) pass [pageTitle] to
/// get a slim second row with a back arrow and the page title, so the navbar
/// itself stays identical everywhere.
class SharedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  /// Kept only so existing callers keep compiling. Tab titles now live in the
  /// bottom navigation; use [pageTitle] for pushed pages.
  final String title;
  final String? pageTitle;
  final VoidCallback? onBack;
  final String? avatarUrl;
  final bool hasNotification;
  final VoidCallback? onNotificationTap;

  /// Custom action for the profile chip. If null and [profileEnabled] is true,
  /// the ambassador profile page is opened.
  final VoidCallback? onAvatarTap;
  final bool profileEnabled;

  static const double _barHeight = 64;
  static const double _titleRowHeight = 46;

  const SharedAppBar({
    super.key,
    this.title = '',
    this.pageTitle,
    this.onBack,
    this.avatarUrl,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onAvatarTap,
    this.profileEnabled = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
      pageTitle == null ? _barHeight : _barHeight + _titleRowHeight);

  /// First name of the signed-in user: ambassador profile first, then the
  /// Google account (covers admins, who have no ambassador record).
  String _displayName(WidgetRef ref) {
    final ambassador = ref.watch(ambassadorStateProvider).ambassador;
    final fullName = ambassador?.fullName.trim() ?? '';
    if (fullName.isNotEmpty) return fullName.split(' ').first;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final meta = user?.userMetadata;
      final metaName = (meta?['full_name'] ?? meta?['name']) as String?;
      if (metaName != null && metaName.trim().isNotEmpty) {
        return metaName.trim().split(' ').first;
      }
      final email = user?.email;
      if (email != null && email.contains('@')) return email.split('@').first;
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = _displayName(ref);
    final showName = MediaQuery.sizeOf(context).width >= 360;
    final VoidCallback? profileTap = onAvatarTap ??
        (profileEnabled ? () => context.push(AppRoutes.profile) : null);

    return Material(
      color: Colors.white,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEDEDED))),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _barHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Maamora',
                        style: GoogleFonts.cairo(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          height: 1.1,
                        ),
                      ),
                      const Spacer(),
                      const _LanguageMenu(),
                      const SizedBox(width: 12),
                      _ProfileChip(
                        name: name,
                        showName: showName,
                        avatarUrl: avatarUrl,
                        onTap: profileTap,
                      ),
                    ],
                  ),
                ),
              ),
              if (pageTitle != null)
                SizedBox(
                  height: _titleRowHeight,
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18),
                        color: AppColors.secondary,
                        onPressed:
                            onBack ?? () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          pageTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Language dropdown (EN / AR) ─────────────────────────────────────────────

class _LanguageMenu extends ConsumerWidget {
  const _LanguageMenu();

  PopupMenuItem<String> _item(
      String code, String label, String short, String current) {
    final selected = current == code;
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              short,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.primary : AppColors.secondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    return PopupMenuButton<String>(
      tooltip: 'Language',
      offset: const Offset(0, 46),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      onSelected: (code) =>
          ref.read(localeProvider.notifier).set(Locale(code)),
      itemBuilder: (_) => [
        _item('en', 'English', 'EN', current),
        _item('ar', 'العربية', 'AR', current),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE3E3E3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 16, color: AppColors.secondary),
            const SizedBox(width: 6),
            Text(
              current.toUpperCase(),
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Profile chip: orange avatar with initial + first name ───────────────────

class _ProfileChip extends StatelessWidget {
  final String name;
  final bool showName;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const _ProfileChip({
    required this.name,
    required this.showName,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty
        ? String.fromCharCode(name.runes.first).toUpperCase()
        : '';
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                image: avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: avatarUrl != null
                  ? null
                  : (initial.isNotEmpty
                      ? Text(
                          initial,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        )
                      : const Icon(Icons.person_outline,
                          size: 20, color: Colors.white)),
            ),
            if (showName && name.isNotEmpty) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 84),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
