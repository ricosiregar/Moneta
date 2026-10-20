import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Moneta/features/categories/add_category_sheet.dart';

void main() {
  testWidgets('AddCategorySheet renders without error or overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AddCategorySheet.show(context);
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    // Tap to open sheet
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.text('Tambah Kategori Baru'), findsOneWidget);
  });
}
