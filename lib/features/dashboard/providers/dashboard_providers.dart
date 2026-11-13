import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';

/// Wallet balance for the dashboard hero card. A provider (instead of calling
/// Supabase inside a widget) gives loading/error states and pull-to-refresh.
final walletBalanceProvider = FutureProvider.autoDispose<double>((ref) {
  return supabaseService.getMyWalletBalance();
});
