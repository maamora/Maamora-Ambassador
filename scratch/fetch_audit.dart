import 'dart:io';
import 'package:supabase/supabase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY']!;
  final client = SupabaseClient(supabaseUrl, supabaseKey);

  final response = await client.from('admin_audit_log').select('*').limit(5);
  print(response);
  exit(0);
}
