import 'package:ambassadors/features/onboarding/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/leaderboard_rewards/screens/rewards_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/pickup/screens/pickup_screen.dart';
import '../widgets/bottom_nav_bar.dart';

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
    const RewardsScreen(),
    const CommunityScreen(),
    const PickupScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
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
      appBar: AppBar(title: Text(title), centerTitle: true),
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
