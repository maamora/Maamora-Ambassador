// features/profile/screens/profile_screen.dart
import 'package:ambassadors/shared/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: _buildBody(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFB7701)),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(provider.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.fetchProfileData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final ambassador = provider.ambassadorData;
    if (ambassador == null) return const SizedBox.shrink();

    // Mapping des données
    final name = ambassador['name'] ?? 'Inconnu';
    final email = ambassador['email'] ?? '';
    final referralCode = ambassador['referral_code'] ?? '';
    final points = ambassador['points_total']?.toString() ?? '0';
    // Remplacez par `avatar_url` si vous l'ajoutez à la base de données
    final avatarUrl = ambassador['avatar_url'];
    final tier = provider.tierName?.toUpperCase() ?? 'SANS NIVEAU';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _buildHeader(name: name, tier: tier, avatarUrl: avatarUrl),
          const SizedBox(height: 24),
          _buildStatsRow(
            points: points,
            linksCount: provider.linksCount.toString(),
            ordersCount: provider.ordersCount.toString(),
          ),
          const SizedBox(height: 16),
          _buildRewardsSection(context, points: points),
          const SizedBox(height: 16),
          _buildAccountDetails(name: name, code: referralCode, email: email),
          const SizedBox(height: 16),
          const _PreferencesSection(),
          const SizedBox(height: 32),
          _buildLogoutButton(context, provider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required String name,
    required String tier,
    String? avatarUrl,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
                image: avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFB7701),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: const Icon(
                  Icons.photo_camera,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2433),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            border: Border.all(color: Colors.amber.shade200),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber.shade700, size: 16),
              const SizedBox(width: 4),
              Text(
                tier,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow({
    required String points,
    required String linksCount,
    required String ordersCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.stars,
            value: points,
            label: 'POINTS TOTAUX',
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons
                .link, // Changé pour refléter les liens au lieu des groupes
            value: linksCount,
            label: 'LIENS CRÉÉS',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_bag,
            value: ordersCount,
            label: 'COMMANDES',
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsSection(BuildContext context, {required String points}) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.redeem, color: Color(0xFFFB7701)),
              SizedBox(width: 8),
              Text(
                'Solde des récompenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Disponible à dépenser',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: '$points ',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2433),
                      ),
                      children: const [
                        TextSpan(
                          text: 'pts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.rewards, extra: int.tryParse(points));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFB7701),
                  padding: EdgeInsets.zero,
                ),
                child: Row(
                  children: const [
                    Text(
                      'Échanger',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails({
    required String name,
    required String code,
    required String email,
  }) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DÉTAILS DU COMPTE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _AccountDetailRow(label: 'Nom complet', value: name),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _AccountDetailRow(label: 'Code de parrainage', value: code),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _AccountDetailRow(label: 'Adresse Email', value: email),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ProfileProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          // 1. Déconnexion via Supabase
          await provider.signOut();

          // 2. Vérification indispensable après un appel asynchrone (async gap)
          if (!context.mounted) return;

          // 3. Redirection vers l'écran de connexion avec GoRouter
          context.go(AppRoutes.login);
        },
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Se déconnecter'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade600,
          side: BorderSide(color: Colors.red.shade200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // Widget _buildLogoutButton(BuildContext context, ProfileProvider provider) {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: OutlinedButton.icon(
  //       onPressed: () async {
  //         await provider.signOut();
  //         // Redirection à gérer via votre routeur (ex: GoRouter)
  //       },
  //       icon: const Icon(Icons.logout, size: 20),
  //       label: const Text('Se déconnecter'),
  //       style: OutlinedButton.styleFrom(
  //         foregroundColor: Colors.red.shade600,
  //         side: BorderSide(color: Colors.red.shade200),
  //         padding: const EdgeInsets.symmetric(vertical: 16),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

// Les Widgets extraits ci-dessous sont inchangés par rapport à la version précédente
// (Je les sépare dans un Stateful widget pour gérer l'état local des préférences s'ils ne sont pas en BDD)

class _PreferencesSection extends StatefulWidget {
  const _PreferencesSection();

  @override
  State<_PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<_PreferencesSection> {
  bool _pushNotifications = true;
  String _selectedLanguage = 'FR';

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRÉFÉRENCES',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.notifications_none, color: Colors.grey),
                  SizedBox(width: 12),
                  Text(
                    'Notifications push',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Switch(
                value: _pushNotifications,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFFFB7701),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (val) => setState(() => _pushNotifications = val),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.language, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Langue', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: ['EN', 'FR', 'AR'].map((lang) {
                    final isSelected = _selectedLanguage == lang;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLanguage = lang),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isSelected
                              ? [
                                  const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          lang,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF1A2433)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isPrimary;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFFB7701) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary ? null : Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? const Color(0xFFFB7701).withValues(alpha: 0.2)
                : const Color(0xFF1A2433).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isPrimary
                ? Colors.white.withValues(alpha: 0.8)
                : const Color(0xFFFB7701),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : const Color(0xFF1A2433),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2433).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AccountDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _AccountDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A2433),
                  ),
                ),
              ],
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
          //   onPressed: () {},
          // ),
        ],
      ),
    );
  }
}
