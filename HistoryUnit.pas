unit HistoryUnit;
interface
uses boardunit,math;
Var HistoryP,HistoryK:array[0..31,0..31,0..3] of Cardinal;
Procedure GudMove(mov:Move;depth:shortint);
Procedure BadMove(mov:Move;depth:shortint);
Function ValMove(mov:Move):Cardinal;
implementation
Procedure GudMove(mov:Move;depth:shortint);
var ot,ku,kto:byte;
Begin
   ot:=DoskPole[mov.ot];
   ku:=DoskPole[mov.ku];
   kto:=nomkto[mov.Kto];
   HistoryP[ot,ku,kto]:=HistoryP[ot,ku,kto]+(1 shl min(depth,10));
   HistoryK[ot,ku,kto]:=HistoryK[ot,ku,kto]+(1 shl min(depth,10));
    if HistoryP[ot,ku,kto]>1000000 then
      Begin
        HistoryP[ot,ku,kto]:=HistoryP[ot,ku,kto] div 2;
        HistoryK[ot,ku,kto]:=HistoryK[ot,ku,kto] div 2;
      end;
end;
Procedure BadMove(mov:Move;depth:Shortint);
var ot,ku,kto:byte;
Begin
   ot:=DoskPole[mov.ot];
   ku:=DoskPole[mov.ku];
   kto:=nomkto[mov.Kto];
   HistoryP[ot,ku,kto]:=HistoryP[ot,ku,kto]+(1 shl min(depth,10));
    if HistoryP[ot,ku,kto]>1000000 then
      Begin
        HistoryP[ot,ku,kto]:=(HistoryP[ot,ku,kto] div 2);
        HistoryK[ot,ku,kto]:=(HistoryK[ot,ku,kto] div 2);
      end;
end;
Function ValMove(Mov:Move):Cardinal;
var ot,ku,kto:byte;
Begin
   ot:=DoskPole[mov.ot];
   ku:=DoskPole[mov.ku];
   kto:=nomkto[mov.Kto];
   ValMove:=(1024*HistoryK[ot,ku,kto])div(HistoryP[ot,ku,kto]);
end;
end.
