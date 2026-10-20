import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/components/app_glass_dialog.dart';
import '../../core/components/app_toast.dart';
import '../../core/components/fun_widgets.dart';
import '../../core/database/wallet_repository.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';

/// Formatter ribuan untuk input nominal rupiah.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = NumberFormat('#,###', 'id_ID').format(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Definisi ekosistem mitra perbankan digital.
class _EcosystemPartner {
  final String name;
  final String type; // 'e_wallet'
  final String purpose;
  const _EcosystemPartner(this.name, this.type, this.purpose);
}

const Map<String, List<_EcosystemPartner>> _bankEcosystems = {
  'Bank Jago': [
    _EcosystemPartner('GoPay', 'e_wallet', 'E-Wallet Gojek & Tokopedia'),
  ],
  'Superbank': [_EcosystemPartner('OVO', 'e_wallet', 'E-Wallet Grab & OVO')],
  'SeaBank': [_EcosystemPartner('ShopeePay', 'e_wallet', 'E-Wallet Shopee')],
};

const _bankPresets = [
  'Mandiri',
  'BCA',
  'BRI',
  'BNI',
  'SeaBank',
  'Bank Jago',
  'Superbank',
  'blu by BCA Digital',
];

const _eWalletPresets = ['ShopeePay', 'OVO', 'DANA', 'GoPay'];

/// Halaman penuh untuk Tambah atau Ubah Dompet.
class WalletFormPage extends StatefulWidget {
  final List<WalletView> all;
  final WalletView? editing;

  const WalletFormPage({super.key, required this.all, this.editing});

  @override
  State<WalletFormPage> createState() => _WalletFormPageState();
}

class _WalletFormPageState extends State<WalletFormPage> {
  WalletRepository get _repo => getIt<WalletRepository>();

  late final _nameCtrl = TextEditingController(
    text: widget.editing?.name ?? '',
  );
  late final _purposeCtrl = TextEditingController(
    text: widget.editing?.purpose ?? '',
  );
  late final _openingCtrl = TextEditingController(
    text: (widget.editing?.openingBalance ?? 0) == 0
        ? ''
        : NumberFormat(
            '#,###',
            'id_ID',
          ).format(widget.editing!.openingBalance.round()),
  );

  // 'cash' | 'bank' | 'e_wallet'
  late String _type = widget.editing?.type ?? 'bank';
  late bool _isParent =
      widget.editing?.parentId == null &&
      (widget.editing?.isIncomeSource ?? true);
  late String? _parentId = widget.editing?.parentId;

  // Selected ecosystem partners to auto-generate
  final Set<String> _selectedEcosystems = {};
  final Map<String, TextEditingController> _ecosystemOpeningCtrls = {};

  TextEditingController _getEcosystemOpeningCtrl(String name) {
    return _ecosystemOpeningCtrls.putIfAbsent(
      name,
      () => TextEditingController(),
    );
  }

  bool get _isEditing => widget.editing != null;

  bool get _hasChildren =>
      widget.editing != null &&
      widget.all.any((w) => w.parentId == widget.editing!.id);

