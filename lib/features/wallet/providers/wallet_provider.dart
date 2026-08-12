import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../models/models.dart';

class WalletData {
  final double balance;
  final List<Commission> commissions;
  final List<Payout> payouts;

  WalletData({
    required this.balance,
    required this.commissions,
    required this.payouts,
  });
}

final walletProvider = AsyncNotifierProvider<WalletNotifier, WalletData>(WalletNotifier.new);

class WalletNotifier extends AsyncNotifier<WalletData> {
  @override
  Future<WalletData> build() => _fetch();

  Future<WalletData> _fetch() async {
    final balance = await supabaseService.getMyWalletBalance();
    final commissions = await supabaseService.getMyCommissions();
    final payouts = await supabaseService.getMyPayouts();

    return WalletData(
      balance: balance,
      commissions: commissions,
      payouts: payouts,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}
