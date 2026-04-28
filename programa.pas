program JogoDeTruco;

const
  PONTOS_PARA_VENCER = 12;
  TOTAL_CARTAS_NAIPE = 10;
  TOTAL_NAIPES       = 4;
  TOTAL_CARTAS_MAO   = 3;

  // Identificadores de jogador
  JOGADOR = 1;
  BOT     = 2;

  // Decisoes durante negociacao de aposta
  APOSTA_CORRER  = 0;
  APOSTA_ACEITAR = 1;
  APOSTA_RETRUCO = 2;

  NOMES_CARTAS: array[1..10] of string = ('4','5','6','7','Q','J','K','A','2','3');
  NAIPES:       array[1..4]  of string = ('Ouros','Espadas','Copas','Paus');

type
  TCarta = record
    nome:  integer;
    naipe: integer;
  end;

  TBaralho = record
    cartas: array[1..40] of TCarta;
    topo:   integer;
  end;

  TMao = record
    cartas:    array[1..3] of TCarta;
    quantidade: integer;
  end;

  TRodada = record
    valorAtual:             integer; // Pontos em disputa (1, 3, 6, 9 ou 12)
    vitoriasPrimeiro:       integer; // Vitorias do jogador nas vazas
    vitoriasSegundo:        integer; // Vitorias do bot nas vazas
    primeiraVazaGanhouQuem: integer; // 0=empate, JOGADOR ou BOT
    quemComecaVaza:         integer; // JOGADOR ou BOT
    quemPodePedirAumento:   integer; // 0=ambos, JOGADOR ou BOT
    quemVenceuPorFuga:      integer; // 0=ninguem fugiu, JOGADOR ou BOT
    rodadaEmpatada:         boolean;
  end;

// Retorna 1 se carta1 vence, 2 se carta2 vence, 0 se empate
function CompararCartas(carta1, carta2: TCarta; manilha: integer): integer;
var
  carta1EManilha, carta2EManilha: boolean;
begin
  carta1EManilha := (carta1.nome = manilha);
  carta2EManilha := (carta2.nome = manilha);

  if carta1EManilha and carta2EManilha then
  begin
    if   carta1.naipe > carta2.naipe then CompararCartas := 1
    else if carta1.naipe < carta2.naipe then CompararCartas := 2
    else                                                                  CompararCartas := 0;
  end
  else if carta1EManilha          then CompararCartas := 1
  else if carta2EManilha          then CompararCartas := 2
  else if carta1.nome > carta2.nome then CompararCartas := 1
  else if carta2.nome > carta1.nome then CompararCartas := 2
  else                                     CompararCartas := 0;
end;

function CriarBaralho(): TBaralho;
var
  baralho: TBaralho;
  i, j: integer;
begin
  baralho.topo := 0;
  for i := 1 to TOTAL_NAIPES do
    for j := 1 to TOTAL_CARTAS_NAIPE do
    begin
      baralho.topo := baralho.topo + 1;
      baralho.cartas[baralho.topo].nome  := j;
      baralho.cartas[baralho.topo].naipe := i;
    end;
  CriarBaralho := baralho;
end;

procedure Embaralhar(var baralho: TBaralho);
var
  i, pos: integer;
  temp: TCarta;
begin
  for i := baralho.topo downto 2 do
  begin
    pos               := random(i) + 1;
    temp              := baralho.cartas[i];
    baralho.cartas[i] := baralho.cartas[pos];
    baralho.cartas[pos] := temp;
  end;
end;

function RetirarCartaDoTopo(var baralho: TBaralho): TCarta;
begin
  RetirarCartaDoTopo := baralho.cartas[baralho.topo];
  baralho.topo := baralho.topo - 1;
end;

function DistribuirMao(var baralho: TBaralho): TMao;
var
  mao: TMao;
  i:   integer;
begin
  mao.quantidade := TOTAL_CARTAS_MAO;
  for i := 1 to TOTAL_CARTAS_MAO do
    mao.cartas[i] := RetirarCartaDoTopo(baralho);
  DistribuirMao := mao;
end;

