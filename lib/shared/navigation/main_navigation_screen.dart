import 'package:ambassadors/features/onboarding/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/leaderboard_rewards/screens/leaderboard_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/pickup/screens/pickup_screen.dart';
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
    const _PlaceholderScreen(title: 'Groups'), // Remplace temporairement CommunityScreen
    const LeaderboardScreen(),
    const _PlaceholderScreen(title: 'Products'), // Remplace temporairement PickupScreen
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

// Placeholder temporaire pour les écrans non encore créés
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$title Screen\n(En cours de construction)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
