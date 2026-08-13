import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/theme/app_theme.dart';
import 'package:pesagem_frangos/widgets/measurement_field.dart';
import 'package:pesagem_frangos/widgets/pesagem_bottom_actions.dart';
import 'package:pesagem_frangos/widgets/pesagem_progress_header.dart';

void main() {
  test('uses the approved Material 3 palette with accessible contrast', () {
    final theme = AppTheme.light;
    final border = theme.inputDecorationTheme.border! as OutlineInputBorder;

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppTheme.primary);
    expect(theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
    expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
    expect(theme.colorScheme.onSurface, AppTheme.text);
    expect(theme.scaffoldBackgroundColor, AppTheme.background);
    expect(border.borderRadius, BorderRadius.circular(12));
    expect(theme.inputDecorationTheme.constraints!.minHeight, 56);
    expect(
      _contrastRatio(theme.colorScheme.onPrimary, theme.colorScheme.primary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(theme.colorScheme.onSurface, theme.colorScheme.surface),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('header announces the current step and progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: const PesagemProgressHeader(
            title: 'Dados do lote',
            currentStep: 1,
            totalSteps: 3,
          ),
        ),
      ),
    );

    expect(find.text('Dados do lote · etapa 1 de 3'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, 1 / 3);
    expect(progress.color, AppTheme.progress);
    expect(progress.backgroundColor, AppTheme.primary);
    expect(
      _contrastRatio(progress.color!, progress.backgroundColor!),
      greaterThanOrEqualTo(3),
    );
  });

  test('progress header rejects invalid step ranges', () {
    expect(
      () => PesagemProgressHeader(
        title: 'Dados do lote',
        currentStep: 0,
        totalSteps: 3,
      ),
      throwsAssertionError,
    );
    expect(
      () => PesagemProgressHeader(
        title: 'Dados do lote',
        currentStep: 4,
        totalSteps: 3,
      ),
      throwsAssertionError,
    );
    expect(
      () => PesagemProgressHeader(
        title: 'Dados do lote',
        currentStep: 1,
        totalSteps: 0,
      ),
      throwsAssertionError,
    );
  });

  testWidgets('measurement field keeps label and unit visible', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MeasurementField(
            label: 'Idade',
            unit: 'dias',
            controller: TextEditingController(text: '21'),
          ),
        ),
      ),
    );

    expect(find.text('Idade'), findsOneWidget);
    expect(find.text('dias'), findsOneWidget);
  });

  testWidgets('bottom actions meet the minimum tap target', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: PesagemBottomActions(
            secondaryLabel: 'Voltar',
            primaryLabel: 'Continuar',
            onSecondary: () {},
            onPrimary: () {},
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.widgetWithText(TextButton, 'Voltar')).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Continuar')).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets(
    'bottom actions do not overflow at compact width and large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            bottomNavigationBar: PesagemBottomActions(
              secondaryLabel: 'Nova pesagem',
              primaryLabel: 'Compartilhar resumo',
              onSecondary: () {},
              onPrimary: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Nova pesagem'), findsOneWidget);
      expect(find.text('Compartilhar resumo'), findsOneWidget);
    },
  );
}

double _contrastRatio(Color first, Color second) {
  final lighter = first.computeLuminance();
  final darker = second.computeLuminance();
  final high = lighter > darker ? lighter : darker;
  final low = lighter > darker ? darker : lighter;
  return (high + 0.05) / (low + 0.05);
}
