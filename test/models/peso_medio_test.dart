import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';

PesoMedio buildPesoMedio({
  int mortalidade = 258,
  List<String> balancas = const ['27010', '27010', '27010', '27010'],
}) {
  return PesoMedio(
    idade: 21,
    avesPesadas: 120,
    avesAlojadas: 10000,
    pesoPadrao: 874,
    racaoRecebida: 30000,
    estoqueRacao: 1570,
    tara: 250,
    balancas: balancas,
    mortalidade: mortalidade,
  )..calcular();
}

void main() {
  test('calcula percentual total, diferença e viabilidade', () {
    final resultado = buildPesoMedio();

    expect(resultado.pesoMedio, closeTo(892, 0.001));
    expect(resultado.porcentagem, closeTo(102.059, 0.001));
    expect(resultado.diferencaPeso, closeTo(18, 0.001));
    expect(resultado.avesVivas, 9742);
    expect(resultado.viabilidade, closeTo(97.42, 0.001));
  });

  test('ignora linhas vazias sem aceitar leituras inválidas', () {
    final resultado = buildPesoMedio(
      balancas: const ['27010', '', '27010', '  ', '27010', '27010'],
    );

    expect(resultado.balancadas, 4);
    expect(resultado.pesoTotal, 108040);
  });

  test('calcula 100% de viabilidade quando não há mortalidade', () {
    expect(buildPesoMedio(mortalidade: 0).viabilidade, 100);
  });
}
