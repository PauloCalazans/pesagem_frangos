import 'package:flutter/material.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/ui/add_pesopadrao_page.dart';
import 'package:pesagem_frangos/ui/pesagem/balancas_step.dart';
import 'package:pesagem_frangos/ui/pesagem/consumo_step.dart';
import 'package:pesagem_frangos/ui/pesagem/lote_step.dart';
import 'package:pesagem_frangos/ui/pesagem/pesagem_form_controllers.dart';
import 'package:pesagem_frangos/ui/resultado_page.dart';
import 'package:pesagem_frangos/util/util.dart';
import 'package:pesagem_frangos/widgets/pesagem_bottom_actions.dart';
import 'package:pesagem_frangos/widgets/pesagem_progress_header.dart';

enum _HomeMenuAction { padroesPeso }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _stepKeys = List.generate(3, (_) => GlobalKey<FormState>());
  final _controllers = PesagemFormControllers();
  final _titles = const [
    'Dados do lote',
    'Consumo e amostra',
    'Leituras das balanças',
  ];

  int _currentStep = 0;
  bool _canPop = false;
  String _sexoSelecionado = 'Macho';
  List<String> _listPesoPadrao = [];
  var _pesoPadraoRequest = 0;

  @override
  void initState() {
    super.initState();
    _controllers.idade.addListener(_setPesoPadrao);
    _loadPesosPadrao();
  }

  @override
  void dispose() {
    _controllers.idade.removeListener(_setPesoPadrao);
    _controllers.dispose();
    super.dispose();
  }

  Future<void> _loadPesosPadrao() async {
    final sexo = _sexoSelecionado;
    final request = ++_pesoPadraoRequest;
    final pesosPadrao = await Util.getListPesoPadrao(sexo);
    if (!mounted || request != _pesoPadraoRequest || sexo != _sexoSelecionado) {
      return;
    }
    _listPesoPadrao = pesosPadrao;
    _setPesoPadrao();
  }

  Future<void> _changeSexo(String sexo) async {
    setState(() => _sexoSelecionado = sexo);
    await _loadPesosPadrao();
  }

  void _setPesoPadrao() {
    final idade = int.tryParse(_controllers.idade.text);
    final pesoPadrao =
        idade != null && idade >= 0 && idade < _listPesoPadrao.length
        ? _listPesoPadrao[idade]
        : '';
    if (_controllers.pesoPadrao.text != pesoPadrao) {
      _controllers.pesoPadrao.value = TextEditingValue(text: pesoPadrao);
    }
  }

  int _parseInt(TextEditingController controller, {int? defaultValue}) {
    return int.tryParse(controller.text.trim()) ??
        defaultValue ??
        (throw ArgumentError.value(controller.text, 'controller'));
  }

  void _continue() {
    if (!_validateAndFocusCurrentStep()) return;
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }
    _calculateAndOpenResult();
  }

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
      if (!mounted) return;
      final context = _controllers.fieldKeys[invalid]!.currentContext;
      _controllers.focusNodes[invalid]!.requestFocus();
      if (context != null) {
        Scrollable.ensureVisible(context, alignment: 0.2);
      }
    });
    return false;
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _calculateAndOpenResult() async {
    FocusScope.of(context).unfocus();
    late final PesoMedio resultado;
    try {
      resultado = PesoMedio(
        idade: _parseInt(_controllers.idade),
        pesoPadrao: _parseInt(_controllers.pesoPadrao),
        avesAlojadas: _parseInt(_controllers.avesAlojadas),
        mortalidade: _parseInt(_controllers.mortalidade),
        racaoRecebida: _parseInt(_controllers.racaoRecebida),
        estoqueRacao: _parseInt(_controllers.estoque),
        tara: _parseInt(_controllers.tara, defaultValue: 0),
        avesPesadas: _parseInt(_controllers.avesPesadas),
        balancas: _controllers.balancas.text.split('\n'),
      );
      resultado.calcular();
    } on ArgumentError catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'As leituras e a tara devem resultar em peso médio positivo',
          ),
        ),
      );
      return;
    }

    final action = await Navigator.of(context).push<ResultadoAction>(
      MaterialPageRoute(builder: (_) => ResultadoPage(resultado: resultado)),
    );
    if (!mounted || action != ResultadoAction.novaPesagem) return;
    for (final controller in [
      _controllers.idade,
      _controllers.pesoPadrao,
      _controllers.avesAlojadas,
      _controllers.mortalidade,
      _controllers.racaoRecebida,
      _controllers.estoque,
      _controllers.tara,
      _controllers.avesPesadas,
      _controllers.balancas,
    ]) {
      controller.clear();
    }
    setState(() => _currentStep = 0);
  }

  Future<bool> _confirmExit() async {
    var close = false;
    await Util.showDialogAlert(
      context: context,
      title: 'Deseja Sair do Aplicativo',
      onConfirm: () {
        close = true;
        Navigator.pop(context);
      },
      onCancel: () => Navigator.pop(context),
    );
    return close;
  }

  Widget _currentStepWidget() {
    switch (_currentStep) {
      case 0:
        return LoteStep(
          formKey: _stepKeys[0],
          controllers: _controllers,
          sexo: _sexoSelecionado,
          onSexoChanged: _changeSexo,
        );
      case 1:
        return ConsumoStep(formKey: _stepKeys[1], controllers: _controllers);
      default:
        return BalancasStep(formKey: _stepKeys[2], controllers: _controllers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !await _confirmExit() || !mounted) return;
        setState(() => _canPop = true);
        Navigator.of(context).pop(result);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nova pesagem'),
          actions: [
            PopupMenuButton<_HomeMenuAction>(
              tooltip: 'Mais opções',
              onSelected: (action) async {
                if (action != _HomeMenuAction.padroesPeso) return;
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => AddPesopadraoPage()),
                );
                if (!mounted) return;
                await _loadPesosPadrao();
                if (!mounted) return;
                _setPesoPadrao();
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
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: PesagemProgressHeader(
                title: _titles[_currentStep],
                currentStep: _currentStep + 1,
                totalSteps: _titles.length,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _currentStepWidget(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: PesagemBottomActions(
          secondaryLabel: _currentStep == 0 ? 'Cancelar' : 'Voltar',
          primaryLabel: _currentStep == 2 ? 'Calcular' : 'Continuar',
          onSecondary: _currentStep == 0
              ? () => Navigator.maybePop(context)
              : _back,
          onPrimary: _continue,
        ),
      ),
    );
  }
}
