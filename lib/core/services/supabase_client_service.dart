// core/services/supabase_client_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static SupabaseClient get client => Supabase.instance.client;
}
