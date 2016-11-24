unit SearchUnit;

interface
uses Boardunit,EdAccess,GenMoveUnit,EvalUnit,mmsystem,HistoryUnit,math,hashunit;
var avaria:boolean;
var avariaT:cardinal;
function AB(a,b:Integer;Depth:Shortint;PV:boolean;Rprobe:boolean;RE:boolean;MinDepth:shortint):Integer;
Var killerot: array[0..255] of byte;
Var killerku:array[0..255] of Byte;
Var killerKto:array[0..255]of byte;
Var killerot2: array[0..255] of byte;
Var killerku2:array[0..255] of Byte;
Var killerKto2:array[0..255]of byte;
Var GUD,BAD:int64;
implementation
const DeltaIID1=75;
const DeltaIID1_1=135;
Const IIdRed=3;
Var DeltaIID:array[1..3]of integer=(40,55,70);
Var DeltaIID_1:array[1..3] of integer=(70,100,130);
Var Margin:array[1..3] of integer=(100,150,200);
// Форсированный вариант
Function QS(a,b:integer):integer;
var KolMoves,i,j,sortV:Byte;
var BestScore,Score:Integer;
Begin
  // Если нет ходов
  if (kolWhite=0) or (kolBlack=0) Then
    Begin
      QS:=-20000+GLPly;
      Exit;
    end;

  // Если мы уже не можем поставить хороший мат
  if (20000-GLPLy)<=A then
      Begin
        QS:=20000-GLPLy;
        Exit;
      end;

  // Если нам уже не могут поставить хороший мат
   if (-20000+GLPLy)>=B then
      Begin
        QS:=-20000+GLPLy;
        Exit;
      end;

  // сгенерируем взятия
  kolMoves:=GenMoveQ;

  // если есть взятия
  if KolMoves>0 then
   Begin
   BestScore:=-100000;
   if kolMoves=1 then
       Begin
          MakeMove(1);
          QS:=-QS(-b,-a);
          unmakemove();
          exit;
       end;
   for i:=1 to kolMoves do
    Begin
      SortV:=0;
      if TekMoves.Mov[i].Kto<>TekMoves.Mov[i].Chto Then SortV:=2;
      SortV:=SortV+TekMoves.Mov[i].kolCap;
      for j := 1 to TekMoves.Mov[i].kolCap do
      if ((TekMoves.Mov[i].CapT[j]) And 8)<>0 then SortV:=SortV+2;
      tekmoves.SortVAL[i]:=SortV;
    end;

     SortM;
     for i:=1 to kolMoves do
     Begin
      MakeMove(i);
      Score:=-QS(-b,-a);
      UnMakeMove;
      if Score>BestScore then
        Begin
          BestScore:=Score;
          if Score>a then
            Begin
              a:=Score;
              if Score>=B then
                Begin
                  QS:=Score;
                  Exit;
                end;
            end;
        end;
     end;
     QS:=BestScore;
   end Else
    Begin
      BestScore:=Eval;
      if BestScore>A then
        Begin
          A:=BestScore;
          if BestScore>=B then
          Begin
            QS:=BestScore;
            exit;
          end;
        end;
      kolMoves:=GenMoveP;
      for i:=1 to kolMoves do
      Begin
        MakeMove(i);
        Score:=-QS(-b,-a);
        UnMakeMove;
        if Score>BestScore then
          Begin
            BestScore:=Score;
            if Score>a then
              Begin
                a:=Score;
                if Score>=B then
                  Begin
                    QS:=Score;
                    Exit;
                  end;
              end;
          end;
      end;
      QS:=BestScore;
    end;
end;

// сам перебор
function AB(a,b:Integer;Depth:Shortint;PV:boolean;Rprobe:Boolean;RE:boolean;MinDepth:shortint):Integer;
 Label Lhash;
Var BestScore:integer;
Var kolMoves,i:Byte;
Var Score:Integer;
Var j,sortv:integer;
var best1,best2:byte;
var depthbest:shortint;
var EDScore:integer;
var NewRE:boolean;
zn1,zn2,zn3:cardinal;
oldA:integer;
Late_Move:Boolean;
Begin
   // не пора ли в ФВ?
   if (Depth<=0)or(GLPly>200) then
    Begin
      AB:=QS(a,b);
      Exit;
    end;

    // Если перебор прерван
    if avaria then
      Begin
        AB:=a;
        exit;
      end;

    // вышло время обдумывания
    if timegettime>AvariaT then
    Begin
      Avaria:=true;
      ab:=a;
      exit;
    end;

  // Если нет ходов
  if (kolWhite=0) or (kolBlack=0) Then
    Begin
      AB:=-20000+GLPly;
      Exit;
    end;

