import 'package:flutter/material.dart';

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

  final fieldKeys = <PesagemField, GlobalKey<FormFieldState<String>>>{
    for (final field in PesagemField.values)
      field: GlobalKey<FormFieldState<String>>(),
  };

  final focusNodes = <PesagemField, FocusNode>{
    for (final field in PesagemField.values) field: FocusNode(),
  };

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
    for (final focusNode in focusNodes.values) {
      focusNode.dispose();
    }
  }
}
