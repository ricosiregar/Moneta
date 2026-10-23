import 'package:flutter/material.dart';

import '../../core/components/app_glass_sheet.dart';
import '../../core/components/app_toast.dart';
import '../../core/components/category_icons.dart';
import '../../core/components/fun_widgets.dart';
import '../../core/database/finance_repository.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';

/// Modal bottom sheet untuk menambah kategori baru (kustom).
class AddCategorySheet extends StatefulWidget {
  final String initialType; // 'expense' or 'income'

  const AddCategorySheet({super.key, this.initialType = 'expense'});

  static Future<CategoryView?> show(
    BuildContext context, {
    String initialType = 'expense',
  }) {
    return AppGlassSheet.show<CategoryView>(
      context: context,
      builder: (_) => AddCategorySheet(initialType: initialType),
    );
  }

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _nameController = TextEditingController();
  late int _typeIndex = widget.initialType == 'income' ? 1 : 0;
  String _selectedIconKey = 'restaurant';
  bool _isSaving = false;

  String get _type => _typeIndex == 1 ? 'income' : 'expense';

  @override
  void initState() {
    super.initState();
    // Default icon sesuai tipe
    if (widget.initialType == 'income') {
      _selectedIconKey = 'wallet';
    } else {
      _selectedIconKey = 'restaurant';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppToast.showWarning(context, 'Masukkan nama kategori');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = getIt<FinanceRepository>();
      final newCat = await repo.addCategory(
        name: name,
        type: _type,
        icon: _selectedIconKey,
      );

      if (!mounted) return;
      Navigator.of(context).pop(newCat);
      AppToast.showSuccess(context, 'Kategori "$name" berhasil dibuat');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _typeIndex == 0;
    final activeColor =
        isExpense ? AppColors.expense : AppColors.income;

    return AppGlassSheet(
      title: 'Tambah Kategori Baru',
      subtitle: 'Pilih jenis dan ikon kategori',
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

              // Type Selector
              Center(
                child: FunTabs(
                  labels: const ['Pengeluaran', 'Pemasukan'],
                  selected: _typeIndex,
                  onChanged: (idx) {
                    setState(() {
                      _typeIndex = idx;
                      if (idx == 1 && _selectedIconKey == 'restaurant') {
                        _selectedIconKey = 'wallet';
                      } else if (idx == 0 && _selectedIconKey == 'wallet') {
                        _selectedIconKey = 'restaurant';
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Live Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.glassCardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.92),
                    width: 1.3,
                  ),
                  boxShadow: AppColors.glassShadowSoft,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        categoryIcon(_selectedIconKey),
                        color: activeColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.trim().isEmpty
                                ? 'Nama Kategori'
                                : _nameController.text.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _nameController.text.trim().isEmpty
                                  ? AppColors.inkMuted
                                  : AppColors.inkPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            child: Text(
                              isExpense ? 'Pengeluaran' : 'Pemasukan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: activeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name Input
              const FunLabel('Nama Kategori'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: glassFill(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Misal: Kopi, Skincare, Donasi, Bonus...',
                    hintStyle:
                        TextStyle(color: AppColors.inkMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: false,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Icon Picker Grid
              const FunLabel('Pilih Emote / Ikon'),
              const SizedBox(height: 10),
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: glassFill(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: kCategoryIconOptions.length,
                    itemBuilder: (context, idx) {
                      final opt = kCategoryIconOptions[idx];
                      final isSelected = opt.key == _selectedIconKey;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentBlue.withValues(alpha: 0.14)
                              : Colors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentBlue
                                : Colors.white.withValues(alpha: 0.9),
                            width: isSelected ? 2 : 1.1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedIconKey = opt.key),
                            borderRadius: BorderRadius.circular(14),
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Icon(
                                opt.icon,
                                size: 24,
                                color: isSelected
                                    ? AppColors.accentBlue
                                    : AppColors.inkSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opt.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.accentBlue
                                      : AppColors.inkSecondary,
                                ),
                              ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              GestureDetector(
                onTap: _isSaving ? null : _save,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _isSaving ? null : AppColors.primaryButtonGradient,
                    color: _isSaving ? AppColors.inkMuted : null,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0x66FFFFFF),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332563EB),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Kategori',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
