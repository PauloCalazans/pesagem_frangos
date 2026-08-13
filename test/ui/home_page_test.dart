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

  testWidgets('opens weight standards through a named menu action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpPesagemApp(tester);

    final optionsMenu = find.byTooltip('Mais opções');
    expect(optionsMenu, findsOneWidget);
    expect(
      tester.getSemantics(optionsMenu),
      isSemantics(tooltip: 'Mais opções', isButton: true),
    );
    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();

    expect(find.text('Padrões de peso'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('form has no overflow on a compact portrait phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpPesagemApp(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets('step actions stay above the keyboard on a compact phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await pumpPesagemApp(tester);
    await fillValidLote(tester);
    await tester.tap(input('idadeField'));
    await tester.pump();

    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    await tester.pumpAndSettle();

    final primaryAction = find.widgetWithText(FilledButton, 'Continuar');
    final keyboardTop =
        (tester.view.physicalSize.height - tester.view.viewInsets.bottom) /
        tester.view.devicePixelRatio;

    expect(tester.takeException(), isNull);
    expect(primaryAction.hitTestable(), findsOneWidget);
    final firstStepSecondaryAction = find.widgetWithText(
      TextButton,
      'Cancelar',
    );
    expect(firstStepSecondaryAction.hitTestable(), findsOneWidget);
    expect(
      tester.getBottomLeft(primaryAction).dy,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(
      tester.getBottomLeft(firstStepSecondaryAction).dy,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(input('idadeField').hitTestable(), findsOneWidget);
    expect(
      tester.getBottomLeft(input('idadeField')).dy,
      lessThanOrEqualTo(keyboardTop),
    );

    await tester.tap(primaryAction);
    await tester.pumpAndSettle();
    await fillValidConsumo(tester);

    final secondStepAction = find.widgetWithText(FilledButton, 'Continuar');
    final secondStepSecondaryAction = find.widgetWithText(TextButton, 'Voltar');
    expect(secondStepAction.hitTestable(), findsOneWidget);
    expect(secondStepSecondaryAction.hitTestable(), findsOneWidget);
    expect(
      tester.getBottomLeft(secondStepAction).dy,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(
      tester.getBottomLeft(secondStepSecondaryAction).dy,
      lessThanOrEqualTo(keyboardTop),
    );

    await tester.tap(secondStepAction);
    await tester.pumpAndSettle();
    await tester.enterText(input('balancasField'), '1200');

    final calculateAction = find.widgetWithText(FilledButton, 'Calcular');
    final thirdStepSecondaryAction = find.widgetWithText(TextButton, 'Voltar');
    expect(calculateAction.hitTestable(), findsOneWidget);
    expect(thirdStepSecondaryAction.hitTestable(), findsOneWidget);
    expect(
      tester.getBottomLeft(calculateAction).dy,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(
      tester.getBottomLeft(thirdStepSecondaryAction).dy,
      lessThanOrEqualTo(keyboardTop),
    );

    await tester.tap(calculateAction);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();

    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('Nova pesagem').hitTestable(), findsOneWidget);
    expect(find.text('Compartilhar resumo').hitTestable(), findsOneWidget);
  });

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
    expect(
      find.text('Preenchido automaticamente pela idade e sexo'),
      findsOneWidget,
    );
  });

  testWidgets('updates the standard weight when the sex changes', (
    tester,
  ) async {
    await pumpPesagemApp(tester);
    await tester.enterText(input('idadeField'), '21');

    await tester.tap(find.byKey(const Key('sexoField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fêmea').last);
    await tester.pumpAndSettle();

    expect(find.text('921'), findsOneWidget);
  });

  testWidgets('keeps the latest standard weight after quickly reverting sex', (
    tester,
  ) async {
    await pumpPesagemApp(tester);
    await tester.enterText(input('idadeField'), '21');

    await tester.tap(find.byKey(const Key('sexoField')));
    await tester.pump();
    await tester.tap(find.text('Fêmea').last);
    await tester.pump();
    await tester.tap(find.byKey(const Key('sexoField')));
    await tester.pump();
    await tester.tap(find.text('Macho').last);
    await tester.pumpAndSettle();

    expect(find.text('1021'), findsOneWidget);
  });

  testWidgets('reloads the standard weight after returning from the editor', (
    tester,
  ) async {
    await pumpPesagemApp(tester);
    await tester.enterText(input('idadeField'), '21');
    expect(find.text('1021'), findsOneWidget);

    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Padrões de peso'));
    await tester.pumpAndSettle();
    await mPrefs.setStringList(
      'padraoMacho',
      List.generate(22, (index) => index == 21 ? '7777' : '${1000 + index}'),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('7777'), findsOneWidget);
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

  testWidgets('filters letters from balance input instead of warning', (
    tester,
  ) async {
    await pumpPesagemApp(tester);
    await fillValidLote(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await fillValidConsumo(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(input('balancasField'), '1200\ntexto');
    await tester.pump();

    expect(
      tester.widget<EditableText>(input('balancasField')).controller.text,
      '1200\n',
    );
    expect(
      find.text('Use somente números, uma pesagem por linha'),
      findsNothing,
    );

    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    expect(find.text('Resultado'), findsOneWidget);
  });

  testWidgets('shows the result page and preserves form data on back', (
    tester,
  ) async {
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

    expect(find.text('Resultado'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Detalhes da pesagem'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Detalhes da pesagem'));
    await tester.pumpAndSettle();
    expect(find.text('Peso total'), findsOneWidget);
    expect(find.text('Média das balanças'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Plantel e alimentação'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Plantel e alimentação'), findsOneWidget);

    Navigator.of(tester.element(find.text('Resultado'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('21'), findsOneWidget);
  });

  testWidgets('accepts trimmed numeric form values when calculating', (
    tester,
  ) async {
    await pumpPesagemApp(tester);
    await tester.enterText(input('idadeField'), '21');
    await tester.enterText(input('idadeField'), ' 21 ');
    await tester.enterText(input('avesAlojadasField'), ' 10000 ');
    await tester.enterText(input('mortalidadeField'), ' 258 ');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(input('racaoRecebidaField'), ' 1000 ');
    await tester.enterText(input('estoqueField'), ' 200 ');
    await tester.enterText(input('avesPesadasField'), ' 10 ');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(input('balancasField'), ' 1200 ');
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    expect(find.text('Resultado'), findsOneWidget);
  });

  testWidgets('handles a rapid continue and back without a key conflict', (
    tester,
  ) async {
    await pumpPesagemApp(tester);
    await fillValidLote(tester);

    await tester.tap(find.text('Continuar'));
    await tester.pump();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Dados do lote · etapa 1 de 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    final snackBar = find.byType(SnackBar);
    final calculateAction = find.widgetWithText(FilledButton, 'Calcular');
    expect(
      tester.getBottomLeft(snackBar).dy,
      lessThanOrEqualTo(tester.getTopLeft(calculateAction).dy),
    );
    expect(calculateAction.hitTestable(), findsOneWidget);
  });
}