function RetirarCartaDaMao(var mao: TMao; posicao: integer): TCarta;
var
  i: integer;
begin
  RetirarCartaDaMao := mao.cartas[posicao];
  for i := posicao to mao.quantidade - 1 do
    mao.cartas[i] := mao.cartas[i + 1];
  mao.quantidade := mao.quantidade - 1;
end;

procedure MostrarMao(mao: TMao);
var
  i: integer;
begin
  writeln('--- SUA MAO ---');
  for i := 1 to mao.quantidade do
    writeln('  [', i, '] ', NOMES_CARTAS[mao.cartas[i].nome], ' de ', NAIPES[mao.cartas[i].naipe]);
end;

procedure MostrarCarta(quem: string; carta: TCarta);
begin
  writeln(quem, ' jogou: ', NOMES_CARTAS[carta.nome], ' de ', NAIPES[carta.naipe]);
end;

function ProximoValorDeAposta(valorAtual: integer): integer;
begin
  case valorAtual of
    1: ProximoValorDeAposta := 3;
    3: ProximoValorDeAposta := 6;
    6: ProximoValorDeAposta := 9;
    9: ProximoValorDeAposta := PONTOS_PARA_VENCER;
  else ProximoValorDeAposta := PONTOS_PARA_VENCER;
  end;
end;

// Exibe opcoes e retorna a decisao do jogador humano
function JogadorDecideAposta(valorProposto: integer; mao: TMao): integer;
var
  escolha: integer;
begin
  MostrarMao(mao);

  if valorProposto < PONTOS_PARA_VENCER then
    write('O que Você faz? [1] Aceitar | [2] Correr | [3] Pedir ',
          ProximoValorDeAposta(valorProposto), ' -> ')
  else
    write('O que Você faz? [1] Aceitar | [2] Correr -> ');

  readln(escolha);

  // RETRUCO so e valido quando ainda ha espaco para aumentar
  if (escolha = 3) and (valorProposto >= PONTOS_PARA_VENCER) then
  begin
    writeln('Nao e possivel pedir mais. Assumindo que aceitou.');
    escolha := APOSTA_ACEITAR;
  end;

  case escolha of
    APOSTA_ACEITAR: JogadorDecideAposta := APOSTA_ACEITAR;
    2:              JogadorDecideAposta := APOSTA_CORRER;
    3:              JogadorDecideAposta := APOSTA_RETRUCO;
  else
    begin
      writeln('Opcao invalida. Assumindo que aceitou.');
      JogadorDecideAposta := APOSTA_ACEITAR;
    end;
  end;
end;

// Simula a decisao do bot: 20% retruco, 50% aceitar, 30% correr
function BotDecideAposta(valorProposto: integer): integer;
var
  sorte: integer;
begin
  sorte := random(10);

  if (sorte < 2) and (valorProposto < PONTOS_PARA_VENCER) then
    BotDecideAposta := APOSTA_RETRUCO
  else if sorte < 7 then
    BotDecideAposta := APOSTA_ACEITAR
  else
    BotDecideAposta := APOSTA_CORRER;
end;

// Conduz a negociacao de truco/aumento entre os dois lados
procedure NegociarAposta(quemPediu: integer; var rodada: TRodada; maoDoJogador: TMao);
var
  valorProposto, quemResponde, decisao: integer;
