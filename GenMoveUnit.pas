unit GenMoveUnit;

interface
Procedure UnGenMove; // Ставим признак что ходы еще не сгенерированы
function  GenMove:Byte; // генерируем все ходы, возвращаем их количество
function  GenMoveQ:Byte; // генерируем взятия, возвращаем их количество
function  GenMoveP:Byte; // генерируем превращения, возвращаем их количество
Procedure MakeMove(i:Byte); // Исполняем ход в неотсортированном списке
Procedure MakeMoveSort(i:Byte); // Исполняем ход в отсортированном списке
Procedure Promote(i:Byte); // продвигаем ход на первое место
Procedure PromoteNoSortMove(i:Byte); // продвигаем ход из хеша
Procedure UnMakeMove; // отменяем ход
Procedure RandomM;  // заполняем значения сортировки генератором СЧ
Procedure SortM; // сортируем по значению сортировки

implementation
Uses BoardUnit;
 // четыре направления
const Nap4:array[0..3]of shortint=(-17,-15,15,17);

// Текущее количество ходов
Var TekKolMoves:Byte;

// структура взятия
var ColCapG:Byte;
CapSQG,CapTG:array[0..31]of byte;
ktoG,otG:Byte;

// Случайное перемешивание ходов
Procedure RandomM;
var i: byte;
Begin
  with TekMoves^ do
   Begin
    For i:=1 to KolMoves do
    SortVal[i]:=Random(1024);
   end;
end;

Procedure Promote(i:Byte);
Var k,l:Byte;
Begin
  With TekMoves^ do
  Begin
    k:=SortMov[i];
    for l:=i Downto 2 do SortMov[l]:=SortMov[l-1];
    SortMov[1]:=k;
  end;
end;

Procedure PromoteNoSortMove(i:Byte);
Var j:Byte;
Begin
   With TekMoves^ do
   for j:=1 to kolMoves do
     if sortMov[j]=i then
       Begin
         promote(j);
         exit;
       end;
end;
// Сортировка ходов
Procedure SortM;
var i,j,y:Byte;
X:Cardinal;
Begin
  with TekMoves^ do
    Begin
      for j:=1 to kolMoves do SortMov[j]:=j;
      for j:=2 to kolMoves do
        Begin
          i:=j-1;
          y:=SortMov[j];
          X:=SortVal[y];
          While((i>0)And(SortVal[SortMov[i]]<X)) do
            Begin
              SortMov[i+1]:=SortMov[i];
              i:=i-1;
            end;
          SortMov[i+1]:=y;
        end;
    end;
end;

// Исполнитель хода
Procedure MakeMove(i:Byte);
Var j:Byte;
Begin
  inc(Nodes);
  With TekMoves^ do
  Begin
    CurrMove:=@Mov[i];
    With CurrMove^ do
    Begin
      if OcHod
        then kolBlack:=kolBlack-kolCap
        Else kolWhite:=KolWhite-kolCap;
      ocHod:=not ocHod;
      pole[ot]:=0;
      pole[ku]:=Chto;
      for j := 1 to kolCap do pole[CapSQ[j]]:=0;
    end;
  end;
  GLPly:=GLPly+1;
  if GlPly>MaxPly then MaxPly:=GlPly;
  TekMoves:=@(MovTree[GLPly]);
end;
Procedure MakeMoveSort(i:Byte);
Begin
  Makemove(TekMoves^.SortMov[i]);
end;
// Отменим ход
Procedure UnMakeMove;
Var j:Byte;
Begin
  GLPly:=GLPly-1;
  TekMoves:=@(MovTree[GLPly]);
  With TekMoves^.CurrMove^ do
  Begin
    ocHod:=not ocHod;
    if OcHod
      then kolBlack:=kolBlack+kolCap
      Else kolWhite:=KolWhite+kolCap;
    pole[ku]:=0;
    pole[ot]:=Kto;
    for j := 1 to kolCap do pole[CapSQ[j]]:=capT[j];
  end;
end;

