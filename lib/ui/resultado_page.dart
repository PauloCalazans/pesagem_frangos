import 'package:flutter/material.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/util/util.dart';
import 'package:pesagem_frangos/widgets/pesagem_bottom_actions.dart';
import 'package:pesagem_frangos/widgets/resultado_content.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ResultadoContent(resultado: resultado),
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
