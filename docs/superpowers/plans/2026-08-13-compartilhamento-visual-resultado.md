# Compartilhamento Visual do Resultado Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir o compartilhamento textual por uma imagem PNG que reproduz o conteúdo visual completo do resultado, sem AppBar nem ações.

**Architecture:** Extrair o corpo do resultado para um widget reutilizável com modo interativo ou totalmente expandido. Renderizar a variante expandida fora da árvore visível com `ScreenshotController.captureFromLongWidget`, entregar os bytes PNG ao `share_plus` como `XFile.fromData` e controlar geração/erro na página por dependências injetáveis.

**Tech Stack:** Flutter 3.41+, Dart 3.12+, Material 3, `screenshot` 3.0.0, `share_plus` 13.3.0, `flutter_test`.

## Global Constraints

- A saída é um arquivo PNG com o título `Resumo da pesagem`.
- A imagem contém todos os cartões, métricas e linhas de `Detalhes da pesagem` e `Plantel e alimentação`.
- A imagem não contém AppBar, `Nova pesagem` nem `Compartilhar resumo`.
- A composição usa fundo sólido, largura lógica de 420 px, margem de 16 px e `pixelRatio` 2.0.
- O compartilhamento não repete o resumo textual completo.
- Toques repetidos ficam bloqueados durante captura e compartilhamento.
- Toda falha mostra exatamente `Não foi possível compartilhar o resumo` e mantém o resultado na tela.
- Não gerar PDF, não salvar na galeria e não adicionar logotipo, marca d'água ou tema de exportação.

## File Structure

- Create `lib/widgets/resultado_content.dart`: composição visual reutilizável do resultado e controle de expansão das seções.
- Create `lib/services/result_image_share.dart`: captura PNG fora da tela, criação do payload de arquivo e chamada nativa de compartilhamento.
- Modify `lib/ui/resultado_page.dart`: estado assíncrono, injeção de captura/compartilhamento e tratamento de erro.
- Modify `lib/widgets/pesagem_bottom_actions.dart`: suporte a ação primária em processamento e desabilitada.
- Modify `pubspec.yaml` and `pubspec.lock`: adicionar `screenshot: ^3.0.0`.
- Modify `test/ui/resultado_page_test.dart`: cobertura da composição completa e do fluxo de compartilhamento.
- Modify `test/widgets/pesagem_components_test.dart`: cobertura do estado de processamento das ações.
- Create `test/services/result_image_share_test.dart`: cobertura real da captura PNG e do payload do `share_plus`.

---

### Task 1: Extrair a composição reutilizável do resultado

**Files:**
- Create: `lib/widgets/resultado_content.dart`
- Modify: `lib/ui/resultado_page.dart`
- Test: `test/ui/resultado_page_test.dart`

**Interfaces:**
- Consumes: `PesoMedio`, `ResultHeroCard`, `ViabilityCard`, `MetricCard`, `ResultDetailsSection` e `ResultLine` existentes.
- Produces: `ResultadoContent({required PesoMedio resultado, bool expandAllDetails = false})`.

- [ ] **Step 1: Escrever o teste que exige todos os detalhes sem interação**

Adicionar o import de `resultado_content.dart` e o teste:

```dart
testWidgets('share content renders every detail already expanded', (
  tester,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ResultadoContent(
            resultado: buildCalculatedResult(),
            expandAllDetails: true,
          ),
        ),
      ),
    ),
  );

  expect(find.text('Peso médio'), findsOneWidget);
  expect(find.text('Percentual do padrão'), findsOneWidget);
  expect(find.text('Viabilidade'), findsOneWidget);
  expect(find.text('GMD'), findsOneWidget);
  expect(find.text('Conversão alimentar'), findsOneWidget);
  expect(find.text('Peso total'), findsOneWidget);
  expect(find.text('Média das balanças'), findsOneWidget);
  expect(find.text('Ração recebida'), findsOneWidget);
  expect(find.text('Estoque atual'), findsOneWidget);
  expect(find.text('Resultado'), findsNothing);
  expect(find.text('Nova pesagem'), findsNothing);
  expect(find.text('Compartilhar resumo'), findsNothing);
});
```

