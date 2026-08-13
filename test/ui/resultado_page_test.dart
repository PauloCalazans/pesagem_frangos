import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/main.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/theme/app_theme.dart';
import 'package:pesagem_frangos/ui/resultado_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

PesoMedio buildCalculatedResult() {
  return PesoMedio(
    idade: 21,
    avesPesadas: 120,
    avesAlojadas: 10000,
    pesoPadrao: 874,
    racaoRecebida: 30000,
    estoqueRacao: 1570,
    tara: 250,
    balancas: const ['27010', '27010', '27010', '27010'],
    mortalidade: 258,
  )..calcular();
}

Finder _input(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(EditableText),
);

Future<void> _pumpPesagemApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'padraoMacho': List.generate(22, (index) => '${1000 + index}'),
    'padraoFemea': List.generate(22, (index) => '${900 + index}'),
  });
  mPrefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
}

Future<void> _openResult(WidgetTester tester) async {
  await tester.enterText(_input('idadeField'), '21');
  await tester.enterText(_input('avesAlojadasField'), '10000');
  await tester.enterText(_input('mortalidadeField'), '258');
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();
  await tester.enterText(_input('racaoRecebidaField'), '1000');
  await tester.enterText(_input('estoqueField'), '200');
  await tester.enterText(_input('avesPesadasField'), '10');
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();
  await tester.enterText(_input('balancasField'), '1200');
  await tester.tap(find.text('Calcular'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows total standard percentage and viability', (tester) async {
    final resultado = buildCalculatedResult();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ResultadoPage(resultado: resultado, onShare: (_) async {}),
      ),
    );

    expect(find.text('892 g'), findsOneWidget);
    expect(find.text('102,1%'), findsOneWidget);
    expect(find.text('97,42%'), findsOneWidget);
    expect(find.text('9.742 aves vivas'), findsOneWidget);
    expect(find.textContaining('2,1% acima'), findsNothing);
  });

  testWidgets('expands weighing audit details', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: ResultadoPage(
          resultado: buildCalculatedResult(),
          onShare: (_) async {},
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Detalhes da pesagem'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final expander = find.bySemanticsLabel('Detalhes da pesagem');
    expect(expander, findsOneWidget);
    expect(
      tester.getSemantics(expander),
      isSemantics(label: 'Detalhes da pesagem', isButton: true),
    );
    await tester.tap(find.text('Detalhes da pesagem'));
    await tester.pumpAndSettle();

    expect(find.text('Peso total'), findsOneWidget);
    expect(find.text('Desconto da tara'), findsOneWidget);
    expect(find.text('Média das balanças'), findsOneWidget);
    expect(find.text('Balanças consideradas'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('result exposes a localized close action', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('pt', 'BR')],
        initialRoute: '/resultado',
        routes: {
          '/': (_) => const Scaffold(),
          '/resultado': (_) => ResultadoPage(
            resultado: buildCalculatedResult(),
            onShare: (_) async {},
          ),
        },
      ),
    );
    await tester.pumpAndSettle();

    final closeResult = find.byTooltip('Voltar');
    expect(closeResult, findsOneWidget);
    expect(
      tester.getSemantics(closeResult),
      isSemantics(tooltip: 'Voltar', isButton: true),
    );
    semantics.dispose();
  });

  testWidgets('result supports enlarged text without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: ResultadoPage(
          resultado: buildCalculatedResult(),
          onShare: (_) async {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('102,1%'), findsOneWidget);
  });

  testWidgets('system back preserves the entered age in HomePage', (
    tester,
  ) async {
    await _pumpPesagemApp(tester);
    await _openResult(tester);

    expect(find.text('Resultado'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<EditableText>(_input('idadeField')).controller.text,
      '21',
    );
  });

  testWidgets(
    'new weighing explicitly clears the form and returns to step one',
    (tester) async {
      await _pumpPesagemApp(tester);
      await _openResult(tester);

      await tester.tap(find.text('Nova pesagem'));
      await tester.pumpAndSettle();

      expect(find.text('Dados do lote · etapa 1 de 3'), findsOneWidget);
      expect(
        tester.widget<EditableText>(_input('idadeField')).controller.text,
        isEmpty,
      );
    },
  );

  testWidgets('shares the same formatted summary shown on screen', (
    tester,
  ) async {
    String? sharedText;
    await tester.pumpWidget(
      MaterialApp(
        home: ResultadoPage(
          resultado: buildCalculatedResult(),
          onShare: (text) async => sharedText = text,
        ),
      ),
    );

    await tester.tap(find.text('Compartilhar resumo'));
    await tester.pump();

    expect(sharedText, contains('Peso médio: 892 g'));
    expect(sharedText, contains('Percentual do padrão: 102,1%'));
    expect(sharedText, contains('Viabilidade: 97,42%'));
    expect(sharedText, contains('GMD: 42,5 g'));
    expect(sharedText, contains('Conversão alimentar: 3,272'));
  });

  testWidgets('keeps long result actions usable on a narrow scaled screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: ResultadoPage(
          resultado: buildCalculatedResult(),
          onShare: (_) async {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Nova pesagem'), findsOneWidget);
    expect(find.text('Compartilhar resumo'), findsOneWidget);
  });

  testWidgets('reports an injected sharing failure without a platform call', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultadoPage(
          resultado: buildCalculatedResult(),
          onShare: (_) => Future<void>.error(StateError('share failed')),
        ),
      ),
    );

    await tester.tap(find.text('Compartilhar resumo'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível compartilhar o resumo'), findsOneWidget);
  });
}
