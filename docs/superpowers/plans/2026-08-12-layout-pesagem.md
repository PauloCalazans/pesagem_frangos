# Pesagem Layout Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesenhar o fluxo de pesagem em três etapas compactas e apresentar resultados hierarquizados, incluindo percentual total do padrão e viabilidade do lote.

**Architecture:** Manter o cálculo no modelo `PesoMedio`, extrair validações puras para uma unidade de domínio e dividir a interface em componentes pequenos de formulário e resultado. `HomePage` continua responsável por coordenar controladores, etapa atual e navegação; `ResultadoPage` recebe um `PesoMedio` já calculado e apenas apresenta seus valores.

**Tech Stack:** Flutter 3.44.9, Dart 3.12.2, Material 3, `flutter_localizations`, `intl`, `shared_preferences`, `share_plus 13.3.0`, `flutter_test`.

## Global Constraints

- Preservar o fluxo de três etapas em orientação retrato.
- Usar Material 3, primária `#087F72`, progresso `#D7EF68`, fundo `#F6F8F7`, superfícies `#FFFFFF` e texto `#1B2529`.
- Usar grade de 8 px, margens laterais de 16 px, campos de aproximadamente 56 px, cantos de aproximadamente 12 px e alvos de toque de no mínimo 48 px.
- Mostrar unidades explícitas: `dias`, `g`, `kg` e `aves`.
- Mostrar o percentual total do padrão, por exemplo `102,1%`, nunca apenas “2,1% acima”.
- Calcular viabilidade como `avesVivas / avesAlojadas * 100`.
- Manter os dados preenchidos ao avançar, voltar e fechar o resultado.
- Atender contraste WCAG AA e não depender somente de cor para sucesso, atenção ou erro.
- Adicionar somente `share_plus: ^13.3.0` para abrir o compartilhamento nativo de texto.
- Preservar alterações locais existentes e limitar cada commit aos arquivos declarados na tarefa.
- Validar a entrega com `flutter analyze --no-version-check`, `flutter test --no-version-check` e `flutter build apk --debug --no-pub`.

---

## File Structure

### Domain

- `lib/models/peso_medio.dart`: cálculos numéricos e resultados da pesagem.
- `lib/util/pesagem_validation.dart`: regras puras de validação dos campos e das leituras.
- `test/models/peso_medio_test.dart`: cobertura das fórmulas e casos-limite.
- `test/util/pesagem_validation_test.dart`: cobertura das validações cruzadas.

### Shared presentation

- `lib/theme/app_theme.dart`: tema Material 3 e tokens visuais aprovados.
- `lib/widgets/measurement_field.dart`: campo numérico com unidade e ajuda.
- `lib/widgets/pesagem_progress_header.dart`: título da etapa e barra de progresso.
- `lib/widgets/pesagem_bottom_actions.dart`: navegação inferior fixa.
- `test/widgets/pesagem_components_test.dart`: comportamento e adaptação dos componentes.

### Weighing flow

- `lib/ui/pesagem/pesagem_form_controllers.dart`: propriedade e descarte dos controladores de texto.
- `lib/ui/pesagem/lote_step.dart`: campos da etapa 1.
- `lib/ui/pesagem/consumo_step.dart`: campos da etapa 2.
- `lib/ui/pesagem/balancas_step.dart`: entrada e resumo das leituras.
- `lib/ui/home_page.dart`: coordenação das etapas, validação, cálculo e navegação.
- `test/ui/home_page_test.dart`: fluxo, preservação e validações por etapa.

### Results and standards

- `lib/ui/resultado_page.dart`: tela completa de resultados.
- `lib/widgets/result_hero_card.dart`: peso médio, percentual e padrão.
- `lib/widgets/viability_card.dart`: viabilidade e aves vivas.
- `lib/widgets/metric_card.dart`: métrica secundária.
- `lib/widgets/result_details_section.dart`: detalhes recolhíveis.
- `test/ui/resultado_page_test.dart`: hierarquia, formatação e detalhes.
- `lib/ui/add_pesopadrao_page.dart`: apresentação Material 3 da edição dos padrões.
- `test/ui/add_pesopadrao_page_test.dart`: acesso, listagem, inclusão e edição.

---

### Task 1: Harden Calculations and Add Viability

**Files:**
- Modify: `lib/models/peso_medio.dart`
- Create: `test/models/peso_medio_test.dart`

**Interfaces:**
- Consumes: constructor `PesoMedio({required int idade, required int avesPesadas, required int avesAlojadas, required int pesoPadrao, required int racaoRecebida, required int estoqueRacao, required int tara, required List<String> balancas, required int mortalidade})`.
- Produces: `double viabilidade`, `double diferencaPeso`, and `void calcular()` with finite results for valid input.

- [ ] **Step 1: Write failing calculation tests**

