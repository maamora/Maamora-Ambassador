import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('47', 'neighbors', Colors.white, Colors.redAccent),
                _buildStatCard('12', 'active this week', Colors.white, Colors.black),
                _buildStatCard('89%', 'retention', const Color(0xFFFCEBC9), Colors.black),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildChip('All', false),
                const SizedBox(width: 8),
                _buildChip('Active', true),
                const SizedBox(width: 8),
                _buildChip('New', false),
                const SizedBox(width: 8),
                _buildChip('At risk', false),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildMemberCard('Hiba B.', true, 'joined 2w ago · 4 buys',
                      'msg', const Color(0xFFE95D35)),
                  _buildMemberCard('Soufiane M.', false, 'joined 5d ago · 2 buys',
                      'msg', const Color(0xFFF2A64C)),
                  _buildMemberCard('Amal K.', true, 'joined 1mo ago · 7 buys',
                      'msg', const Color(0xFFE95D35)),
                  _buildMemberCard('Karim T.', false, 'joined 3d ago · 1 buys',
                      'msg', const Color(0xFFF2A64C)),
                  _buildMemberCard('Salma R.', false, 'joined 6w ago - quiet - 0 buys',
                      'nudge', const Color(0xFFE95D35),
                      isPale: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, Color bgColor, Color valueColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMemberCard(String name, bool isFire, String details,
      String action, Color avatarColor,
      {bool isPale = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isPale ? const Color(0xFFFBE4DC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (isFire) const Text(' 🔥'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.5),
              color: action == 'nudge' ? const Color(0xFFFBE4DC) : Colors.white,
            ),
            child: Text(
              action,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