// Если мы уже не можем поставить хороший мат
  if (20000-GLPLy)<=A then
      Begin
        AB:=20000-GLPLy;
        Exit;
      end;

  // Если нам уже не могут поставить хороший мат
   if (-20000+GLPLy)>=B then
      Begin
        AB:=-20000+GLPLy;
        Exit;
      end;

  olda:=a;
  BestScore:=-100000;

   // нет взятий - пробуем ЭБ
  //if TekMoves.Mov[1].kolCap=0 then
  if (kolwhite+kolBlack)<=EdPieces then
     Begin
      EDScore:=EdProbe();
       if RE then
          Begin
            if (EdScore=10000) then
              Begin
                AB:=20000-GLPly;
                Exit;
              end;
            if (EdScore=-10000) then
              Begin
                AB:=-20000+GLPly;
                Exit;
              end;
          end;
       if EdScore=0 then
         Begin
           AB:=0;
           exit;
         end;
       if edscore=10000 then
          Begin
            if 3000>=b then
               Begin
                 AB:=3000;
                 exit;
               end;
          end;
       if edscore=-10000 then
          Begin
            if a>=-3000 then
               Begin
                 AB:=-3000;
                 exit;
               end;
          end;
     end;
     
  // попробуем отсечь по оценке в Хеше
  zorb(zn1,zn2,zn3);
  Tekmoves.z1:=zn1;
  Tekmoves.z2:=Zn2;
  TekMoves.z3:=Zn3;

  // Проверим повторение
  j:=GLPLY-4;
  if j>0 then
  if MovTree[GLPLY-1].CurrMove^.kolcap=0 then
  if MovTree[GLPLY-2].CurrMove^.kolcap=0 then
  if ((MovTree[GLPLY-1].CurrMove^.kto)and 8) <> 0 then
  if ((MovTree[GLPLY-2].CurrMove^.kto)and 8) <> 0 then
  while j>0 do
    Begin
       if MovTree[j].CurrMove^.kolcap=0 then
       if MovTree[j+1].CurrMove^.kolcap=0 then
       if ((MovTree[j].CurrMove^.kto)and 8) <> 0 then
       if ((MovTree[j+1].CurrMove^.kto)and 8) <> 0 then
       Begin
          if MovTree[j].z1=zn1 then
           if MovTree[j].z2=zn2 then
            if MovTree[j].z3=zn3 then
              Begin
                ab:=0;
                exit;
              end;
       end Else break;
       j:=j-2;
    end;
  if ScoreFromHash(zn1,zn2,zn3,A,B,PV,Score,Depth,GLply) Then
     Begin
       ab:=Score;
       Exit;
     end;
  ungenMove;
  // Селективный ProbCut
  if (kolWhite+kolBlack)>Edpieces then
  if PV=false then
    if Rprobe=true then
    if MinDepth<Depth then
   // if Depth>1 then
    if (A>-1000)and(A<1000) then
    Begin
     if max(max(Depth-IIDRed,0),mindepth)=0 then // Futility
      Begin
         Score:=AB(A-Margin[Depth],A-Margin[Depth]+1,0,false,false,RE,0);
         if Score<=(A-Margin[Depth]) then
           Begin
             if Score>-19000 then BestScore:=Score+Margin[Depth]
              Else BestScore:=Score;
              goto Lhash;
           end;
      end
     Else //MultiCut
     Begin
       if max(max(Depth-IIDRed,0),mindepth)=1 then
       Begin
          if AB(A-DeltaIID1_1,A-DeltaIID1_1+1,0,false,false,RE,0)<=(A-DeltaIID1_1) then
         Begin
          sortV:=Depth-max(max(Depth-IIDRed,0),mindepth);
          Score:=AB(A-DeltaIID_1[sortV],A-DeltaIID_1[sortV]+1,1,false,false,RE,MinDepth);
          if Score<=(A-DeltaIID_1[sortV]) then
            Begin
              if Score>-19000 then BestScore:=Score+DeltaIID_1[sortV]
              Else BestScore:=Score;
              goto Lhash;
            end

         end;
       end
       else
      Begin
       if AB(A-DeltaIID1,A-DeltaIID1+1,0,false,false,RE,0)<=(A-DeltaIID1) then
         Begin
          sortV:=Depth-max(max(Depth-IIDRed,0),mindepth);
          Score:=AB(A-DeltaIID[sortV],A-DeltaIID[sortV]+1,max(max(Depth-IIDRed,0),mindepth),false,false,RE,MinDepth);
          if Score<=(A-DeltaIID[sortV]) then
            Begin
              if Score>-19000 then BestScore:=Score+DeltaIID[sortV]
              Else BestScore:=Score;
              goto Lhash;
            end

         end;
      end;
     end;
    end;

  // берем лучшие ходы из Хеша
  best1:=0;
  Best2:=0;
  BestmovefromHash(zn1,zn2,zn3,best1,best2,depthbest);
  if PV then
    if Depth>2 then
     if (Best1=0)
    or (DepthBest<(Depth-2))
     then
      Begin
   //   Writeln(GLPLY:3,Depth:3);
     AB(-20000,20000,Depth-2
     ,true,false,RE,max(MinDepth-1,0));
       end;
  if not PV then
    if  tekmoves.Generation=false then
     if Depth>3 then  //Writeln(GLPLY:3,Depth:3);
       if (best1=0)or (DepthBest<((Depth+1) div 5)) then
       begin
         AB(-20000,20000,((Depth+1) div 5),true,false,RE,((Depth+1) div 5));
        // tekmoves.generation:=false;
       end;

  // Сгенерируем ходы
  if tekmoves.Generation=false then
  Begin
    KolMoves:=GenMove;
    // нет ходов
    if kolMoves=0 then
      Begin
        AB:=-20000+GLPly;
        exit;
      end;

  // заполним значения для сортировки
  if kolMoves>1 then
  if TekMoves.Mov[1].kolCap=0 then
    for i:=1 to kolMoves do
    Begin
      tekmoves.sortval[i]:=integer(valmove(TekMoves.mov[i]))+random(5);
      if TekMoves.Mov[i].kto<>TekMoves.Mov[i].chto then  tekmoves.SortVAL[i]:=4096;
      if tekmoves.Mov[i].ot=KillerOt[GLPly] then
      if tekmoves.Mov[i].ku=Killerku[GLPly] then
      if tekmoves.Mov[i].kto=Killerkto[GLPly] then
        tekmoves.SortVAL[i]:=2048;
      if tekmoves.Mov[i].ot=KillerOt2[GLPly] then
      if tekmoves.Mov[i].ku=Killerku2[GLPly] then
      if tekmoves.Mov[i].kto=Killerkto2[GLPly] then
        tekmoves.SortVAL[i]:=2000;
    end
    else
    for i:=1 to kolMoves do
    Begin
      SortV:=0;
      if TekMoves.Mov[i].Kto<>TekMoves.Mov[i].Chto Then SortV:=2;
      SortV:=SortV+TekMoves.Mov[i].kolCap;
      for j := 1 to TekMoves.Mov[i].kolCap do
        if ((TekMoves.Mov[i].CapT[j]) And 8)<>0 then SortV:=SortV+2;
      tekmoves.SortVAL[i]:=SortV;
    end;
 ;
    if best2<>0 then tekmoves.sortval[best2]:=4999;

    if best1<>0 then tekmoves.sortval[best1]:=5000;

    // отсортируем ходы
    SortM;
    // сбросим киллеры
    killerot[GLPLY+2]:=0;
    killerku[GLPLY+2]:=0;
    killerkto[GLPLy+2]:=0;
    killerot2[GLPLY+2]:=0;
    killerku2[GLPLY+2]:=0;
    killerkto2[GLPLy+2]:=0;
    killerot[GLPLY+1]:=0;
    killerku[GLPLY+1]:=0;
    killerkto[GLPLy+1]:=0;
    killerot2[GLPLY+1]:=0;
    killerku2[GLPLY+1]:=0;
    killerkto2[GLPLy+1]:=0;
  end
  Else
    begin
      kolmoves:=tekmoves.kolMoves;
          // нет ходов
      if kolMoves=0 then
       Begin
        AB:=-20000+GLPly;
        exit;
       end;

      if best2<>0 then PromoteNoSortMove(Best2);
      if best1<>0 then PromoteNoSortMove(Best1);
    end;

   for i:=1 to kolMoves do
      Begin
       if i>2 then Late_Move:=true else Late_Move:=False;
       
      if (TekMoves.Mov[1].kolCap>0)or ((TekMoves.Mov[tekmoves.sortmov[i]].Kto and 8)=0)
        then NewRE:=true Else NewRe:=RE;

        MakeMoveSort(i);
        if kolMoves=1 then
           Score:=-AB(-b,-a,Depth,PV,true,NewRE,MinDepth)
         else
         if PV then
           Begin
             if i=1 then
              Score:=-AB(-b,-a,Depth-1,true,true,NewRE,MinDepth-1)
              Else
                Begin
                   Score:=-AB(-a-1,-a,Depth-1,false,false,NewRE,MinDepth-1);
                   if Score>a then
                   Score:=-AB(-b,-a,Depth-1,true,true,NewRE,MinDepth-1);
                end;
           end
            else
            Begin
              if (i<3)or(depth<3)or(minDepth>=Depth) then Score:=-AB(-a-1,-a,Depth-1,false,not Late_Move,NewRE,minDepth-1)
                eLSE
                 Begin
                   if depth<10 then
                      Score:=-AB(-a-1,-a,max(Depth-2,mindepth-1),false,false,NewRE,MinDepth-1)   //2
                      else  Score:=-AB(-a-1,-a,max(Depth-2,mindepth-1),false,false,NewRE,MinDepth-1); //3
                   if Score>a then
                   Score:=-AB(-b,-a,Depth-1,PV,true,NewRE,MinDepth-1);
                 end;
            end;
        UnMakeMove;
        if avaria then
            Begin
              AB:=a;
              exit;
            end;
        if Score>BestScore then
          Begin
            BestScore:=Score;
            if Score>a then
              Begin
                promote(i);
                // сохраним хороший ход в хеше
                addtoHash(zn1,zn2,zn3,tekmoves.sortmov[1],depth);
                a:=Score;
                if Score>=B then
                  Begin

                    // если не взятие и не превращение -
                    // сохраним киллера
                    if TekMoves.Mov[1].kolCap=0 then
                    if TekMoves.Mov[tekmoves.sortmov[1]].kto=TekMoves.Mov[tekmoves.sortmov[1]].chto then
                    if (killerOt[GlPly]<>tekmoves.Mov[tekmoves.sortmov[1]].ot)or
                    (killerku[GlPly]<>tekmoves.Mov[tekmoves.sortmov[1]].ku) or
                    (killerkto[GlPly]<>tekmoves.Mov[tekmoves.sortmov[1]].kto)
                    then
                      Begin
                        killerOt2[GlPly]:=killerOt[GlPly];
                        killerku2[GlPly]:=killerku[GlPly];
                        killerkto2[GlPly]:=killerkto[GlPly];
                        killerOt[GlPly]:=tekmoves.Mov[tekmoves.sortmov[1]].ot;
                        killerku[GlPly]:=tekmoves.Mov[tekmoves.sortmov[1]].ku;
                        killerkto[GlPly]:=tekmoves.Mov[tekmoves.sortmov[1]].kto;
                      end;

                    // сохраним историю
                    if (depth>=1)
                    then
                     if tekmoves.Mov[1].kolCap=0 then
                         Begin
                            gudMove(tekmoves.Mov[tekmoves.sortmov[1]],depth);
                            for j:=2 to i do
                              Begin
                                badMove(tekmoves.Mov[tekmoves.SortMov[j]],depth);
                              end;
                         end;

                    // сохраним оценку в хеше
                    if not avaria then AddToHashScore(Zn1,zn2,zn3,Depth,1,BestScore,GLply);
                    AB:=Score;
                    Exit;
                  end;
              end;
          end;
      end;
 Lhash:
      if BestScore<=oldA then
        Begin
       if not Avaria Then AddToHashScore(Zn1,zn2,zn3,Depth,-1,BestScore,GLply)
         end
       Else if (PV) and (BestScore<B) then
       if not Avaria Then AddToHashScore(Zn1,zn2,zn3,Depth,0,BestScore,GLPLY);
      AB:=BestScore;
end;

end.
