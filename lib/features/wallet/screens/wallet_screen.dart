import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Placeholder screen for the Wallet tab — to be implemented in a future batch.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F0),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Color(0xFFFB7701),
              ),
              const SizedBox(height: 16),
              Text(
                'Wallet',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A2433),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8A8078),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
