// features/onboarding/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
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
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _codeController = TextEditingController();

  String? _selectedPayout;
  bool _ndaAccepted = false;
  bool _isActivating = false;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _handleActivate() {
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
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isActivating = false);
      widget.onActivateSuccess?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        _buildFormFields(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildBottomSection(),
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

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Invite Code'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _codeController,
          hint: 'e.g. SALE-7F3K',
          icon: Icons.card_giftcard_outlined,
        ),
        const SizedBox(height: 20),
        _buildFieldLabel('Full Name (as on ID)'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nameController,
          hint: 'Fatima Zahra',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _buildFieldLabel('Phone Number'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _phoneController,
          hint: 'e.g., +212 600 000 000',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildFieldLabel('City or Neighborhood (Douar)'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _cityController,
          hint: 'e.g., Salé, Tabriquet',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 20),
        _buildFieldLabel('Preferred Payout Method'),
        const SizedBox(height: 8),
        _buildPayoutDropdown(),
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
          onChanged: (val) => setState(() => _selectedPayout = val),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
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
                  onChanged: (val) =>
                      setState(() => _ndaAccepted = val ?? false),
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
                        text:
                            ' and commit to keeping community deals confidential.',
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
                backgroundColor: _ndaAccepted
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.55),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isActivating ? null : _handleActivate,
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
        ],
      ),
    );
  }
}
