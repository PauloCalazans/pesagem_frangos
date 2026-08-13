# Compartilhamento visual do resultado

## Objetivo

Alterar a ação **Compartilhar resumo** para compartilhar uma imagem PNG formatada do resultado, em vez de somente um resumo textual. A imagem deve preservar a identidade visual da tela, mostrar todos os dados e excluir elementos de navegação.

## Experiência do usuário

- O usuário toca em **Compartilhar resumo** na tela de resultado.
- Enquanto a imagem é preparada, a ação primária fica desabilitada e indica processamento para impedir acionamentos repetidos.
- O compartilhamento nativo é aberto com uma imagem PNG e o título **Resumo da pesagem**.
- A imagem contém todos os cartões, métricas e linhas detalhadas do resultado.
- A imagem não contém a barra superior, o botão **Nova pesagem** nem o botão **Compartilhar resumo**.
- Caso a operação falhe, a tela permanece intacta e exibe a mensagem **Não foi possível compartilhar o resumo**.

## Composição visual

O conteúdo dos resultados será extraído para um componente reutilizável. A tela interativa continuará usando seções expansíveis. A composição destinada ao compartilhamento reutilizará os mesmos componentes, cores, tipografia, formatação numérica e espaçamentos, mas apresentará permanentemente todas as linhas das seções **Detalhes da pesagem** e **Plantel e alimentação**.

A versão compartilhável terá fundo sólido, margens próprias e largura lógica controlada, sem depender do tamanho da tela ou da posição atual da rolagem. A renderização usará densidade suficiente para manter o texto legível em aplicativos de mensagens e e-mail.

## Arquitetura e fluxo de dados

1. `ResultadoPage` solicita o compartilhamento e entra no estado de processamento.
2. Um componente visual dedicado recebe o mesmo objeto `PesoMedio` usado pela tela.
3. O componente completo é renderizado fora da área visível e convertido em bytes PNG.
4. Os bytes são gravados em um arquivo temporário com extensão `.png`.
5. `share_plus` abre o compartilhamento nativo usando o arquivo e o título **Resumo da pesagem**.
6. Ao terminar ou falhar, o estado de processamento é encerrado.

A geração da imagem e o compartilhamento serão expostos por dependências injetáveis onde necessário, permitindo testar o comportamento sem acionar APIs de plataforma.

## Tratamento de falhas

Erros de renderização, codificação PNG, gravação temporária ou chamada ao compartilhamento nativo serão tratados pela mesma fronteira. Nenhuma falha deve remover o resultado ou reiniciar a pesagem. O usuário receberá somente a mensagem objetiva **Não foi possível compartilhar o resumo** e poderá tentar novamente.

## Testes e critérios de aceite

- A ação compartilha um arquivo PNG, não apenas texto.
- A composição compartilhável contém peso médio, percentual do padrão, viabilidade, eficiência e todas as linhas das duas seções detalhadas.
- A composição não contém AppBar nem ações de navegação/compartilhamento.
- O conteúdo compartilhado independe do estado aberto ou fechado das seções na tela.
- A ação não pode ser disparada novamente enquanto a geração estiver em andamento.
- Uma falha mantém a tela e apresenta a mensagem definida.
- Os testes existentes de layout responsivo e acessibilidade permanecem aprovados.

## Fora de escopo

- Gerar PDF.
- Adicionar logotipo, marca d'água ou personalização de tema para exportação.
- Compartilhar simultaneamente o resumo textual completo.
- Persistir imagens geradas na galeria do dispositivo.