// Добавим ходы белой простой
Procedure AddMoveW(o,k:Byte);
Begin
  inc(TekKolMoves);
  with TekMoves^.Mov[TekKolMoves] Do
  Begin
    ot:=o;
    ku:=k;
    kto:=WP;
    kolCap:=0;
    if (k >= 144)
    Then chto:=WD
    else chto:=WP;
  end;
end;

// Добавим ходы черной простой
Procedure AddMoveB(o,k:Byte);
Begin
  inc(TekKolMoves);
  with TekMoves^.Mov[TekKolMoves] Do
  Begin
    ot:=o;
    ku:=k;
    kto:=BP;
    kolCap:=0;
    if (k <= 48)
    Then chto:=BD
    else chto:=BP;
  end;
end;

// добавим ходы белой дамки
Procedure AddMoveWD(o,k1:Byte;nap:Shortint);
var k:Byte;
Begin
  k:=k1;
  with TekMoves^ do
  while k<>o do
  Begin
    inc(TekkolMoves);
    with Mov[TekkolMoves] Do
    Begin
      ot:=o;
      ku:=k;
      kto:=WD;
      chto:=WD;
      kolCap:=0;
    end;
    k:=k+nap;
  end;
end;

// Добавим ходы черной дамки
Procedure AddMoveBD(o,k1:Byte;nap:Shortint);
var k:Byte;
Begin
  k:=k1;
  with TekMoves^ do
  while k<>o do
  Begin
    inc(TekkolMoves);
    with Mov[TekkolMoves] Do
    Begin
      ot:=o;
      ku:=k;
      kto:=BD;
      chto:=BD;
      kolCap:=0;
    end;
    k:=k+nap;
  end;
end;

// Сгенерирум ходы белых
Procedure GenMoveW;
Var i,ot,ku:Byte;
Begin
  for i:=0 to 31 do
      Begin
        ot:=poledosk[i];
        Case Pole[ot] of
        WP:
          Begin
            if pole[ot+15]=0 then AddMoveW(ot,ot+15);
            if pole[ot+17]=0 then AddMoveW(ot,ot+17);
          end;
        WD:
            Begin
                ku:=ot+17;
                if Pole[ku]=0 then
                Begin
                  while pole[ku+17]=0 do ku:=ku+17;
                  addMoveWD(ot,ku,-17);
                end;

                ku:=ot+15;
                if Pole[ku]=0 then
                Begin
                  while pole[ku+15]=0 do ku:=ku+15;
                  addMoveWD(ot,ku,-15);
                end;

                ku:=ot-17;
                if Pole[ku]=0 then
                Begin
                  while pole[ku-17]=0 do ku:=ku-17;
                  addMoveWD(ot,ku,17);
                end;

                ku:=ot-15;
                if Pole[ku]=0 then
                Begin
                  while pole[ku-15]=0 do ku:=ku-15;
                  addMoveWD(ot,ku,15);
                end;
            end;
        end; //case
      end;
end;

// Сгенерирум ходы Черных
Procedure GenMoveB;
Var i,ot,ku:Byte;
Begin
  for i:=0 to 31 do
      Begin
        ot:=poledosk[i];
        Case Pole[ot] of
        BP:
          Begin
            if pole[ot-15]=0 then AddMoveB(ot,ot-15);
            if pole[ot-17]=0 then AddMoveB(ot,ot-17);
          end;
        BD:
            Begin
                ku:=ot+17;
                if Pole[ku]=0 then
                Begin
                  while pole[ku+17]=0 do ku:=ku+17;
                  addMoveBD(ot,ku,-17);
                end;

                ku:=ot+15;
                if Pole[ku]=0 then
                Begin
                  while pole[ku+15]=0 do ku:=ku+15;
                  addMoveBD(ot,ku,-15);
                end;

                ku:=ot-17;
                if Pole[ku]=0 then
                Begin
                  while pole[ku-17]=0 do ku:=ku-17;
                  addMoveBD(ot,ku,17);
                end;

                ku:=ot-15;
                if Pole[ku]=0 then
                Begin
                  while pole[ku-15]=0 do ku:=ku-15;
                  addMoveBD(ot,ku,15);
                end;
            end;
        end; //case
      end;
