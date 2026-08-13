import 'package:flutter/material.dart';
import 'package:pesagem_frangos/util/util.dart';

class ResultHeroCard extends StatelessWidget {
  const ResultHeroCard({
    super.key,
    required this.pesoMedio,
    required this.percentualPadrao,
    required this.pesoPadrao,
    required this.diferencaPeso,
  });

  final double pesoMedio;
  final double percentualPadrao;
  final int pesoPadrao;
  final double diferencaPeso;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.primary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peso médio',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colors.onPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              '${Util.formatDecimal(pesoMedio, decimals: 0)} g',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _HeroMetric(
                    label: 'Percentual do padrão',
                    value: '${Util.formatDecimal(percentualPadrao)}%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _HeroMetric(
                    label: 'Peso padrão',
                    value: '${Util.formatInteger(pesoPadrao)} g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Diferença: ${diferencaPeso >= 0 ? '+' : ''}${Util.formatDecimal(diferencaPeso, decimals: 0)} g',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: onPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
