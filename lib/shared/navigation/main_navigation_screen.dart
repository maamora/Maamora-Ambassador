import 'package:ambassadors/features/onboarding/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/leaderboard_rewards/screens/leaderboard_screen.dart';
import '../../features/groups/screens/my_groups_screen.dart';
import '../../features/shop/screens/products_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/shared_app_bar.dart';
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Liste des pages pour l'IndexedStack
  final List<Widget> _pages = [
    const DashboardScreen(),
    const MyGroupsScreen(), // Remplace temporairement CommunityScreen
    const LeaderboardScreen(),
    const ProductsScreen(), // Products Screen
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'MAAMORA';
      case 1:
        return 'GROUPS';
      case 2:
        return 'LEADERBOARD';
      case 3:
        return 'PRODUCTS';
      case 4:
        return 'PROFILE';
      default:
        return 'MAAMORA';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: _getTitle(_currentIndex),
        hasNotification: true, // Placeholder ou condition réelle
        onAvatarTap: () => _onTabTapped(4), // Redirige vers l'onglet Profile
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SharedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

