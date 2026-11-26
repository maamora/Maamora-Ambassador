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
      _nameController.text =
          prefs.getString('reg_name') ?? _nameController.text;
      _phoneController.text =
          prefs.getString('reg_phone') ?? _phoneController.text;
      _cityController.text =
          prefs.getString('reg_city') ?? _cityController.text;
      _codeController.text =
          prefs.getString('reg_code') ?? _codeController.text;
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
      final dynamic result = await Supabase.instance.client.rpc(
        'verify_invite_code_status',
        params: {'p_code': code},
      );

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
      if ((effective == 'unused' ||
              effective == 'available' ||
              effective.isEmpty) &&
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
      MaamoraToast.error(context, authState.errorMessage!);
    }
  }

  void _handleActivate() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();
    final code = _codeController.text.trim();

    if (!_ndaAccepted) {
      MaamoraToast.info(context, context.tr('reg_accept_nda'));
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
      await ref
          .read(authProvider.notifier)
          .registerAmbassador(
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
      MaamoraToast.error(context, e.toString());
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
    final isAuthenticated =
        authState.status != AmbassadorStatus.initial &&
        authState.status != AmbassadorStatus.unauthenticated;
    final isGoogleLoading = authState.isLoading;

    // Condition to enable Google button
    final canSignInGoogle = _isCodeValidated && _ndaAccepted;
    // Condition to enable Activate button
    final canActivate =
        _isCodeValidated &&
        _isFormComplete() &&
        _ndaAccepted &&
        isAuthenticated;

    // Presentation-only progress: derived from the existing gates above.
    final int step;
    if (!_isCodeValidated) {
      step = 1;
    } else if (!_isFormComplete()) {
      step = 2;
    } else if (!isAuthenticated) {
      step = 3;
    } else {
      step = 4;
    }

    return Scaffold(
      backgroundColor: MaamoraColors.scaffold,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MaamoraSpacing.xl,
                      vertical: MaamoraSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        const SizedBox(height: MaamoraSpacing.screen),
                        _RegisterSteps(step: step),
                        const SizedBox(height: MaamoraSpacing.xl),
                        _buildCodeSection(),
                        const SizedBox(height: 24),
                        _buildFormFields(),
                        const SizedBox(height: 24),
                        _buildGoogleButton(
                          canSignInGoogle,
                          isAuthenticated,
                          isGoogleLoading,
                        ),
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
        const SizedBox(height: MaamoraSpacing.sm),
        Row(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: MaamoraSpacing.sm),
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
      return Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(MaamoraSpacing.lg),
          decoration: BoxDecoration(
            color: MaamoraColors.successSoft,
            borderRadius: MaamoraRadius.inputR,
            border: Border.all(color: MaamoraColors.successEdge),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: MaamoraColors.success),
              const SizedBox(width: MaamoraSpacing.md),
              Expanded(
                child: Text(
                  context.tr(
                    'reg_code_valid',
                    args: {'code': _codeController.text.trim()},
                  ),
                  style: AppTheme.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MaamoraColors.successOn,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context.tr('reg_code_lbl')),
        const SizedBox(height: MaamoraSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _codeController,
                hint: context.tr('reg_code_hint'),
                icon: Icons.card_giftcard_outlined,
                hasError: _codeError != null,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_isCheckingCode) _verifyCode();
                },
              ),
            ),
            const SizedBox(width: MaamoraSpacing.md),
            SizedBox(
              height: 54, // Same height as text field
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: MaamoraColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: MaamoraRadius.inputR,
                  ),
                  elevation: 0,
                ),
                onPressed: _isCheckingCode ? null : _verifyCode,
                child: _isCheckingCode
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MaamoraColors.onPrimary,
                        ),
                      )
                    : Text(context.tr('reg_verify')),
              ),
            ),
          ],
        ),
        if (_codeError != null) ...[
          const SizedBox(height: MaamoraSpacing.sm),
          _InlineFieldError(message: _codeError!),
        ],
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
            const SizedBox(height: MaamoraSpacing.sm),
            _buildTextField(
              controller: _nameController,
              hint: context.tr('reg_name_hint'),
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: MaamoraSpacing.screen),
            _buildFieldLabel(context.tr('reg_phone_lbl')),
            const SizedBox(height: MaamoraSpacing.sm),
            _buildPhoneInput(),
            const SizedBox(height: MaamoraSpacing.screen),
            _buildFieldLabel(context.tr('reg_city_lbl')),
            const SizedBox(height: MaamoraSpacing.sm),
            _buildTextField(
              controller: _cityController,
              hint: context.tr('reg_city_hint'),
              icon: Icons.location_on_outlined,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: MaamoraSpacing.screen),
            _buildFieldLabel(context.tr('reg_payout_lbl')),
            const SizedBox(height: MaamoraSpacing.sm),
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
        AnimatedContainer(
          duration: MaamoraDurations.fast,
          decoration: BoxDecoration(
            color: MaamoraColors.surface,
            borderRadius: MaamoraRadius.inputR,
            border: Border.all(
              color: digits.isNotEmpty && !isPhoneValid
                  ? MaamoraColors.danger
                  : MaamoraColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MaamoraSpacing.md,
                  vertical: MaamoraSpacing.lg,
                ),
                decoration: const BoxDecoration(
                  color: MaamoraColors.surfaceLow,
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(MaamoraRadius.input - 1),
                    bottomStart: Radius.circular(MaamoraRadius.input - 1),
                  ),
                ),
                // The country code stays LTR even in Arabic.
                child: Text(
                  '+212',
                  textDirection: TextDirection.ltr,
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
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (digits.isNotEmpty && !isPhoneValid) ...[
          const SizedBox(height: MaamoraSpacing.sm),
          _InlineFieldError(message: context.tr('reg_phone_err')),
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
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool hasError = false,
  }) {
    return AnimatedContainer(
      duration: MaamoraDurations.fast,
      decoration: BoxDecoration(
        color: MaamoraColors.surface,
        borderRadius: MaamoraRadius.inputR,
        border: Border.all(
          color: hasError ? MaamoraColors.danger : MaamoraColors.border,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
          ),
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: MaamoraSpacing.lg,
            vertical: MaamoraSpacing.lg,
          ),
        ),
      ),
    );
  }

  Widget _buildPayoutDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: MaamoraColors.surface,
        borderRadius: MaamoraRadius.inputR,
        border: Border.all(color: MaamoraColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: MaamoraSpacing.md),
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
              const SizedBox(width: MaamoraSpacing.md),
              Flexible(
                child: Text(
                  context.tr('reg_payout_hint'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
                  ),
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
            return DropdownMenuItem<String>(value: method, child: Text(method));
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

  Widget _buildGoogleButton(
    bool canSignIn,
    bool isAuthenticated,
    bool isLoading,
  ) {
    if (isAuthenticated) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: MaamoraSpacing.lg),
        decoration: BoxDecoration(
          color: MaamoraColors.successSoft,
          borderRadius: MaamoraRadius.inputR,
          border: Border.all(color: MaamoraColors.successEdge),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: MaamoraColors.success),
            const SizedBox(width: MaamoraSpacing.sm),
            Flexible(
              child: Text(
                context.tr('reg_google_connected'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MaamoraColors.successOn,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          backgroundColor: MaamoraColors.surface,
          side: BorderSide(
            color: canSignIn
                ? MaamoraColors.borderStrong
                : MaamoraColors.disabledBg,
          ),
          shape: RoundedRectangleBorder(borderRadius: MaamoraRadius.inputR),
        ),
        onPressed: canSignIn && !isLoading ? _handleGoogleSignIn : null,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.g_mobiledata,
                    size: 28,
                    color: canSignIn
                        ? AppColors.secondary
                        : MaamoraColors.disabledFg,
                  ),
                  const SizedBox(width: MaamoraSpacing.sm),
                  Text(
                    context.tr('reg_google_btn'),
                    style: AppTheme.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: canSignIn
                          ? AppColors.secondary
                          : MaamoraColors.disabledFg,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomSection(bool canActivate) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        MaamoraSpacing.xl,
        MaamoraSpacing.lg,
        MaamoraSpacing.xl,
        MaamoraSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: MaamoraColors.surface,
        border: Border(top: BorderSide(color: MaamoraColors.border)),
      ),
      child: Column(
        children: [
          // NDA checkbox — the whole row is the tap target (≥ 48dp).
          MergeSemantics(
            child: InkWell(
              borderRadius: MaamoraRadius.inputR,
              onTap: () => setState(() => _ndaAccepted = !_ndaAccepted),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
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
                    const SizedBox(width: MaamoraSpacing.md),
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
                              style: const TextStyle(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: context.tr('reg_nda_commit')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: MaamoraSpacing.md),
          // Activate button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canActivate
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.55),
                foregroundColor: MaamoraColors.onPrimary,
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
                        color: MaamoraColors.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            context.tr('reg_submit'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: MaamoraColors.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: MaamoraSpacing.sm),
                        const Icon(
                          Icons.arrow_forward,
                          color: MaamoraColors.onPrimary,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: MaamoraSpacing.sm),
          TextButton(
            onPressed: widget.onGoToLogin,
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryText),
            child: Text(context.tr('reg_have_account')),
          ),
        ],
      ),
    );
  }
}

