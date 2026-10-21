import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/components/app_glass_dialog.dart';
import '../../core/components/app_toast.dart';
import '../../core/components/category_icons.dart';
import '../../core/components/fun_widgets.dart';
import '../../core/database/finance_repository.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import 'add_category_sheet.dart';

const _defaultExpenseCats = {
  'makanan',
  'transport',
  'belanja',
  'tagihan',
  'hiburan',
  'kesehatan',
  'lainnya',
};

const _defaultIncomeCats = {
  'gaji',
  'bonus',
  'investasi',
  'penjualan',
  'lainnya',
};

/// Halaman manajemen kategori untuk melihat daftar, menambah kategori kustom,
/// dan menghapus kategori kustom.
class CategoriesManagePage extends StatefulWidget {
  final int initialTab; // 0: Pengeluaran, 1: Pemasukan

  const CategoriesManagePage({super.key, this.initialTab = 0});

  @override
  State<CategoriesManagePage> createState() => _CategoriesManagePageState();
}

class _CategoriesManagePageState extends State<CategoriesManagePage> {
  late int _selectedTab = widget.initialTab;

  FinanceRepository get _repo => getIt<FinanceRepository>();

  bool _isDefaultCategory(CategoryView cat) {
    final lower = cat.name.trim().toLowerCase();
    if (cat.type == 'income') {
      return _defaultIncomeCats.contains(lower);
    }
    return _defaultExpenseCats.contains(lower);
  }

  Future<void> _deleteCategory(CategoryView cat) async {
    final confirmed = await AppGlassDialog.show(
      context: context,
      icon: Icons.delete_outline_rounded,
      title: 'Hapus "${cat.name}"?',
      message:
          'Kategori ini akan dihapus dari daftar pilihan. Riwayat transaksi lama yang memakai kategori ini tetap aman.',
      confirmLabel: 'Hapus',
      isDestructive: true,
    );

    if (confirmed == true) {
      await _repo.deleteCategory(cat.id);
      if (mounted) {
        AppToast.showSuccess(context, 'Kategori "${cat.name}" dihapus');
      }
    }
  }

  Future<void> _openAddCategory() async {
    final type = _selectedTab == 0 ? 'expense' : 'income';
    await AddCategorySheet.show(context, initialType: type);
  }

  @override
  Widget build(BuildContext context) {
    final currentType = _selectedTab == 0 ? 'expense' : 'income';
    final activeThemeColor =
        _selectedTab == 0 ? AppColors.expense : AppColors.income;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: GlassPage(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  FunRoundButton(
                    Icons.arrow_back_rounded,
                    size: 40,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: FunPageHeader(
                      title: 'Atur Kategori',
                      subtitle: 'Kelola & tambah kategori kustom',
                    ),
                  ),
                  FunRoundButton(
                    Icons.add_rounded,
                    size: 40,
                    onTap: _openAddCategory,
                  ),
                ],
              ),
            ),

            // Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: FunTabs(
                  labels: const ['Pengeluaran', 'Pemasukan'],
                  selected: _selectedTab,
                  onChanged: (i) => setState(() => _selectedTab = i),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category Stream List
            Expanded(
              child: StreamBuilder<List<CategoryView>>(
                stream: _repo.watchCategories(currentType),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? const <CategoryView>[];

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                      await Future.delayed(const Duration(milliseconds: 300));
                    },
                    child: categories.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: SizedBox(
                              height: 350,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      size: 48,
                                      color: AppColors.inkMuted.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Belum ada kategori',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.inkSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Tekan tombol + di atas untuk menambah',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isDefault = _isDefaultCategory(cat);

                      return FunCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: activeThemeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              child: Icon(
                                categoryIcon(cat.icon),
                                size: 22,
                                color: activeThemeColor,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.inkPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDefault
                                              ? glassFill(context)
                                              : activeThemeColor
                                                  .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                        child: Text(
                                          isDefault ? 'Bawaan' : 'Kustom',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isDefault
                                                ? AppColors.inkMuted
                                                : activeThemeColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (!isDefault)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: AppColors.expense,
                                ),
                                tooltip: 'Hapus kategori',
                                onPressed: () => _deleteCategory(cat),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              gradient: AppColors.glassSheetGradient,
              border: const Border(
                top: BorderSide(color: Colors.white, width: 1.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: GestureDetector(
                onTap: _openAddCategory,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0x66FFFFFF),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332563EB),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tambah Kategori ${_selectedTab == 0 ? 'Pengeluaran' : 'Pemasukan'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
