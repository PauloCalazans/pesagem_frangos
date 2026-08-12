import 'package:flutter_test/flutter_test.dart';
import 'package:pesagem_frangos/util/pesagem_validation.dart';

void main() {
  group('PesagemValidation', () {
    test('exige inteiro maior que zero', () {
      expect(
        PesagemValidation.requiredPositive('0', label: 'Idade'),
        'Idade deve ser maior que zero',
      );
      expect(PesagemValidation.requiredPositive('21', label: 'Idade'), isNull);
    });

    test('rejeita valores base vazios, não numéricos e negativos', () {
      expect(
        PesagemValidation.requiredPositive('', label: 'Idade'),
        'Informe Idade em números inteiros',
      );
      expect(
        PesagemValidation.nonNegative('', label: 'Mortalidade'),
        'Informe Mortalidade em números inteiros',
      );
      expect(
        PesagemValidation.nonNegative('texto', label: 'Mortalidade'),
        'Informe Mortalidade em números inteiros',
      );
      expect(
        PesagemValidation.validateMortalidade(
          mortalidade: '-1',
          avesAlojadas: '100',
        ),
        'Mortalidade não pode ser negativo',
      );
      expect(
        PesagemValidation.validateEstoque(estoque: '-1', racaoRecebida: '300'),
        'Estoque não pode ser negativo',
      );
    });

    test('mortalidade deve ser menor que aves alojadas', () {
      expect(
        PesagemValidation.validateMortalidade(
          mortalidade: '100',
          avesAlojadas: '100',
        ),
        'Mortalidade deve ser menor que aves alojadas',
      );
    });

    test('estoque não pode superar ração recebida', () {
      expect(
        PesagemValidation.validateEstoque(estoque: '301', racaoRecebida: '300'),
        'Estoque não pode superar a ração recebida',
      );
    });

    test('balanças priorizam linhas não numéricas', () {
      expect(
        PesagemValidation.validateBalancas('\n0\ntexto'),
        'Use somente números, uma pesagem por linha',
      );
      expect(
        PesagemValidation.validateBalancas('1200\ntexto'),
        'Use somente números, uma pesagem por linha',
      );
    });

    test('balanças exigem ao menos uma leitura positiva', () {
      expect(
        PesagemValidation.validateBalancas('\n0\n'),
        'Informe ao menos uma pesagem válida',
      );
      expect(PesagemValidation.validateBalancas('1200\n1300'), isNull);
    });
  });
}
