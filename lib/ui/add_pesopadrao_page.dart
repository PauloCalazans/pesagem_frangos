import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pesagem_frangos/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPesopadraoPage extends StatefulWidget {
  @override
  _AddPesopadraoPageState createState() => _AddPesopadraoPageState();
}

class _AddPesopadraoPageState extends State<AddPesopadraoPage> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _mPrefs;

  List<DropdownMenuItem<String>> _listSexo = Util.sexo();
  TextEditingController _pesoPadraoController = TextEditingController();
  TextEditingController _pesoPadraoEditController = TextEditingController();
  String _sexoSelecionado = 'Macho';

  List<String> _padraoMacho;
  List<String> _padraoFemea;
  List<String> _listPesoPadrao = [];

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

  _addPeso(String peso) async {
    if(_listPesoPadrao.length < 55) {
      if(_sexoSelecionado == 'Macho') {
        setState(() {
          _padraoMacho = _listPesoPadrao;
          _padraoMacho.add(peso);
        });

        await _mPrefs.setStringList("padraoMacho", _padraoMacho);
      } else if(_sexoSelecionado == 'Fêmea') {
        setState(() {
          _padraoFemea = _listPesoPadrao;
          _padraoFemea.add(peso);
        });

        await _mPrefs.setStringList("padraoFemea", _padraoFemea);
      }
    }
  }

  _editPeso(String peso, int index) async {

    if(_sexoSelecionado == 'Macho') {
      setState(() {
        _padraoMacho = _listPesoPadrao;
        _padraoMacho[index] = peso;
      });

      await _mPrefs.setStringList("padraoMacho", _padraoMacho);
    } else if(_sexoSelecionado == 'Fêmea') {
      setState(() {
        _padraoFemea = _listPesoPadrao;
        _padraoFemea[index] = peso;
      });

      await _mPrefs.setStringList("padraoFemea", _padraoFemea);
    }
  }

  _removePeso() async {

    if(_sexoSelecionado == 'Macho') {
      setState(() {
        _padraoMacho.removeLast();
      });

      await _mPrefs.setStringList("padraoMacho", _padraoMacho);
    } else if(_sexoSelecionado == 'Fêmea') {
      setState(() {
        _padraoFemea.removeLast();
      });

      await _mPrefs.setStringList("padraoFemea", _padraoFemea);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        title: Text('Peso Padrão'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Row(
              children: [

                Expanded(
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
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.add_circle, size: 30,),
                    onPressed: () {
                      _addPeso(_pesoPadraoController.text);

                      _pesoPadraoController.value = TextEditingValue(text: '');
                    },
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  border: Border.all()
              ),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('Idade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black)),
                    Text('Peso Padrão', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black))
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _listPesoPadrao != null ? _listPesoPadrao.length : 0,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: InkWell(
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(), left: BorderSide(), right: BorderSide())
                          ),
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text('$index', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
                                Text('${_listPesoPadrao[index]}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    onLongPress: () async {
                      _pesoPadraoEditController.value = TextEditingValue(text: _listPesoPadrao[index]);
                      await showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(width * .1, height * .45, width * .1, height * .25),
                        items: [
                          PopupMenuItem<String>(
                              value: 'Editar',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                Container(
                                  width: width * .40,
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 20),
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    validator: Util.validateForm,
                                    controller: _pesoPadraoEditController,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Peso Padrão'
                                    ),
                                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.add_circle),
                                        onPressed: () {
                                          _editPeso(_pesoPadraoEditController.text, index);
                                          _pesoPadraoEditController.value = TextEditingValue(text: '');
                                          Navigator.pop(context);
                                        },
                                      ),

                                      IconButton(
                                        icon: Icon(Icons.delete_forever),
                                        onPressed: () {
                                          if(_sexoSelecionado != 'Misto') {
                                            Util.showDialogAlert(
                                              context: context,
                                              title: 'Remover o último peso registrado?',
                                              onConfirm: () {
                                                Navigator.pop(context); // fechar dialog
                                                Navigator.pop(context); // fechar menu popup
                                                _removePeso();
                                              },
                                              onCancel: () {
                                                Navigator.pop(context); // fechar dialog
                                                Navigator.pop(context); // fechar menu popup
                                              }
                                            );
                                          } else {
                                            Util.showDialogAlert(
                                              context: context,
                                              title: 'O Padrão do Misto é calculado a partir dos outros',
                                              onConfirm: () => Navigator.pop(context),
                                              onCancel: () => Navigator.pop(context),
                                            );
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ]
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
