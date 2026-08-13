import 'package:flutter/material.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/util/util.dart';
import 'package:pesagem_frangos/widgets/metric_card.dart';
import 'package:pesagem_frangos/widgets/pesagem_bottom_actions.dart';
import 'package:pesagem_frangos/widgets/result_details_section.dart';
import 'package:pesagem_frangos/widgets/result_hero_card.dart';
import 'package:pesagem_frangos/widgets/viability_card.dart';
import 'package:share_plus/share_plus.dart';

enum ResultadoAction { novaPesagem }

typedef ShareText = Future<void> Function(String text);

Future<void> shareTextNative(String text) async {
  await SharePlus.instance.share(
    ShareParams(
      title: 'Resumo da pesagem',
      subject: 'Resumo da pesagem',
      text: text,
    ),
  );
}

String buildResumoPesagem(PesoMedio resultado) {
  return [
    'Resumo da pesagem',
    'Peso médio: ${Util.formatDecimal(resultado.pesoMedio, decimals: 0)} g',
    'Percentual do padrão: ${Util.formatDecimal(resultado.porcentagem)}%',
    'Viabilidade: ${Util.formatDecimal(resultado.viabilidade, decimals: 2)}%',
    'GMD: ${Util.formatDecimal(resultado.gmd)} g',
    'Conversão alimentar: ${Util.formatDecimal(resultado.ca, decimals: 3)}',
    'Consumo: ${Util.formatInteger(resultado.consumo)} kg',
    'Mortalidade: ${Util.formatInteger(resultado.mortalidade)} aves',
  ].join('\n');
}

class ResultadoPage extends StatelessWidget {
  const ResultadoPage({super.key, required this.resultado, this.onShare});

  final PesoMedio resultado;
  final ShareText? onShare;

  Future<void> _share(BuildContext context) async {
    try {
      await (onShare ?? shareTextNative)(buildResumoPesagem(resultado));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar o resumo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = resultado;
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
              children: [
                ResultLine(label: 'Aves alojadas', value: '${r.avesAlojadas}'),
                ResultLine(
                  label: 'Mortalidade',
                  value: '${r.mortalidade} aves',
                ),
                ResultLine(
                  label: 'Ração recebida',
                  value: '${r.racaoRecebida} kg',
                ),
                ResultLine(
                  label: 'Estoque atual',
                  value: '${r.estoqueRacao} kg',
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: PesagemBottomActions(
        secondaryLabel: 'Nova pesagem',
        primaryLabel: 'Compartilhar resumo',
        onSecondary: () => Navigator.pop(context, ResultadoAction.novaPesagem),
        onPrimary: () => _share(context),
      ),
    );
  }
}