  List<WalletView> get _parentOptions => widget.all
      .where((w) => w.parentId == null && w.id != widget.editing?.id)
      .toList();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _purposeCtrl.dispose();
    _openingCtrl.dispose();
    for (final ctrl in _ecosystemOpeningCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  double _parseAmount(String text) =>
      double.tryParse(text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

  void _onTypeChanged(String newType) {
    setState(() {
      _type = newType;
      _selectedEcosystems.clear();
      for (final ctrl in _ecosystemOpeningCtrls.values) {
        ctrl.clear();
      }
    });
  }

  void _selectPreset(String presetName) {
    setState(() {
      _nameCtrl.text = presetName;
      _selectedEcosystems.clear();
      for (final ctrl in _ecosystemOpeningCtrls.values) {
        ctrl.clear();
      }
      // Bila memilih bank ekosistem dan saat ini statusnya parent, beri opsi ekosistem
    });
  }

  List<_EcosystemPartner>? get _currentEcosystemPartners {
    final name = _nameCtrl.text.trim();
    for (final entry in _bankEcosystems.entries) {
      if (name.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _toast('Nama dompet wajib diisi');
      return;
    }

    if (!_isParent && _parentId == null && _parentOptions.isNotEmpty) {
      _toast('Pilih dompet parent terlebih dahulu');
      return;
    }

    final openingBal = _parseAmount(_openingCtrl.text);
    final purpose = _purposeCtrl.text.trim();
    final isIncome = _isParent;

    try {
      final partners = _currentEcosystemPartners;
      if (!_isEditing &&
          _isParent &&
          partners != null &&
          _selectedEcosystems.isNotEmpty) {
        final toCreate = partners
            .where((p) => _selectedEcosystems.contains(p.name))
            .map(
              (p) => (
                name: p.name,
                type: p.type,
                purpose: p.purpose,
                openingBalance: _parseAmount(
                  _ecosystemOpeningCtrls[p.name]?.text ?? '',
                ),
              ),
            )
            .toList();

        await _repo.saveWalletWithEcosystemChildren(
          id: widget.editing?.id,
          name: name,
          type: _type,
          parentId: null,
          purpose: purpose,
          isIncomeSource: isIncome,
          openingBalance: openingBal,
          ecosystemChildren: toCreate,
        );
      } else {
        await _repo.saveWallet(
          id: widget.editing?.id,
          name: name,
          type: _type,
          parentId: _isParent ? null : _parentId,
          purpose: purpose,
          isIncomeSource: isIncome,
          openingBalance: openingBal,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        AppToast.showSuccess(
          context,
          _isEditing
              ? 'Dompet berhasil diperbarui'
              : 'Dompet baru berhasil dibuat',
        );
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, e);
    }
  }

  Future<void> _delete() async {
    final ok = await AppGlassDialog.show(
      context: context,
      icon: Icons.delete_outline_rounded,
      title: 'Hapus Dompet Ini?',
      message:
          'Dompet akan disembunyikan. Dompet anak (jika ada) akan tetap aman dan berubah menjadi dompet biasa.',
      confirmLabel: 'Hapus',
      isDestructive: true,
    );

    if (ok != true || !mounted) return;
    await _repo.deleteWallet(widget.editing!.id);
    if (mounted) Navigator.pop(context);
  }

  void _toast(String msg, {bool isError = false}) {
    if (isError) {
      AppToast.showError(context, msg);
    } else {
      AppToast.showWarning(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ecosystemPartners = _currentEcosystemPartners;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: GlassPage(
        bottom: false,
        child: SafeArea(
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
                    Expanded(
                      child: Text(
                        _isEditing ? 'Ubah Dompet' : 'Tambah Dompet Baru',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkPrimary,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.expense,
                        ),
                        onPressed: _delete,
                      ),
                  ],
                ),
              ),

              // Form Scrollable Content
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    // 1. Jenis Dompet
                    const FunLabel('1. Jenis Dompet'),
                    const SizedBox(height: 8),
                    _buildTypeSelector(),

                    const SizedBox(height: 20),

                    // 2. Preset Cepat & Input Nama
                    _buildNameAndPresetSection(),

                    const SizedBox(height: 20),

                    // 3. Saldo Awal
                    const FunLabel('3. Saldo Awal (Rp)'),
                    const SizedBox(height: 8),
                    _buildOpeningBalanceField(),

                    const SizedBox(height: 20),

                    // 4. Hierarki Dompet (Parent vs Child)
                    _buildHierarchySection(),

                    const SizedBox(height: 20),

                    // 5. Fitur Ekosistem (Opsional)
                    if (_isParent &&
                        _type == 'bank' &&
                        ecosystemPartners != null &&
                        !_isEditing) ...[
                      _buildEcosystemSection(ecosystemPartners),
                      const SizedBox(height: 20),
                    ],

                    // 6. Tujuan Dompet (Opsional)
                    const FunLabel('Tujuan (Opsional)'),
                    const SizedBox(height: 8),
                    _buildPurposeField(),

                    const SizedBox(height: 32),

                    // Tombol Simpan
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _isEditing
                              ? 'Simpan Perubahan'
                              : 'Buat Dompet Sekarang',
                          style: const TextStyle(
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
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets Builder ──────────────────────────────────────────────────────

  Widget _buildTypeSelector() {
    final types = [
      ('Tunai', 'cash', Icons.payments_outlined),
      ('Bank', 'bank', Icons.account_balance_outlined),
      ('E-Wallet', 'e_wallet', Icons.account_balance_wallet_outlined),
    ];

    return Row(
      children: [
        for (int i = 0; i < types.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _onTypeChanged(types[i].$2),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == types[i].$2
                      ? AppColors.inkPrimary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _type == types[i].$2
                        ? AppColors.inkPrimary
                        : const Color(0xFFE2E8F0),
                    width: _type == types[i].$2 ? 2 : 1,
                  ),
                  boxShadow: _type == types[i].$2
                      ? [
                          BoxShadow(
                            color: AppColors.inkPrimary.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      types[i].$3,
                      size: 22,
                      color: _type == types[i].$2
                          ? Colors.white
                          : AppColors.inkSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      types[i].$1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _type == types[i].$2
                            ? Colors.white
                            : AppColors.inkPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNameAndPresetSection() {
    List<String>? presets;
    String hint = 'Nama dompet';
    String labelText = '2. Nama Dompet';

    if (_type == 'bank') {
      presets = _bankPresets;
      hint = 'Pilih bank di atas atau ketik nama bank...';
      labelText = '2. Pilih Bank atau Ketik Sendiri';
    } else if (_type == 'e_wallet') {
      presets = _eWalletPresets;
      hint = 'Pilih e-wallet di atas atau ketik sendiri...';
      labelText = '2. Pilih E-Wallet atau Ketik Sendiri';
    } else {
      hint = 'Contoh: Dompet Harian, Uang Kas Tunai';
      labelText = '2. Nama Dompet Tunai';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FunLabel(labelText),
        if (presets != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in presets)
                FunPill(
                  label: p,
                  selected:
                      _nameCtrl.text.trim().toLowerCase() ==
                      p.trim().toLowerCase(),
                  onTap: () => _selectPreset(p),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _nameCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.inkPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.inkMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningBalanceField() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _openingCtrl,
        keyboardType: TextInputType.number,
        inputFormatters: [_ThousandsFormatter()],
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.inkPrimary,
        ),
        decoration: const InputDecoration(
          prefixText: 'Rp ',
          prefixStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.inkPrimary,
          ),
          hintText: '0',
          hintStyle: TextStyle(
            color: AppColors.inkMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildHierarchySection() {
    final parents = _parentOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FunLabel('4. Hierarki Dompet (Parent atau Child)'),
        const SizedBox(height: 8),

        // Segmented Control: Parent vs Child
        Row(
          children: [
            Expanded(
              child: FunPill(
                label: '👑 Dompet Parent',
                selected: _isParent,
                onTap: () => setState(() {
                  _isParent = true;
                  _parentId = null;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FunPill(
                label: '🔗 Dompet Child',
                selected: !_isParent,
                onTap: _hasChildren
                    ? null
                    : () => setState(() {
                        _isParent = false;
                        if (_parentId == null && parents.isNotEmpty) {
                          _parentId = parents.first.id;
                        }
                      }),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Info / Sub-pilihan
        if (_hasChildren)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: const Text(
              'Dompet ini telah memiliki dompet anak, sehingga berstatus tetap sebagai Dompet Parent.',
              style: TextStyle(fontSize: 12, color: AppColors.inkPrimary),
            ),
          )
        else if (_isParent)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Dompet Parent adalah rekening induk (sumber pendapatan/gaji) yang dapat mengalokasikan saldo ke dompet-dompet anak.',
              style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
            ),
          ),

        // Daftar Pilihan Dompet Parent bila Child dipilih
        if (!_isParent) ...[
          const SizedBox(height: 14),
          const Text(
            'Pilih Dompet Parent / Induk:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.inkPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (parents.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Belum ada Dompet Parent di aplikasi Anda. Jadikan dompet pertama Anda sebagai Dompet Parent terlebih dahulu.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in parents)
                  InkWell(
                    onTap: () => setState(() => _parentId = p.id),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _parentId == p.id
                            ? AppColors.inkPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _parentId == p.id
                              ? AppColors.inkPrimary
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _parentId == p.id
                                ? Icons.check_circle_rounded
                                : Icons.account_balance_wallet_outlined,
                            size: 16,
                            color: _parentId == p.id
                                ? Colors.white
                                : AppColors.inkSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _parentId == p.id
                                  ? Colors.white
                                  : AppColors.inkPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${fmtRp(p.balance)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: _parentId == p.id
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ],
    );
  }

  Widget _buildEcosystemSection(List<_EcosystemPartner> partners) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.hub_outlined,
                size: 20,
                color: AppColors.accentBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ekosistem Terintegrasi ${_nameCtrl.text}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Centang layanan mitra yang ingin sekalian dibuatkan otomatis sebagai Dompet Anak, dan tentukan saldo awalnya:',
            style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 12),
          for (final p in partners) ...[
            Builder(
              builder: (context) {
                final isChecked = _selectedEcosystems.contains(p.name);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isChecked
                          ? AppColors.accentBlue
                          : const Color(0xFFE2E8F0),
                      width: isChecked ? 1.5 : 1,
                    ),
                    boxShadow: isChecked
                        ? [
                            BoxShadow(
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isChecked) {
                              _selectedEcosystems.remove(p.name);
                            } else {
                              _selectedEcosystems.add(p.name);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isChecked,
                                activeColor: AppColors.accentBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selectedEcosystems.add(p.name);
                                    } else {
                                      _selectedEcosystems.remove(p.name);
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkPrimary,
                                    ),
                                  ),
                                  Text(
                                    p.purpose,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const FunBadge('E-Wallet'),
                          ],
                        ),
                      ),
                      if (isChecked) ...[
                        const SizedBox(height: 10),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Saldo Awal:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Rp',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: _getEcosystemOpeningCtrl(p.name),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    _ThousandsFormatter(),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.inkPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '0 (opsional)',
                                    hintStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.inkMuted,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPurposeField() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _purposeCtrl,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.inkPrimary,
        ),
        decoration: const InputDecoration(
          hintText: 'mis. Belanja bulanan, hiburan, dana pensiun',
          hintStyle: TextStyle(
            color: AppColors.inkMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
