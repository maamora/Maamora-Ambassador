import 'package:flutter/material.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/theme/app_colors.dart';
import '../providers/my_groups_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../design_system/design_system.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(myGroupsProvider.notifier)
          .createGroup(
            productName: _nameController.text.trim(),
            productDescription: _descController.text.trim(),
            pricePerPerson: double.parse(_priceController.text.trim()),
            seatsTotal: int.parse(_seatsController.text.trim()),
          );
      if (mounted) {
        // Toast in the root overlay survives the pop.
        MaamoraToast.success(context, context.tr('cg_created'));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        MaamoraToast.error(
          context,
          context.tr('common_error', args: {'e': e.toString()}),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Required + must parse exactly like `_submit` does (same parser), so the
  /// error shows under the field instead of failing after the tap.
  String? _requiredNumber(String? val, {required bool integer}) {
    if (val == null || val.isEmpty) return context.tr('cg_required');
    final ok = integer
        ? int.tryParse(val.trim()) != null
        : double.tryParse(val.trim()) != null;
    return ok ? null : context.tr('cg_invalid_number');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaamoraColors.scaffold,
      appBar: SharedAppBar(pageTitle: context.tr('cg_title')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MaamoraSpacing.screen),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('cg_details'),
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.tr('cg_product_name'),
                ),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                validator: (val) => (val == null || val.isEmpty)
                    ? context.tr('cg_required')
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: context.tr('cg_product_desc'),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (val) => (val == null || val.isEmpty)
                    ? context.tr('cg_required')
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: context.tr('cg_price'),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (val) => _requiredNumber(val, integer: false),
                    ),
                  ),
                  const SizedBox(width: MaamoraSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _seatsController,
                      decoration: InputDecoration(
                        labelText: context.tr('cg_seats'),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) _submit();
                      },
                      validator: (val) => _requiredNumber(val, integer: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MaamoraSpacing.xl),
              AppButton(
                label: context.tr('cg_title'),
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
