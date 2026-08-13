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
  ].join('\n');
}

class ResultadoPage extends StatelessWidget {
  const ResultadoPage({super.key, required this.resultado, this.onShare});

  final PesoMedio resultado;
  final ShareText? onShare;

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
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'GMD',
                    value: '${Util.formatDecimal(r.gmd)} g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: 'Conversão alimentar',
                    value: Util.formatDecimal(r.ca, decimals: 3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ResultDetailsSection(
              title: 'Detalhes da pesagem',
              children: [
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
        onPrimary: () =>
            (onShare ?? shareTextNative)(buildResumoPesagem(resultado)),
      ),
    );
  }
}