/// Error shown right under its field: icon + text, announced to readers.
class _InlineFieldError extends StatelessWidget {
  const _InlineFieldError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExcludeSemantics(
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: 2),
              child: Icon(
                Icons.error_outline_rounded,
                size: 16,
                color: MaamoraColors.danger,
              ),
            ),
          ),
          const SizedBox(width: MaamoraSpacing.xs + 2),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: MaamoraColors.danger,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Four-segment progress (Code → Infos → Google → Activation). Pure display:
/// the step is derived from the screen's existing gates, never stored.
class _RegisterSteps extends StatelessWidget {
  const _RegisterSteps({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final reduced = MaamoraMotion.reduced(context);
    return Semantics(
      label:
          '${context.tr('reg_step', args: {'n': step})}. ${context.tr('reg_step_$step')}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 1; i <= 4; i++) ...[
                if (i > 1) const SizedBox(width: MaamoraSpacing.xs + 2),
                Expanded(
                  child: AnimatedContainer(
                    duration: reduced ? Duration.zero : MaamoraDurations.normal,
                    curve: MaamoraMotion.standard,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step
                          ? MaamoraColors.primary
                          : MaamoraColors.border,
                      borderRadius: BorderRadius.circular(MaamoraRadius.chip),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: MaamoraSpacing.sm),
          AnimatedSwitcher(
            duration: reduced ? Duration.zero : MaamoraDurations.normal,
            child: Row(
              key: ValueKey(step),
              children: [
                Text(
                  context.tr('reg_step_$step'),
                  style: AppTheme.labelMd.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  context.tr('reg_step', args: {'n': step}),
                  style: AppTheme.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
