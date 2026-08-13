import 'package:flutter/material.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/util/util.dart';
import 'package:pesagem_frangos/widgets/metric_card.dart';
import 'package:pesagem_frangos/widgets/result_details_section.dart';
import 'package:pesagem_frangos/widgets/result_hero_card.dart';
import 'package:pesagem_frangos/widgets/viability_card.dart';

class ResultadoContent extends StatelessWidget {
  const ResultadoContent({
    super.key,
    required this.resultado,
    this.expandAllDetails = false,
  });

  final PesoMedio resultado;
  final bool expandAllDetails;

  @override
  Widget build(BuildContext context) {
    final r = resultado;
    return Column(
      key: const Key('resultadoContent'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultHeroCard(
          pesoMedio: r.pesoMedio,
          percentualPadrao: r.porcentagem,
          pesoPadrao: r.pesoPadrao,
          diferencaPeso: r.diferencaPeso,
        ),
        const SizedBox(height: 12),
        ViabilityCard(viabilidade: r.viabilidade, avesVivas: r.avesVivas),
        const SizedBox(height: 12),
        Text('Eficiência', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final cardWidth = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    label: 'GMD',
                    value: '${Util.formatDecimal(r.gmd)} g',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    label: 'Conversão alimentar',
                    value: Util.formatDecimal(r.ca, decimals: 3),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    label: 'Consumo',
                    value: '${Util.formatInteger(r.consumo)} kg',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    label: 'Mortalidade',
                    value: '${Util.formatInteger(r.mortalidade)} aves',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        ResultDetailsSection(
          title: 'Detalhes da pesagem',
          initiallyExpanded: expandAllDetails,
          children: [
            ResultLine(
              label: 'Idade',
              value: '${Util.formatInteger(r.idade)} dias',
            ),
            ResultLine(
              label: 'Tara unitária',
              value: '${Util.formatInteger(r.tara)} g',
            ),
            ResultLine(
              label: 'Aves pesadas',
              value: '${Util.formatInteger(r.avesPesadas)} aves',
            ),
            ResultLine(
              label: 'Peso total',
              value: '${Util.formatInteger(r.pesoTotal)} g',
            ),
            ResultLine(
              label: 'Desconto da tara',
              value: '${Util.formatInteger(r.desconto)} g',
            ),
            ResultLine(
              label: 'Média das balanças',
              value:
                  '${Util.formatDecimal((r.pesoTotal - r.desconto) / r.balancadas)} g',
            ),
            ResultLine(
              label: 'Balanças consideradas',
              value: '${r.balancadas}',
            ),
          ],
        ),
        const SizedBox(height: 12),
        ResultDetailsSection(
          title: 'Plantel e alimentação',
          initiallyExpanded: expandAllDetails,
          children: [
            ResultLine(label: 'Aves alojadas', value: '${r.avesAlojadas}'),
            ResultLine(label: 'Mortalidade', value: '${r.mortalidade} aves'),
            ResultLine(label: 'Ração recebida', value: '${r.racaoRecebida} kg'),
            ResultLine(label: 'Estoque atual', value: '${r.estoqueRacao} kg'),
          ],
        ),
      ],
    );
  }
}