Create a helper and explicit expectations in `test/models/peso_medio_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';

PesoMedio buildPesoMedio({
  int mortalidade = 258,
  List<String> balancas = const ['27010', '27010', '27010', '27010'],
}) {
  return PesoMedio(
    idade: 21,
    avesPesadas: 120,
    avesAlojadas: 10000,
    pesoPadrao: 874,
    racaoRecebida: 30000,
    estoqueRacao: 1570,
    tara: 250,
    balancas: balancas,
    mortalidade: mortalidade,
  )..calcular();
}

void main() {
  test('calcula percentual total, diferença e viabilidade', () {
    final resultado = buildPesoMedio();

    expect(resultado.pesoMedio, closeTo(892, 0.001));
    expect(resultado.porcentagem, closeTo(102.059, 0.001));
    expect(resultado.diferencaPeso, closeTo(18, 0.001));
    expect(resultado.avesVivas, 9742);
    expect(resultado.viabilidade, closeTo(97.42, 0.001));
  });

  test('ignora linhas vazias sem aceitar leituras inválidas', () {
    final resultado = buildPesoMedio(
      balancas: const ['27010', '', '27010', '  ', '27010', '27010'],
    );

    expect(resultado.balancadas, 4);
    expect(resultado.pesoTotal, 108040);
  });

  test('calcula 100% de viabilidade quando não há mortalidade', () {
    expect(buildPesoMedio(mortalidade: 0).viabilidade, 100);
  });
}
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test --no-version-check test/models/peso_medio_test.dart`

Expected: FAIL because `diferencaPeso` and `viabilidade` do not exist.

- [ ] **Step 3: Implement the smallest model change**

Add fields and formulas to `PesoMedio`:

```dart
late double viabilidade;
late double diferencaPeso;

void calcularDiferencaPeso() {
  diferencaPeso = pesoMedio - pesoPadrao;
}

void calcularViabilidade() {
  viabilidade = (avesVivas / avesAlojadas) * 100;
}
```

Normalize balance parsing through one private getter so `contarBalancas` and `somarPesoBalancas` use the same accepted values:

```dart
Iterable<int> get _pesosValidos => balancas
    .map((peso) => int.tryParse(peso.trim()))
    .whereType<int>()
    .where((peso) => peso > 0);
```

Call `calcularDiferencaPeso()` after `calcularPesoMedio()` and `calcularViabilidade()` after `calcularAvesVivas()`.

- [ ] **Step 4: Run tests and verify GREEN**

Run: `flutter test --no-version-check test/models/peso_medio_test.dart`

Expected: PASS, 3 tests.

- [ ] **Step 5: Format and commit**

```powershell
dart format lib/models/peso_medio.dart test/models/peso_medio_test.dart
git add lib/models/peso_medio.dart test/models/peso_medio_test.dart
git commit -m "feat: add flock viability calculation"
```

---

### Task 2: Add Cross-Field Validation Rules

**Files:**
- Create: `lib/util/pesagem_validation.dart`
- Create: `test/util/pesagem_validation_test.dart`

**Interfaces:**
- Consumes: raw field strings from `TextEditingController.text`.
- Produces: `String? requiredPositive(String? value, {required String label})`, `String? nonNegative(String? value, {required String label, bool allowEmpty = false})`, `String? validateMortalidade({required String? mortalidade, required String? avesAlojadas})`, `String? validateEstoque({required String? estoque, required String? racaoRecebida})`, and `String? validateBalancas(String? value)`.

- [ ] **Step 1: Write failing validation tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/util/pesagem_validation.dart';

void main() {
  group('PesagemValidation', () {
    test('exige inteiro maior que zero', () {
      expect(
        PesagemValidation.requiredPositive('0', label: 'Idade'),
        'Idade deve ser maior que zero',
      );
      expect(
        PesagemValidation.requiredPositive('21', label: 'Idade'),
        isNull,
      );
    });

    test('mortalidade deve ser menor que aves alojadas', () {
      expect(
        PesagemValidation.validateMortalidade(
          mortalidade: '100',
          avesAlojadas: '100',
        ),
        'Mortalidade deve ser menor que aves alojadas',
      );
    });

    test('estoque não pode superar ração recebida', () {
      expect(
        PesagemValidation.validateEstoque(
          estoque: '301',
          racaoRecebida: '300',
        ),
        'Estoque não pode superar a ração recebida',
      );
    });

    test('balanças exigem ao menos uma leitura positiva', () {
      expect(
        PesagemValidation.validateBalancas('\n0\ntexto'),
        'Informe ao menos uma pesagem válida',
      );
      expect(PesagemValidation.validateBalancas('1200\n1300'), isNull);
    });
  });
}
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test --no-version-check test/util/pesagem_validation_test.dart`

Expected: FAIL because `PesagemValidation` is undefined.

- [ ] **Step 3: Implement pure validators**

Create a non-instantiable class:

```dart
class PesagemValidation {
  PesagemValidation._();

  static int? _integer(String? value) => int.tryParse(value?.trim() ?? '');

  static String? requiredPositive(String? value, {required String label}) {
    final parsed = _integer(value);
    if (parsed == null) return 'Informe $label em números inteiros';
    if (parsed <= 0) return '$label deve ser maior que zero';
    return null;
  }

