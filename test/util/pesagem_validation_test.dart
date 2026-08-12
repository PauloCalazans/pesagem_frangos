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

    test('balanças exigem ao menos uma leitura positiva', () {
      expect(
        PesagemValidation.validateBalancas('\n0\ntexto'),
        'Informe ao menos uma pesagem válida',
      );
      expect(PesagemValidation.validateBalancas('1200\n1300'), isNull);
    });
  });
}
