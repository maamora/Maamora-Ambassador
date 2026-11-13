import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../models/models.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

class MoroccanBank {
  final String name;
  final String code; // 3-digit prefix
  final String shortName;

  const MoroccanBank({
    required this.name,
    required this.code,
    required this.shortName,
  });
}

List<MoroccanBank> kMoroccanBanks = [
  MoroccanBank(name: 'CIH Bank', code: '230', shortName: 'CIH'),
  MoroccanBank(name: 'Attijariwafa bank', code: '007', shortName: 'Attijari'),
  MoroccanBank(name: 'Banque Populaire (BCP)', code: '181', shortName: 'BCP'),
  MoroccanBank(name: 'Bank of Africa (BMCE)', code: '011', shortName: 'BOA'),
  MoroccanBank(name: 'Al Barid Bank', code: '350', shortName: 'Barid Bank'),
  MoroccanBank(name: 'Société Générale Maroc', code: '021', shortName: 'SGMB'),
  MoroccanBank(name: 'BMCI (BNP Paribas)', code: '013', shortName: 'BMCI'),
  MoroccanBank(name: 'Crédit du Maroc', code: '022', shortName: 'CDM'),
  MoroccanBank(name: 'Crédit Agricole du Maroc', code: '225', shortName: 'CAM'),
  MoroccanBank(name: 'CFG Bank', code: '050', shortName: 'CFG'),
  MoroccanBank(name: 'Umnia Bank', code: '101', shortName: 'Umnia'),
  MoroccanBank(name: 'Bank Assafa', code: '103', shortName: 'Assafa'),
  MoroccanBank(name: 'Autre banque', code: '999', shortName: 'Autre'),
];

const List<String> kCashPickupProviders = [
  'Wafacash',
  'Cash Plus',
  'Barid Cash',
  'Al Barid Bank (Mise à disposition)',
  'Canal M',
];

class PayoutMethodBottomSheet extends ConsumerStatefulWidget {
  final Ambassador ambassador;

  const PayoutMethodBottomSheet({
    super.key,
    required this.ambassador,
  });

  static Future<void> show({
    required BuildContext context,
    required Ambassador ambassador,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PayoutMethodBottomSheet(ambassador: ambassador),
    );
  }

  @override
  ConsumerState<PayoutMethodBottomSheet> createState() => _PayoutMethodBottomSheetState();
}