end;

// Сгенерирум ходы белых
Procedure GenMovePW;
Var i,ot:Byte;
Begin
  for i:=24 to 27 do
      Begin
        ot:=poledosk[i];
        if Pole[ot]=WP Then
          Begin
            if pole[ot+15]=0 then AddMoveW(ot,ot+15);
            if pole[ot+17]=0 then AddMoveW(ot,ot+17);
          end;
      end;
end;

// Сгенерирум ходы Черных
Procedure GenMovePB;
Var i,ot:Byte;
Begin
  for i:=4 to 7 do
      Begin
        ot:=poledosk[i];
        if Pole[ot]=BP Then
          Begin
            if pole[ot-15]=0 then AddMoveB(ot,ot-15);
            if pole[ot-17]=0 then AddMoveB(ot,ot-17);
          end;
      end;
end;

// добавим взятия белой дамки
Procedure AddCapWD(o:Byte;nap:Shortint);
var Flag:Boolean;
var i:Byte;
var k,o1,gde,chto1:Byte;
var nap1:Shortint;
Begin
  Flag:=False;
  o1:=o;
  while pole[o1]=0 do
  Begin
    for i:=3 downto 0 do
    Begin
      Nap1:=nap4[i];
      if (nap1=nap) or (nap1=-nap) then continue;
      gde:=o1;
      while Pole[gde]=0 do gde:=Byte(gde+nap1);
      k:=Byte(gde+nap1);
      chto1:=pole[gde];
      if Pole[k]=0 then
      if (chto1 And 4)<>0 then
      Begin
        Flag:=true;
        inc(ColCapG);
        CapSQG[ColCapG]:=gde;
        CaptG[ColCapG]:=chto1;
        pole[gde]:=ZZ;
        AddCapWD(k,nap1);
        Dec(ColCapG);
        pole[gde]:=chto1;
      end;
    end;

    o1:=Byte(o1+nap);
  end;

  k:=Byte(o1+nap);
  chto1:=pole[o1];
  if Pole[k]=0 then
  if (chto1 And 4)<>0 then
  Begin
    Flag:=true;
    inc(ColCapG);
    CapSQG[ColCapG]:=o1;
    CaptG[ColCapG]:=chto1;
    pole[o1]:=ZZ;
    AddCapWD(k,nap);
    Dec(ColCapG);
    pole[o1]:=chto1;
  end;


  if Flag=False then
  With TekMoves^ do
  Begin
    k:=o;
    While(Pole[k]=0) do
    Begin
      inc(TekKolMoves);
      with Mov[TekkolMoves] Do
      Begin
        ot:=otG;
        ku:=k;
        kto:=ktoG;
        kolCap:=colCapG;

        for i:=1 to ColCapG do
        Begin
          CapSq[i]:=CapSqG[i];
          CapT[i]:=CapTG[i];
        end;
        chto:=WD;
      end;
    k:=Byte(k+Nap);
    end;
  end;
end;

// добавим взятия черной дамки
Procedure AddCapBD(o:Byte;nap:Shortint);
var Flag:Boolean;
var i:Byte;
var k,o1,gde,chto1:Byte;
var nap1:Shortint;
Begin
  Flag:=False;
  o1:=o;
  while pole[o1]=0 do
  Begin
    for i:=0 to 3 do
    Begin
      Nap1:=nap4[i];
      if (nap1=nap) or (nap1=-nap) then continue;
      gde:=o1;
      while Pole[gde]=0 do gde:=Byte(gde+nap1);
      k:=Byte(gde+nap1);
      chto1:=pole[gde];
      if Pole[k]=0 then
      if (chto1 And 2)<>0 then
      Begin
        Flag:=true;
        inc(ColCapG);
        CapSQG[ColCapG]:=gde;
        CaptG[ColCapG]:=chto1;
        pole[gde]:=ZZ;
        AddCapBD(k,nap1);
        Dec(ColCapG);
        pole[gde]:=chto1;
      end;
    end;

    o1:=Byte(o1+nap);
  end;

  k:=Byte(o1+nap);
  chto1:=pole[o1];
  if Pole[k]=0 then
  if (chto1 And 2)<>0 then
  Begin
    Flag:=true;
    inc(ColCapG);
    CapSQG[ColCapG]:=o1;
    CaptG[ColCapG]:=chto1;
    pole[o1]:=ZZ;
    AddCapBD(k,nap);
    Dec(ColCapG);
    pole[o1]:=chto1;
  end;


  if Flag=False then
  With TekMoves^ do
  Begin
    k:=o;
    While(Pole[k]=0) do
    Begin
      inc(TekKolMoves);
      with Mov[TekkolMoves] Do
      Begin
        ot:=otG;
        ku:=k;
        kto:=ktoG;
        kolCap:=colCapG;

        for i:=1 to ColCapG do
        Begin
          CapSq[i]:=CapSqG[i];
          CapT[i]:=CapTG[i];
        end;
        chto:=BD;
      end;
    k:=Byte(k+Nap);
    end;
  end;
