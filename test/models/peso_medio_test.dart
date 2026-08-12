import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/models/peso_medio.dart';

PesoMedio buildPesoMedio({
  int idade = 21,
  int avesPesadas = 120,
  int avesAlojadas = 10000,
  int pesoPadrao = 874,
  int tara = 250,
  int mortalidade = 258,
  List<String> balancas = const ['27010', '27010', '27010', '27010'],
}) {
  return PesoMedio(
    idade: idade,
    avesPesadas: avesPesadas,
    avesAlojadas: avesAlojadas,
    pesoPadrao: pesoPadrao,
    racaoRecebida: 30000,
    estoqueRacao: 1570,
    tara: tara,
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
    expect(resultado.pesoMedio.isFinite, isTrue);
    expect(resultado.porcentagem.isFinite, isTrue);
    expect(resultado.gmd.isFinite, isTrue);
    expect(resultado.ca.isFinite, isTrue);
    expect(resultado.viabilidade.isFinite, isTrue);
  });

  test('ignora linhas inválidas sem aceitá-las como leituras', () {
    final resultado = buildPesoMedio(
      balancas: const [
        '27010',
        '',
        '27010',
        '  ',
        'inválido',
        '0',
        '27010',
        '27010',
      ],
    );

    expect(resultado.balancadas, 4);
    expect(resultado.pesoTotal, 108040);
  });

  test('calcula 100% de viabilidade quando não há mortalidade', () {
    expect(buildPesoMedio(mortalidade: 0).viabilidade, 100);
  });

  test('rejeita valores de domínio não positivos antes de calcular', () {
    for (final resultado in [
      () => buildPesoMedio(idade: 0),
      () => buildPesoMedio(idade: -1),
      () => buildPesoMedio(avesPesadas: 0),
      () => buildPesoMedio(avesPesadas: -1),
      () => buildPesoMedio(avesAlojadas: 0),
      () => buildPesoMedio(avesAlojadas: -1),
      () => buildPesoMedio(pesoPadrao: 0),
      () => buildPesoMedio(pesoPadrao: -1),
    ]) {
      expect(resultado, throwsArgumentError);
    }
  });

  test('rejeita lote sem aves vivas', () {
    expect(() => buildPesoMedio(mortalidade: 10000), throwsArgumentError);
  });

  test('rejeita ausência de leituras positivas', () {
    expect(
      () => buildPesoMedio(balancas: const ['', ' ', 'inválido', '0']),
      throwsArgumentError,
    );
  });

  test('rejeita peso médio não positivo que invalidaria a conversão', () {
    expect(() => buildPesoMedio(tara: 27010), throwsArgumentError);
  });
}