  static String? nonNegative(
    String? value, {
    required String label,
    bool allowEmpty = false,
  }) {
    if ((value ?? '').trim().isEmpty && allowEmpty) return null;
    final parsed = _integer(value);
    if (parsed == null) return 'Informe $label em números inteiros';
    if (parsed < 0) return '$label não pode ser negativo';
    return null;
  }
}
```

Implement the three cross-field methods with the exact messages asserted above. `validateBalancas` must trim each line, accept only parsed integers greater than zero, and reject any nonempty nonnumeric line.

```dart
static String? validateMortalidade({
  required String? mortalidade,
  required String? avesAlojadas,
}) {
  final baseError = nonNegative(mortalidade, label: 'Mortalidade');
  if (baseError != null) return baseError;
  final alojadas = _integer(avesAlojadas);
  final mortes = _integer(mortalidade)!;
  if (alojadas != null && mortes >= alojadas) {
    return 'Mortalidade deve ser menor que aves alojadas';
  }
  return null;
}

static String? validateEstoque({
  required String? estoque,
  required String? racaoRecebida,
}) {
  final baseError = nonNegative(estoque, label: 'Estoque');
  if (baseError != null) return baseError;
  final recebida = _integer(racaoRecebida);
  final atual = _integer(estoque)!;
  if (recebida != null && atual > recebida) {
    return 'Estoque não pode superar a ração recebida';
  }
  return null;
}

static String? validateBalancas(String? value) {
  final lines = (value ?? '').split('\n').map((line) => line.trim());
  if (lines.any((line) => line.isNotEmpty && int.tryParse(line) == null)) {
    return 'Use somente números, uma pesagem por linha';
  }
  final valid = lines
      .map(int.tryParse)
      .whereType<int>()
      .where((weight) => weight > 0);
  return valid.isEmpty ? 'Informe ao menos uma pesagem válida' : null;
}
```

- [ ] **Step 4: Run validation and model tests**

Run: `flutter test --no-version-check test/util/pesagem_validation_test.dart test/models/peso_medio_test.dart`

Expected: PASS, 7 tests.

- [ ] **Step 5: Format and commit**

```powershell
dart format lib/util/pesagem_validation.dart test/util/pesagem_validation_test.dart
git add lib/util/pesagem_validation.dart test/util/pesagem_validation_test.dart
git commit -m "feat: validate weighing inputs"
```

---

### Task 3: Establish the Material 3 Theme and Shared Form Components

**Files:**
- Create: `lib/theme/app_theme.dart`
- Create: `lib/widgets/measurement_field.dart`
- Create: `lib/widgets/pesagem_progress_header.dart`
- Create: `lib/widgets/pesagem_bottom_actions.dart`
- Modify: `lib/main.dart`
- Create: `test/widgets/pesagem_components_test.dart`

**Interfaces:**
- Consumes: `TextEditingController`, validator callbacks, current step, total steps and navigation callbacks.
- Produces: `AppTheme.light`, `MeasurementField`, `PesagemProgressHeader`, and `PesagemBottomActions`.

- [ ] **Step 1: Write failing component tests**

Test the approved labels, semantics and dimensions:

```dart
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
```

Add a third test that pumps `PesagemBottomActions` and asserts `Voltar` and `Continuar` have tappable sizes of at least 48 logical pixels.

```dart
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
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test --no-version-check test/widgets/pesagem_components_test.dart`

Expected: FAIL because the theme and widgets do not exist.

- [ ] **Step 3: Implement the approved theme**

Expose the theme through:

```dart
abstract final class AppTheme {
  static const primary = Color(0xFF087F72);
  static const progress = Color(0xFFD7EF68);
  static const background = Color(0xFFF6F8F7);
  static const text = Color(0xFF1B2529);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: const Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: background,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          constraints: BoxConstraints(minHeight: 56),
        ),
      );
}
```

Set `theme: AppTheme.light` in `MyApp`.

- [ ] **Step 4: Implement the three components**

Use these public constructors:

```dart
const MeasurementField({
  super.key,
  required this.label,
  required this.controller,
  this.formFieldKey,
  this.focusNode,
  this.unit,
  this.helperText,
  this.validator,
  this.textInputAction = TextInputAction.next,
  this.onFieldSubmitted,
});

const PesagemProgressHeader({
  super.key,
  required this.title,
  required this.currentStep,
  required this.totalSteps,
});