end;

// Добавим взятия белых
Procedure AddCapW(o:Byte);
var chto1,k,gde:Byte;
var flag:Boolean;
var i:byte;
nap:Shortint;
Begin
  if o>=144 then
    Begin
      if (o-15)=CapSqG[colCapG] then AddCapWD(o,15);
      if (o-17)=CapSqG[colCapG] then AddCapWD(o,17);
      exit;
    end;
  Flag:=False;
  for i:=3 downto 0  do
   Begin
    nap:=nap4[i];
    gde:=o+nap;
    k:=gde+nap;
    chto1:=pole[gde];
    if Pole[k]=0 then
    if (chto1 And 4)<>0 then
      Begin
        Flag:=true;
        inc(ColCapG);
        CapSQG[ColCapG]:=gde;
        CaptG[ColCapG]:=chto1;
        pole[gde]:=ZZ;
        AddCapW(k);
        Dec(ColCapG);
        pole[gde]:=chto1;
      end;
   end;

  if Flag=False then
  With TekMoves^ do
  Begin
    inc(TekkolMoves);
    with Mov[TekkolMoves] Do
    Begin
      ot:=otG;
      ku:=o;
      kto:=WP;
      kolCap:=colCapG;

      for i:=1 to ColCapG do
      Begin
        CapSq[i]:=CapSqG[i];
        CapT[i]:=CapTG[i];
      end;
      chto:=WP;
    end;
  end;
end;

// Добавим взятия черных
Procedure AddCapB(o:Byte);
var chto1,k,gde:Byte;
var flag:Boolean;
var i:byte;
nap:Shortint;
Begin
  if o<=48 then
    Begin
      if (o+15)=CapSqG[colCapG] then AddCapBD(o,-15);
      if (o+17)=CapSqG[colCapG] then AddCapBD(o,-17);
      exit;
    end;
  Flag:=False;
  for i:=0 to 3  do
   Begin
    nap:=nap4[i];
    gde:=o+nap;
    k:=gde+nap;
    chto1:=pole[gde];
    if Pole[k]=0 then
    if (chto1 And 2)<>0 then
      Begin
        Flag:=true;
        inc(ColCapG);
        CapSQG[ColCapG]:=gde;
        CaptG[ColCapG]:=chto1;
        pole[gde]:=ZZ;
        AddCapB(k);
        Dec(ColCapG);
        pole[gde]:=chto1;
      end;
   end;

  if Flag=False then
  With TekMoves^ do
  Begin
    inc(TekkolMoves);
    with Mov[TekkolMoves] Do
    Begin
      ot:=otG;
      ku:=o;
      kto:=ktoG;
      kolCap:=colCapG;

      for i:=1 to ColCapG do
      Begin
        CapSq[i]:=CapSqG[i];
        CapT[i]:=CapTG[i];
      end;
      chto:=BP;
    end;
  end;
end;

