import 'package:flutter/material.dart';
import 'package:pesagem_frangos/theme/app_theme.dart';

class PesagemProgressHeader extends StatelessWidget {
  const PesagemProgressHeader({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
  });

  final String title;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final stepLabel = '$title · etapa $currentStep de $totalSteps';

    return Semantics(
      label: stepLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stepLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: currentStep / totalSteps,
            color: AppTheme.progress,
          ),
        ],
      ),
    );
  }
}
