import 'package:flutter/material.dart';
import 'package:pesagem_frangos/util/util.dart';

class ViabilityCard extends StatelessWidget {
  const ViabilityCard({
    super.key,
    required this.viabilidade,
    required this.avesVivas,
  });

  final double viabilidade;
  final int avesVivas;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.favorite_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Viabilidade',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Util.formatDecimal(viabilidade, decimals: 2)}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('${Util.formatInteger(avesVivas)} aves vivas'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
