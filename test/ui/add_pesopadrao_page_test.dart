import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/main.dart';
import 'package:pesagem_frangos/theme/app_theme.dart';
import 'package:pesagem_frangos/ui/add_pesopadrao_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpStandardsPage(
    WidgetTester tester, {
    required Map<String, List<String>> initialValues,
  }) async {
    SharedPreferences.setMockInitialValues(initialValues);
    mPrefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: AddPesopadraoPage()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> selectSexo(WidgetTester tester, String sexo) async {
    await tester.tap(find.byKey(const Key('sexoPadraoField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(sexo).last);
    await tester.pumpAndSettle();
  }

  testWidgets('adds a numeric standard and exposes visible row actions', (
    tester,
  ) async {
    await pumpStandardsPage(
      tester,
      initialValues: {
        'padraoMacho': <String>['42', '56'],
        'padraoFemea': <String>['40', '54'],
      },
    );

    expect(find.text('Idade'), findsOneWidget);
    expect(find.text('Peso padrão'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('novoPesoPadraoField')), '70');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('70 g'), findsOneWidget);
    expect(mPrefs.getStringList('padraoMacho'), <String>['42', '56', '70']);
    await tester.tap(find.byTooltip('Ações da idade 2'));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Excluir'), findsOneWidget);
  });

  testWidgets('edits the selected standard through its row action', (
    tester,
  ) async {
    await pumpStandardsPage(
      tester,
      initialValues: {
        'padraoMacho': <String>['42', '56'],
        'padraoFemea': <String>['40', '54'],
      },
    );

    await tester.tap(find.byTooltip('Ações da idade 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('editarPesoPadraoField')),
      '58',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('58 g'), findsOneWidget);
    expect(mPrefs.getStringList('padraoMacho'), <String>['42', '58']);
  });

  testWidgets('removes the exact selected standard instead of the last row', (
    tester,
  ) async {
    await pumpStandardsPage(
      tester,
      initialValues: {
        'padraoMacho': <String>['42', '56'],
        'padraoFemea': <String>['40', '54'],
      },
    );

    await tester.tap(find.byTooltip('Ações da idade 0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('42 g'), findsNothing);
    expect(find.text('56 g'), findsOneWidget);
    expect(mPrefs.getStringList('padraoMacho'), <String>['56']);
  });

  testWidgets('rejects deletion for the derived mixed standard', (
    tester,
  ) async {
    await pumpStandardsPage(
      tester,
      initialValues: {
        'padraoMacho': <String>['42', '56'],
        'padraoFemea': <String>['40', '54'],
      },
    );
    await selectSexo(tester, 'Misto');

    await tester.tap(find.byTooltip('Ações da idade 0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(
      find.text('O padrão do Misto é calculado a partir dos outros'),
      findsOneWidget,
    );
  });
}
