unit BoardUnit;

interface
// используетс€ дл€ сортировки ходов
Const WP=19;     //010011    // бела€ проста€
Const WD=11;     //001011    // бела€ дамка
Const BP=21;     //010101    // черна€ проста€
Const BD=13;     //001101    // черна€ дамка
Const ZZ=32;     //100000    // поле за пределами доски
// пута€ клетка - 0 (ноль)
var poleDosk,doskPole,nomkto:array[0..255] of Byte;
var MapEd:array[0..31] of byte;
Var PWtoED,PBtoED:array[0..255] of Byte;
// структура данных - ход
Type Move=Record
  ot:     Byte;   // откуда производитс€ ход
  ku:     Byte;   // куда в итоге перемещаетс€ шашки
  Kto:    Byte;  // номинал шашки до хода
  Chto:   Byte; // номинал шашки после хода
  kolCap: Byte; // количество съеденных шашек
  CapSQ: Array[0..31] of Byte; // пол€ на которых съедаютс€ шашки
  CapT:  Array[0..31] of Byte;  // номинал съеденных шашек
end;

// —труктура данных - список ходов
Type Moves=Record
   Mov:Array [0..255] of Move; // сами ходы
   SortMov:Array [0..255] of Byte;  // упор€дочивание ходов
   SortVAL:Array [0..255] of Cardinal; // значение упор€дочивани€
   CurrMove:^Move;             // ссылка на текущий сделанный ход
   kolMoves:Byte;
   Generation:Boolean; // ’оды сгенерированы
   z1,z2,z3:Cardinal;
end;

// —труктура данных - сгенерированные по дереву ходы
Type MovesTree=Array[0..255] of Moves;
// —генерированные и сделанные ходы по дереву

// структура данных - доска
Type Doska=Array[0..255] of Byte;

// переменные
// сама доска
Var pole:Doska;
Var ochod:Boolean;
Var kolWhite:Byte;
Var kolBlack:Byte;
Var kolWhiteP:Byte;
Var kolBlackP:Byte;
Var kolWhiteD:Byte;
Var kolBlackD:Byte;
// ѕеременные дл€ дерева
Var GLPly:Byte; // глубина дерева, количество сделанных ходов
Var MovTree:MovesTree; // дерево ходов
Var TekMoves:^Moves;  // ссылка на текущие сгенерированные ходы
Var Nodes:int64;
Var MaxPLY:Byte;

// ѕроцедуры
procedure initTree;    // »нициализаци€ дерева
Procedure InitBoard;   // –асстановка начальной позиции

implementation

procedure initTree;
Begin
  GLPly:=0;
  Nodes:=0;
  MaxPLY:=0;
  TekMoves:=@(MovTree[0]);
end;

Procedure InitBoard;
var i,j,ot,k:Byte;
Begin
nomkto[11]:=0;
nomkto[13]:=1;
nomkto[19]:=2;
nomkto[21]:=3;

PWtoED[0]:=4;
PWtoED[11]:=9;
PWtoED[13]:=10;
PWtoED[19]:=1;
PWtoED[21]:=2;

PBtoED[0]:=4;
PBtoED[11]:=10;
PBtoED[13]:=9;
PBtoED[19]:=2;
PBtoED[21]:=1;
   

  k:=0;
  for i:=0 to 255 do  pole[i]:=ZZ;
  for i:=2 to 9 do
  for j:=1 to 4 do
    Begin
      ot:=(i shl 4)xor(j shl 1)xor(i And 1);
      poleDosk[k]:=ot;
      DoskPole[ot]:=k;
      k:=k+1;
      if i<5
      then pole[ot]:=WP
      else
        Begin
          if i>6
          then pole[ot]:=BP
          else pole[ot]:=0;
        end;
    end;
  kolWhite:=12;
  kolBlack:=12;
  kolWhiteP:=12;
  kolBlackP:=12;
  kolWhiteD:=0;
  kolBlackD:=0;
  ochod:=true;
  initTree;

for i:=0 to 3 do
 for j:=0 to 7 do
  MapED[j*4+i]:=poleDosk[(7-j)*4+i];
end;
end.
