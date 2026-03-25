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

function retiraCarta(var baralho: TBaralho): TCarta;
var
  cartaVazia: TCarta;
begin
  if baralho.topo > 0 then
  begin
    retiraCarta := baralho.cartas[baralho.topo];
    baralho.topo := baralho.topo - 1;
  end
  else
  begin
    writeln('Erro: Não há mais cartas no baralho!');
    cartaVazia.nome := '';
    cartaVazia.naipe := '';
    cartaVazia.pontuacao_carta := 0;
    cartaVazia.pontuacao_naipe := 0;
    retiraCarta := cartaVazia;
  end;
end;

begin
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
