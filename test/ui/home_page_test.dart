import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpPesagemApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'padraoMacho': List.generate(22, (index) => '${1000 + index}'),
      'padraoFemea': List.generate(22, (index) => '${900 + index}'),
    });
    mPrefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
  }

  Finder input(String key) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(EditableText),
  );

  Future<void> fillValidLote(WidgetTester tester) async {
    await tester.enterText(input('idadeField'), '21');
    await tester.enterText(input('avesAlojadasField'), '10000');
    await tester.enterText(input('mortalidadeField'), '258');
  }

  Future<void> fillValidConsumo(WidgetTester tester) async {
    await tester.enterText(input('racaoRecebidaField'), '1000');
    await tester.enterText(input('estoqueField'), '200');
    await tester.enterText(input('avesPesadasField'), '10');
  }

  testWidgets('navigates through steps and preserves lot data', (tester) async {
    await pumpPesagemApp(tester);

    expect(find.text('Dados do lote · etapa 1 de 3'), findsOneWidget);
    await fillValidLote(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Consumo e amostra · etapa 2 de 3'), findsOneWidget);
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('21'), findsOneWidget);
    expect(find.text('10000'), findsOneWidget);
  });

  testWidgets('populates the standard weight from seeded preferences', (
    tester,
  ) async {
    await pumpPesagemApp(tester);

    await tester.enterText(input('idadeField'), '21');

    expect(find.text('1021'), findsOneWidget);
  });

  testWidgets('focuses the first invalid field in the current step', (
    tester,
  ) async {
    await pumpPesagemApp(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(find.text('Idade deve ser maior que zero'), findsOneWidget);
    final editable = tester.widget<EditableText>(input('idadeField'));
    expect(editable.focusNode.hasFocus, isTrue);
  });

  testWidgets('rejects mortality equal to housed birds', (tester) async {
    await pumpPesagemApp(tester);
    await tester.enterText(input('idadeField'), '21');
    await tester.enterText(input('avesAlojadasField'), '100');
    await tester.enterText(input('mortalidadeField'), '100');
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(
      find.text('Mortalidade deve ser menor que aves alojadas'),
      findsOneWidget,
    );
  });

  testWidgets('rejects stock above received feed', (tester) async {
    await pumpPesagemApp(tester);
    await fillValidLote(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(input('racaoRecebidaField'), '300');
    await tester.enterText(input('estoqueField'), '301');
    await tester.enterText(input('avesPesadasField'), '10');
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(
      find.text('Estoque não pode superar a ração recebida'),
      findsOneWidget,
    );
  });

  testWidgets('rejects an invalid balance line', (tester) async {
    await pumpPesagemApp(tester);
    await fillValidLote(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await fillValidConsumo(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(input('balancasField'), '1200\ntexto');
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(
      find.text('Use somente números, uma pesagem por linha'),
      findsOneWidget,
    );
  });

  testWidgets('keeps the existing calculation result details', (tester) async {
    await pumpPesagemApp(tester);
    await fillValidLote(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await fillValidConsumo(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(input('balancasField'), '1200');
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    expect(find.text('Resultado dos Cálculos'), findsOneWidget);
    expect(find.textContaining('Peso Total'), findsOneWidget);
    expect(find.textContaining('Média das Balanças'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Mortalidade'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('Mortalidade'), findsOneWidget);
  });

  testWidgets('does not update form controllers after disposal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    mPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MyApp());
    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a validation message for a non-positive average weight', (
    tester,
  ) async {
    await pumpPesagemApp(tester);
    await fillValidLote(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(input('racaoRecebidaField'), '1000');
    await tester.enterText(input('estoqueField'), '200');
    await tester.enterText(input('taraField'), '100');
    await tester.enterText(input('avesPesadasField'), '1');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(input('balancasField'), '100');
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(
      find.text('As leituras e a tara devem resultar em peso médio positivo'),
      findsOneWidget,
    );
  });
}
