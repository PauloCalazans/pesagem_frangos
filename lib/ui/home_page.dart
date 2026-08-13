import 'package:flutter/material.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/ui/add_pesopadrao_page.dart';
import 'package:pesagem_frangos/ui/pesagem/balancas_step.dart';
import 'package:pesagem_frangos/ui/pesagem/consumo_step.dart';
import 'package:pesagem_frangos/ui/pesagem/lote_step.dart';
import 'package:pesagem_frangos/ui/pesagem/pesagem_form_controllers.dart';
import 'package:pesagem_frangos/util/util.dart';
import 'package:pesagem_frangos/widgets/pesagem_bottom_actions.dart';
import 'package:pesagem_frangos/widgets/pesagem_progress_header.dart';

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

  void _calculateAndOpenResult() {
    FocusScope.of(context).unfocus();
    final resultado = PesoMedio(
      idade: int.parse(_controllers.idade.text),
      pesoPadrao: int.parse(_controllers.pesoPadrao.text),
      avesAlojadas: int.parse(_controllers.avesAlojadas.text),
      mortalidade: int.parse(_controllers.mortalidade.text),
      racaoRecebida: int.parse(_controllers.racaoRecebida.text),
      estoqueRacao: int.parse(_controllers.estoque.text),
      tara: int.tryParse(_controllers.tara.text) ?? 0,
      avesPesadas: int.parse(_controllers.avesPesadas.text),
      balancas: _controllers.balancas.text.split('\n'),
    );
    try {
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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.3,
        maxChildSize: 0.96,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Resultado dos Cálculos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _resultRow('Idade', '${resultado.idade} dias'),
            _resultRow('Aves Alojadas', '${resultado.avesAlojadas}'),
            _resultRow('Peso Total', '${resultado.pesoTotal} g'),
            _resultRow('Tara Balança', '${resultado.tara} g'),
            _resultRow('Desconto Total', '${resultado.desconto} g'),
            _resultRow('Balançadas', '${resultado.balancadas}'),
            _resultRow(
              'Média das Balanças',
              '${Util.nf().format((resultado.pesoTotal - resultado.desconto) / resultado.balancadas)} g',
            ),
            _resultRow('Aves Pesadas', '${resultado.avesPesadas}'),
            _resultRow(
              'Peso médio',
              '${Util.nf().format(resultado.pesoMedio)} g',
            ),
            _resultRow('Peso padrão', '${resultado.pesoPadrao} g'),
            _resultRow(
              'Porcentagem',
              '${Util.nf().format(resultado.porcentagem)} %',
            ),
            _resultRow('GMD', '${Util.nf().format(resultado.gmd)} g'),
            _resultRow('Ração Recebida', '${resultado.racaoRecebida} kg'),
            _resultRow('Estoque', '${resultado.estoqueRacao} kg'),
            _resultRow('Consumo ração', '${resultado.consumo} kg'),
            _resultRow('Mortalidade', '${resultado.mortalidade}'),
            _resultRow('Aves vivas', '${resultado.avesVivas}'),
            _resultRow('Conversão alimentar', Util.nfCa().format(resultado.ca)),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: $value'),
    );
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
            IconButton(
              icon: const Icon(Icons.mode_edit, size: 28),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddPesopadraoPage()),
              ),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(_currentStep),
                    child: _currentStepWidget(),
                  ),
                ),
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
