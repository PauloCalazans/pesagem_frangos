class PesoMedio {
  int idade;
  int avesPesadas;
  int avesAlojadas;
  double gmd;
  int mortalidade;
  double pesoMedio;
  int pesoPadrao;
  double porcentagem;
  double ca;
  int consumo;
  int racaoRecebida;
  int estoqueRacao;
  int tara;
  int pesoTotal;
  int balancadas; // quantas balanças foram digitadas
  List<String> balancas;
  int desconto;
  int avesVivas;

  PesoMedio(
      {this.idade,
      this.avesPesadas,
      this.avesAlojadas,
      this.pesoPadrao,
      this.racaoRecebida,
      this.estoqueRacao,
      this.tara,
      this.balancas,
      this.mortalidade});

  int contarBalancas() {
    balancadas = 0;
    balancas.forEach((it) {
      if(it.isNotEmpty && int.tryParse(it) > 0) {
        balancadas++;
      }
    });
    return balancadas;
  }

  int calcularDesconto() {
    desconto = tara * balancadas;
    return desconto;
  }

  int somarPesoBalancas() {
    pesoTotal = 0;
    balancas.forEach((peso) {
      if(peso.isNotEmpty) {
        pesoTotal += int.tryParse(peso);
      }
    });

    return pesoTotal;
  }

  double calcularPesoMedio() {
    pesoMedio = (pesoTotal-desconto) / avesPesadas;
    return pesoMedio;
  }

  double calcularGmd() {
    gmd = pesoMedio / idade;
    return gmd;
  }

  int calcularConsumo() {
    consumo = racaoRecebida - estoqueRacao;
    return consumo;
  }

  double calcularConversao() {
    ca = consumo / ((pesoMedio * avesVivas)/1000);
    return ca;
  }

  double calcularPorcentagem() {
    porcentagem = (pesoMedio / pesoPadrao) * 100;
    return porcentagem;
  }

  int calcularAvesVivas() {
    avesVivas = avesAlojadas - mortalidade;
    return avesVivas;
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
