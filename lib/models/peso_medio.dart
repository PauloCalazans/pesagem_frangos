class PesoMedio {
  late double gmd;
  late double pesoMedio;
  late double porcentagem;
  late double ca;
  late int consumo;
  late int pesoTotal;
  late int balancadas; // quantas balanças foram digitadas
  late int desconto;
  late int avesVivas;
  late double viabilidade;
  late double diferencaPeso;

  int idade;
  int avesPesadas;
  int avesAlojadas;
  int pesoPadrao;
  int racaoRecebida;
  int estoqueRacao;
  int tara;
  List<String> balancas;
  int mortalidade;

  PesoMedio({
    required this.idade,
    required this.avesPesadas,
    required this.avesAlojadas,
    required this.pesoPadrao,
    required this.racaoRecebida,
    required this.estoqueRacao,
    required this.tara,
    required this.balancas,
    required this.mortalidade,
  });

  Iterable<int> get _pesosValidos => balancas
      .map((peso) => int.tryParse(peso.trim()))
      .whereType<int>()
      .where((peso) => peso > 0);

  void validarEntradas() {
    if (idade <= 0) {
      throw ArgumentError.value(idade, 'idade', 'deve ser maior que zero');
    }
    if (avesPesadas <= 0) {
      throw ArgumentError.value(
        avesPesadas,
        'avesPesadas',
        'deve ser maior que zero',
      );
    }
    if (avesAlojadas <= 0) {
      throw ArgumentError.value(
        avesAlojadas,
        'avesAlojadas',
        'deve ser maior que zero',
      );
    }
    if (pesoPadrao <= 0) {
      throw ArgumentError.value(
        pesoPadrao,
        'pesoPadrao',
        'deve ser maior que zero',
      );
    }
  }

  void validarBalancas() {
    if (balancadas == 0) {
      throw ArgumentError.value(
        balancas,
        'balancas',
        'deve conter ao menos uma leitura positiva',
      );
    }
  }

  void validarPesoMedio() {
    if (!pesoMedio.isFinite || pesoMedio <= 0) {
      throw ArgumentError.value(
        tara,
        'tara',
        'não pode resultar em peso médio não positivo',
      );
    }
  }

  void validarAvesVivas() {
    if (avesVivas <= 0) {
      throw ArgumentError.value(
        mortalidade,
        'mortalidade',
        'deve deixar ao menos uma ave viva',
      );
    }
  }

  contarBalancas() {
    balancadas = _pesosValidos.length;
  }

  calcularDesconto() {
    desconto = tara * balancadas;
  }

  somarPesoBalancas() {
    pesoTotal = 0;
    for (final peso in _pesosValidos) {
      pesoTotal += peso;
    }
  }

  calcularPesoMedio() {
    pesoMedio = (pesoTotal - desconto) / avesPesadas;
  }

  calcularDiferencaPeso() {
    diferencaPeso = pesoMedio - pesoPadrao;
  }

  calcularGmd() {
    gmd = pesoMedio / idade;
  }

  calcularConsumo() {
    consumo = racaoRecebida - estoqueRacao;
  }

  calcularConversao() {
    ca = consumo / ((pesoMedio * avesVivas) / 1000);
  }

  calcularPorcentagem() {
    porcentagem = (pesoMedio / pesoPadrao) * 100;
  }

  calcularAvesVivas() {
    avesVivas = avesAlojadas - mortalidade;
  }

  calcularViabilidade() {
    viabilidade = (avesVivas / avesAlojadas) * 100;
  }

  calcular() {
    validarEntradas();
    contarBalancas();
    validarBalancas();
    calcularDesconto();
    somarPesoBalancas();
    calcularPesoMedio();
    validarPesoMedio();
    calcularDiferencaPeso();
    calcularGmd();
    calcularConsumo();
    calcularAvesVivas();
    validarAvesVivas();
    calcularViabilidade();
    calcularConversao();
    calcularPorcentagem();
  }
}
