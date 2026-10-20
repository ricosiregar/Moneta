import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/components/app_glass_sheet.dart';
import '../../core/components/app_toast.dart';
import '../../core/components/fun_widgets.dart';
import '../../core/database/wallet_repository.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_colors.dart';
import 'wallet_form_page.dart';

IconData _typeIcon(String type) => switch (type) {
  'bank' => Icons.account_balance_outlined,
  'e_wallet' => Icons.account_balance_wallet_outlined,
  _ => Icons.payments_outlined,
};

String _typeLabel(String type) => switch (type) {
  'bank' => 'Bank',
  'e_wallet' => 'E-Wallet',
  _ => 'Tunai',
};

double _parseAmount(String text) =>
    double.tryParse(text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

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

/// Kelola dompet: wallet induk → anak, alokasi gaji, dan transfer.
class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  WalletRepository get _repo => getIt<WalletRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: GlassPage(
        child: StreamBuilder<List<WalletView>>(
          stream: _repo.watchWallets(),
          builder: (context, snap) {
            final wallets = snap.data ?? const <WalletView>[];
            final ids = wallets.map((w) => w.id).toSet();
            final roots = wallets
                .where((w) => w.parentId == null || !ids.contains(w.parentId))
                .toList();
            final total = wallets.fold<double>(0, (a, w) => a + w.balance);

            return Column(
              children: [
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
                          title: 'Dompet',
                          subtitle: 'Induk, anak, dan alokasi saldo',
                        ),
                      ),
                      FunRoundButton(
                        Icons.swap_horiz_rounded,
                        size: 40,
                        onTap: wallets.length < 2
                            ? null
                            : () => _showTransfer(context, wallets),
                      ),
                      const SizedBox(width: 8),
                      FunRoundButton(
                        Icons.add_rounded,
                        size: 40,
                        onTap: () => _showWalletForm(context, wallets),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 300));
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    children: [
                      FunCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FunLabel(
                              'Total Aset',
                              icon: Icons.wallet_outlined,
                            ),
                            const SizedBox(height: 6),
                            MoneyText(fmtRp(total), size: 28),
                            const SizedBox(height: 4),
                            Text(
                              '${wallets.length} dompet',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (wallets.isEmpty)
                        const FunCard(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'Belum ada dompet. Tekan + untuk menambah.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      for (final root in roots) ...[
                        _WalletGroup(
                          root: root,
                          children: wallets
                              .where((w) => w.parentId == root.id)
                              .toList(),
                          all: wallets,
                          repo: _repo,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showWalletForm(
    BuildContext context,
    List<WalletView> all, {
    WalletView? editing,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletFormPage(all: all, editing: editing),
      ),
    );
  }

  void _showTransfer(BuildContext context, List<WalletView> all,
      {String? initialFromId}) {
    _showSheet(
      context,
      _TransferForm(
        repo: _repo,
        wallets: all,
        initialFromId: initialFromId,
      ),
    );
  }
}

Future<void> _showSheet(BuildContext context, Widget child) {
  return AppGlassSheet.show(
    context: context,
    builder: (_) => child,
  );
}

void _toast(BuildContext context, String msg, {bool isError = false}) {
  if (isError) {
    AppToast.showError(context, msg);
  } else {
    AppToast.showWarning(context, msg);
  }
}

// ── Group (induk + anak) ─────────────────────────────────────────────────

class _WalletGroup extends StatelessWidget {
  final WalletView root;
  final List<WalletView> children;
  final List<WalletView> all;
  final WalletRepository repo;
  const _WalletGroup({
    required this.root,
    required this.children,
    required this.all,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    return FunCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WalletRow(
            wallet: root,
            hasChildren: children.isNotEmpty,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WalletFormPage(all: all, editing: root),
              ),
            ),
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final c in children)
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: _WalletRow(
                  wallet: c,
                  child: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WalletFormPage(all: all, editing: c),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FunPill(
              label: 'Atur Alokasi',
              icon: Icons.tune_rounded,
              selected: true,
              expand: true,
              onTap: () => _showSheet(
                context,
                _AllocationForm(repo: repo, source: root, children: children),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  final WalletView wallet;
  final bool child;
  final bool hasChildren;
  final VoidCallback onTap;
  const _WalletRow({
    required this.wallet,
    this.child = false,
    this.hasChildren = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      _typeLabel(wallet.type),
      if (wallet.purpose != null) wallet.purpose!,
    ].join(' • ');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            IconBox(_typeIcon(wallet.type), size: child ? 36 : 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          wallet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: child ? 13 : 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                      ),
                      if (!child && (wallet.isIncomeSource || hasChildren)) ...[
                        const SizedBox(width: 6),
                        const FunBadge('Dompet Parent'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            MoneyText(fmtRp(wallet.balance), size: child ? 13 : 15),
          ],
        ),
      ),
    );
  }
}

// ── Sheet building blocks ────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SheetShell({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return AppGlassSheet(
      title: title,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool money;
  final bool number;
  final String? prefix;
  final ValueChanged<String>? onChanged;
  const _Field({
    required this.controller,
    required this.hint,
    this.money = false,
    this.number = false,
    this.prefix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: (money || number)
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: money ? [_ThousandsFormatter()] : null,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          hintStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.accentBlue,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

Widget _gap(double h) => SizedBox(height: h);

Widget _pillRow<T>({
  required List<(String, T)> items,
  required T selected,
  required ValueChanged<T> onChanged,
}) {
  return SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) => FunPill(
        label: items[i].$1,
        selected: items[i].$2 == selected,
        onTap: () => onChanged(items[i].$2),
      ),
    ),
  );
}



// ── Alokasi ──────────────────────────────────────────────────────────────

class _AllocationForm extends StatefulWidget {
  final WalletRepository repo;
  final WalletView source;
  final List<WalletView> children;
  const _AllocationForm({
    required this.repo,
    required this.source,
    required this.children,
  });

  @override
  State<_AllocationForm> createState() => _AllocationFormState();
}

class _AllocationFormState extends State<_AllocationForm> {
  late final Map<String, TextEditingController> _ctrls = {
    for (final c in widget.children) c.id: TextEditingController(),
  };
  bool _autoTransfer = true;

  @override
  void initState() {
    super.initState();
    widget.repo.getAllocations(widget.source.id).then((rules) {
      if (!mounted) return;
      for (final r in rules) {
        final p = r.percent;
        if (p != null) {
          _ctrls[r.targetWalletId]?.text = p == p.roundToDouble()
              ? p.round().toString()
              : p.toString();
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _pct(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  double get _totalPct => _ctrls.values.fold(0, (a, c) => a + _pct(c));

  double _share(double pct) =>
      (widget.source.balance * pct / 100).roundToDouble();

  double get _totalShare =>
      _ctrls.values.fold(0, (a, c) => a + _share(_pct(c)));

  Future<void> _save() async {
    final totalPct = _totalPct;
    if (totalPct > 100) {
      _toast(context, 'Total alokasi tidak boleh lebih dari 100%');
      return;
    }

    final totalShare = _totalShare;
    if (_autoTransfer && totalShare > widget.source.balance) {
      _toast(
        context,
        'Saldo ${widget.source.name} tidak cukup (${fmtRp(widget.source.balance)})',
      );
      return;
    }

    final nav = Navigator.of(context);
    final percents = {for (final e in _ctrls.entries) e.key: _pct(e.value)};

    if (_autoTransfer && totalShare > 0 && widget.source.balance > 0) {
      await widget.repo.distributeAllocations(
        sourceWalletId: widget.source.id,
        percents: percents,
        baseAmount: widget.source.balance,
      );
      nav.pop();
      if (!mounted) return;
      AppToast.showSuccess(
        context,
        'Alokasi tersimpan & ${fmtRp(totalShare)} berhasil dipindahkan dari ${widget.source.name}',
      );
    } else {
      await widget.repo.saveAllocations(widget.source.id, percents);
      nav.pop();
      if (!mounted) return;
      AppToast.showSuccess(context, 'Aturan alokasi berhasil disimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPct = _totalPct;
    final totalShare = _totalShare;
    final remainingPct = (100 - totalPct).clamp(0, 100);
    final remainingBalance = (widget.source.balance - totalShare).clamp(
      0,
      double.infinity,
    );

    return _SheetShell(
      title: 'Atur Alokasi: ${widget.source.name}',
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              IconBox(_typeIcon(widget.source.type), size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.source.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const FunBadge('Dompet Parent'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Saldo: ${fmtRp(widget.source.balance)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _gap(16),
        for (final c in widget.children) ...[
          Builder(
            builder: (context) {
              final pct = _pct(_ctrls[c.id]!);
              final share = _share(pct);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.inkPrimary,
                              ),
                            ),
                            if (c.purpose != null)
                              Text(
                                c.purpose!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: _Field(
                          controller: _ctrls[c.id]!,
                          hint: '0',
                          number: true,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '%',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (pct > 0 && widget.source.balance > 0) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '→ ${fmtRp(share)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          _gap(10),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: totalPct > 100
                ? AppColors.expense.withValues(alpha: 0.08)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Alokasi: ${totalPct.toStringAsFixed(totalPct == totalPct.roundToDouble() ? 0 : 1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: totalPct > 100
                          ? AppColors.expense
                          : AppColors.inkPrimary,
                    ),
                  ),
                  if (widget.source.balance > 0)
                    Text(
                      fmtRp(totalShare),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: totalPct > 100
                            ? AppColors.expense
                            : AppColors.inkPrimary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sisa di ${widget.source.name}: ${remainingPct.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  if (widget.source.balance > 0)
                    Text(
                      fmtRp(remainingBalance),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.inkMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        _gap(12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pindahkan saldo otomatis',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkPrimary,
                    ),
                  ),
                  Text(
                    'Otomatis transfer dari ${widget.source.name} ke dompet anak saat disimpan',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _autoTransfer,
              onChanged: (v) => setState(() => _autoTransfer = v),
            ),
          ],
        ),
        _gap(16),
        _PrimaryButton(
          _autoTransfer && totalShare > 0
              ? 'Simpan & Pindahkan (${fmtRp(totalShare)})'
              : 'Simpan Alokasi',
          _save,
        ),
      ],
    );
  }
}

// ── Transfer ─────────────────────────────────────────────────────────────

class _TransferForm extends StatefulWidget {
  final WalletRepository repo;
  final List<WalletView> wallets;
  final String? initialFromId;
  const _TransferForm({
    required this.repo,
    required this.wallets,
    this.initialFromId,
  });

  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  final _amount = TextEditingController();
  final _fee = TextEditingController();
  final _note = TextEditingController();
  late String _from;
  late String _to;

  @override
  void initState() {
    super.initState();
    final initFrom = widget.initialFromId != null &&
            widget.wallets.any((w) => w.id == widget.initialFromId)
        ? widget.initialFromId!
        : widget.wallets.first.id;
    _from = initFrom;
    final available = widget.wallets.where((w) => w.id != _from).toList();
    _to = available.isNotEmpty ? available.first.id : '';
  }

  @override
  void dispose() {
    _amount.dispose();
    _fee.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = _parseAmount(_amount.text);
    if (amount <= 0) {
      _toast(context, 'Isi nominal transfer');
      return;
    }
    if (_to.isEmpty) {
      _toast(context, 'Pilih dompet tujuan');
      return;
    }
    if (_from == _to) {
      _toast(context, 'Dompet asal dan tujuan harus berbeda');
      return;
    }

    final nav = Navigator.of(context);
    try {
      await widget.repo.createTransfer(
        fromWalletId: _from,
        toWalletId: _to,
        amount: amount,
        fee: _parseAmount(_fee.text),
        note: _note.text,
      );
      nav.pop();
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [for (final w in widget.wallets) (w.name, w.id)];
    final toItems = [
      for (final w in widget.wallets)
        if (w.id != _from) (w.name, w.id),
    ];

    return _SheetShell(
      title: 'Pindah Uang',
      children: [
        const FunLabel('Dari'),
        _gap(8),
        _pillRow<String>(
          items: items,
          selected: _from,
          onChanged: (v) => setState(() {
            _from = v;
            if (_to == v ||
                !widget.wallets.any((w) => w.id == _to && w.id != v)) {
              final next = widget.wallets.firstWhere((w) => w.id != v);
              _to = next.id;
            }
          }),
        ),
        _gap(16),
        const FunLabel('Ke'),
        _gap(8),
        _pillRow<String>(
          items: toItems,
          selected: _to,
          onChanged: (v) => setState(() => _to = v),
        ),
        _gap(16),
        const FunLabel('Nominal'),
        _gap(8),
        _Field(controller: _amount, hint: '0', money: true, prefix: 'Rp '),
        _gap(16),
        const FunLabel('Biaya admin (opsional)'),
        _gap(8),
        _Field(controller: _fee, hint: '0', money: true, prefix: 'Rp '),
        _gap(16),
        _Field(controller: _note, hint: 'Catatan'),
        _gap(20),
        _PrimaryButton('Pindahkan', _save),
      ],
    );
  }
}
