import 'package:flutter/material.dart';
import 'package:pesagem_frangos/main.dart';
import 'package:pesagem_frangos/util/util.dart';

enum _PadraoAction { editar, excluir }

class AddPesopadraoPage extends StatefulWidget {
  const AddPesopadraoPage({super.key});

  @override
  State<AddPesopadraoPage> createState() => _AddPesopadraoPageState();
}

class _AddPesopadraoPageState extends State<AddPesopadraoPage> {
  final _formKey = GlobalKey<FormState>();
  final _pesoPadraoController = TextEditingController();
  final _pesoPadraoEditController = TextEditingController();
  String _sexoSelecionado = 'Macho';
  List<String> _listPesoPadrao = [];

  bool get _isDerivedStandard => _sexoSelecionado == 'Misto';

  @override
  void initState() {
    super.initState();
    _getListPesoPadrao();
  }

  @override
  void dispose() {
    _pesoPadraoController.dispose();
    _pesoPadraoEditController.dispose();
    super.dispose();
  }

  Future<void> _getListPesoPadrao() async {
    final sexo = _sexoSelecionado;
    final listPadrao = await Util.getListPesoPadrao(sexo);
    if (!mounted || sexo != _sexoSelecionado) return;
    setState(() => _listPesoPadrao = List<String>.from(listPadrao));
  }

  Future<void> _selectSexo(String? sexo) async {
    if (sexo == null || sexo == _sexoSelecionado) return;
    setState(() => _sexoSelecionado = sexo);
    await _getListPesoPadrao();
  }

  String? _validatePositiveWeight(String? value) {
    final weight = int.tryParse(value?.trim() ?? '');
    if (weight == null || weight <= 0) return 'Informe um peso maior que zero';
    return null;
  }

  Future<void> _saveList(List<String> updatedList) async {
    final sexo = _sexoSelecionado;
    final preferenceKey = switch (sexo) {
      'Macho' => 'padraoMacho',
      'Fêmea' => 'padraoFemea',
      _ => null,
    };
    if (preferenceKey == null) return;
    await mPrefs.setStringList(preferenceKey, updatedList);
    if (!mounted || sexo != _sexoSelecionado) return;
    setState(() => _listPesoPadrao = updatedList);
  }

  Future<void> _addPeso() async {
    if (_isDerivedStandard || !_formKey.currentState!.validate()) return;
    if (_listPesoPadrao.length >= 55) return;
    final peso = _pesoPadraoController.text.trim();
    await _saveList([..._listPesoPadrao, peso]);
    if (!mounted) return;
    _pesoPadraoController.clear();
  }

  Future<void> _editPeso(String peso, int index) async {
    if (_isDerivedStandard || index >= _listPesoPadrao.length) return;
    final updatedList = List<String>.from(_listPesoPadrao)..[index] = peso;
    await _saveList(updatedList);
  }

  Future<void> _removePeso(int index) async {
    if (_isDerivedStandard || index >= _listPesoPadrao.length) return;
    final updatedList = List<String>.from(_listPesoPadrao)..removeAt(index);
    await _saveList(updatedList);
  }

  void _handleRowAction(_PadraoAction action, int index) {
    if (_isDerivedStandard) {
      _showMixedStandardMessage();
      return;
    }
    switch (action) {
      case _PadraoAction.editar:
        _showEditDialog(index);
      case _PadraoAction.excluir:
        _showDeleteDialog(index);
    }
  }

  Future<void> _showMixedStandardMessage() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          'O padrão do Misto é calculado a partir dos outros',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(int index) async {
    _pesoPadraoEditController.text = _listPesoPadrao[index];
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar peso padrão'),
        content: Form(
          key: formKey,
          child: TextFormField(
            key: const Key('editarPesoPadraoField'),
            controller: _pesoPadraoEditController,
            autofocus: true,
            keyboardType: TextInputType.number,
            validator: _validatePositiveWeight,
            decoration: const InputDecoration(labelText: 'Peso padrão'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await _editPeso(_pesoPadraoEditController.text.trim(), index);
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(int index) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir padrão?'),
        content: Text('Remover o peso da idade $index?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _removePeso(index);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Padrões de peso')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: DropdownButtonFormField<String>(
                key: const Key('sexoPadraoField'),
                initialValue: _sexoSelecionado,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: Util.sexo(),
                onChanged: _selectSexo,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const Key('novoPesoPadraoField'),
                        controller: _pesoPadraoController,
                        enabled: !_isDerivedStandard,
                        keyboardType: TextInputType.number,
                        validator: _validatePositiveWeight,
                        decoration: const InputDecoration(
                          labelText: 'Novo peso padrão',
                          suffixText: 'g',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _isDerivedStandard ? null : _addPeso,
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Idade',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Peso padrão',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _listPesoPadrao.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(child: Text('$index')),
                  title: Text('${_listPesoPadrao[index]} g'),
                  subtitle: Text('Idade $index dias'),
                  trailing: PopupMenuButton<_PadraoAction>(
                    tooltip: 'Ações da idade $index',
                    onSelected: (action) => _handleRowAction(action, index),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _PadraoAction.editar,
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar'),
                        ),
                      ),
                      PopupMenuItem(
                        value: _PadraoAction.excluir,
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Excluir'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
