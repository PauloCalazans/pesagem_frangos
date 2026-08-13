import 'package:flutter/material.dart';
import 'package:pesagem_frangos/ui/pesagem/pesagem_form_controllers.dart';
import 'package:pesagem_frangos/util/pesagem_validation.dart';
import 'package:pesagem_frangos/util/util.dart';
import 'package:pesagem_frangos/widgets/measurement_field.dart';

class LoteStep extends StatelessWidget {
  const LoteStep({
    super.key,
    required this.formKey,
    required this.controllers,
    required this.sexo,
    required this.onSexoChanged,
  });

  final GlobalKey<FormState> formKey;
  final PesagemFormControllers controllers;
  final String sexo;
  final ValueChanged<String> onSexoChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputDecorator(
            key: const Key('sexoField'),
            decoration: const InputDecoration(labelText: 'Sexo'),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: sexo,
                isDense: true,
                onChanged: (value) {
                  if (value != null) onSexoChanged(value);
                },
                items: Util.sexo(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          MeasurementField(
            key: const Key('idadeField'),
            label: 'Idade',
            unit: 'dias',
            controller: controllers.idade,
            formFieldKey: controllers.fieldKeys[PesagemField.idade],
            focusNode: controllers.focusNodes[PesagemField.idade],
            validator: (value) => PesagemValidation.requiredPositive(
              (value ?? '').trim().isEmpty ? '0' : value,
              label: 'Idade',
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 12),
          MeasurementField(
            key: const Key('pesoPadraoField'),
            label: 'Peso padrão',
            unit: 'g',
            helperText: 'Preenchido automaticamente pela idade e sexo',
            controller: controllers.pesoPadrao,
            formFieldKey: controllers.fieldKeys[PesagemField.pesoPadrao],
            focusNode: controllers.focusNodes[PesagemField.pesoPadrao],
            validator: (value) =>
                PesagemValidation.requiredPositive(value, label: 'Peso padrão'),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 12),
          MeasurementField(
            key: const Key('avesAlojadasField'),
            label: 'Aves alojadas',
            unit: 'aves',
            controller: controllers.avesAlojadas,
            formFieldKey: controllers.fieldKeys[PesagemField.avesAlojadas],
            focusNode: controllers.focusNodes[PesagemField.avesAlojadas],
            validator: (value) => PesagemValidation.requiredPositive(
              value,
              label: 'Aves alojadas',
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 12),
          MeasurementField(
            key: const Key('mortalidadeField'),
            label: 'Mortalidade',
            unit: 'aves',
            controller: controllers.mortalidade,
            formFieldKey: controllers.fieldKeys[PesagemField.mortalidade],
            focusNode: controllers.focusNodes[PesagemField.mortalidade],
            validator: (_) => PesagemValidation.validateMortalidade(
              mortalidade: controllers.mortalidade.text,
              avesAlojadas: controllers.avesAlojadas.text,
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
          ),
        ],
      ),
    );
  }
}