begin
  valorProposto := ProximoValorDeAposta(rodada.valorAtual);
  quemResponde  := 3 - quemPediu;

  repeat
    writeln('');

    // Anuncia o valor proposto por quem esta pedindo
    if valorProposto = 3 then
    begin
      if quemPediu = BOT then writeln('>>> O bot pediu truco! <<<')
      else                     writeln('>>> Você pediu truco! <<<');
    end
    else
    begin
      if quemPediu = BOT then writeln('>>> O bot pediu ', valorProposto, '! <<<')
      else                     writeln('>>> Você pediu ', valorProposto, '! <<<');
    end;

    // Colhe a decisao de quem deve responder
    if quemResponde = JOGADOR then
      decisao := JogadorDecideAposta(valorProposto, maoDoJogador)
    else
      decisao := BotDecideAposta(valorProposto);

    case decisao of
      APOSTA_ACEITAR:
        begin
          if quemResponde = JOGADOR then
            writeln('>>> Você aceitou! A rodada vale ', valorProposto, ' ponto(s). <<<')
          else
            writeln('>>> O bot aceitou! A rodada vale ', valorProposto, ' ponto(s). <<<');

          rodada.valorAtual           := valorProposto;
          rodada.quemPodePedirAumento := quemResponde; // quem aceitou pode pedir a seguir
        end;

      APOSTA_CORRER:
        begin
          if quemResponde = JOGADOR then
            writeln('>>> Você correu! O bot ganha a rodada. <<<')
          else
            writeln('>>> O bot correu! Você ganha a rodada. <<<');

          rodada.quemVenceuPorFuga := quemPediu; // quem pediu vence quando o outro corre
        end;

      APOSTA_RETRUCO:
        begin
          // Troca os papeis: quem respondia agora passa a ser o pedidor
          valorProposto := ProximoValorDeAposta(valorProposto);
          quemPediu    := quemResponde;
          quemResponde := 3 - quemResponde;
        end;
    end;

  until decisao <> APOSTA_RETRUCO;
end;

procedure TurnoDoJogador(var maoJogador: TMao; var rodada: TRodada; var cartaJogada: TCarta);
var
  escolha, acao, valorFuturo: integer;
  podeAumentar: boolean;
begin
  MostrarMao(maoJogador);

  podeAumentar := (rodada.valorAtual < PONTOS_PARA_VENCER) and
                  ((rodada.quemPodePedirAumento = 0) or
                   (rodada.quemPodePedirAumento = JOGADOR));

  if podeAumentar then
  begin
    valorFuturo := ProximoValorDeAposta(rodada.valorAtual);
    if valorFuturo = 3 then
      write('O que deseja fazer? [1] Jogar carta | [2] Pedir TRUCO -> ')
    else
      write('O que deseja fazer? [1] Jogar carta | [2] Pedir ', valorFuturo, ' -> ');

    readln(acao);
    if acao = 2 then
      NegociarAposta(JOGADOR, rodada, maoJogador);
  end;

  if rodada.quemVenceuPorFuga = 0 then
  begin
    write('Escolha a carta (1 a ', maoJogador.quantidade, '): ');
    readln(escolha);
    if (escolha < 1) or (escolha > maoJogador.quantidade) then
      escolha := 1;
    cartaJogada := RetirarCartaDaMao(maoJogador, escolha);
  end;
end;

procedure TurnoDoBot(var maoBot: TMao; var rodada: TRodada; var cartaJogada: TCarta; maoJogador: TMao);
var
  podeAumentar: boolean;
begin
  podeAumentar := (rodada.valorAtual < PONTOS_PARA_VENCER) and
                  ((rodada.quemPodePedirAumento = 0) or
                   (rodada.quemPodePedirAumento = BOT));

  if podeAumentar and (random(10) < 2) then
    NegociarAposta(BOT, rodada, maoJogador);

  if rodada.quemVenceuPorFuga = 0 then
    cartaJogada := RetirarCartaDaMao(maoBot, random(maoBot.quantidade) + 1);
end;

