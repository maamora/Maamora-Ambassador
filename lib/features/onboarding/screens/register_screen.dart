// features/onboarding/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    super.key,
    this.onActivateSuccess,
    this.onGoToLogin,
    this.initialInviteCode,
  });

  final VoidCallback? onActivateSuccess;
  final VoidCallback? onGoToLogin;
  final String? initialInviteCode;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _codeController = TextEditingController();

  String? _selectedPayout;
  bool _ndaAccepted = false;
  bool _isActivating = false;
  bool _isCheckingCode = false;
  bool _isCodeValidated = false;
  String? _codeError;

  final List<String> _payoutMethods = [
    'CIH Bank',
    'Attijari wafabank',
    'Banque Populaire',
    'BMCE Bank',
    'Cash (en main propre)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialInviteCode != null) {
      _codeController.text = widget.initialInviteCode!;
    }
    _restoreFormData();
  }

  Future<void> _restoreFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('reg_name') ?? _nameController.text;
      _phoneController.text = prefs.getString('reg_phone') ?? _phoneController.text;
      _cityController.text = prefs.getString('reg_city') ?? _cityController.text;
      _codeController.text = prefs.getString('reg_code') ?? _codeController.text;
      _selectedPayout = prefs.getString('reg_payout') ?? _selectedPayout;
      _ndaAccepted = prefs.getBool('reg_nda') ?? _ndaAccepted;
      _isCodeValidated = prefs.getBool('reg_code_valid') ?? _isCodeValidated;
    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reg_name', _nameController.text.trim());
    await prefs.setString('reg_phone', _phoneController.text.trim());
    await prefs.setString('reg_city', _cityController.text.trim());
    await prefs.setString('reg_code', _codeController.text.trim());
    if (_selectedPayout != null) {
      await prefs.setString('reg_payout', _selectedPayout!);
    }
    await prefs.setBool('reg_nda', _ndaAccepted);
    await prefs.setBool('reg_code_valid', _isCodeValidated);
  }

  Future<void> _clearFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reg_name');
    await prefs.remove('reg_phone');
    await prefs.remove('reg_city');
    await prefs.remove('reg_code');
    await prefs.remove('reg_payout');
    await prefs.remove('reg_nda');
    await prefs.remove('reg_code_valid');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isCheckingCode = true;
      _codeError = null;
      _isCodeValidated = false;
    });

    try {
      final dynamic result = await Supabase.instance.client
          .rpc('verify_invite_code_status', params: {'p_code': code});

      if (!mounted) return;

      // Le RPC peut renvoyer : null (introuvable), une ligne (Map), une liste
      // de lignes, un statut scalaire (String) ou un booléen — tout gérer.
      Map<String, dynamic>? row;
      String? status;
      DateTime? expiresAt;

      dynamic unwrap(dynamic r) {
        if (r is List) return r.isEmpty ? null : r.first;
        return r;
      }

      final data = unwrap(result);
      if (data == null) {
        setState(() {
          _isCheckingCode = false;
          _codeError = context.tr('reg_code_invalid');
        });
        return;
      } else if (data is Map) {
        row = Map<String, dynamic>.from(data);
        status = (row['status'] ?? row['code_status'])?.toString();
        final exp = row['expires_at']?.toString();
        if (exp != null && exp != 'null') expiresAt = DateTime.tryParse(exp);
      } else if (data is String) {
        status = data;
      } else if (data is bool) {
        status = data ? 'unused' : 'invalid';
      } else {
        status = data.toString();
      }

      // Statut effectif : un code « unused » dont la date est passée est expiré.
      var effective = (status ?? '').toLowerCase();
      if ((effective == 'unused' || effective == 'available' || effective.isEmpty) &&
          expiresAt != null &&
          DateTime.now().isAfter(expiresAt)) {
        effective = 'expired';
      }

      switch (effective) {
        case 'unused':
        case 'available':
        case 'valid':
        case 'active':
          setState(() {
            _isCheckingCode = false;
            _isCodeValidated = true;
          });
          return;
        case 'expired':
          setState(() {
            _isCheckingCode = false;
            _codeError = context.tr('reg_code_expired');
          });
          return;
        case 'invalid':
        case '':
          setState(() {
            _isCheckingCode = false;
            _codeError = context.tr('reg_code_invalid');
          });
          return;
        default:
          // used, revoked, etc.
          setState(() {
            _isCheckingCode = false;
            _codeError = context.tr('reg_code_used');
          });
          return;
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('[RegisterScreen] _verifyCode error: $e');
      // Afficher la VRAIE erreur (RLS, RPC absente, réseau…) au lieu d'un
      // message générique qui masquait la cause réelle.
      setState(() {
        _isCheckingCode = false;
        _codeError = context.tr('common_error', args: {'e': e.toString()});
      });
    }
  }

  void _handleGoogleSignIn() async {
    await _saveFormData(); // Save form before redirecting
    await ref.read(authProvider.notifier).signInWithGoogle(isRegister: true);
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }

  void _handleActivate() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();
    final code = _codeController.text.trim();

    if (!_ndaAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('reg_accept_nda')),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    setState(() => _isActivating = true);

    // Normalisation : chiffres seuls, sans espaces ; un « 0 » de tête
    // (0612345678) est retiré car +212 le remplace → +212612345678.
    var phoneDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.length == 10 && phoneDigits.startsWith('0')) {
      phoneDigits = phoneDigits.substring(1);
    }

    try {
      await ref.read(authProvider.notifier).registerAmbassador(
        fullName: name,
        phone: '+212$phoneDigits',
        city: city,
        inviteCode: code,
      );
      if (!mounted) return;
      await _clearFormData();
      widget.onActivateSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isActivating = false);
      }
    }
  }

  bool _isFormComplete() {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return _nameController.text.trim().isNotEmpty &&
        digits.length == 10 &&
        _cityController.text.trim().isNotEmpty &&
        _selectedPayout != null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.status != AmbassadorStatus.initial &&
        authState.status != AmbassadorStatus.unauthenticated;
    final isGoogleLoading = authState.isLoading;

    // Condition to enable Google button
    final canSignInGoogle = _isCodeValidated && _ndaAccepted;
    // Condition to enable Activate button
    final canActivate = _isCodeValidated && _isFormComplete() && _ndaAccepted && isAuthenticated;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        const SizedBox(height: 24),
                        _buildCodeSection(),
                        const SizedBox(height: 24),
                        _buildFormFields(),
                        const SizedBox(height: 24),
                        _buildGoogleButton(canSignInGoogle, isAuthenticated, isGoogleLoading),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildBottomSection(canActivate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('reg_title'),
          style: AppTheme.headlineXl.copyWith(
            color: AppColors.secondary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.lock_outline,
              size: 15,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                context.tr('reg_sub'),
                style: AppTheme.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCodeSection() {
    if (_isCodeValidated) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MaamoraColors.primarySoft, // Orange clair
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('reg_code_valid', args: {'code': _codeController.text.trim()}),
                style: AppTheme.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context.tr('reg_code_lbl')),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _codeController,
                hint: context.tr('reg_code_hint'),
                icon: Icons.card_giftcard_outlined,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 54, // Same height as text field
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _isCheckingCode ? null : _verifyCode,
                child: _isCheckingCode
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(context.tr('reg_verify')),
              ),
            ),
          ],
        ),
        if (_codeError != null) ...[
          const SizedBox(height: 8),
          Text(
            _codeError!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ]
      ],
    );
  }

  Widget _buildFormFields() {
    // Disable form fields if code is not validated yet to force code validation first (optional but good UX)
    return Opacity(
      opacity: _isCodeValidated ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !_isCodeValidated,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel(context.tr('reg_name_lbl')),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: context.tr('reg_name_hint'),
              icon: Icons.person_outline,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel(context.tr('reg_phone_lbl')),
            const SizedBox(height: 8),
            _buildPhoneInput(),
            const SizedBox(height: 20),
            _buildFieldLabel(context.tr('reg_city_lbl')),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _cityController,
              hint: context.tr('reg_city_hint'),
              icon: Icons.location_on_outlined,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel(context.tr('reg_payout_lbl')),
            const SizedBox(height: 8),
            _buildPayoutDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final isPhoneValid = digits.length == 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: digits.isNotEmpty && !isPhoneValid
                  ? Colors.red
                  : MaamoraColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: const BoxDecoration(
                  color: MaamoraColors.surfaceLow,
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(11),
                    bottomStart: Radius.circular(11),
                  ),
                ),
                child: Text(
                  '+212',
                  style: AppTheme.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  // Chiffres uniquement, 10 max (ex : 0612345678).
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (_) => setState(() {}),
                  style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: context.tr('reg_phone_hint'),
                    hintStyle: AppTheme.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (digits.isNotEmpty && !isPhoneValid) ...[
          const SizedBox(height: 6),
          Text(
            context.tr('reg_phone_err'),
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTheme.labelMd.copyWith(
        color: AppColors.secondary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MaamoraColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPayoutDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MaamoraColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPayout,
          isExpanded: true,
          hint: Row(
            children: [
              const Icon(
                Icons.credit_card_outlined,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('reg_payout_hint'),
                style: AppTheme.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.onSurfaceVariant,
          ),
          style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
          items: _payoutMethods.map((method) {
            return DropdownMenuItem<String>(
              value: method,
              child: Text(method),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedPayout = val;
            });
          },
        ),
      ),
    );
  }

  Widget _buildGoogleButton(bool canSignIn, bool isAuthenticated, bool isLoading) {
    if (isAuthenticated) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              context.tr('reg_google_connected'),
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: canSignIn ? MaamoraColors.borderStrong : Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: canSignIn && !isLoading ? _handleGoogleSignIn : null,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.g_mobiledata,
                    size: 28,
                    color: canSignIn ? AppColors.secondary : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('reg_google_btn'),
                    style: AppTheme.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: canSignIn ? AppColors.secondary : Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomSection(bool canActivate) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          // NDA checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _ndaAccepted,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(
                    color: MaamoraColors.textFaint,
                    width: 1.5,
                  ),
                  onChanged: (val) {
                    setState(() => _ndaAccepted = val ?? false);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: context.tr('reg_nda_iagree')),
                      TextSpan(
                        text: context.tr('reg_nda_link'),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: context.tr('reg_nda_commit'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Activate button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canActivate
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.55),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: canActivate && !_isActivating ? _handleActivate : null,
              child: _isActivating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('reg_submit'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onGoToLogin,
            child: Text(context.tr('reg_have_account')),
          ),
        ],
      ),
    );
  }
}
