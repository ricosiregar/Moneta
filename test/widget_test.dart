import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Moneta/core/components/floating_bottom_nav.dart';
import 'package:Moneta/core/components/fun_widgets.dart';
import 'package:Moneta/core/theme/app_colors.dart';

void main() {
  test('AppColors canvas should be 0xFFF8FAFC', () {
    expect(AppColors.canvas.value, equals(0xFFF8FAFC));
  });

  testWidgets('FunPill in horizontal scroll renders without error', (tester) async {
    const tabs = ['Semua', 'Pengeluaran', 'Pemasukan', 'Pindah Uang'];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final t in tabs)
                  FunPill(label: t),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Pengeluaran'), findsOneWidget);
  });

  testWidgets('FloatingBottomNav switches tabs rapidly without duplicate key error', (tester) async {
    int current = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StatefulBuilder(
            builder: (context, setState) {
              return FloatingBottomNav(
                currentIndex: current,
                onTabSelected: (i) => setState(() => current = i),
                onFabTap: () {},
              );
            },
          ),
        ),
      ),
    );

    // Rapidly tap different tabs within milliseconds
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