procedure ProcessarResultadoDaVaza(resultadoVaza, numeroVaza: integer; var rodada: TRodada);
begin
  case resultadoVaza of
    JOGADOR:
      begin
        writeln('-> Você venceu essa vaza!');
        rodada.vitoriasPrimeiro := rodada.vitoriasPrimeiro + 1;
        if numeroVaza = 1 then rodada.primeiraVazaGanhouQuem := JOGADOR;
        rodada.quemComecaVaza := JOGADOR;
      end;

    BOT:
      begin
        writeln('-> O bot venceu essa vaza!');
        rodada.vitoriasSegundo := rodada.vitoriasSegundo + 1;
        if numeroVaza = 1 then rodada.primeiraVazaGanhouQuem := BOT;
        rodada.quemComecaVaza := BOT;
      end;

    0: // Empate (empachou)
      begin
        writeln('-> Empate!');

        if numeroVaza = 1 then
          rodada.primeiraVazaGanhouQuem := 0

        else if numeroVaza = 2 then
          case rodada.primeiraVazaGanhouQuem of
            JOGADOR:
              begin
                writeln('(Você ganhou a 1a vaza, então Você vence a rodada!)');
                rodada.vitoriasPrimeiro := 2;
              end;
            BOT:
              begin
                writeln('(O bot ganhou a 1a vaza, então o bot vence a rodada!)');
                rodada.vitoriasSegundo := 2;
              end;
            0:
              begin
                writeln('(A 1a vaza também empatou: rodada empatada, sem pontos!)');
                rodada.rodadaEmpatada := true;
              end;
          end

        else // 3a vaza empatada
          begin
            writeln('(3a vaza empatada: rodada empatada, sem pontos!)');
            rodada.rodadaEmpatada := true;
          end;
      end;
  end;

  rodada.quemPodePedirAumento := 0;
end;

procedure PrepararMesaDaRodada(var baralho: TBaralho; var maoJogador, maoBot: TMao;
                                var vira: TCarta; var manilha: integer);
begin
  baralho    := CriarBaralho();
  Embaralhar(baralho);

  vira       := RetirarCartaDoTopo(baralho);
  maoJogador := DistribuirMao(baralho);
  maoBot     := DistribuirMao(baralho);

  if vira.nome = TOTAL_CARTAS_NAIPE then
    manilha := 1
  else
    manilha := vira.nome + 1;
end;

procedure ExecutarTurnosDaVaza(var maoJogador, maoBot: TMao; var rodada: TRodada;
                                var cartaJogador, cartaBot: TCarta);
begin
  if rodada.quemComecaVaza = JOGADOR then
  begin
    writeln('Você comeca esta vaza.');
    TurnoDoJogador(maoJogador, rodada, cartaJogador);
    if rodada.quemVenceuPorFuga = 0 then
      TurnoDoBot(maoBot, rodada, cartaBot, maoJogador);
  end
  else
  begin
    writeln('O bot comeca esta vaza.');
    TurnoDoBot(maoBot, rodada, cartaBot, maoJogador);

    if rodada.quemVenceuPorFuga = 0 then
    begin
      writeln('');
      writeln('>>> O Bot jogou primeiro e colocou na mesa: ',
              NOMES_CARTAS[cartaBot.nome], ' de ', NAIPES[cartaBot.naipe], ' <<<');
      writeln('');
      TurnoDoJogador(maoJogador, rodada, cartaJogador);
    end;
  end;
end;

// Retorna JOGADOR, BOT ou 0 (empate) como vencedor da rodada
function DeterminarVencedorDaRodada(rodada: TRodada): integer;
begin
  if rodada.rodadaEmpatada then
    DeterminarVencedorDaRodada := 0
  else if rodada.vitoriasPrimeiro >= 2 then
    DeterminarVencedorDaRodada := JOGADOR
  else
    DeterminarVencedorDaRodada := BOT;
end;

procedure AtualizarPlacar(vencedor, valorRodada: integer;
                           var pontuacaoJogador, pontuacaoBot, quemComecaMao: integer);
begin
  case vencedor of
    JOGADOR:
      begin
        writeln('*** VVocê venceu essa rodada! +', valorRodada, ' ponto(s) ***');
        pontuacaoJogador := pontuacaoJogador + valorRodada;
        quemComecaMao    := BOT; // perdedor comeca a proxima
      end;
    BOT:
      begin
        writeln('*** O bot venceu essa rodada! +', valorRodada, ' ponto(s) ***');
        pontuacaoBot  := pontuacaoBot + valorRodada;
        quemComecaMao := JOGADOR;
      end;
    0:
      writeln('*** Rodada empatada! Nenhum ponto marcado. ***');
  end;
end;

procedure JogarRodada(var pontuacaoJogador, pontuacaoBot, quemComecaMao: integer);
var
  baralho:          TBaralho;
  maoJogador, maoBot: TMao;
  cartaJogador, cartaBot, vira: TCarta;
  rodada:           TRodada;
  manilha, resultadoVaza, numeroVaza, vencedorDaRodada: integer;
