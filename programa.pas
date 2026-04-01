program BaralhoDeTruco;

type
  TCarta = record
    nome: string;
    pontuacao_carta: integer;
    naipe: string;
    pontuacao_naipe: integer;
  end;

  TBaralho = record
    cartas: array[1..40] of TCarta;
    tamanho_maximo: integer;
    topo: integer;
  end;

var
  meuBaralho: TBaralho;
  nomesCartas: array[1..10] of string;
  nomesNaipes: array[1..4] of string;
  i, j: integer;

function retirarCarta(var baralho: TBaralho): TCarta;
begin
  //Não precisamos verificar se o baralho está vazio pois o baralho tem 40
  //cartas, e vamos tirar no máximo 7 (3 em cada mão mais 1 manilha)

  //retorna a carta do topo do baralho
  retirarCarta := baralho.cartas[baralho.topo];

  //atualiza o topo do baralho para ser a carta abaixo da carta retirada
  baralho.topo := baralho.topo - 1;
end;

function compararCarta(carta1, carta2: TCarta; valor_manilha: integer): boolean;
begin
  //Se as duas cartas são manilhas, o desempate é pelo naipe
  if (carta1.pontuacao_carta = valor_manilha) and (carta2.pontuacao_carta = valor_manilha) then
  begin
    if carta1.pontuacao_naipe > carta2.pontuacao_naipe then
      compararCarta := true;
    else
      compararCarta := false; 
  end
  
  //Se apenas a primeira carta é manilha, retorna true
  else if (carta1.pontuacao_carta = valor_manilha) then
  begin
    compararCarta := true;
  end
  
  //Se apenas a segunda é manilha, retorna false
  else if (carta2.pontuacao_carta = valor_manilha) then
  begin
    compararCarta := false;
  end
  
  //Nenhuma é manilha: compara o valor das cartas e, em caso de empaite o naipe
  else
  if carta1.pontuacao_carta = carta2.pontuacao_carta then
  begin
    if carta1.pontuacao_naipe > carta2.pontuacao_naipe then
      compararCarta := true;
    else
      compararCarta := false; 
  end
  else
  begin
    if carta1.pontuacao_carta > carta2.pontuacao_carta then
      compararCarta := true;
    else
      compararCarta := false;
  end;
end;

procedure embaralhar(var baralho: TBaralho);
var
  i, posAleatoria: integer;
  cartaTemp: TCarta;
begin
  //itera do topo até a penultima carta
  for i := baralho.topo downto 2 do
  begin
  
    //gera um número entre a carta atual e 1
    posAleatoria := random(i) + 1;
    
    //armazena a carta atual temporariamente
    cartaTemp := baralho.cartas[i];
    
    //Troca a carta na posição atual com a carta da posição no número aleatório gerado
    baralho.cartas[i] := baralho.cartas[posAleatoria];
    baralho.cartas[posAleatoria] := cartaTemp;
  end;
end;

procedure cortarBaralho(var baralho: TBaralho);
var
  corte, i, indiceTemp: integer;
  cartasTemp: array[1..40] of TCarta;
begin
  corte := random(baralho.topo) + 1;

  //se o corte cair no topo a ordem não muda
  if corte < baralho.topo then
  begin
    indiceTemp := 1;

    //cartas acima do corte vão pro fundo do baralho
    for i := corte + 1 to baralho.topo do
    begin
      cartasTemp[indiceTemp] := baralho.cartas[i];
      indiceTemp := indiceTemp + 1;
    end;

    //depois é só ir adicionando cartas abaixo do corte ao baralho
    for i := 1 to corte do
    begin
      cartasTemp[indiceTemp] := baralho.cartas[i];
      indiceTemp := indiceTemp + 1;
    end;

    //passa as cartas do baralho temporário pro baralho original
    for i := 1 to baralho.topo do
    begin
      baralho.cartas[i] := cartasTemp[i];
    end;
  end;
end;

procedure mostrarBaralho(baralho: TBaralho);
var
  i: integer;
begin
  writeln('--- CARTAS NO BARALHO ---');
  
  //verifica se o baralho está vazio
  if baralho.topo = 0 then
  begin
    writeln('O baralho esta vazio!');
  end
  else
  begin
    //itera do topo até o fundo do baralho
    for i := baralho.topo downto 1 do
    begin
      //printa o nome da carta junto com o naipe
      writeln(baralho.cartas[i].nome, ' de ', baralho.cartas[i].naipe);
    end;
  end;
  
  writeln('-------------------------');
end;

begin
  randomize;
    
  nomesCartas[1] := '4';
  nomesCartas[2] := '5';
  nomesCartas[3] := '6';
  nomesCartas[4] := '7';
  nomesCartas[5] := 'Q';
  nomesCartas[6] := 'J';
  nomesCartas[7] := 'K';
  nomesCartas[8] := 'As';
  nomesCartas[9] := '2';
  nomesCartas[10] := '3';
  
  nomesNaipes[1] := 'Ouros';
  nomesNaipes[2] := 'Espadas';
  nomesNaipes[3] := 'Copas';
  nomesNaipes[4] := 'Paus';

  meuBaralho.tamanho_maximo := 40;
  meuBaralho.topo := 0;

  for i := 1 to 4 do
  begin
    for j := 1 to 10 do
    begin
      meuBaralho.topo := meuBaralho.topo + 1;
      
      meuBaralho.cartas[meuBaralho.topo].nome := nomesCartas[j];
      meuBaralho.cartas[meuBaralho.topo].pontuacao_carta := j;
      
      meuBaralho.cartas[meuBaralho.topo].naipe := nomesNaipes[i];
      meuBaralho.cartas[meuBaralho.topo].pontuacao_naipe := i;
    end;
  end;
  
  writeln('Baralho de Truco inicializado!');
  writeln('Tamanho atual da pilha (topo): ', meuBaralho.topo);
  writeln('Carta no topo: ', meuBaralho.cartas[meuBaralho.topo].nome, ' de ', meuBaralho.cartas[meuBaralho.topo].naipe);

end.
