import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/leaderboard_rewards/screens/leaderboard_screen.dart';
import '../../features/share/screens/share_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/shared_app_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // 4 pages, matching the wireframe exactly: Home (0), Board (1), Share (2),
  // Wallet (3). Profile is reached from the avatar in the top bar, not from
  // a 5th tab.
  final List<Widget> _pages = const [
    HomeScreen(),
    LeaderboardScreen(),
    ShareScreen(),
    WalletScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 1:
        return context.tr('title_board');
      case 2:
        return context.tr('title_share');
      case 3:
        return context.tr('title_wallet');
      default:
        return context.tr('title_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: _getTitle(_currentIndex),
        onAvatarTap: () => context.push(AppRoutes.profile),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SharedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
