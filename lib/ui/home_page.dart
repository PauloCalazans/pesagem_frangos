import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/ui/add_pesopadrao_page.dart';
import 'package:pesagem_frangos/util/util.dart';
import 'package:pesagem_frangos/widgets/stepper_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _mPrefs;

  int _currentStep = 0;
  String _sexoSelecionado = 'Macho';
  List<DropdownMenuItem<String>> _listSexo = Util.sexo();
  List<String> _listPesoPadrao = [];

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _idadeController = TextEditingController();
  TextEditingController _pesoPadraoController = TextEditingController();
  TextEditingController _avesAlojadasController = TextEditingController();
  TextEditingController _mortalidadeController = TextEditingController();
  TextEditingController _racaoController = TextEditingController();
  TextEditingController _estoqueController = TextEditingController();
  TextEditingController _taraController = TextEditingController();
  TextEditingController _avesPesadasController = TextEditingController();
  TextEditingController _balancasController = TextEditingController();

  @override
  void initState() {
   _doInit();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _doInit() async {
    _mPrefs = await _prefs;

    _getListPesoPadrao();
    if(mounted) {
      setState(() { });
    }
  }

  _getListPesoPadrao() async {
    var listPadrao = await Util.getListPesoPadrao(_sexoSelecionado, _mPrefs);
    setState(() {
      _listPesoPadrao = listPadrao;
    });
  }

  Widget _richText(String textBold, dynamic textNormal) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                children: [
                  TextSpan(text: "${textBold}: ", style: TextStyle(fontWeight: FontWeight.w500)),
                  TextSpan(text: "${textNormal}"),
                ]
            ),
          ),

          SizedBox(height: 4)
        ],
      ),
    );
  }

  _stepContinue() async {
    if(_currentStep == 2) {

      if(_formKey.currentState.validate()) {
        _calcularPeso();
      } else {
        await Util.showDialogAlert(
          context: context,
          title: 'Existem informações a serem preenchidas',
          onConfirm: () => Navigator.pop(context),
          onCancel: () => Navigator.pop(context),
          titleConfirm: 'Ok',
          titleCancel: 'Fechar'
        );
      }
    }

    if(_currentStep < 2)
      setState(() {
        _currentStep += 1;
    });
  }

  _calcularPeso() {
    FocusScope.of(context).requestFocus(new FocusNode()); // fecha o teclado

    PesoMedio vo = new PesoMedio(
        idade: int.tryParse(_idadeController.text),
        pesoPadrao: int.tryParse(_pesoPadraoController.text),
        avesAlojadas: int.tryParse(_avesAlojadasController.text),
        mortalidade: int.tryParse(_mortalidadeController.text),
        racaoRecebida: int.tryParse(_racaoController.text),
        estoqueRacao: int.tryParse(_estoqueController.text),
        tara: int.tryParse(_taraController.text),
        avesPesadas: int.tryParse(_avesPesadasController.text),
        balancas: _balancasController.text.split('\n')
    );

    vo.calcular();

    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      elevation: 5,
      enableDrag: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.3,
          maxChildSize: 0.96,
          expand: false,
          builder: (context, scrollController){
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment:MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: 40,
                          height: 6,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      Text('Resultado dos Cálculos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black))
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Divider(height: 4),
                ),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [

                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _richText("Idade", '${vo.idade} dias'),
                          _richText("AvesAlojadas", vo.avesAlojadas),
                          _richText("Peso Total", '${vo.pesoTotal} g'),
                          _richText("Tara Balaça", '${vo.tara} g'),
                          _richText("Desconto Total", '${vo.desconto} g'),
                          _richText("Balançadas", vo.balancadas),
                          _richText("Média das Balanças", '${Util.nf().format((vo.pesoTotal-vo.desconto)/vo.balancadas)} g'),
                          _richText("Aves Pesadas", vo.avesPesadas),
                          _richText("Peso Médio", '${Util.nf().format(vo.pesoMedio)} g'),
                          _richText("Peso Padrão", '${vo.pesoPadrao} g'),
                          _richText("Porcentagem", '${Util.nf().format(vo.porcentagem)} %'),
                          _richText("GMD", '${Util.nf().format(vo.gmd)} g'),
                          _richText("Ração Recebida", '${vo.racaoRecebida} Kg'),
                          _richText("Estoque", '${vo.estoqueRacao} Kg'),
                          _richText("Consumo Ração", '${vo.consumo} Kg'),
                          _richText("Mortalidade", vo.mortalidade),
                          _richText("Aves Vivas", vo.avesVivas),
                          _richText("Convesão Alimentar", Util.nfCa().format(vo.ca)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }
    );
  }

  Future<bool> _willPopScope() async {
    bool close = false;
    await Util.showDialogAlert(
        context: context,
        title: 'Deseja Sair do Aplicativo',
        onConfirm: () {
              close = true;
              Navigator.pop(context);
            },
        onCancel: () => Navigator.pop(context)
          );

    return close;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopScope,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pesagem'),
          actions: [
            IconButton(
              icon: Icon(Icons.mode_edit, size: 32),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddPesopadraoPage())),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: StepperCustom(
            currentStep: _currentStep,
            onStepContinue: _stepContinue,
            onStepCancel: () {
              if(_currentStep >= 1) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            steps: [
              StepCustom(
                content: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelStyle: TextStyle(fontSize: 20),
                          labelText: "Sexo",
                          border: OutlineInputBorder()
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            value: _sexoSelecionado,
                            isDense: true,
                            hint: Text("Selecione um sexo"),
                            onChanged: (String selection) {
                              setState(() {
                                _sexoSelecionado = selection;
                              });

                              _getListPesoPadrao();
                            },
                            items: _listSexo,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: Util.validateForm,
                        controller: _idadeController,
                        decoration: InputDecoration(
                          labelText: 'Idade',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String value) {
                          var idade = int.tryParse(value);
                          if(idade <= _listPesoPadrao.length) {
                            print(_listPesoPadrao[idade]);
                            _pesoPadraoController.value = TextEditingValue(text: _listPesoPadrao[idade]);
                          }
                          print(idade);
                        },
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: Util.validateForm,
                        controller: _pesoPadraoController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Peso Padrão'
                        ),
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: Util.validateForm,
                        controller: _avesAlojadasController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Aves Alojadas'
                        ),
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: Util.validateForm,
                        controller: _mortalidadeController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Mortalidade'
                        ),
                        onFieldSubmitted: (_) => _stepContinue(),
                      ),
                    ),
                  ],
                )
              ),

              StepCustom(
                content: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: Util.validateForm,
                        controller: _racaoController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Ração Recebida'
                        ),
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: Util.validateForm,
                        controller: _estoqueController,
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Estoque de Hoje'
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: Util.validateForm,
                        controller: _taraController,
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Tara Balança'
                        ),
                      ),
                    ),

                    TextFormField(
                      style: TextStyle(fontSize: 20),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      controller: _avesPesadasController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Aves Pesadas'
                      ),
                      validator: Util.validateForm,
                      onFieldSubmitted: (_) => _stepContinue(),
                    ),
                  ],
                )
              ),

              StepCustom(
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                    cursorWidth: 3,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 200,
                    textInputAction: TextInputAction.newline,
                    validator: Util.validateForm,
                    controller: _balancasController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\n]'))
                    ],
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Balanças'
                    ),
                  ),
                )
              ),
            ],
          ),
        )
      ),
    );
  }
}