const PesagemBottomActions({
  super.key,
  required this.secondaryLabel,
  required this.primaryLabel,
  required this.onSecondary,
  required this.onPrimary,
});
```

`MeasurementField` uses numeric input, visible suffix, `AutovalidateMode.onUserInteraction`, and a minimum height of 56. The header computes `currentStep / totalSteps`. The bottom bar wraps both controls in `SafeArea` and enforces a minimum height of 48.

- [ ] **Step 5: Run tests, format and analyze the touched files**

```powershell
dart format lib/theme lib/widgets/measurement_field.dart lib/widgets/pesagem_progress_header.dart lib/widgets/pesagem_bottom_actions.dart lib/main.dart test/widgets/pesagem_components_test.dart
flutter test --no-version-check test/widgets/pesagem_components_test.dart
flutter analyze --no-version-check lib/theme lib/widgets/measurement_field.dart lib/widgets/pesagem_progress_header.dart lib/widgets/pesagem_bottom_actions.dart lib/main.dart
```

Expected: component tests PASS and analyzer reports no issues in the listed files.

- [ ] **Step 6: Commit**

```powershell
git add lib/theme/app_theme.dart lib/widgets/measurement_field.dart lib/widgets/pesagem_progress_header.dart lib/widgets/pesagem_bottom_actions.dart lib/main.dart test/widgets/pesagem_components_test.dart
git commit -m "feat: add pesagem visual system"
```

---

### Task 4: Build and Integrate the Three-Step Form

**Files:**
- Create: `lib/ui/pesagem/pesagem_form_controllers.dart`
- Create: `lib/ui/pesagem/lote_step.dart`
- Create: `lib/ui/pesagem/consumo_step.dart`
- Create: `lib/ui/pesagem/balancas_step.dart`
- Modify: `lib/ui/home_page.dart`
- Delete: `lib/widgets/stepper_custom.dart`
- Modify: `test/widget_test.dart`
- Create: `test/ui/home_page_test.dart`

**Interfaces:**
- Consumes: validators from Task 2 and shared widgets from Task 3.
- Produces: `enum PesagemField`, `PesagemFormControllers`, the three step widgets, and a `HomePage` that validates and focuses the first invalid field before opening `ResultadoPage(resultado: pesoMedio)`.

- [ ] **Step 1: Write failing navigation and preservation tests**

Initialize mocked preferences in `setUp`, pump `MyApp`, and assert the new copy:

```dart
testWidgets('navigates through steps and preserves lot data', (tester) async {
  await pumpPesagemApp(tester);
  Finder input(String key) => find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(EditableText),
      );

  expect(find.text('Dados do lote · etapa 1 de 3'), findsOneWidget);
  await tester.enterText(input('idadeField'), '21');
  await tester.enterText(input('avesAlojadasField'), '10000');
  await tester.enterText(input('mortalidadeField'), '258');
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();

  expect(find.text('Consumo e amostra · etapa 2 de 3'), findsOneWidget);
  await tester.tap(find.text('Voltar'));
  await tester.pumpAndSettle();
  expect(find.text('21'), findsOneWidget);
  expect(find.text('10000'), findsOneWidget);
});
```

Add focused tests for automatic weight population, mortality equal to housed birds, stock above received feed, and an invalid balance line.

```dart
testWidgets('focuses the first invalid field in the current step', (tester) async {
  await pumpPesagemApp(tester);
  await tester.tap(find.text('Continuar'));
  await tester.pump();

  expect(find.text('Idade deve ser maior que zero'), findsOneWidget);
  final field = tester.widget<TextFormField>(
    find.descendant(
      of: find.byKey(const Key('idadeField')),
      matching: find.byType(TextFormField),
    ),
  );
  expect(field.focusNode!.hasFocus, isTrue);
});

