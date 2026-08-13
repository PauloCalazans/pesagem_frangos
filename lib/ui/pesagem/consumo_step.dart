import 'package:flutter/material.dart';
import 'package:pesagem_frangos/ui/pesagem/pesagem_form_controllers.dart';
import 'package:pesagem_frangos/util/pesagem_validation.dart';
import 'package:pesagem_frangos/widgets/measurement_field.dart';

class ConsumoStep extends StatelessWidget {
  const ConsumoStep({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MeasurementField(
            key: const Key('racaoRecebidaField'),
            label: 'Ração recebida',
            unit: 'kg',
            controller: controllers.racaoRecebida,
            formFieldKey: controllers.fieldKeys[PesagemField.racaoRecebida],
            focusNode: controllers.focusNodes[PesagemField.racaoRecebida],
            validator: (value) => PesagemValidation.requiredPositive(
              value,
              label: 'Ração recebida',
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 12),
          MeasurementField(
            key: const Key('estoqueField'),
            label: 'Estoque de hoje',
            unit: 'kg',
            controller: controllers.estoque,
            formFieldKey: controllers.fieldKeys[PesagemField.estoque],
            focusNode: controllers.focusNodes[PesagemField.estoque],
            validator: (_) => PesagemValidation.validateEstoque(
              estoque: controllers.estoque.text,
              racaoRecebida: controllers.racaoRecebida.text,
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 12),
          MeasurementField(
            key: const Key('taraField'),
            label: 'Tara',
            unit: 'g',
            controller: controllers.tara,
            formFieldKey: controllers.fieldKeys[PesagemField.tara],
            focusNode: controllers.focusNodes[PesagemField.tara],
            validator: (value) => PesagemValidation.nonNegative(
              value,
              label: 'Tara',
              allowEmpty: true,
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 12),
          MeasurementField(
            key: const Key('avesPesadasField'),
            label: 'Aves pesadas',
            unit: 'aves',
            controller: controllers.avesPesadas,
            formFieldKey: controllers.fieldKeys[PesagemField.avesPesadas],
            focusNode: controllers.focusNodes[PesagemField.avesPesadas],
            validator: (value) => PesagemValidation.requiredPositive(
              value,
              label: 'Aves pesadas',
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
          ),
        ],
      ),
    );
  }
}
