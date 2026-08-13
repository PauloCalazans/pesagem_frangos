import 'package:flutter/material.dart';

class PesagemBottomActions extends StatelessWidget {
  const PesagemBottomActions({
    super.key,
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.onSecondary,
    required this.onPrimary,
  });

  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback onSecondary;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          spacing: 12,
          overflowAlignment: OverflowBarAlignment.center,
          overflowSpacing: 8,
          children: [
            TextButton(
              onPressed: onSecondary,
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Text(secondaryLabel),
            ),
            FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Text(primaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