testWidgets('rejects mortality equal to housed birds', (tester) async {
  await pumpPesagemApp(tester);
  Finder input(String key) => find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(EditableText),
      );
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
```

For automatic weight, seed `padraoMacho` with values for ages 0–21, enter age `21`, and expect the twenty-second value in `pesoPadraoField`. For stock and balance errors, navigate to their respective steps and assert the exact messages from Task 2.

- [ ] **Step 2: Run the focused tests and verify RED**

Run: `flutter test --no-version-check test/ui/home_page_test.dart test/widget_test.dart`

Expected: FAIL because the new labels, keys and navigation structure are absent.

- [ ] **Step 3: Introduce controller ownership**

`PesagemFormControllers` owns the nine existing controllers and exposes:

```dart
class PesagemFormControllers {
  final idade = TextEditingController();
  final pesoPadrao = TextEditingController();
  final avesAlojadas = TextEditingController();
  final mortalidade = TextEditingController();
  final racaoRecebida = TextEditingController();
  final estoque = TextEditingController();
  final tara = TextEditingController();
  final avesPesadas = TextEditingController();
  final balancas = TextEditingController();

  void dispose() {
    for (final controller in [
      idade,
      pesoPadrao,
      avesAlojadas,
      mortalidade,
      racaoRecebida,
      estoque,
      tara,
      avesPesadas,
      balancas,
    ]) {
      controller.dispose();
    }
  }
}
```

Add field identity, form keys and focus nodes to the same owner:

```dart
enum PesagemField {
  idade,
  pesoPadrao,
  avesAlojadas,
  mortalidade,
  racaoRecebida,
  estoque,
  tara,
  avesPesadas,
  balancas,
}

final fieldKeys = <PesagemField, GlobalKey<FormFieldState<String>>>{
  for (final field in PesagemField.values)
    field: GlobalKey<FormFieldState<String>>(),
};
final focusNodes = <PesagemField, FocusNode>{
  for (final field in PesagemField.values) field: FocusNode(),
};
```

Dispose every `FocusNode` together with the text controllers.

- [ ] **Step 4: Implement the three stateless step widgets**

Use exact contracts:

```dart
LoteStep({
  required GlobalKey<FormState> formKey,
  required PesagemFormControllers controllers,
  required String sexo,
  required ValueChanged<String> onSexoChanged,
});

ConsumoStep({
  required GlobalKey<FormState> formKey,
  required PesagemFormControllers controllers,
});

BalancasStep({
  required GlobalKey<FormState> formKey,
  required PesagemFormControllers controllers,
});
```

Assign stable widget keys `sexoField`, `idadeField`, `pesoPadraoField`, `avesAlojadasField`, `mortalidadeField`, `racaoRecebidaField`, `estoqueField`, `taraField`, `avesPesadasField`, and `balancasField`. Each `MeasurementField` receives the corresponding `fieldKeys[field]` through `formFieldKey` and `focusNodes[field]` through `focusNode`; Task 3 declares both optional constructor parameters and passes `formFieldKey` to the inner `TextFormField.key`. Use the validators from Task 2. Tara remains optional and uses `PesagemValidation.nonNegative(value, label: 'Tara', allowEmpty: true)`; an empty tara is converted to zero when constructing `PesoMedio`.

- [ ] **Step 5: Replace `StepperCustom` coordination in `HomePage`**

Use one `GlobalKey<FormState>` per step, an indexed list of titles and `AnimatedSwitcher` for the current child:

```dart
final _stepKeys = List.generate(3, (_) => GlobalKey<FormState>());
final _controllers = PesagemFormControllers();
int _currentStep = 0;

void _continue() {
  if (!_validateAndFocusCurrentStep()) return;
  if (_currentStep < 2) {
    setState(() => _currentStep++);
    return;
  }
  _calculateAndOpenResult();
}
```

Implement ordered error focus without duplicating validation rules:

```dart
bool _validateAndFocusCurrentStep() {
  final valid = _stepKeys[_currentStep].currentState!.validate();
  if (valid) return true;
  final order = <List<PesagemField>>[
    [
      PesagemField.idade,
      PesagemField.pesoPadrao,
      PesagemField.avesAlojadas,
      PesagemField.mortalidade,
    ],
    [
      PesagemField.racaoRecebida,
      PesagemField.estoque,
      PesagemField.tara,
      PesagemField.avesPesadas,
    ],
    [PesagemField.balancas],
  ];
  final invalid = order[_currentStep].firstWhere(
    (field) => _controllers.fieldKeys[field]!.currentState?.hasError ?? false,
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = _controllers.fieldKeys[invalid]!.currentContext;
    _controllers.focusNodes[invalid]!.requestFocus();
    if (context != null) Scrollable.ensureVisible(context, alignment: 0.2);
  });
  return false;
}
```

Build the screen with `PesagemProgressHeader`, `Expanded(SingleChildScrollView(...))`, and `PesagemBottomActions`. Dispose `_controllers` in `dispose`. Remove `StepperCustom` after all references are gone.

- [ ] **Step 6: Update the startup smoke test**

Change expectations in `test/widget_test.dart` to `Nova pesagem`, `Dados do lote · etapa 1 de 3`, `Sexo`, and `Continuar`.

- [ ] **Step 7: Run tests and verify GREEN**

Run: `flutter test --no-version-check test/ui/home_page_test.dart test/widget_test.dart test/widgets/pesagem_components_test.dart`

Expected: all flow and shared-component tests PASS.

- [ ] **Step 8: Format and commit**

```powershell
dart format lib/ui/home_page.dart lib/ui/pesagem test/ui/home_page_test.dart test/widget_test.dart
git add lib/ui/home_page.dart lib/ui/pesagem lib/widgets/stepper_custom.dart test/ui/home_page_test.dart test/widget_test.dart
git commit -m "feat: redesign weighing form flow"
```

---

### Task 5: Implement the Hierarchical Results Screen

**Files:**
- Create: `lib/ui/resultado_page.dart`
- Create: `lib/widgets/result_hero_card.dart`
- Create: `lib/widgets/viability_card.dart`
- Create: `lib/widgets/metric_card.dart`
- Create: `lib/widgets/result_details_section.dart`
- Modify: `lib/ui/home_page.dart`
- Modify: `lib/util/util.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Create: `test/ui/resultado_page_test.dart`

**Interfaces:**
- Consumes: a calculated `PesoMedio resultado` and the theme from Task 3.
- Produces: `enum ResultadoAction { novaPesagem }`, `typedef ShareText = Future<void> Function(String text)`, `ResultadoPage({required PesoMedio resultado, ShareText? onShare})`, `Util.formatDecimal(double value, {int decimals = 1})`, and `Util.formatInteger(num value)`.

- [ ] **Step 1: Write failing result hierarchy tests**

```dart
testWidgets('shows total standard percentage and viability', (tester) async {
  final resultado = buildCalculatedResult();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: ResultadoPage(resultado: resultado),
    ),
  );

  expect(find.text('892 g'), findsOneWidget);
  expect(find.text('102,1%'), findsOneWidget);
  expect(find.text('97,42%'), findsOneWidget);
  expect(find.text('9.742 aves vivas'), findsOneWidget);
  expect(find.textContaining('2,1% acima'), findsNothing);
});
```

