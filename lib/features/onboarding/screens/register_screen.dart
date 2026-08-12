// features/onboarding/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/navigation/app_routes.dart';

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
    });

    final isValid = await ref.read(authProvider.notifier).checkInviteCode(code);

    if (!mounted) return;
    setState(() {
      _isCheckingCode = false;
      if (isValid) {
        _isCodeValidated = true;
      } else {
        _codeError = 'Code invalide, expiré ou déjà utilisé.';
      }
    });
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
        const SnackBar(
          content: Text('Veuillez accepter les conditions NDA.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    setState(() => _isActivating = true);
    
    try {
      await ref.read(authProvider.notifier).registerAmbassador(
        fullName: name,
        phone: '+212$phone',
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
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
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
      backgroundColor: const Color(0xFFFAF4EE),
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
          'Activate your account',
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
            Text(
              'Enter your details and invite code below',
              style: AppTheme.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
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
          color: const Color(0xFFFDF0E4), // Orange clair
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Validated Invite: ${_codeController.text.trim()}',
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
        _buildFieldLabel('Invite Code'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _codeController,
                hint: 'e.g. SALE-7F3K',
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
                    : const Text('Vérifier'),
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
            _buildFieldLabel('Full Name (as on ID)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Fatima Zahra',
              icon: Icons.person_outline,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('Phone Number'),
            const SizedBox(height: 8),
            _buildPhoneInput(),
            const SizedBox(height: 20),
            _buildFieldLabel('City or Neighborhood (Douar)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _cityController,
              hint: 'e.g., Salé, Tabriquet',
              icon: Icons.location_on_outlined,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('Preferred Payout Method'),
            const SizedBox(height: 8),
            _buildPayoutDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DFDA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF0E9E2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                bottomLeft: Radius.circular(11),
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
              onChanged: (_) => setState(() {}),
              style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: '6 XX XX XX XX',
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
        border: Border.all(color: const Color(0xFFE5DFDA)),
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
        border: Border.all(color: const Color(0xFFE5DFDA)),
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
                'Select method...',
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Connecté avec Google',
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
          side: BorderSide(color: canSignIn ? const Color(0xFFDDD5CC) : Colors.grey.shade300),
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
                    'Se connecter avec Google',
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF4EE),
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
                    color: Color(0xFFCFC7BE),
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
                    children: const [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Ambassador NDA Terms',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' and commit to keeping community deals confidential.',
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Activate my account',
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
            child: const Text('J\'ai déjà un compte'),
          ),
        ],
      ),
    );
  }
}
