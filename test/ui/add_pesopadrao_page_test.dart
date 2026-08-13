import 'dart:async';

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
    Future<List<String>> Function(String sexo)? loadPesos,
    Future<bool> Function(String key, List<String> values)? savePesos,
  }) async {
    SharedPreferences.setMockInitialValues(initialValues);
    mPrefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddPesopadraoPage(loadPesos: loadPesos, savePesos: savePesos),
      ),
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

  testWidgets('keeps the newest load after an ABA sex change', (tester) async {
    final staleFemale = Completer<List<String>>();
    var femaleLoads = 0;
    await pumpStandardsPage(
      tester,
      initialValues: const {},
      loadPesos: (sexo) {
        if (sexo == 'Macho') return Future.value(<String>['42']);
        if (sexo == 'Fêmea' && femaleLoads++ == 0) return staleFemale.future;
        return Future.value(<String>['58']);
      },
    );

    await selectSexo(tester, 'Fêmea');
    await selectSexo(tester, 'Macho');
    await selectSexo(tester, 'Fêmea');
    staleFemale.complete(<String>['40']);
    await tester.pumpAndSettle();

    expect(find.text('58 g'), findsOneWidget);
    expect(find.text('40 g'), findsNothing);
  });

  testWidgets('does not let a stale load overwrite a confirmed save', (
    tester,
  ) async {
    final staleLoad = Completer<List<String>>();
    await pumpStandardsPage(
      tester,
      initialValues: const {},
      loadPesos: (_) => staleLoad.future,
      savePesos: (_, __) async => true,
    );

    await tester.enterText(find.byKey(const Key('novoPesoPadraoField')), '70');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    staleLoad.complete(<String>['42']);
    await tester.pumpAndSettle();

    expect(find.text('70 g'), findsOneWidget);
    expect(find.text('42 g'), findsNothing);
  });

  testWidgets('disables a second mutation while the first save is pending', (
    tester,
  ) async {
    final save = Completer<bool>();
    var saveCalls = 0;
    await pumpStandardsPage(
      tester,
      initialValues: const {},
      loadPesos: (_) => Future.value(<String>['42']),
      savePesos: (_, __) {
        saveCalls++;
        return save.future;
      },
    );

    await tester.enterText(find.byKey(const Key('novoPesoPadraoField')), '70');
    await tester.tap(find.text('Adicionar'));
    await tester.pump();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    final rowMenu = tester.widget<PopupMenuButton>(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    expect(rowMenu.onSelected, isNull);
    await tester.tap(find.text('Adicionar'));
    expect(saveCalls, 1);

    save.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('70 g'), findsOneWidget);
  });

  testWidgets('keeps the confirmed list and reports a failed save', (
    tester,
  ) async {
    await pumpStandardsPage(
      tester,
      initialValues: const {},
      loadPesos: (_) => Future.value(<String>['42']),
      savePesos: (_, __) async => false,
    );

    await tester.enterText(find.byKey(const Key('novoPesoPadraoField')), '70');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('42 g'), findsOneWidget);
    expect(find.text('70 g'), findsNothing);
    expect(find.text('Não foi possível salvar o padrão'), findsOneWidget);
  });

  testWidgets('keeps the confirmed list when saving throws', (tester) async {
    await pumpStandardsPage(
      tester,
      initialValues: const {},
      loadPesos: (_) => Future.value(<String>['42']),
      savePesos: (_, __) async => throw StateError('storage unavailable'),
    );

    await tester.enterText(find.byKey(const Key('novoPesoPadraoField')), '70');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('42 g'), findsOneWidget);
    expect(find.text('70 g'), findsNothing);
    expect(find.text('Não foi possível salvar o padrão'), findsOneWidget);
  });

  testWidgets('shows an empty-state message for an empty standard list', (
    tester,
  ) async {
    await pumpStandardsPage(tester, initialValues: const {});

    expect(find.text('Nenhum padrão cadastrado'), findsOneWidget);
  });

  testWidgets('disables adding and blocks editing for mixed standards', (
    tester,
  ) async {
    await pumpStandardsPage(
      tester,
      initialValues: {
        'padraoMacho': <String>['42'],
        'padraoFemea': <String>['40'],
      },
    );
    await selectSexo(tester, 'Misto');

    final addButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(addButton.onPressed, isNull);
    await tester.tap(find.byTooltip('Ações da idade 0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(
      find.text('O padrão do Misto é calculado a partir dos outros'),
      findsOneWidget,
    );
  });
}