begin
  rodada.valorAtual             := 1;
  rodada.vitoriasPrimeiro       := 0;
  rodada.vitoriasSegundo        := 0;
  rodada.primeiraVazaGanhouQuem := 0;
  rodada.quemPodePedirAumento   := 0;
  rodada.quemComecaVaza         := quemComecaMao;
  rodada.quemVenceuPorFuga      := 0;
  rodada.rodadaEmpatada         := false;

  PrepararMesaDaRodada(baralho, maoJogador, maoBot, vira, manilha);

  writeln('A carta virada (Vira) e: ', NOMES_CARTAS[vira.nome], ' de ', NAIPES[vira.naipe]);
  writeln('As manilhas da rodada sao as cartas: ', NOMES_CARTAS[manilha]);
  writeln('---------------------------------------');

  numeroVaza := 0;
  while (rodada.vitoriasPrimeiro < 2) and (rodada.vitoriasSegundo < 2) and
        (maoJogador.quantidade > 0) and (not rodada.rodadaEmpatada) do
  begin
    numeroVaza := numeroVaza + 1;
    writeln('');
    writeln('--- Vaza ', numeroVaza, ' ---');

    ExecutarTurnosDaVaza(maoJogador, maoBot, rodada, cartaJogador, cartaBot);

    // Fuga encerra a rodada imediatamente
    if rodada.quemVenceuPorFuga <> 0 then
    begin
      if rodada.quemVenceuPorFuga = JOGADOR then
        rodada.vitoriasPrimeiro := 2
      else
        rodada.vitoriasSegundo := 2;
      break;
    end;

    writeln('');
    if rodada.quemComecaVaza = JOGADOR then
    begin
      MostrarCarta('Você', cartaJogador);
      MostrarCarta('Bot ', cartaBot);
    end
    else
    begin
      MostrarCarta('Bot ', cartaBot);
      MostrarCarta('Você', cartaJogador);
    end;

    resultadoVaza := CompararCartas(cartaJogador, cartaBot, manilha);
    ProcessarResultadoDaVaza(resultadoVaza, numeroVaza, rodada);

    writeln('---------------------------------------');

    if rodada.quemComecaVaza = JOGADOR then
      rodada.quemComecaVaza := BOT
    else
      rodada.quemComecaVaza := JOGADOR;
  end;

  vencedorDaRodada := DeterminarVencedorDaRodada(rodada);
  AtualizarPlacar(vencedorDaRodada, rodada.valorAtual, pontuacaoJogador, pontuacaoBot, quemComecaMao);
end;

procedure JogarPartida();
var
  pontuacaoJogador, pontuacaoBot, quemComecaMao: integer;
begin
  pontuacaoJogador := 0;
  pontuacaoBot     := 0;
  quemComecaMao    := random(2) + 1;

  while (pontuacaoJogador < PONTOS_PARA_VENCER) and
        (pontuacaoBot     < PONTOS_PARA_VENCER) do
  begin
    writeln('');
    writeln('=======================================');
    writeln('PLACAR: Você ', pontuacaoJogador, ' x ', pontuacaoBot, ' Bot');
    writeln('=======================================');

    JogarRodada(pontuacaoJogador, pontuacaoBot, quemComecaMao);

    if quemComecaMao = JOGADOR then
      quemComecaMao := BOT
    else
      quemComecaMao := JOGADOR;
  end;

  writeln('');
  writeln('=========== FIM DE JOGO ===========');
  writeln('Placar final: Você ', pontuacaoJogador, ' x ', pontuacaoBot, ' Bot');

  if pontuacaoJogador >= PONTOS_PARA_VENCER then
    writeln('Parabéns! Você Ganhou a partida!')
  else
    writeln('O bot ganhou a partida!');
end;

begin
  randomize;
  writeln('=== Truco ===');
  writeln('');
  JogarPartida();
  writeln('');
  writeln('Pressione ENTER para sair.');
  readln;
end.
