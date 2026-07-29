import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/my_groups_provider.dart';

const Color _primaryContainer = Color(0xFFFB7701);
const Color _surface = Color(0xFFFFF8F5);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF251912);
const Color _onSurfaceVariant = Color(0xFF584236);
const Color _outlineVariant = Color(0xFFE0C0B0);


class OrderDetailsScreen extends StatelessWidget {
  final GroupWithProduct groupData;
  const OrderDetailsScreen({super.key, required this.groupData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: const BackButton(color: _onBackground),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: GoogleFonts.plusJakartaSans(
                color: _onBackground,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Order #${groupData.group.id.substring(0, 8).toUpperCase()}',
              style: GoogleFonts.inter(
                color: _onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _ProductCard(groupData: groupData),
              const SizedBox(height: 16),
              _FulfillmentStatusCard(groupData: groupData),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final GroupWithProduct groupData;
  const _ProductCard({required this.groupData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: groupData.productImageUrl.isNotEmpty
                    ? Image.network(
                        groupData.productImageUrl,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 80,
                        width: 80,
                        color: _outlineVariant,
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupData.productName.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: _onBackground,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Group: ${groupData.group.compteurActuel}/${groupData.group.seuilMin} members',
                      style: GoogleFonts.inter(
                        color: _onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${groupData.group.prixGroupe?.toStringAsFixed(2) ?? groupData.productPrice.toStringAsFixed(2)} DH',
                      style: GoogleFonts.plusJakartaSans(
                        color: _primaryContainer,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: _outlineVariant, height: 1),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBE3D8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFC5D1F6),
                      child: Text(
                        'SM',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1E3A8A),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PURCHASED BY',
                          style: GoogleFonts.inter(
                            color: _onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Sarah M.',
                          style: GoogleFonts.inter(
                            color: _onBackground,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '+2,500 pts',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FulfillmentStatusCard extends StatelessWidget {
  final GroupWithProduct groupData;
  const _FulfillmentStatusCard({required this.groupData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FULFILLMENT STATUS',
            style: GoogleFonts.inter(
              color: _onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          _StatusTimeline(
            title: 'Group Created',
            subtitle: 'Waiting for members',
            isCompleted: true,
            isLast: false,
          ),
          _StatusTimeline(
            title: 'Group Confirmed',
            subtitle: groupData.group.isUnlocked ? 'Goal Reached' : 'Pending Members',
            isCompleted: groupData.group.isUnlocked,
            isActive: !groupData.group.isUnlocked,
            isLast: false,
            messageBox: groupData.group.isUnlocked
                ? 'Group threshold reached. Order is being processed.'
                : 'Need ${groupData.group.seuilMin - groupData.group.compteurActuel} more members to unlock group price.',
          ),
          _StatusTimeline(
            title: 'Delivered',
            subtitle: 'Estimated: -',
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;
  final String? messageBox;

  const _StatusTimeline({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isActive = false,
    required this.isLast,
    this.messageBox,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? _primaryContainer
                    : (isActive ? Colors.white : const Color(0xFFF6DED2)),
                border: isActive ? Border.all(color: _primaryContainer, width: 2) : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : (isActive
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primaryContainer,
                            ),
                          ),
                        )
                      : const Icon(Icons.local_shipping_outlined,
                          color: Color(0xFF584236), size: 12)),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: messageBox != null ? 100 : 40,
                color: isCompleted || isActive ? _primaryContainer : const Color(0xFFF6DED2),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: isActive ? _primaryContainer : (isCompleted ? _onBackground : _onSurfaceVariant),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: _onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (messageBox != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE3D8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    messageBox!,
                    style: GoogleFonts.inter(
                      color: _onBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