class _PayoutMethodBottomSheetState extends ConsumerState<PayoutMethodBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final TextEditingController _ribController;
  late final TextEditingController _bankAccountHolderController;
  late final TextEditingController _cashRecipientController;
  late final TextEditingController _cinController;
  late final TextEditingController _cashAgencyNoteController;

  MoroccanBank? _selectedBank;
  String _selectedCashProvider = kCashPickupProviders.first;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final isCash = widget.ambassador.payoutMethod == 'cash_pickup';
    _tabController = TabController(length: 2, vsync: this, initialIndex: isCash ? 1 : 0);

    // Initial values from ambassador
    final initialRibDigits = _extractDigits(widget.ambassador.payoutBankRib ?? '');
    _ribController = TextEditingController(text: _formatRib(initialRibDigits));
    _bankAccountHolderController = TextEditingController(text: widget.ambassador.fullName);
    
    // Parse cash pickup details if present
    final cashDetails = widget.ambassador.payoutCashPoint ?? '';
    _cashRecipientController = TextEditingController(text: widget.ambassador.fullName);
    _cinController = TextEditingController(text: _parseCin(cashDetails));
    _cashAgencyNoteController = TextEditingController(text: _parseNote(cashDetails));
    _selectedCashProvider = _parseProvider(cashDetails) ?? kCashPickupProviders.first;

    // Detect bank from RIB prefix or default
    if (initialRibDigits.length >= 3) {
      _detectAndSetBank(initialRibDigits);
    } else {
      _selectedBank = kMoroccanBanks.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ribController.dispose();
    _bankAccountHolderController.dispose();
    _cashRecipientController.dispose();
    _cinController.dispose();
    _cashAgencyNoteController.dispose();
    super.dispose();
  }

  String _extractDigits(String text) {
    return text.replaceAll(RegExp(r'\D'), '');
  }

  String _formatRib(String rawDigits) {
    final digits = _extractDigits(rawDigits);
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 24; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  void _detectAndSetBank(String rawDigits) {
    final digits = _extractDigits(rawDigits);
    if (digits.length >= 3) {
      final prefix = digits.substring(0, 3);
      final match = kMoroccanBanks.where((b) => b.code == prefix);
      if (match.isNotEmpty) {
        setState(() {
          _selectedBank = match.first;
        });
        return;
      }
    }
  }

  String _parseCin(String cashDetails) {
    final reg = RegExp(r'CIN:\s*([A-Za-z0-9]+)', caseSensitive: false);
    final match = reg.firstMatch(cashDetails);
    return match?.group(1) ?? '';
  }

  String _parseNote(String cashDetails) {
    final reg = RegExp(r'Agence:\s*(.+)$', caseSensitive: false);
    final match = reg.firstMatch(cashDetails);
    return match?.group(1)?.trim() ?? '';
  }

  String? _parseProvider(String cashDetails) {
    for (final p in kCashPickupProviders) {
      if (cashDetails.toLowerCase().contains(p.toLowerCase())) {
        return p;
      }
    }
    return null;
  }

  void _onRibChanged(String value) {
    final rawDigits = _extractDigits(value);
    if (rawDigits.length > 24) {
      final truncated = rawDigits.substring(0, 24);
      final formatted = _formatRib(truncated);
      _ribController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      return;
    }

    _detectAndSetBank(rawDigits);
  }

  Future<void> _pasteRib() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text != null && text.isNotEmpty) {
        final rawDigits = _extractDigits(text);
        final digits = rawDigits.length > 24 ? rawDigits.substring(0, 24) : rawDigits;
        final formatted = _formatRib(digits);
        setState(() {
          _ribController.text = formatted;
          _detectAndSetBank(digits);
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final isBankTab = _tabController.index == 0;
    setState(() => _isSaving = true);

    try {
      if (isBankTab) {
        final ribDigits = _extractDigits(_ribController.text);
        if (ribDigits.length != 24) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(context.tr('payout_rib_len', args: {'n': ribDigits.length})),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          setState(() => _isSaving = false);
          return;
        }

        final bankName = _selectedBank?.name ?? 'Banque';
        final holder = _bankAccountHolderController.text.trim();
        final formattedRibValue = '$bankName - $ribDigits${holder.isNotEmpty ? ' ($holder)' : ''}';

        await ref.read(profileProvider.notifier).updateProfile(
          payoutMethod: 'bank',
          payoutBankRib: formattedRibValue,
          payoutCashPoint: null,
        );
      } else {
        // Cash Pickup
        final cin = _cinController.text.trim();
        final recipient = _cashRecipientController.text.trim();
        final note = _cashAgencyNoteController.text.trim();

        if (cin.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(context.tr('payout_cin_required')),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          setState(() => _isSaving = false);
          return;
        }

        final cashValue = '$_selectedCashProvider - ${recipient.isNotEmpty ? recipient : widget.ambassador.fullName} (CIN: $cin)${note.isNotEmpty ? ' - Agence: $note' : ''}';

        await ref.read(profileProvider.notifier).updateProfile(
          payoutMethod: 'cash_pickup',
          payoutBankRib: null,
          payoutCashPoint: cashValue,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(context.tr('payout_saved')),
              ],
            ),
            backgroundColor: MaamoraColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('common_error', args: {'e': e.toString()})),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _removePayoutMethod() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.tr('payout_delete_title'),
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.tr('payout_delete_msg'),
          style: GoogleFonts.cairo(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('payout_cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr('payout_delete_btn')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        await ref.read(profileProvider.notifier).updateProfile(
          payoutMethod: null,
          payoutBankRib: null,
          payoutCashPoint: null,
        );
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('payout_deleted')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('common_error', args: {'e': e.toString()})), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasExistingMethod = widget.ambassador.payoutMethod != null;
    final ribDigits = _extractDigits(_ribController.text);
    final isRibComplete = ribDigits.length == 24;

    return Container(
      constraints: BoxConstraints(
        // Adapts to the keyboard: the sheet (header included) always fits in
        // the space above the keyboard instead of being clipped at the top.
        maxHeight: MediaQuery.of(context).size.height - bottomInset - 32,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('payout_mode_title'),
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('payout_friday'),
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Method Tab Selector (RIB vs Cash Pickup)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_rounded, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            context.tr('payout_bank_tab'),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_atm_rounded, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            context.tr('payout_cash_tab'),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab views
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      if (_tabController.index == 0) {
                        return _buildBankTransferForm(ribDigits, isRibComplete);
                      } else {
                        return _buildCashPickupForm();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Security notice banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MaamoraColors.surfaceLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MaamoraColors.borderStrong),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: MaamoraColors.success,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.tr('payout_security_note'),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.tr('payout_save'),
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  if (hasExistingMethod) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        onPressed: _isSaving ? null : _removePayoutMethod,
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                        label: Text(
                          context.tr('payout_delete'),
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferForm(String ribDigits, bool isRibComplete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bank Selector
        Text(
          context.tr('payout_lbl_bank'),
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MoroccanBank>(
              value: _selectedBank,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
              items: kMoroccanBanks.map((bank) {
                return DropdownMenuItem<MoroccanBank>(
                  value: bank,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          bank.code != '999' ? bank.code : '•••',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          bank.code == '999'
                              ? context.tr('payout_bank_other')
                              : bank.name,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onBackground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (bank) {
                if (bank != null) {
                  setState(() => _selectedBank = bank);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Account Holder Name
        Text(
          context.tr('payout_lbl_holder'),
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: _bankAccountHolderController,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.tr('payout_holder_hint'),
              hintStyle: TextStyle(color: MaamoraColors.textFaint, fontSize: 13),
              icon: Icon(Icons.person_outline, size: 20, color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 24-digit RIB
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('payout_lbl_rib'),
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              '${ribDigits.length}/24',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isRibComplete ? AppColors.success : (ribDigits.isNotEmpty ? AppColors.primary : AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRibComplete
                  ? AppColors.success
                  : (ribDigits.isNotEmpty ? AppColors.primary : AppColors.cardBorder),
              width: isRibComplete || ribDigits.isNotEmpty ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ribController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                  ],
                  onChanged: (val) {
                    _onRibChanged(val);
                    setState(() {});
                  },
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '230 780 1234567890123456 78',
                    hintStyle: TextStyle(
                      color: MaamoraColors.disabledBorder,
                      fontSize: 13,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Paste button
              GestureDetector(
                onTap: _pasteRib,
                child: Tooltip(
                  message: context.tr('payout_paste_rib'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.content_paste_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('payout_paste'),
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.tr('payout_rib_hint'),
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCashPickupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Provider Dropdown
        Text(
          context.tr('payout_lbl_org'),
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCashProvider,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurfaceVariant),
              items: kCashPickupProviders.map((provider) {
                return DropdownMenuItem<String>(
                  value: provider,
                  child: Text(
                    provider,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCashProvider = val);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Recipient Full Name
        Text(
          context.tr('payout_lbl_name'),
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: _cashRecipientController,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.tr('payout_name_hint'),
              hintStyle: TextStyle(color: MaamoraColors.textFaint, fontSize: 13),
              icon: Icon(Icons.badge_outlined, size: 20, color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // CIN
        Text(
          context.tr('payout_lbl_cin'),
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: _cinController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              TextInputFormatter.withFunction((oldValue, newValue) =>
                  newValue.copyWith(text: newValue.text.toUpperCase())),
            ],
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.tr('payout_cin_hint'),
              hintStyle: TextStyle(color: MaamoraColors.textFaint, fontSize: 13),
              icon: Icon(Icons.credit_card_rounded, size: 20, color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Agency Note / City
        Text(
          context.tr('payout_lbl_city'),
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: _cashAgencyNoteController,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: context.tr('payout_city_hint'),
              hintStyle: TextStyle(color: MaamoraColors.textFaint, fontSize: 13),
              icon: Icon(Icons.location_on_outlined, size: 20, color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}