Procedure ACWP(ot,gde,ku:Byte);
var chto:byte;
Begin
  pole[ot]:=0;
  chto:=pole[gde];
  OtG:=ot;
  ktoG:=WP;
  ColCapG:=1;
  CapSQG[1]:=gde;
  CaptG[1]:=chto;
  pole[gde]:=ZZ;
  AddCapW(ku);
  pole[gde]:=chto;
  pole[ot]:=WP;
end;
Procedure ACBP(ot,gde,ku:Byte);
var chto:byte;
Begin
  pole[ot]:=0;
  chto:=pole[gde];
  OtG:=ot;
  ktoG:=BP;
  ColCapG:=1;
  CapSQG[1]:=gde;
  CaptG[1]:=chto;
  pole[gde]:=ZZ;
  AddCapB(ku);
  pole[gde]:=chto;
  pole[ot]:=BP;
end;
Procedure ACWD(ot,gde,ku:Byte;nap:Shortint);
var chto:byte;
Begin
  pole[ot]:=0;
  chto:=pole[gde];
  OtG:=ot;
  ktoG:=WD;
  ColCapG:=1;
  CapSQG[1]:=gde;
  CaptG[1]:=chto;
  pole[gde]:=ZZ;
  AddCapWD(ku,nap);
  pole[gde]:=chto;
  pole[ot]:=WD;
end;
Procedure ACBD(ot,gde,ku:Byte;nap:Shortint);
var chto:byte;
Begin
  pole[ot]:=0;
  chto:=pole[gde];
  OtG:=ot;
  ktoG:=BD;
  ColCapG:=1;
  CapSQG[1]:=gde;
  CaptG[1]:=chto;
  pole[gde]:=ZZ;
  AddCapBD(ku,nap);
  pole[gde]:=chto;
  pole[ot]:=BD;
end;
Procedure isCapW;
var i,ot,ot1:byte;
Begin
  for i:=0 to 31 do
      Begin
        ot:=poleDosk[i];
        case pole[ot] of
        WP: Begin
              if (pole[ot+17]and 4)<>0 then
                if pole[ot+34]=0 then
                  Begin
                    ACWP(ot,ot+17,ot+34);
                  end;
              if (pole[ot+15]and 4)<>0 then
                if pole[ot+30]=0 then
                  Begin
                    ACWP(ot,ot+15,ot+30);
                  end;
              if (pole[ot-17]and 4)<>0 then
                if pole[ot-34]=0 then
                  Begin
                    ACWP(ot,ot-17,ot-34);
                  end;
              if (pole[ot-15]and 4)<>0 then
                if pole[ot-30]=0 then
                  Begin
                    ACWP(ot,ot-15,ot-30);
                  end;
            end;
          WD: Begin
              ot1:=ot+17;
              while pole[ot1]=0 do ot1:=ot1+17;
              if (pole[ot1]and 4)<>0 then
                if pole[ot1+17]=0 then
                  Begin
                    ACWD(ot,ot1,ot1+17,17);
                  end;
              ot1:=ot+15;
              while pole[ot1]=0 do ot1:=ot1+15;
              if (pole[ot1]and 4)<>0 then
                if pole[ot1+15]=0 then
                  Begin
                    ACWD(ot,ot1,ot1+15,15);
                  end;
              ot1:=ot-17;
              while pole[ot1]=0 do ot1:=ot1-17;
              if (pole[ot1]and 4)<>0 then
                if pole[ot1-17]=0 then
                  Begin
                    ACWD(ot,ot1,ot1-17,-17);
                  end;
              ot1:=ot-15;
              while pole[ot1]=0 do ot1:=ot1-15;
              if (pole[ot1]and 4)<>0 then
                if pole[ot1-15]=0 then
                  Begin
                    ACWD(ot,ot1,ot1-15,-15);
                  end;
            end;
        end;
      end;
