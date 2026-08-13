import 'package:flutter/material.dart';

class PesagemBottomActions extends StatelessWidget {
  const PesagemBottomActions({
    super.key,
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.onSecondary,
    required this.onPrimary,
    this.primaryLoading = false,
  });

  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback onSecondary;
  final VoidCallback onPrimary;
  final bool primaryLoading;

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
              onPressed: primaryLoading ? null : onPrimary,
              style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
              child: primaryLoading
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(opacity: 0, child: Text(primaryLabel)),
                        const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    )
                  : Text(primaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
