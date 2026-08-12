import 'package:flutter/material.dart';

class MeasurementField extends StatelessWidget {
  const MeasurementField({
    super.key,
    required this.label,
    required this.controller,
    this.formFieldKey,
    this.focusNode,
    this.unit,
    this.helperText,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final GlobalKey<FormFieldState<String>>? formFieldKey;
  final FocusNode? focusNode;
  final String? unit;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: TextFormField(
        key: formFieldKey,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          helperText: helperText,
        ),
      ),
    );
  }
}