end;
Procedure isCapB;
var i,ot,ot1:byte;
Begin
  for i:=0 to 31 do
      Begin
        ot:=poleDosk[i];
        case pole[ot] of
        BP: Begin
              if (pole[ot+17]and 2)<>0 then
                if pole[ot+34]=0 then
                  Begin
                    ACBP(ot,ot+17,ot+34);
                  end;
              if (pole[ot+15]and 2)<>0 then
                if pole[ot+30]=0 then
                  Begin
                    ACBP(ot,ot+15,ot+30);
                  end;
              if (pole[ot-17]and 2)<>0 then
                if pole[ot-34]=0 then
                  Begin
                    ACBP(ot,ot-17,ot-34);
                  end;
              if (pole[ot-15]and 2)<>0 then
                if pole[ot-30]=0 then
                  Begin
                    ACBP(ot,ot-15,ot-30);
                  end;
            end;
          BD: Begin
              ot1:=ot+17;
              while pole[ot1]=0 do ot1:=ot1+17;
              if (pole[ot1]and 2)<>0 then
                if pole[ot1+17]=0 then
                  Begin
                    ACBD(ot,ot1,ot1+17,17);
                  end;
              ot1:=ot+15;
              while pole[ot1]=0 do ot1:=ot1+15;
              if (pole[ot1]and 2)<>0 then
                if pole[ot1+15]=0 then
                  Begin
                    ACBD(ot,ot1,ot1+15,15);
                  end;
              ot1:=ot-17;
              while pole[ot1]=0 do ot1:=ot1-17;
              if (pole[ot1]and 2)<>0 then
                if pole[ot1-17]=0 then
                  Begin
                    ACBD(ot,ot1,ot1-17,-17);
                  end;
              ot1:=ot-15;
              while pole[ot1]=0 do ot1:=ot1-15;
              if (pole[ot1]and 2)<>0 then
                if pole[ot1-15]=0 then
                  Begin
                    ACBD(ot,ot1,ot1-15,-15);
                  end;
            end;
        end;
      end;
end;
// Сгенерируем ходы
Function GenMove():Byte;
Begin
  // Если у кого-то кончились фишки, то ходить нельзя :)
  if (kolWhite=0)or(kolBlack=0) then
    Begin
      GenMove:=0;
      Exit;
    end;

  //  Теперь сама генерация
  TekKolMoves:=0;
  if ocHod
  then  // ход Белых
    Begin
    isCapW;
    if TekKolMoves=0 then GenMoveW;
    end
  else  // ход Черных
    Begin
      isCapB;
      if TekKolMoves=0 then GenMoveB;
    end;
  TekMoves.kolMoves:=TekKolMoves;
  TekMoves.Generation:=true;
  GenMove:=TekKolMoves; // вернем количество возможных ходов в позиции
end;
procedure unGenMove;
Begin
  TekMoves.Generation:=false;
end;
// Сгенерируем ходы для ФВ
Function GenMoveQ():Byte;
Begin
  // Если у кого-то кончились фишки, то ходить нельзя :)
  if (kolWhite=0)or(kolBlack=0) then
    Begin
      GenMoveQ:=0;
      Exit;
    end;

  //  Теперь сама генерация
  TekKolMoves:=0;
  if ocHod
  then  // ход Белых
    Begin
    isCapW;
   // if TekKolMoves=0 then GenMoveW;
    end
  else  // ход Черных
    Begin
      isCapB;
   //   if TekKolMoves=0 then GenMoveB;
    end;
  TekMoves.kolMoves:=TekKolMoves;
  TekMoves.Generation:=false;
  GenMoveQ:=TekKolMoves; // вернем количество возможных ходов в позиции
end;

Function GenMoveP():Byte;
Begin
  // Если у кого-то кончились фишки, то ходить нельзя :)
  if (kolWhite=0)or(kolBlack=0) then
    Begin
      GenMoveP:=0;
      Exit;
    end;

  //  Теперь сама генерация
  TekKolMoves:=0;
  if ocHod
  then  // ход Белых
    Begin
     GenMovePW;
   // if TekKolMoves=0 then GenMoveW;
    end
  else  // ход Черных
    Begin
     GenMovePB;
   //   if TekKolMoves=0 then GenMoveB;
    end;
  TekMoves.kolMoves:=TekKolMoves;
  TekMoves.Generation:=false;
  GenMoveP:=TekKolMoves; // вернем количество возможных ходов в позиции
end;
end.
