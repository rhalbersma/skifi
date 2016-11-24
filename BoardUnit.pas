unit BoardUnit;

interface
// ������������ ��� ���������� �����
Const WP=19;     //010011    // ����� �������
Const WD=11;     //001011    // ����� �����
Const BP=21;     //010101    // ������ �������
Const BD=13;     //001101    // ������ �����
Const ZZ=32;     //100000    // ���� �� ��������� �����
// ����� ������ - 0 (����)
var poleDosk,doskPole,nomkto:array[0..255] of Byte;
var MapEd:array[0..31] of byte;
Var PWtoED,PBtoED:array[0..255] of Byte;
// ��������� ������ - ���
Type Move=Record
  ot:     Byte;   // ������ ������������ ���
  ku:     Byte;   // ���� � ����� ������������ �����
  Kto:    Byte;  // ������� ����� �� ����
  Chto:   Byte; // ������� ����� ����� ����
  kolCap: Byte; // ���������� ��������� �����
  CapSQ: Array[0..31] of Byte; // ���� �� ������� ��������� �����
  CapT:  Array[0..31] of Byte;  // ������� ��������� �����
end;

// ��������� ������ - ������ �����
Type Moves=Record
   Mov:Array [0..255] of Move; // ���� ����
   SortMov:Array [0..255] of Byte;  // �������������� �����
   SortVAL:Array [0..255] of Cardinal; // �������� ��������������
   CurrMove:^Move;             // ������ �� ������� ��������� ���
   kolMoves:Byte;
   Generation:Boolean; // ���� �������������
   z1,z2,z3:Cardinal;
end;

// ��������� ������ - ��������������� �� ������ ����
Type MovesTree=Array[0..255] of Moves;
// ��������������� � ��������� ���� �� ������

// ��������� ������ - �����
Type Doska=Array[0..255] of Byte;

// ����������
// ���� �����
Var pole:Doska;
Var ochod:Boolean;
Var kolWhite:Byte;
Var kolBlack:Byte;
Var kolWhiteP:Byte;
Var kolBlackP:Byte;
Var kolWhiteD:Byte;
Var kolBlackD:Byte;
// ���������� ��� ������
Var GLPly:Byte; // ������� ������, ���������� ��������� �����
Var MovTree:MovesTree; // ������ �����
Var TekMoves:^Moves;  // ������ �� ������� ��������������� ����
Var Nodes:int64;
Var MaxPLY:Byte;

// ���������
procedure initTree;    // ������������� ������
Procedure InitBoard;   // ����������� ��������� �������

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
