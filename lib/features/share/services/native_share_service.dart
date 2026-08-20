import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class NativeShareService {
  /// Shares a product referral link with custom text to social media/messaging apps
  static Future<void> shareReferralLink({
    required String productName,
    required String referralUrl,
    String? customMessage,
  }) async {
    final message = customMessage ??
        'Découvrez $productName sur Maamora ! Utilisez mon lien exclusif : $referralUrl';
    
    await Share.share(
      message,
      subject: 'Recommandation Maamora : $productName',
    );
  }

  /// Shares a custom invitation message (e.g. WhatsApp)
  static Future<void> shareCustomMessage({
    required String message,
    String? subject,
  }) async {
    await Share.share(
      message,
      subject: subject ?? 'Maamora - Rejoignez mon groupe',
    );
  }

  /// Copies referral URL to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
