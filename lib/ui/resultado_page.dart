import 'package:flutter/material.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/services/result_image_share.dart';
import 'package:pesagem_frangos/widgets/pesagem_bottom_actions.dart';
import 'package:pesagem_frangos/widgets/resultado_content.dart';

enum ResultadoAction { novaPesagem }

class ResultadoPage extends StatefulWidget {
  const ResultadoPage({
    super.key,
    required this.resultado,
    this.captureImage,
    this.onShare,
  });

  final PesoMedio resultado;
  final CaptureResultImage? captureImage;
  final ShareResultImage? onShare;

  @override
  State<ResultadoPage> createState() => _ResultadoPageState();
}

class _ResultadoPageState extends State<ResultadoPage> {
  bool _isSharing = false;

  Future<void> _share() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final bytes = await (widget.captureImage ?? captureResultImage)(
        context,
        widget.resultado,
      );
      if (!mounted) return;
      await (widget.onShare ?? shareResultImage)(bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar o resumo')),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ResultadoContent(resultado: widget.resultado),
      ),
      bottomNavigationBar: PesagemBottomActions(
        secondaryLabel: 'Nova pesagem',
        primaryLabel: 'Compartilhar resumo',
        onSecondary: () => Navigator.pop(context, ResultadoAction.novaPesagem),
        onPrimary: _share,
        primaryLoading: _isSharing,
      ),
    );
  }
}