- [ ] **Step 2: Executar o teste e confirmar RED**

Run: `flutter test --no-version-check test/ui/resultado_page_test.dart --plain-name "share content renders every detail already expanded"`

Expected: FAIL porque `ResultadoContent` ainda não existe.

- [ ] **Step 3: Criar `ResultadoContent` e reutilizá-lo na página**

Mover a `Column` atualmente dentro do `SingleChildScrollView` de `ResultadoPage` para:

```dart
class ResultadoContent extends StatelessWidget {
  const ResultadoContent({
    super.key,
    required this.resultado,
    this.expandAllDetails = false,
  });

  final PesoMedio resultado;
  final bool expandAllDetails;

  @override
  Widget build(BuildContext context) {
    final r = resultado;
    return Column(
      key: const Key('resultadoContent'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultHeroCard(
          pesoMedio: r.pesoMedio,
          percentualPadrao: r.porcentagem,
          pesoPadrao: r.pesoPadrao,
          diferencaPeso: r.diferencaPeso,
        ),
        const SizedBox(height: 12),
        ViabilityCard(viabilidade: r.viabilidade, avesVivas: r.avesVivas),
        const SizedBox(height: 12),
        Text('Eficiência', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final cardWidth = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    label: 'GMD',
                    value: '${Util.formatDecimal(r.gmd)} g',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    label: 'Conversão alimentar',
                    value: Util.formatDecimal(r.ca, decimals: 3),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    label: 'Consumo',
                    value: '${Util.formatInteger(r.consumo)} kg',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    label: 'Mortalidade',
                    value: '${Util.formatInteger(r.mortalidade)} aves',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        ResultDetailsSection(
          title: 'Detalhes da pesagem',
          initiallyExpanded: expandAllDetails,
          children: [
            ResultLine(
              label: 'Idade',
              value: '${Util.formatInteger(r.idade)} dias',
            ),
            ResultLine(
              label: 'Tara unitária',
              value: '${Util.formatInteger(r.tara)} g',
            ),
            ResultLine(
              label: 'Aves pesadas',
              value: '${Util.formatInteger(r.avesPesadas)} aves',
            ),
            ResultLine(
              label: 'Peso total',
              value: '${Util.formatInteger(r.pesoTotal)} g',
            ),
            ResultLine(
              label: 'Desconto da tara',
              value: '${Util.formatInteger(r.desconto)} g',
            ),
            ResultLine(
              label: 'Média das balanças',
              value:
                  '${Util.formatDecimal((r.pesoTotal - r.desconto) / r.balancadas)} g',
            ),
            ResultLine(
              label: 'Balanças consideradas',
              value: '${r.balancadas}',
            ),
          ],
        ),
        const SizedBox(height: 12),
        ResultDetailsSection(
          title: 'Plantel e alimentação',
          initiallyExpanded: expandAllDetails,
          children: [
            ResultLine(label: 'Aves alojadas', value: '${r.avesAlojadas}'),
            ResultLine(label: 'Mortalidade', value: '${r.mortalidade} aves'),
            ResultLine(
              label: 'Ração recebida',
              value: '${r.racaoRecebida} kg',
            ),
            ResultLine(
              label: 'Estoque atual',
              value: '${r.estoqueRacao} kg',
            ),
          ],
        ),
      ],
    );
  }
}
```

Em `ResultadoPage`, manter o `SingleChildScrollView`, o padding de 16 px e substituir a composição movida por:

```dart
ResultadoContent(resultado: resultado)
```

Não alterar textos, fórmulas, formatação numérica ou comportamento padrão fechado das seções.

- [ ] **Step 4: Executar testes focados e confirmar GREEN**

Run: `flutter test --no-version-check test/ui/resultado_page_test.dart`

Expected: PASS, incluindo os testes existentes de expansão, texto ampliado e navegação.

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/resultado_content.dart lib/ui/resultado_page.dart test/ui/resultado_page_test.dart
git commit -m "refactor: extract result content"
```

---

### Task 2: Renderizar e preparar o PNG compartilhável

**Files:**
- Create: `lib/services/result_image_share.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Test: `test/services/result_image_share_test.dart`

