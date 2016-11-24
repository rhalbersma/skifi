

unit HashUnit;

interface
uses Boardunit;

Procedure Zorb(var z1,z2,z3:cardinal);
Procedure AddToHash(Zn1,zn2,zn3:Cardinal;BestMN:Byte;Depth:Shortint);
Procedure AddToHashScore(Zn1,zn2,zn3:Cardinal;Depth:ShortInt;ScoreT:ShortInt;Score:Integer;ply:byte);
Procedure InitHash;
Procedure SetHashSize(size:integer);
Procedure NewHashLevel;
Procedure AddDrawScoreToHash;
Procedure BestMoveFromHash(z1,z2,z3:Cardinal;Var Best1,Best2:Byte;Var DepthBest:ShortInt);
Function ScoreFromHash
(z1,z2,z3:Cardinal;A,B:Integer;PV:Boolean;Var Score:Integer;Depth:Shortint;ply:byte):Boolean;

Type HashZ=Record
 z1,z2:Cardinal;
 DepthM:Shortint;
 NomDost:byte;
 BestM1,BestM2:Byte;
 DepthS:Shortint;
 ScoreT:Shortint;
 ScoreS:Integer;
end;


Var Hash:Array of HashZ;


implementation
Var Level:Byte;
Var HashSize:Cardinal;
var zorb1,zorb2,zorb3:array[0..3,0..31] of cardinal;

// получение Хеша Позиции
Procedure Zorb(var z1,z2,z3:cardinal);
Var i,kto:byte;
begin
z1:=0;
z2:=0;
z3:=0;
   for i:=0 to 31 do
    begin
        kto:=pole[poledosk[i]];
        if Kto>0 then
           Begin
             kto:=nomkto[kto];
             z1:=z1 xor zorb1[Kto,i];
             z2:=z2 xor zorb2[Kto,i];
             z3:=z3 xor zorb3[Kto,i];
           end;
      end;
   if ochod then
    Begin
       z1:=Not z1;
       z2:=not z2;
       z3:=not z3;
   end;
   z3:=z3 mod HashSize;
end;

// Получение Лучшего Хода из Хеша
Procedure BestMoveFromHash(z1,z2,z3:Cardinal;Var Best1,Best2:Byte;Var DepthBest:ShortInt);
Begin
  Best1:=0;
  Best2:=0;
  DepthBest:=0;
  if Hash[z3].z1=z1 then
    if Hash[z3].z2=z2 then
    Begin
     Hash[z3].NomDost:=Level;
     if Hash[z3].BestM1>0 then
     Begin
       Best1:=Hash[z3].BestM1;
       Best2:=Hash[z3].BestM2;
       DepthBest:=Hash[z3].DepthM;
     end;
    end;
end;


// получение оценки из Хеша
Function ScoreFromHash
(z1,z2,z3:Cardinal;A,B:Integer;PV:Boolean;Var Score:Integer;Depth:Shortint;ply:byte):Boolean;
Begin
    if Hash[z3].z1=z1 then
    if Hash[z3].z2=z2 then
     Begin
       Score:=Hash[z3].ScoreS;
       if Score>15000 then Score:=Score-ply;
       if Score<-15000 then Score:=Score+ply;
       Hash[z3].NomDost:=Level;
     if Hash[z3].DepthS>=Depth then
         Begin
           if  Hash[z3].ScoreT=0 then
              Begin
                ScoreFromHash:=true;
                exit;
              end;
            if (Not PV) and (Hash[z3].ScoreT=1)
              And (Score>=B) then
              Begin
                ScoreFromHash:=true;
                exit;
              end;
             if (Not PV) and (Hash[z3].ScoreT=-1)
              And (Score<=A) then
              Begin
                ScoreFromHash:=true;
                exit;
              end;
         end;
      if (Score<=a)and(Score<-15000)and(Hash[z3].ScoreT<=0) then
       Begin
         ScoreFromHash:=true;
         exit;
       end;
     if (Score>=b)and(Score>15000)and(Hash[z3].ScoreT>=0) then
       Begin
         ScoreFromHash:=true;
         exit;
       end;
     end;
    ScoreFromHash:=False;
