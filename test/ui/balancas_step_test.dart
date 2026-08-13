import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/ui/pesagem/balancas_step.dart';
import 'package:pesagem_frangos/ui/pesagem/pesagem_form_controllers.dart';

void main() {
  Future<PesagemFormControllers> pumpBalancasStep(WidgetTester tester) async {
    final controllers = PesagemFormControllers();
    addTearDown(controllers.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BalancasStep(
            formKey: GlobalKey<FormState>(),
            controllers: controllers,
          ),
        ),
      ),
    );
    return controllers;
  }

  Finder balanceInput() => find.descendant(
    of: find.byKey(const Key('balancasField')),
    matching: find.byType(EditableText),
  );

  testWidgets('filters letters from typed or pasted balance readings', (
    tester,
  ) async {
    final controllers = await pumpBalancasStep(tester);

    await tester.enterText(balanceInput(), '12a00\ntexto\n13b00');
    await tester.pump();

    expect(controllers.balancas.text, '1200\n\n1300');
    expect(
      find.text('Use somente números, uma pesagem por linha'),
      findsNothing,
    );
  });

  testWidgets('updates the valid-reading count after every edit', (
    tester,
  ) async {
    await pumpBalancasStep(tester);

    expect(find.text('0 leituras válidas'), findsOneWidget);

    await tester.enterText(balanceInput(), '1200\n0\n1300');
    await tester.pump();
    expect(find.text('2 leituras válidas'), findsOneWidget);

    await tester.enterText(balanceInput(), '1200');
    await tester.pump();
    expect(find.text('1 leitura válida'), findsOneWidget);
  });
}