**Interfaces:**
- Consumes: `ResultadoContent` da Task 1 e `PesoMedio`.
- Produces: `typedef CaptureResultImage`, `typedef ShareResultImage`, `captureResultImage(BuildContext, PesoMedio)`, `buildResultShareParams(Uint8List)` e `shareResultImage(Uint8List)`.

- [ ] **Step 1: Adicionar o teste de captura real e payload de imagem**

Criar `test/services/result_image_share_test.dart` com um `testWidgets` que obtém um `BuildContext`, chama a API desejada e valida assinatura PNG e conteúdo do payload:

```dart
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

  final bytes = await captureResultImage(
    captureContext,
    buildCalculatedResult(),
  );
  expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);

  final params = buildResultShareParams(bytes);
  expect(params.text, isNull);
  expect(params.title, 'Resumo da pesagem');
  expect(params.subject, 'Resumo da pesagem');
  expect(params.files, hasLength(1));
  expect(params.files!.single.mimeType, 'image/png');
  expect(params.fileNameOverrides, ['resumo-da-pesagem.png']);
});
```

Importar ou duplicar no arquivo de teste somente o fixture `buildCalculatedResult`; não importar outro arquivo de teste.

- [ ] **Step 2: Executar o teste e confirmar RED**

Run: `flutter test --no-version-check test/services/result_image_share_test.dart`

Expected: FAIL porque o serviço e a dependência `screenshot` ainda não existem.

- [ ] **Step 3: Adicionar a dependência e implementar o serviço mínimo**

Adicionar em `dependencies`:

```yaml
screenshot: ^3.0.0
```

Executar `flutter pub get --no-version-check` para atualizar `pubspec.lock`.

Criar `lib/services/result_image_share.dart` com estas assinaturas e parâmetros:

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/widgets/resultado_content.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

typedef CaptureResultImage =
    Future<Uint8List> Function(BuildContext context, PesoMedio resultado);
typedef ShareResultImage = Future<void> Function(Uint8List pngBytes);

Future<Uint8List> captureResultImage(
  BuildContext context,
  PesoMedio resultado,
) {
  final media = MediaQuery.of(context).copyWith(
    textScaler: TextScaler.noScaling,
  );
  final background = Theme.of(context).scaffoldBackgroundColor;

  return ScreenshotController().captureFromLongWidget(
    InheritedTheme.captureAll(
      context,
      MediaQuery(
        data: media,
        child: Material(
          color: background,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ResultadoContent(
              resultado: resultado,
              expandAllDetails: true,
            ),
          ),
        ),
      ),
    ),
    context: context,
    constraints: const BoxConstraints.tightFor(width: 420),
    pixelRatio: 2,
    delay: const Duration(milliseconds: 100),
  );
}
```

Construir o payload e executar o compartilhamento:

```dart
ShareParams buildResultShareParams(Uint8List pngBytes) {
  return ShareParams(
    title: 'Resumo da pesagem',
    subject: 'Resumo da pesagem',
    files: [XFile.fromData(pngBytes, mimeType: 'image/png')],
    fileNameOverrides: const ['resumo-da-pesagem.png'],
  );
}

Future<void> shareResultImage(Uint8List pngBytes) async {
  await SharePlus.instance.share(buildResultShareParams(pngBytes));
}
```

`XFile.fromData` deixa o `share_plus` criar o arquivo temporário no cache da aplicação; não persistir o PNG na galeria nem anexar o resumo textual.

- [ ] **Step 4: Executar teste e análise focados**

Run: `flutter test --no-version-check test/services/result_image_share_test.dart`

Expected: PASS com bytes iniciados pela assinatura PNG.

Run: `flutter analyze --no-version-check lib/services/result_image_share.dart lib/widgets/resultado_content.dart test/services/result_image_share_test.dart`

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/services/result_image_share.dart test/services/result_image_share_test.dart
git commit -m "feat: render shareable result image"
```

---

### Task 3: Integrar o fluxo assíncrono à tela de resultado

**Files:**
- Modify: `lib/ui/resultado_page.dart`
- Modify: `lib/widgets/pesagem_bottom_actions.dart`
- Modify: `test/ui/resultado_page_test.dart`
- Modify: `test/widgets/pesagem_components_test.dart`

