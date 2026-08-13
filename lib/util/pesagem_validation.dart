class PesagemValidation {
  PesagemValidation._();

  static int? _integer(String? value) => int.tryParse(value?.trim() ?? '');

  static String? requiredPositive(String? value, {required String label}) {
    final parsed = _integer(value);
    if (parsed == null) return 'Informe $label em números inteiros';
    if (parsed <= 0) return '$label deve ser maior que zero';
    return null;
  }

  static String? nonNegative(
    String? value, {
    required String label,
    bool allowEmpty = false,
  }) {
    if ((value ?? '').trim().isEmpty && allowEmpty) return null;
    final parsed = _integer(value);
    if (parsed == null) return 'Informe $label em números inteiros';
    if (parsed < 0) return '$label não pode ser negativo';
    return null;
  }

  static String? validateMortalidade({
    required String? mortalidade,
    required String? avesAlojadas,
  }) {
    final baseError = nonNegative(mortalidade, label: 'Mortalidade');
    if (baseError != null) return baseError;
    final alojadas = _integer(avesAlojadas);
    final mortes = _integer(mortalidade)!;
    if (alojadas != null && mortes >= alojadas) {
      return 'Mortalidade deve ser menor que aves alojadas';
    }
    return null;
  }

  static String? validateEstoque({
    required String? estoque,
    required String? racaoRecebida,
  }) {
    final baseError = nonNegative(estoque, label: 'Estoque');
    if (baseError != null) return baseError;
    final recebida = _integer(racaoRecebida);
    final atual = _integer(estoque)!;
    if (recebida != null && atual > recebida) {
      return 'Estoque não pode superar a ração recebida';
    }
    return null;
  }

  static String? validateBalancas(String? value) {
    final lines = (value ?? '')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.any((line) => line.isNotEmpty && int.tryParse(line) == null)) {
      return 'Use somente números, uma pesagem por linha';
    }
    final readings = lines.map(int.parse).toList();
    final valid = readings.where((weight) => weight > 0);
    if (valid.isEmpty) return 'Informe ao menos uma pesagem válida';
    if (readings.any((weight) => weight <= 0)) {
      return 'Cada pesagem deve ser maior que zero';
    }
    return null;
  }
}
