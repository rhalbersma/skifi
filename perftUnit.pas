unit perftUnit;

interface
uses mmsystem,BoardUnit,GenMoveUnit,EvalUnit,SearchUnit,HistoryUnit,hashunit;
Procedure Perft(D:Byte);
implementation
function Minimax(d:Byte):int64;
var kolMoves:Byte;
var i:Byte;
Var M:int64;
Begin
  if d=1 then
    Begin
       kolMoves:=1;
      // KolMoves:=GenMove;
       Eval;
       (*if kolMoves>0 then
          if Tekmoves.Mov[1].kolCap=0 then
             Begin
               kolPr:=0;
               for I:=1 to kolMoves do
                 if Tekmoves.Mov[i].kto<>Tekmoves.Mov[i].Chto then inc(kolPR);
               if kolPR<>GenMoveP then Writeln('Error') Else
                Begin
                 // if KolPR>0 then Writeln('OK');

                end;

             end;*)
       for i:=1 to kolMoves do
        Begin
           // Makemove(i);
           // UnMakeMove;
        end;
       MiniMax:=kolMoves;
       Exit;
    end;
    M:=0;
    unGenMove;
    kolMoves:=GenMove;
    randomM;
    SortM;
    for i:=1 to kolMoves do
        Begin
          MakemoveSort(i);
          M:=M+minimax(d-1);
          UnMakeMove;
          Promote(i);
        end;
   Minimax:=M;
end;

Procedure Perft(D:Byte);
Var i,j,k:integer;
var BestScore,Score:Integer;
Var kolMov:Byte;
Var t,t1:Cardinal;
Var kolNodes:int64;
Var NewRE:Boolean;
Begin
  Randomize;
  initBoard;
  sethashsize(32);
  avaria:=false;
  avariaT:=TimeGetTime+10000000;
  inithash();
  ochod:=false;
  t1:=timegettime;
  ochod:=false;
    inittree();
  kolMov:=genmove;
  randomM;
  sortM;

  for i:=0 to 255  do
      Begin
        killerOt[i]:=0;
        KillerKu[i]:=0;
        KillerKto[i]:=0;
        killerOt2[i]:=0;
        KillerKu2[i]:=0;
        KillerKto2[i]:=0;
      end;
      GuD:=0;
      Bad:=0;
  for i:=0 to 31 do
    for j:=0 to 31 do
      for k:=0 to 3 do
        Begin
          HistoryP[i,j,k]:=1;
          HistoryK[i,j,k]:=1;
        end;
  for i:=1 to 25 do
    Begin
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
      BestScore:=-100000;
      for j:=1 to kolMov do
         Begin
           if (TekMoves.Mov[1].kolCap>0)or ((TekMoves.Mov[tekmoves.sortmov[j]].Kto and 8)=0)
        then NewRE:=true Else NewRe:=false;
           MakeMoveSort(j);
           if j=1 then Score:=-AB(-100000,-BestScore,i-1,true,true,NewRE,trunc(i*0.49+0.5))
             Else
               Begin
                 Score:=-AB(-BestScore-1,-BestScore,i-1,false,false,NewRE,trunc(i*0.49+0.5));
                if Score>BestScore then
                 Score:=-AB(-100000,-BestScore,i-1,true,true,NewRE,trunc(i*0.49+0.5));
               end;
           unmakeMove;
           if Score>BestScore then
            Begin
              Promote(j);
              BestScore:=Score;
            end;
         end;
     // Writeln(BestScore);
      Writeln('Score= ',BestScore,' depth=',i,'  Time=',TimeGetTime-t1:10,'  Nodes=',Nodes:12, Round(Nodes/(Timegettime-t1+1)):10, MaxPly:6);
   end;
 //  Writeln(gud:10,bad:10,gud*100/(bad+gud):6:2);
  ochod:=false;
  t1:=timegettime;
  for i:=1 to D do
  Begin
    t:=TimegetTime;
    kolNodes:=Minimax(i);
    Writeln('Depth=',i:2,'  Time=',TimeGetTime-t:10,'  Nodes=',kolNodes:12, Round(Nodes/(Timegettime-t1+1)):10, MaxPly:6);
  end;
end;
end.
