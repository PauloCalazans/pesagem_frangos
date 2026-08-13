import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/services/result_image_share.dart';
import 'package:pesagem_frangos/theme/app_theme.dart';
import 'package:pesagem_frangos/widgets/resultado_content.dart';

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

void main() {
  testWidgets('renders every detail statically for offscreen capture', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: ResultadoContent(
                resultado: buildCalculatedResult(),
                expandAllDetails: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ExpansionTile), findsNothing);
    expect(find.text('Detalhes da pesagem'), findsOneWidget);
    expect(find.text('Plantel e alimentação'), findsOneWidget);
    expect(find.text('Balanças consideradas'), findsOneWidget);
    expect(find.text('Ração recebida'), findsOneWidget);
  });

  testWidgets('captures the complete result as a PNG share payload', (
    tester,
  ) async {
    late BuildContext captureContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            captureContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    final bytes = (await tester.runAsync(
      () => captureResultImage(captureContext, buildCalculatedResult()),
    ))!;
    expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);

    final params = buildResultShareParams(bytes);
    expect(params.text, isNull);
    expect(params.title, 'Resumo da pesagem');
    expect(params.subject, 'Resumo da pesagem');
    expect(params.files, hasLength(1));
    expect(params.files!.single.mimeType, 'image/png');
    expect(params.fileNameOverrides, ['resumo-da-pesagem.png']);
  });
}