end;
// Добавление хода в хеш
procedure AddToHash(Zn1,zn2,zn3:Cardinal;BestMN:Byte;Depth:Shortint);
Var H:^HashZ;
Begin
  H:=addr(Hash[zn3]);
  if (H.z1<>zn1)or (h.z2<>zn2) then
       Begin   // затрем старую позицию
         if ((H.DepthS<=Depth)and(H.DepthM<=Depth))or
         ((level<>H.NomDost)and(H.DepthS<100)) then
            Begin
              h.z1:=zn1;
              h.z2:=zn2;
              h.DepthM:=depth;
              h.NomDost:=Level;
              h.BestM1:=BestMN;
              h.BestM2:=0;
              h.DepthS:=0;
              h.ScoreT:=0;
              h.ScoreS:=0;
            end;
       end
     Else // Именно эта позиция сейчас в хеше.
     Begin
        H.NomDost:=Level;
        if (BestMN<>H.BestM1) then
          Begin
            if Depth>=h.DepthM then
               Begin
               h.BestM2:=h.BestM1;
               h.BestM1:=BestMN;
               End
             Else h.BestM2:=BestMN;
          end;
        if h.DepthM<Depth then h.DepthM:=depth;
     end;
end;

// Хеш оценок.
procedure AddToHashScore
(Zn1,zn2,zn3:Cardinal;Depth:Shortint;ScoreT:ShortInt;Score:Integer;ply:Byte);
Var H:^HashZ;
Begin

 // корректировка матовой оценки
 if Score>=15000 then Score:=Score+ply;
 if Score<=-15000 then Score:=Score-ply;

  H:=addr(Hash[zn3]);
  if (H.z1<>zn1)or (h.z2<>zn2) then
       Begin   // затрем старую позицию
         if ((H.DepthS<=Depth)and(H.DepthM<=Depth))or
         ((level<>H.NomDost)and(H.DepthS<100)) then
            Begin
              h.z1:=zn1;
              h.z2:=zn2;
              h.DepthM:=0;
              h.NomDost:=Level;
              h.BestM1:=0;
              h.BestM2:=0;
              h.DepthS:=Depth;
              h.ScoreT:=ScoreT;
              h.ScoreS:=Score;
            end;
       end
     Else // Именно эта позиция сейчас в хеше.
     Begin
        H.NomDost:=Level;
        if h.DepthS<=Depth then
        Begin
          h.DepthS:=Depth;
          h.ScoreT:=ScoreT;
          h.ScoreS:=Score;
        end;
     end;
end;

// записать ничейную оценку текущей позиции в хеш
// сделано для контрля повторений позиции
Procedure AddDrawScoreToHash;
var z1,z2,z3:Cardinal;
Begin
  zorb(z1,z2,z3);
  AddToHashScore(Z1,z2,z3,100,0,0,0);
end;

// установим размер Хеша
Procedure SetHashSize(size:integer);
Begin
  if size>512 then size:=512;
  if size<32 then size:=32;
  HashSize:=(size-2)*51000;
  setLength(Hash,HashSize+1);
end;

// Обсчет другой позиции
Procedure NewHashLevel;
Begin
  if Level>=254 then Level:=1 Else Level:=Level+1;
end;

// Инициализация Зобриста и очистка хеша
Procedure InitHash;
var i,j:Byte;
Var i1:Cardinal;
Begin
  setLength(Hash,HashSize+1);
  level:=1;
  Randomize();
     for i:=0 to 3 do
     for j:=0 to 31 do
     Begin
        Zorb1[i,j]:=(cardinal(Random(65534)+1) Shl 16)xor cardinal(Random(65534)+1);
        Zorb2[i,j]:=(cardinal(Random(65534)+1) Shl 16)xor cardinal(Random(65534)+1);
        Zorb3[i,j]:=(cardinal(Random(65534)+1) Shl 16)xor cardinal(Random(65534)+1);
     end;
     for i1:=0 to HashSize do
       Begin
         Hash[i1].z1:=0;
         Hash[i1].z2:=0;
         Hash[i1].DepthM:=0;
         Hash[i1].NomDost:=0;
         Hash[i1].BestM1:=0;
         Hash[i1].BestM2:=0;
         Hash[i1].DepthS:=0;
         Hash[i1].ScoreT:=0;
         Hash[i1].ScoreS:=0;
       end;
end;
end.

