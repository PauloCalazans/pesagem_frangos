import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pesagem_frangos/ui/pesagem/pesagem_form_controllers.dart';
import 'package:pesagem_frangos/util/pesagem_validation.dart';

int _validReadingCount(String value) => value
    .split('\n')
    .map((line) => int.tryParse(line.trim()))
    .whereType<int>()
    .where((reading) => reading > 0)
    .length;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: controllers.fieldKeys[PesagemField.balancas],
              controller: controllers.balancas,
              focusNode: controllers.focusNodes[PesagemField.balancas],
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 5,
              maxLines: 20,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: PesagemValidation.validateBalancas,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\n]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Balanças',
                helperText: 'Uma pesagem por linha',
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controllers.balancas,
              builder: (context, value, _) {
                final count = _validReadingCount(value.text);
                final label = count == 1
                    ? '1 leitura válida'
                    : '$count leituras válidas';
                return Semantics(
                  liveRegion: true,
                  child: Text(
                    label,
                    key: const Key('validReadingsCount'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
