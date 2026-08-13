import 'package:flutter/material.dart';
import 'package:pesagem_frangos/ui/pesagem/pesagem_form_controllers.dart';
import 'package:pesagem_frangos/util/pesagem_validation.dart';

class BalancasStep extends StatelessWidget {
  const BalancasStep({
    super.key,
    required this.formKey,
    required this.controllers,
  });

  final GlobalKey<FormState> formKey;
  final PesagemFormControllers controllers;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: KeyedSubtree(
        key: const Key('balancasField'),
        child: TextFormField(
          key: controllers.fieldKeys[PesagemField.balancas],
          controller: controllers.balancas,
          focusNode: controllers.focusNodes[PesagemField.balancas],
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 5,
          maxLines: 20,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: PesagemValidation.validateBalancas,
          decoration: const InputDecoration(
            labelText: 'Balanças',
            helperText: 'Uma pesagem por linha',
          ),
        ),
      ),
    );
  }
}