Add one test that taps `Detalhes da pesagem` and finds `Peso total`, `Desconto da tara`, `Média das balanças`, and `Balanças consideradas`. Add one test that closes the result and verifies the previously entered age remains in `HomePage`.

```dart
testWidgets('expands weighing audit details', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: ResultadoPage(resultado: buildCalculatedResult())),
  );
  await tester.tap(find.text('Detalhes da pesagem'));
  await tester.pumpAndSettle();

  expect(find.text('Peso total'), findsOneWidget);
  expect(find.text('Desconto da tara'), findsOneWidget);
  expect(find.text('Média das balanças'), findsOneWidget);
  expect(find.text('Balanças consideradas'), findsOneWidget);
});
```

Add a sharing test with an injected callback so it does not open a platform sheet during tests:

```dart
testWidgets('shares the same formatted summary shown on screen', (tester) async {
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
});
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test --no-version-check test/ui/resultado_page_test.dart`

Expected: FAIL because `ResultadoPage` and result widgets do not exist.

- [ ] **Step 3: Centralize locale-aware number formatting**

Replace the ambiguous patterns in `Util` with:

```dart
static String formatDecimal(double value, {int decimals = 1}) {
  final pattern = switch (decimals) {
    0 => '#,##0',
    1 => '#,##0.0',
    2 => '#,##0.00',
    3 => '#,##0.000',
    _ => throw ArgumentError.value(decimals, 'decimals', 'Use 0, 1, 2 ou 3'),
  };
  return NumberFormat(pattern, 'pt_BR').format(value);
}

static String formatInteger(num value) =>
    NumberFormat.decimalPattern('pt_BR').format(value);
```

Replace calls to `nfCa()` with `formatDecimal(resultado.ca, decimals: 3)` and remove `nfCa()` after its last caller is migrated.

- [ ] **Step 4: Implement focused result components**

Use these contracts:

```dart
const ResultHeroCard({
  super.key,
  required this.pesoMedio,
  required this.percentualPadrao,
  required this.pesoPadrao,
  required this.diferencaPeso,
});

const ViabilityCard({
  super.key,
  required this.viabilidade,
  required this.avesVivas,
});

const MetricCard({
  super.key,
  required this.label,
  required this.value,
});

const ResultDetailsSection({
  super.key,
  required this.title,
  required this.children,
  this.initiallyExpanded = false,
});
```

`ResultHeroCard` must format the percentage as the total value. `ViabilityCard` must show the percentage with two decimals and the number of birds. `ResultDetailsSection` uses `ExpansionTile` and a semantic button label.

Populate result sections exactly as follows:

```dart
ResultDetailsSection(
  title: 'Detalhes da pesagem',
  children: [
    ResultLine(label: 'Peso total', value: '${Util.formatInteger(r.pesoTotal)} g'),
    ResultLine(label: 'Desconto da tara', value: '${Util.formatInteger(r.desconto)} g'),
    ResultLine(
      label: 'Média das balanças',
      value: '${Util.formatDecimal((r.pesoTotal - r.desconto) / r.balancadas)} g',
    ),
    ResultLine(label: 'Balanças consideradas', value: '${r.balancadas}'),
  ],
),
ResultDetailsSection(
  title: 'Plantel e alimentação',
  children: [
    ResultLine(label: 'Aves alojadas', value: '${r.avesAlojadas}'),
    ResultLine(label: 'Mortalidade', value: '${r.mortalidade} aves'),
    ResultLine(label: 'Ração recebida', value: '${r.racaoRecebida} kg'),
    ResultLine(label: 'Estoque atual', value: '${r.estoqueRacao} kg'),
  ],
),
```

Export `ResultLine({required String label, required String value})` from `result_details_section.dart` because `ResultadoPage` constructs the rows directly.

- [ ] **Step 5: Build `ResultadoPage` and wire navigation**

Use `Scaffold` with title `Resultado`, a scrollable body, and bottom actions `Nova pesagem` and `Compartilhar resumo`. Replace the existing modal bottom sheet in `_calcularPeso` with:

```dart
await Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) => ResultadoPage(resultado: resultado),
  ),
);
```

Declare `enum ResultadoAction { novaPesagem }`. Returning from this route with the system back action must not clear `PesagemFormControllers`. The `Nova pesagem` button calls `Navigator.pop(context, ResultadoAction.novaPesagem)`; `HomePage` clears controllers and returns to step zero only when that exact result is received.

- [ ] **Step 6: Add native text sharing and its injectable boundary**

Add `share_plus: ^13.3.0` to `pubspec.yaml`, run `flutter pub get`, and create `String buildResumoPesagem(PesoMedio resultado)` in `resultado_page.dart` containing the same formatted weight, total percentage, viability, GMD and conversion shown on screen. Define the default boundary with the current package API:

```dart
typedef ShareText = Future<void> Function(String text);

Future<void> shareTextNative(String text) async {
  await SharePlus.instance.share(
    ShareParams(
      title: 'Resumo da pesagem',
      subject: 'Resumo da pesagem',
      text: text,
    ),
  );
}
```

`ResultadoPage` invokes `onShare ?? shareTextNative`. The widget test injects `onShare`; production opens the native share sheet.

