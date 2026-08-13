import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';
import 'package:pesagem_frangos/widgets/resultado_content.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

typedef CaptureResultImage =
    Future<Uint8List> Function(BuildContext context, PesoMedio resultado);
typedef ShareResultImage = Future<void> Function(Uint8List pngBytes);

Future<Uint8List> captureResultImage(
  BuildContext context,
  PesoMedio resultado,
) {
  final media = MediaQuery.of(
    context,
  ).copyWith(textScaler: TextScaler.noScaling);
  final background = Theme.of(context).scaffoldBackgroundColor;

  return ScreenshotController().captureFromLongWidget(
    Localizations.override(
      context: context,
      child: InheritedTheme.captureAll(
        context,
        MediaQuery(
          data: media,
          child: Material(
            color: background,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ResultadoContent(
                resultado: resultado,
                expandAllDetails: true,
              ),
            ),
          ),
        ),
      ),
    ),
    context: context,
    constraints: const BoxConstraints.tightFor(width: 420),
    pixelRatio: 2,
    delay: const Duration(milliseconds: 100),
  );
}

ShareParams buildResultShareParams(Uint8List pngBytes) {
  return ShareParams(
    title: 'Resumo da pesagem',
    subject: 'Resumo da pesagem',
    files: [XFile.fromData(pngBytes, mimeType: 'image/png')],
    fileNameOverrides: const ['resumo-da-pesagem.png'],
  );
}

Future<void> shareResultImage(Uint8List pngBytes) async {
  await SharePlus.instance.share(buildResultShareParams(pngBytes));
}
