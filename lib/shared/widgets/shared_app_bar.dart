import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared app bar that matches the mockup:
/// [Logo icon] [Title]  ·  [Avatar circle] on the right.
class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? avatarUrl;
  final bool hasNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const SharedAppBar({
    super.key,
    this.title = 'MAAMORA',
    this.avatarUrl,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDE8E4), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Brand logo mark
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'M',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFB7701),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: const Color(0xFF1A2433),
                  ),
                ),
                const Spacer(),
                // Avatar on the right
                GestureDetector(
                  onTap: onAvatarTap,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE8DDD3),
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 22,
                            color: Color(0xFF8A8078),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