**Interfaces:**
- Consumes: `CaptureResultImage`, `ShareResultImage`, `captureResultImage` e `shareResultImage` da Task 2.
- Produces: `ResultadoPage` com dependências opcionais `captureImage` e `onShare`, além de `PesagemBottomActions(primaryLoading: bool)`.

- [ ] **Step 1: Substituir o teste textual por testes RED do arquivo e concorrência**

Remover o teste `shares the same formatted summary shown on screen`. Adicionar imports de `dart:async` e `dart:typed_data`, e criar:

```dart
testWidgets('captures and shares one PNG image', (tester) async {
  final expectedBytes = Uint8List.fromList([137, 80, 78, 71]);
  Uint8List? sharedBytes;
  await tester.pumpWidget(
    MaterialApp(
      home: ResultadoPage(
        resultado: buildCalculatedResult(),
        captureImage: (_, _) async => expectedBytes,
        onShare: (bytes) async => sharedBytes = bytes,
      ),
    ),
  );

  await tester.tap(find.text('Compartilhar resumo'));
  await tester.pumpAndSettle();

  expect(sharedBytes, same(expectedBytes));
});

testWidgets('blocks repeated sharing while the image is being prepared', (
  tester,
) async {
  final capture = Completer<Uint8List>();
  var captureCalls = 0;
  var shareCalls = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: ResultadoPage(
        resultado: buildCalculatedResult(),
        captureImage: (_, _) {
          captureCalls++;
          return capture.future;
        },
        onShare: (_) async => shareCalls++,
      ),
    ),
  );

  await tester.tap(find.text('Compartilhar resumo'));
  await tester.pump();
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  await tester.tap(find.text('Compartilhar resumo'), warnIfMissed: false);
  expect(captureCalls, 1);

  capture.complete(Uint8List.fromList([137, 80, 78, 71]));
  await tester.pumpAndSettle();
  expect(shareCalls, 1);
  expect(find.byType(CircularProgressIndicator), findsNothing);
});
```

Preservar o teste existente de falha no compartilhamento, apenas adaptando a assinatura para bytes:

```dart
testWidgets('reports an injected sharing failure without a platform call', (
  tester,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ResultadoPage(
        resultado: buildCalculatedResult(),
        captureImage: (_, _) async => Uint8List.fromList([137, 80, 78, 71]),
        onShare: (_) => Future<void>.error(StateError('share failed')),
      ),
    ),
  );

  await tester.tap(find.text('Compartilhar resumo'));
  await tester.pumpAndSettle();
  expect(find.text('Não foi possível compartilhar o resumo'), findsOneWidget);
});
```

Adicionar também a falha de captura para cobrir a outra fronteira:

```dart
testWidgets('reports an image capture failure and keeps the result', (
  tester,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ResultadoPage(
        resultado: buildCalculatedResult(),
        captureImage: (_, _) => Future<Uint8List>.error(
          StateError('capture failed'),
        ),
        onShare: (_) async => fail('share must not be called'),
      ),
    ),
  );

  await tester.tap(find.text('Compartilhar resumo'));
  await tester.pumpAndSettle();
  expect(find.text('Não foi possível compartilhar o resumo'), findsOneWidget);
  expect(find.text('892 g'), findsOneWidget);
});
```

Atualizar os demais `onShare` existentes para receber `Uint8List` sem expectativas textuais.

- [ ] **Step 2: Adicionar teste RED do botão em processamento**

Em `test/widgets/pesagem_components_test.dart`, adicionar:

```dart
testWidgets('primary action shows progress and is disabled while loading', (
  tester,
) async {
  var taps = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        bottomNavigationBar: PesagemBottomActions(
          secondaryLabel: 'Nova pesagem',
          primaryLabel: 'Compartilhar resumo',
          onSecondary: () {},
          onPrimary: () => taps++,
          primaryLoading: true,
        ),
      ),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  await tester.tap(find.text('Compartilhar resumo'), warnIfMissed: false);
  expect(taps, 0);
});
```