- [ ] **Step 7: Run tests and verify GREEN**

Run: `flutter test --no-version-check test/ui/resultado_page_test.dart test/ui/home_page_test.dart test/models/peso_medio_test.dart`

Expected: all result, flow and calculation tests PASS.

- [ ] **Step 8: Format and commit**

```powershell
dart format lib/ui/resultado_page.dart lib/ui/home_page.dart lib/widgets/result_hero_card.dart lib/widgets/viability_card.dart lib/widgets/metric_card.dart lib/widgets/result_details_section.dart lib/util/util.dart test/ui/resultado_page_test.dart
git add lib/ui/resultado_page.dart lib/ui/home_page.dart lib/widgets/result_hero_card.dart lib/widgets/viability_card.dart lib/widgets/metric_card.dart lib/widgets/result_details_section.dart lib/util/util.dart pubspec.yaml pubspec.lock test/ui/resultado_page_test.dart
git commit -m "feat: add hierarchical weighing results"
```

---

### Task 6: Redesign Weight-Standard Access and Editing

**Files:**
- Modify: `lib/ui/home_page.dart`
- Modify: `lib/ui/add_pesopadrao_page.dart`
- Create: `test/ui/add_pesopadrao_page_test.dart`

**Interfaces:**
- Consumes: existing `Util.getListPesoPadrao`, `mPrefs`, and the approved Material theme.
- Produces: a named `Padrões de peso` menu action and an accessible standards editor with visible edit/delete actions.

- [ ] **Step 1: Write failing menu and editor tests**

```dart
testWidgets('opens weight standards through a named menu action', (tester) async {
  await pumpPesagemApp(tester);
  await tester.tap(find.byTooltip('Mais opções'));
  await tester.pumpAndSettle();
  expect(find.text('Padrões de peso'), findsOneWidget);
});
```

Add tests that select `Macho`, find headers `Idade` and `Peso padrão`, add a numeric standard, edit a row through a visible `Editar` action, and reject deletion for `Misto` with the existing explanatory message.

```dart
testWidgets('adds and exposes visible row actions', (tester) async {
  await pumpStandardsPage(tester, initialValues: {
    'padraoMacho': <String>['42', '56'],
    'padraoFemea': <String>['40', '54'],
  });

  expect(find.text('Idade'), findsOneWidget);
  expect(find.text('Peso padrão'), findsWidgets);
  await tester.enterText(find.byKey(const Key('novoPesoPadraoField')), '70');
  await tester.tap(find.text('Adicionar'));
  await tester.pumpAndSettle();
  expect(find.text('70 g'), findsOneWidget);

  await tester.tap(find.byTooltip('Ações da idade 2'));
  await tester.pumpAndSettle();
  expect(find.text('Editar'), findsOneWidget);
  expect(find.text('Excluir'), findsOneWidget);
});
```

`pumpStandardsPage` calls `SharedPreferences.setMockInitialValues`, initializes `mPrefs`, and pumps `MaterialApp(theme: AppTheme.light, home: AddPesopadraoPage())`. The mixed-standard deletion test selects `Misto`, opens a row menu, taps `Excluir`, and asserts `O padrão do Misto é calculado a partir dos outros`.

- [ ] **Step 2: Run the focused tests and verify RED**

Run: `flutter test --no-version-check test/ui/add_pesopadrao_page_test.dart`

Expected: FAIL because access still uses an unlabeled pencil and row actions require a long press.

- [ ] **Step 3: Replace the pencil with a named overflow action**

Use `PopupMenuButton` with tooltip `Mais opções` and a `PopupMenuItem` containing icon plus text `Padrões de peso`. Navigate to `AddPesopadraoPage` on selection and refresh the selected automatic standard when returning.

```dart
PopupMenuButton<_HomeMenuAction>(
  tooltip: 'Mais opções',
  onSelected: (action) async {
    if (action != _HomeMenuAction.padroesPeso) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => AddPesopadraoPage()),
    );
    await _getListPesoPadrao();
    _setPesoPadrao(_controllers.idade.text);
  },
  itemBuilder: (_) => const [
    PopupMenuItem(
      value: _HomeMenuAction.padroesPeso,
      child: ListTile(
        leading: Icon(Icons.monitor_weight_outlined),
        title: Text('Padrões de peso'),
      ),
    ),
  ],
)
```

- [ ] **Step 4: Rebuild the editor with Material 3 controls**

Use `DropdownMenu<String>` or a compact decorated dropdown, a 56 px numeric field and a filled `Adicionar` button. Replace the bordered 30 px rows and long-press popup with `ListTile` rows showing age, formatted weight and an overflow menu containing visible `Editar` and `Excluir` entries. Preserve the existing rule that `Misto` is derived and cannot be edited or deleted directly.

```dart
ListTile(
  leading: CircleAvatar(child: Text('$index')),
  title: Text('${_listPesoPadrao[index]} g'),
  subtitle: Text('Idade $index dias'),
  trailing: PopupMenuButton<_PadraoAction>(
    tooltip: 'Ações da idade $index',
    onSelected: (action) => _handleRowAction(action, index),
    itemBuilder: (_) => const [
      PopupMenuItem(value: _PadraoAction.editar, child: Text('Editar')),
      PopupMenuItem(value: _PadraoAction.excluir, child: Text('Excluir')),
    ],
  ),
)
```

