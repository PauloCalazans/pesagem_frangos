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

  int idade;
  int avesPesadas;
  int avesAlojadas;
  int pesoPadrao;
  int racaoRecebida;
  int estoqueRacao;
  int tara;
  List<String> balancas;
  int mortalidade;

  PesoMedio(
      {required this.idade,
      required this.avesPesadas,
      required this.avesAlojadas,
      required this.pesoPadrao,
      required this.racaoRecebida,
      required this.estoqueRacao,
      required this.tara,
      required this.balancas,
      required this.mortalidade});

  contarBalancas() {
    balancadas = 0;
    balancas.forEach((it) {
      if(it.isNotEmpty && int.tryParse(it)! > 0) {
        balancadas++;
      }
    });
  }

  calcularDesconto() {
    desconto = tara * balancadas;
  }

  somarPesoBalancas() {
    pesoTotal = 0;
    balancas.forEach((peso) {
      if(peso.isNotEmpty) {
        pesoTotal += int.tryParse(peso)!;
      }
    });
  }

  calcularPesoMedio() {
    pesoMedio = (pesoTotal-desconto) / avesPesadas;
  }

  calcularGmd() {
    gmd = pesoMedio / idade;
  }

  calcularConsumo() {
    consumo = racaoRecebida - estoqueRacao;
  }

  calcularConversao() {
    ca = consumo / ((pesoMedio * avesVivas)/1000);
  }

  calcularPorcentagem() {
    porcentagem = (pesoMedio / pesoPadrao) * 100;
  }

  calcularAvesVivas() {
    avesVivas = avesAlojadas - mortalidade;
  }

  calcular() {
    contarBalancas();
    calcularDesconto();
    somarPesoBalancas();
    calcularPesoMedio();
    calcularGmd();
    calcularConsumo();
    calcularAvesVivas();
    calcularConversao();
    calcularPorcentagem();
  }
}
