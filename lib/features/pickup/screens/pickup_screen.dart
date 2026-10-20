import 'package:flutter/material.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/design_kit.dart';

/// Prototype screen (not yet wired to Supabase) — restyled to match the
/// Maamora Ambassador design system: same colors, same rounded cards,
/// same icons and badges as the rest of the app.
class PickupScreen extends StatelessWidget {
  const PickupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SharedAppBar(pageTitle: 'Pickup'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SectionCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: const Color(0xFFFFF0E3), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Truck arriving', style: GoogleFonts.cairo(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                          const SizedBox(height: 2),
                          Text('Sat · 10:00 — 23 orders', style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text("Today's handoffs", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _OrderRow(name: 'Hiba', item: 'Olive oil 5L', id: 'M-2049', status: 'ready'),
                  _OrderRow(name: 'Soufiane', item: 'Couscous 2kg', id: 'M-2050', status: 'ready'),
                  _OrderRow(name: 'Amal', item: 'Argan soap', id: 'M-2051', status: 'picked up', isPicked: true),
                  _OrderRow(name: 'Karim', item: 'Mint tea', id: 'M-2052', status: 'ready'),
                  _OrderRow(name: 'Salma', item: 'Olive oil 5L', id: 'M-2053', status: 'no-show', isNoShow: true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: AppButton(label: 'Print list', variant: AppButtonVariant.outlined, onPressed: () {})),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: AppButton(label: 'Close pickup', trailingIcon: Icons.arrow_forward, onPressed: () {})),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.name,
    required this.item,
    required this.id,
    required this.status,
    this.isPicked = false,
    this.isNoShow = false,
  });
  final String name;
  final String item;
  final String id;
  final String status;
  final bool isPicked;
  final bool isNoShow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isPicked ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: isPicked ? AppColors.primary : AppColors.cardBorder, width: 1.4),
              ),
              child: isPicked ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$name · $item', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text('$id · ', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                      Text(
                        status,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isNoShow ? AppColors.error : (isPicked ? const Color(0xFF2E7D32) : AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isPicked)
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF0E3),
                ),
                child: Icon(isNoShow ? Icons.notifications_active_outlined : Icons.call_outlined, size: 16, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