Use `showDialog` with a numeric `TextFormField` for editing. `_handleRowAction` checks `_sexoSelecionado == 'Misto'` before mutation and shows the exact explanatory message asserted by the test.

- [ ] **Step 5: Run tests, format and analyze**

```powershell
dart format lib/ui/home_page.dart lib/ui/add_pesopadrao_page.dart test/ui/add_pesopadrao_page_test.dart
flutter test --no-version-check test/ui/add_pesopadrao_page_test.dart test/ui/home_page_test.dart
flutter analyze --no-version-check lib/ui/home_page.dart lib/ui/add_pesopadrao_page.dart
```

Expected: tests PASS and analyzer reports no issues in both UI files.

- [ ] **Step 6: Commit**

```powershell
git add lib/ui/home_page.dart lib/ui/add_pesopadrao_page.dart test/ui/add_pesopadrao_page_test.dart
git commit -m "feat: improve weight standard editor"
```

---

### Task 7: Accessibility, Responsive Regression, and Final Verification

**Files:**
- Modify: `test/ui/home_page_test.dart`
- Modify: `test/ui/resultado_page_test.dart`
- Modify: `test/widgets/pesagem_components_test.dart`
- Review: all files changed by Tasks 1–6

**Interfaces:**
- Consumes: completed weighing flow.
- Produces: regression evidence for compact phones, enlarged text, keyboard-safe scrolling, semantics, analysis, tests and Android compilation.

- [ ] **Step 1: Add failing responsive tests**

Set representative view sizes and text scaling explicitly:

```dart
testWidgets('form has no overflow on a compact portrait phone', (tester) async {
  tester.view.physicalSize = const Size(720, 1280);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await pumpPesagemApp(tester);
  expect(tester.takeException(), isNull);
  expect(find.text('Continuar'), findsOneWidget);
});

testWidgets('result supports enlarged text without overflow', (tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
      child: MaterialApp(
        theme: AppTheme.light,
        home: ResultadoPage(resultado: buildCalculatedResult()),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(find.text('102,1%'), findsOneWidget);
});
```

Add a semantics test that verifies tooltip/labels for the options menu, close result action and expandable details.

- [ ] **Step 2: Run the responsive tests and verify their initial status**

Run: `flutter test --no-version-check test/widgets/pesagem_components_test.dart test/ui/home_page_test.dart test/ui/resultado_page_test.dart`

Expected: PASS if Tasks 3–5 already meet the constraints; otherwise FAIL with the first concrete overflow or missing semantic label to correct in Step 3.

- [ ] **Step 3: Apply only evidence-driven layout corrections**

For an overflow, replace the specific rigid `Row` with `Wrap`, `Flexible`, or a one-column breakpoint based on `LayoutBuilder`; do not globally shrink text. For a keyboard obstruction, ensure the step content is in `SingleChildScrollView` with bottom padding from `MediaQuery.viewInsetsOf(context).bottom`. For missing semantics, add the exact Portuguese tooltip or `Semantics(label: ...)` asserted by the test.

- [ ] **Step 4: Run the complete automated suite**

Run: `flutter test --no-version-check`

Expected: all tests PASS with zero failures.

- [ ] **Step 5: Run static analysis**

Run: `flutter analyze --no-version-check`

Expected: `No issues found!`.

- [ ] **Step 6: Build the Android debug artifact**

Run: `flutter build apk --debug --no-pub`

Expected: exit code 0 and a debug APK under `build/app/outputs/flutter-apk/`.

- [ ] **Step 7: Verify on the connected portrait device**

Run the app on the already connected Android device, then inspect all three steps, keyboard interaction, errors, result expansion, percentage `102,1%`, viability and return-with-data-preserved behavior. Capture screenshots only as temporary review artifacts; do not commit them.

- [ ] **Step 8: Review repository hygiene**

```powershell
git diff --check
git status --short
git diff --stat
```

Confirm no `.superpowers/` session data, generated APK, ephemeral iOS files or unrelated pre-existing changes are staged.

- [ ] **Step 9: Commit the regression coverage**

```powershell
git add test/ui/home_page_test.dart test/ui/resultado_page_test.dart test/widgets/pesagem_components_test.dart
git commit -m "test: cover responsive pesagem layout"
```

---

## Completion Checklist

- [ ] Every task has completed its RED/GREEN cycle.
- [ ] `PesoMedio` exposes finite `porcentagem`, `diferencaPeso` and `viabilidade` for every form-valid input.
- [ ] The three-step form preserves entered values in both navigation directions.
- [ ] The result shows `102,1%`-style total percentages and never substitutes the difference percentage.
- [ ] Viability and live birds are primary result indicators.
- [ ] Weight standards are accessible through a named action.
- [ ] All inputs expose units, local errors and accessible labels.
- [ ] Full test, analyzer and Android build commands pass from fresh runs.
- [ ] Only files belonging to the current task are staged for each commit.
