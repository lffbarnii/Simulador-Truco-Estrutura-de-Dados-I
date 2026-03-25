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

  cartaRetirada: TCarta; 

function retirarCarta(var baralho: TBaralho): TCarta;
var
  cartaVazia: TCarta;
begin
  //verifica se o baralho não está vazio
  if baralho.topo > 0 then
  begin
    //retorna a carta do topo do baralho
    retirarCarta := baralho.cartas[baralho.topo];

    //atualiza o topo do baralho para ser a carta abaixo da carta retirada
    baralho.topo := baralho.topo - 1;
  end
  else
  begin
    writeln('Erro: Não há mais cartas no baralho!');
    cartaVazia.nome := '';
    cartaVazia.naipe := '';
    cartaVazia.pontuacao_carta := 0;
    cartaVazia.pontuacao_naipe := 0;
    retirarCarta := cartaVazia;
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
