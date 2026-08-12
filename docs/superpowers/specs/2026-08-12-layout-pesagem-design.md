# Redesign do fluxo de pesagem

**Data:** 12 de agosto de 2026

**Status:** aprovado para planejamento

**Plataforma:** Flutter, orientação retrato

## Contexto

O aplicativo auxilia o cálculo de indicadores de um lote de frangos. Seu uso principal ocorre em uma situação confortável, como sobre uma mesa; operação com uma mão não é requisito. A interface atual possui campos excessivamente altos, pouco contexto sobre as etapas, grande área vazia, ações pouco destacadas e uma tela de resultados apresentada como uma lista extensa sem hierarquia.

## Objetivos

- Tornar o preenchimento mais compacto e fácil de revisar.
- Preservar o fluxo conhecido de três etapas.
- Explicitar unidades, valores automáticos e progresso.
- Dar destaque aos indicadores usados para decisão e anotação.
- Apresentar o percentual total em relação ao padrão, como `102,1%`, e não somente a diferença percentual.
- Acrescentar a viabilidade do lote aos cálculos e aos resultados principais.
- Impedir combinações de dados inválidas antes do cálculo.

## Fora de escopo

- Alterar as tabelas de peso padrão existentes.
- Criar autenticação, sincronização remota ou histórico persistente de pesagens.
- Oferecer layouts específicos para tablet ou orientação paisagem nesta primeira entrega.
- Refatorar áreas que não participam do fluxo de pesagem ou da edição dos padrões.

## Direção escolhida

Foram consideradas três estruturas:

1. Fluxo guiado e compacto, mantendo as três etapas atuais.
2. Formulário único rolável, separado em seções recolhíveis.
3. Assistente explicativo, com mais orientação textual em cada etapa.

A opção escolhida foi o **fluxo guiado e compacto**. Ela reduz a mudança de comportamento para usuários atuais, melhora a hierarquia e evita expor todos os campos simultaneamente.

## Estrutura do fluxo

### Etapa 1 — Dados do lote

- Sexo.
- Idade, em dias.
- Peso padrão, em gramas.
- Aves alojadas.
- Mortalidade acumulada, em aves.

Sexo e idade atualizam automaticamente o peso padrão. O campo continua editável, mas exibe a indicação “Preenchido automaticamente pela idade e sexo”.

### Etapa 2 — Consumo e amostra

- Ração recebida, em quilogramas.
- Estoque atual de ração, em quilogramas.
- Tara da balança, em gramas.
- Aves pesadas.

### Etapa 3 — Pesagens

- Entrada das leituras das balanças.
- Uma leitura válida por linha.
- Resumo da quantidade de leituras válidas antes do cálculo.

O usuário pode avançar ou voltar sem perder valores. Cada etapa valida somente os campos que apresenta. A última ação é “Calcular”; nas etapas anteriores, a ação é “Continuar”.

## Estrutura visual

### Cabeçalho

- Título “Nova pesagem”.
- Nome e posição da etapa, por exemplo “Dados do lote · etapa 1 de 3”.
- Barra de progresso horizontal.
- Menu de opções com a ação textual “Padrões de peso”, substituindo o lápis sem identificação.

### Formulário

- Grade de espaçamento baseada em 8 px.
- Margens laterais de 16 px.
- Campos com aproximadamente 56 px de altura.
- Cantos com raio aproximado de 12 px.
- Alvos de toque com no mínimo 48 px.
- Campos relacionados podem compartilhar uma linha quando os rótulos e valores couberem sem truncamento, como sexo e idade.
- Unidades aparecem como sufixos visíveis: `dias`, `g`, `kg` e `aves`.

### Navegação

- Barra de ações fixa na parte inferior.
- Ação secundária discreta à esquerda: “Cancelar” na primeira etapa e “Voltar” nas demais.
- Ação principal preenchida à direita: “Continuar” ou “Calcular”.
- O teclado e as áreas seguras do dispositivo não podem encobrir os campos nem as ações.

## Linguagem visual

- Material 3 como base dos componentes.
- Cor primária: verde-petróleo `#087F72`.
- Cor de progresso: verde-lima suave `#D7EF68`.
- Fundo: `#F6F8F7`.
- Superfícies: branco `#FFFFFF`.
- Texto principal: `#1B2529`.
- Tipografia nativa do Material 3, com números de resultados maiores que seus rótulos.
- Estados de sucesso, atenção e erro usam ícone e texto, sem depender somente de cor.

## Tela de resultados

O resultado abre em tela completa. Fechá-lo ou voltar ao formulário preserva os dados preenchidos para correção. A hierarquia é:

1. **Crescimento:** peso médio, percentual total do padrão e peso padrão.
2. **Sobrevivência:** viabilidade do lote e aves vivas.
3. **Eficiência:** GMD, conversão alimentar, consumo e mortalidade.
4. **Auditoria:** peso total, tara, desconto, quantidade e média das balanças e demais valores de apoio em seções recolhíveis.

