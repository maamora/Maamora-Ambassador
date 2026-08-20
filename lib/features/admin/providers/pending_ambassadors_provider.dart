import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final pendingAmbassadorsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final res = await Supabase.instance.client
      .from('ambassadors')
      .select('id')
      .eq('status', 'pending');
  return (res as List).length;
});