- [ ] **Step 3: Executar os testes e confirmar RED**

Run: `flutter test --no-version-check test/ui/resultado_page_test.dart test/widgets/pesagem_components_test.dart`

Expected: FAIL porque `ResultadoPage` ainda recebe compartilhamento textual e `PesagemBottomActions` não possui `primaryLoading`.

- [ ] **Step 4: Implementar o estado de processamento e as dependências injetáveis**

Converter `ResultadoPage` para `StatefulWidget` e definir:

```dart
const ResultadoPage({
  super.key,
  required this.resultado,
  this.captureImage,
  this.onShare,
});

final PesoMedio resultado;
final CaptureResultImage? captureImage;
final ShareResultImage? onShare;
```

No estado, implementar uma única operação por vez:

```dart
bool _isSharing = false;

Future<void> _share() async {
  if (_isSharing) return;
  setState(() => _isSharing = true);
  try {
    final bytes = await (widget.captureImage ?? captureResultImage)(
      context,
      widget.resultado,
    );
    if (!mounted) return;
    await (widget.onShare ?? shareResultImage)(bytes);
  } catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível compartilhar o resumo')),
    );
  } finally {
    if (mounted) setState(() => _isSharing = false);
  }
}
```

Passar `_isSharing` às ações:

```dart
PesagemBottomActions(
  secondaryLabel: 'Nova pesagem',
  primaryLabel: 'Compartilhar resumo',
  onSecondary: () => Navigator.pop(context, ResultadoAction.novaPesagem),
  onPrimary: _share,
  primaryLoading: _isSharing,
)
```

Em `PesagemBottomActions`, adicionar `this.primaryLoading = false`, declarar `final bool primaryLoading` e alterar apenas o `FilledButton`:

```dart
FilledButton(
  onPressed: primaryLoading ? null : onPrimary,
  style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
  child: primaryLoading
      ? Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: 0, child: Text(primaryLabel)),
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        )
      : Text(primaryLabel),
)
```

O `Text(primaryLabel)` transparente preserva largura e semântica enquanto o indicador fornece o estado visual de processamento.

- [ ] **Step 5: Executar testes focados e confirmar GREEN**

Run: `flutter test --no-version-check test/ui/resultado_page_test.dart test/widgets/pesagem_components_test.dart test/services/result_image_share_test.dart`

Expected: PASS para compartilhamento único, bloqueio concorrente, erro, composição completa e PNG.

- [ ] **Step 6: Executar verificação completa**

Run: `flutter test --no-version-check`

Expected: todos os testes PASS.

Run: `flutter analyze --no-version-check`

Expected: `No issues found!`

Run: `flutter build apk --debug --no-pub`

Expected: APK debug gerado em `build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 7: Commit**

```bash
git add lib/ui/resultado_page.dart lib/widgets/pesagem_bottom_actions.dart test/ui/resultado_page_test.dart test/widgets/pesagem_components_test.dart
git commit -m "feat: share formatted result image"
```

---

### Task 4: Revisão final de requisitos e higiene

**Files:**
- Review: all files changed by Tasks 1–3

**Interfaces:**
- Consumes: implementation complete from Tasks 1–3.
- Produces: evidence that the branch is ready for review without generated artifacts.

- [ ] **Step 1: Conferir o diff contra a especificação**

Run: `git diff master...HEAD -- lib test pubspec.yaml pubspec.lock`

Confirmar explicitamente: PNG; todos os detalhes; ausência de AppBar e botões na composição; largura 420; margem 16; `pixelRatio` 2; sem texto completo; bloqueio concorrente; mensagem exata de erro.

- [ ] **Step 2: Conferir higiene do repositório**

Run: `git status --short`

Expected: nenhum arquivo gerado ou alteração não commitada.

Run: `git diff --check master...HEAD`

Expected: nenhuma saída.

- [ ] **Step 3: Solicitar revisão de código**

Usar `superpowers:requesting-code-review` com a especificação `docs/superpowers/specs/2026-08-13-compartilhamento-visual-resultado-design.md`, este plano e o diff completo. Corrigir qualquer achado Critical ou Important com novo ciclo RED/GREEN antes de finalizar.