O bloco principal apresenta um formato equivalente a:

- Peso médio: `892 g`.
- Percentual do padrão: `102,1%`.
- Peso padrão: `874 g`.
- Diferença absoluta: `+18 g`, como informação secundária.

O percentual principal sempre representa o total em relação ao padrão. Um lote exatamente no padrão exibe `100,0%`; a interface não substitui esse valor por frases como “2,1% acima”.

A viabilidade aparece em bloco próprio, por exemplo:

- Viabilidade: `97,42%`.
- Aves vivas: `9.742`.

As ações inferiores são “Nova pesagem” e “Compartilhar resumo”. O resumo compartilhável deve usar os mesmos valores e unidades apresentados na tela.

## Cálculos

As fórmulas existentes são preservadas e a viabilidade é acrescentada:

```text
aves vivas = aves alojadas − mortalidade
peso médio = (peso total − desconto total da tara) ÷ aves pesadas
percentual do padrão = peso médio ÷ peso padrão × 100
GMD = peso médio ÷ idade
consumo = ração recebida − estoque atual
conversão alimentar = consumo ÷ ((peso médio × aves vivas) ÷ 1000)
viabilidade = aves vivas ÷ aves alojadas × 100
```

Percentual do padrão e viabilidade são valores numéricos do modelo, não textos previamente formatados. A interface aplica a formatação adequada ao locale `pt-BR`.

## Validação e erros

- Todos os campos obrigatórios mostram erro junto ao próprio campo.
- Idade, peso padrão, aves alojadas e aves pesadas devem ser maiores que zero.
- Mortalidade, tara e estoque não podem ser negativos.
- Mortalidade deve ser menor que aves alojadas; um lote sem aves vivas não possui conversão alimentar calculável.
- Estoque atual não pode superar ração recebida.
- Deve existir ao menos uma leitura de balança válida e positiva.
- Linhas vazias entre leituras podem ser ignoradas; texto não numérico é rejeitado.
- O cálculo não é executado quando puder resultar em divisão por zero ou valor não finito.
- Ao falhar uma validação, o app mantém todos os dados e leva o foco ao primeiro campo inválido da etapa.

## Componentes previstos

- `PesagemProgressHeader`: título, etapa e progresso.
- `MeasurementField`: campo numérico com unidade, ajuda e erro.
- `PesagemBottomActions`: ações fixas e estado de carregamento/desabilitado.
- `ResultHeroCard`: peso médio, percentual e padrão.
- `ViabilityCard`: viabilidade e aves vivas.
- `MetricCard`: indicador secundário com rótulo, valor e unidade.
- `ResultDetailsSection`: grupo recolhível de valores de auditoria.

Os componentes de apresentação recebem valores já calculados e não implementam regras de negócio. Os cálculos permanecem no modelo ou em uma unidade de domínio testável.

## Acessibilidade e adaptação

- Contraste de texto e controles deve atender WCAG AA.
- Rótulos permanecem visíveis mesmo quando o campo contém valor.
- Ícones possuem rótulos semânticos.
- A interface suporta escala de texto sem cortar valores ou ações.
- O formulário rola quando teclado ou escala de texto reduzirem a área disponível.
- A primeira entrega deve funcionar em larguras usuais de celulares Android em orientação retrato.

## Estratégia de testes

### Testes unitários

- Todos os cálculos existentes.
- Percentual total do padrão acima, abaixo e exatamente em `100%`.
- Viabilidade para mortalidade zero, parcial e igual às aves alojadas; o último caso valida a fórmula isolada, embora o formulário o rejeite por inviabilizar a conversão alimentar.
- Proteção contra denominadores iguais a zero.

### Testes de widget

- Navegação entre as três etapas com preservação dos dados.
- Atualização automática do peso padrão por sexo e idade.
- Mensagens de validação e foco no primeiro campo inválido.
- Exibição e formatação de percentual, viabilidade e unidades.
- Expansão das seções de detalhes.

### Testes visuais

- Tela principal e resultados em tamanhos de celular representativos.
- Teclado aberto, escala de texto ampliada e valores numéricos longos.
- Ausência de overflow, truncamento de indicadores e ações encobertas.

## Critérios de aceite

- O usuário conclui a pesagem pelas três etapas sem perder dados ao voltar.
- O layout elimina a grande área vazia observada na tela atual e mantém as ações sempre acessíveis.
- Unidades e origem automática do peso padrão ficam explícitas.
- O resultado mostra o percentual total do padrão, nunca somente a diferença percentual.
- O resultado mostra viabilidade e aves vivas entre os indicadores principais.
- Entradas inválidas não produzem cálculo nem valores infinitos.
- Os detalhes atuais permanecem disponíveis, organizados em grupos.
