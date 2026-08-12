import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/widgets/measurement_field.dart';
import 'package:pesagem_frangos/widgets/pesagem_bottom_actions.dart';
import 'package:pesagem_frangos/widgets/pesagem_progress_header.dart';

void main() {
  testWidgets('header announces the current step and progress', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PesagemProgressHeader(
            title: 'Dados do lote',
            currentStep: 1,
            totalSteps: 3,
          ),
        ),
      ),
    );

    expect(find.text('Dados do lote · etapa 1 de 3'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('measurement field keeps label and unit visible', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
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
}
