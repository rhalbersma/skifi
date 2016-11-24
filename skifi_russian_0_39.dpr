library skifi_russian_0_39;



uses
  SysUtils,
  Classes,
  mmsystem,
  Windows,
  Math,
  SearchUnit in 'SearchUnit.pas',
  BoardUnit in 'BoardUnit.pas',
  EvalUnit in 'EvalUnit.pas',
  GenMoveUnit in 'GenMoveUnit.pas',
  HashUnit in 'HashUnit.pas',
  HistoryUnit in 'HistoryUnit.pas',
  perftUnit in 'perftUnit.pas',
  EdAccess in 'EdAccess.pas';
var
 stop_r:boolean;
Procedure EI_EGDB(My:Pointer); stdcall;
Begin
  if Handle01<>0 then
  Begin
    FreeLibrary(Handle01);
    Handle01:=0;
    EdPieces:=0;
  end;

  try
      Handle01 := LoadLibrary('..\Engines\ED_Scifi.dll'); { загрузка dll }
      @EI_EGDB_I := GetProcAddress(Handle01, 'EI_EGDB_I');
      @EdProbe_I := GetProcAddress(Handle01, 'EdProbe_I');
      EdPieces:=EI_EGDB_I(Pchar('russian'),My);
  except
    if Handle01<>0 then
    Begin
     FreeLibrary(Handle01);
     Handle01:=0;
    end;
    EdPieces:=0;
  end;
end;

type PF_SearchInfo=Procedure(score,depth,speed:integer;pv,cm:Pchar); stdcall;
type PF_SearchInfoEx=Procedure(score,depth,speed:pchar; pv:pointer; cv:pchar); stdcall;
Var procE:PF_SearchInfo;
Var procEX:PF_SearchInfoEx=nil;
Var TimeT,InkT:integer;
Var Memory:Integer;
// Вернем имя программы
function EI_GetName():PChar;stdcall;
Begin

	EI_GetName:=pchar('Skifi russian 0.39');
end;

// Новая партия, очистим доску
procedure  EI_NewGame();stdcall;
Begin
 InitBoard;
 SetHashSize(Memory);
 InitHash;
 AddDrawScoreToHash;
end;
Function SQStr(i:Byte):String;
Begin
  SQstr:=CHR((i mod 16)+ORD('a')-2)+CHR((i div 16)+ORD('1')-2);
end;
Function MoveStr(M:Move):PChar;
var s:String;
var i:Byte;
Begin
  s:='';
  s:=s+SQStr(M.ot);
  if M.kolCap>0 then s:=s+':';
  for i:=1 to M.kolCap do s:=s+SQstr(M.capSQ[i])+':';
  s:=s+SqStr(M.ku);
  Movestr:=PChar(s);
end;
// Тут думаем, потом возвращаем ход
Function  EI_Think():Pchar;stdcall;
var kolMov:Byte;
var i,j,j1,k:integer;
var BPusto1,BPusto2:Byte;
Var M1:Move;
Var BestScore,Score,Score1:Integer;
var minTime,NachTime:cardinal;
var Speed:Integer;
Var Potracheno:Cardinal;
Var MateSTR:String;
Var NewRE:boolean;
var best1,best2:byte;
var depthbest:shortint;
var ScoreS,PV:pchar;
var AvariaT1,AvariaT2,pott:cardinal;
zn1,zn2,zn3:cardinal;
begin
  initTree;
  NewHashLevel;
  NachTime:=TimeGetTime;
  Avaria:=False;
  stop_r:=false;
  AvariaT:=3*inkT+(TimeT div 4);
  if (AvariaT>cardinal(inkT))and(AvariaT>cardinal(TimeT)) then
  AvariaT:=max(inkT,TimeT);

  if AvariaT>200 then AvariaT:=((AvariaT*9) div 10)-30;
  if AvariaT<150 then AvariaT:=150;
  AvariaT1:=NachTime+(AvariaT div 2);
  AvariaT2:=NachTime+AvariaT;
  minTime:=AvariaT div 4;

  AvariaT:=AvariaT2;
  mintime:=NachTime+mintime;



  BestScore:=0;
  kolMov:=genmove;
  if kolmov=0 then
    Begin
      Ei_Think:=nil;
      exit;
    end;
    if kolMov=1  then
    Begin
     // AddDrawScoreToHash;
     // EI_Think:=MoveStr(TekMoves^.Mov[1]);
     // MakeMove(1);
     // AddDrawScoreToHash;
     // exit;
     AvariaT1:=NachTime+((MinTime-NachTime) div 5)*2;
     AvariaT2:=AvariaT1;
     AvariaT:=AvariaT1;
     minTime:=NachTime+((MinTime-NachTime) div 5);
    end;
  AddDrawScoreToHash;
  randomM;
  sortM;
    best1:=0;
  Best2:=0;
  zorb(zn1,zn2,zn3);
  BestmovefromHash(zn1,zn2,zn3,best1,best2,depthbest);
  if best2<>0 then PromoteNoSortMove(Best2);
  if best1<>0 then PromoteNoSortMove(Best1);
  for i:=0 to 2  do
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
  for i:=2 to 60 do
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
                          if avaria then  break;

       potracheno:=TimeGetTime-NachTime;
       if (i>10)or(potracheno>100) then
       Begin
        MateStr:='';
        if (BestScore>15000) or (BestScore<-15000) then
        Begin
          if BestScore>15000 then  MateSTR:=' +M'+Inttostr((20000-BestScore+1) div 2);
          if BestScore<-15000 then  MateSTR:=' -M'+Inttostr((BestScore+20000+1) div 2);
        end;
        if MateStr='' then ScoreS:=pchar(inttostr(round(BestScore/1.6))) Else ScoreS:=pchar(MateStr);
        PV:=pchar(''+string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]])));
        if (Potracheno>50) Then Speed:=Nodes div Potracheno Else Speed:=0;
        if @ProcEx=nil then
        procE(0+round(BestScore/1.6),0+i,Speed,pchar(''+string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]]))+' d='+inttostr(i-1)+'/'+inttostr(maxPLY)+Matestr),pchar('1/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[1]]))))
        Else
        procEX(ScoreS,pchar(inttostr(i)+'/'+inttostr(MaxPly)),pchar(''+inttostr(Speed)),@PV,pchar('1/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[1]]))));
       end;

       BestScore:=-100000;
      for j:=1 to kolMov do
         Begin
         if j>1 then AvariaT:=avariaT2;
         if (j>1)and(i>10) then
         Begin
           potracheno:=TimeGetTime-NachTime;
           MateStr:='';
           if (BestScore>15000) or (BestScore<-15000) then
            Begin
              if BestScore>15000 then  MateSTR:=' +M'+Inttostr((20000-BestScore+1) div 2);
              if BestScore<-15000 then  MateSTR:=' -M'+Inttostr((BestScore+20000+1) div 2);
            end;
        if MateStr='' then ScoreS:=pchar(inttostr(round(BestScore/1.6))) Else ScoreS:=pchar(MateStr);
        PV:=pchar(''+string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]])));
        if (Potracheno>50) Then Speed:=Nodes div Potracheno Else Speed:=0;
        if @ProcEx=nil then
        procE(0+round(BestScore/1.6),0+i,Speed,pchar(''+string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]]))+' d='+inttostr(i)+'/'+inttostr(maxPLY)+Matestr),pchar(inttostr(j)+'/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[j]]))))
        Else
        procEX(ScoreS,pchar(inttostr(i)+'/'+inttostr(MaxPly)),pchar(''+inttostr(Speed)),@PV,pchar(inttostr(j)+'/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[j]]))));
         End;
           if (TekMoves.Mov[1].kolCap>0)or ((TekMoves.Mov[tekmoves.sortmov[j]].Kto and 8)=0)
        then NewRE:=true Else NewRe:=false;
           MakeMoveSort(j);
           if j=1 then Score:=-AB(-100000,-BestScore,i-1,true,true,NewRE,trunc(i*0.49-0.5))
             Else
               Begin
                 Score:=-AB(-BestScore-1,-BestScore,i-1,false,false,NewRE,trunc(i*0.49-0.5));
                if Score>BestScore then
                 Score:=-AB(-100000,-BestScore,i-1,true,false,NewRE,trunc(i*0.49-0.5));
               end;
           unmakeMove;
           if avaria then break;
           if Score>BestScore then
            Begin
              Promote(j);
              BestScore:=Score;  potracheno:=TimeGetTime-NachTime;
                if (i>10)or(potracheno>100) then
                  Begin
                     MateStr:='';
                     if (BestScore>15000) or (BestScore<-15000) then
                     Begin
                        if BestScore>15000 then  MateSTR:=' +M'+Inttostr((20000-BestScore+1) div 2);
                        if BestScore<-15000 then  MateSTR:=' -M'+Inttostr((BestScore+20000+1) div 2);
                      end;
                    if MateStr='' then ScoreS:=pchar(inttostr(round(BestScore/1.6))) Else ScoreS:=pchar(MateStr);
                    PV:=pchar(''+string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]])));
                    if (Potracheno>50) Then Speed:=Nodes div Potracheno Else Speed:=0;
                    if @ProcEx=nil then
                    procE(0+round(BestScore/1.6),0+i,Speed,pchar(''+string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]]))+' d='+inttostr(i)+'/'+inttostr(maxPLY)+Matestr),pchar(inttostr(j)+'/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[1]]))))
                    Else
                    procEX(ScoreS,pchar(inttostr(i)+'/'+inttostr(MaxPly)),pchar(''+inttostr(Speed)),@PV,pchar(inttostr(j)+'/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[1]]))));
                  end;

            end;
         end;
          pott:=timegetTime-Nachtime;
          if (i>100)or (Avaria)or((pott+Nachtime)>mintime) then
        Begin
          break;
        end;
        AvariaT:=min(AvariaT1,max(mintime,Nachtime+pott*5));
     // Writeln(BestScore);
     // Writeln('Score= ',BestScore,' depth=',i,'  Time=',TimeGetTime-t1:10,'  Nodes=',Nodes:12, Round(Nodes/(Timegettime-t1+1)):10, MaxPly:6);
   end;

   if stop_r=false then  EI_Think:=MoveStr(TekMoves^.Mov[TekMoves^.SortMov[1]])
   else EI_Think:=nil;
     MakeMoveSort(1);
     AddDrawScoreToHash;
end;

// Установим время, интересует только наше
procedure EI_SetTime(time,otime:integer);stdcall;
Begin
  TimeT:=time;
end;

// Контроль времени
procedure EI_SetTimeControl(time,inc:integer);stdcall;
Begin
  timeT:=Time;
  inkT:=inc;
end;
Procedure EI_SetSearchInfoEx(sie:PF_SearchInfoEx);stdcall;
Begin
 ProcEx:=sie;
End;
// Инициализации движка
Procedure EI_Initialization(PF_SearchInfo:PF_SearchInfo;mem_lim:integer);stdcall;
begin
  ProcE:=PF_SearchInfo;
  Memory:=mem_Lim;
  SetHashSize(Memory);
  initBoard;
  initHash;
end;

// установить доску
Procedure EI_SetupBoard(pos:Pchar);stdcall;
var i,j,ot:byte;
var ch:integer;
var s:string;
begin
  s:=trim(string(pos))+'                                         ';
  ch:=0;
  initBoard;
  initHash;
  kolWhite:=0;
  kolBlack:=0;
   for i:=9 downto 2 do
    for j:=1 to 4 do
      Begin
        ot:=(i shl 4)xor(j shl 1)xor(i And 1);
        ch:=ch+1;
        case s[ch] of
         'w': begin pole[ot]:=WP;kolWhite:=kolWhite+1 end;
         'b': begin pole[ot]:=BP;kolBlack:=kolBlack+1 end;
         'W': begin pole[ot]:=WD;kolWhite:=kolWhite+1 end;
         'B': begin pole[ot]:=BD;kolBlack:=kolBlack+1 end;
         else pole[ot]:=0;
        end;
      end;
   if s[33]='w' then ochod:=true;
   if s[33]='b' then ochod:=false;
   AddDrawScoreToHash;
end;

// получим координату
Function koord(s:String):byte;
var k:Byte;
Begin
  k:=ord(s[1])-ord('a')+2+16*(ord(s[2])-ord('1')+2);
  koord:=k;
end;
// сделать ход
Procedure EI_MakeMove(move:Pchar);stdcall;
var ot,ku:byte;
cap:array[1..255] of byte;
colcap:byte;
kolMoves:Byte;
move1:string;
var i,j:integer;
var tot:boolean;
begin
  kolMoves:=GenMove;
  colcap:=0;
  move1:=trim(string(move))+'@';
  ot:=koord(Copy(move1,1,2));
  i:=3;
  while copy(move1,i,1)<>'@' do
       Begin
         ColCap:=Colcap+1;
         while copy(move1,i,1)=':' do i:=i+1;
         cap[colcap]:=koord(copy(Move1,i,2));
         i:=i+2;
       end;
  ku:=cap[colCap];
  ColCap:=ColCap-1;
  for i:=1 to KolMoves do
    if (ot=(TekMoves^.Mov[i].ot))And(ku=TekMoves^.Mov[i].ku)and(ColCap=TekMoves^.mov[i].kolCap) then
     Begin
       tot:=true;
       for j:=1 to colcap do
          if TekMoves^.Mov[i].CapSQ[j]<>cap[j] then
            Begin
              tot:=false;
              Break;
            end;
       if tot=true then
           Begin
           AddDrawScoreToHash;
           MakeMove(i);
           AddDrawScoreToHash;
             break;
           end;
     end;
end;
// PV
Function PVFromHash(m:integer):String;
var best1,best2,kolmov:byte;
var depthbest:shortint;
Var s:String;
zn1,zn2,zn3:cardinal;
Begin
 if m=0  then
   Begin
     PVFromHash:='';
     exit;
   end;
 s:=string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]]));
 MakeMoveSort(1);
 KolMov:=genmove;
 zorb(zn1,zn2,zn3);
 Best1:=0;
 BestmovefromHash(zn1,zn2,zn3,best1,best2,depthbest);
 if kolMov=1 then Best1:=1;
 if Best1<>0 then
 Begin
  randomM;
  sortM;
  PromoteNoSortMove(Best1);
  s:=s+' '+PVFromHash(m-1);
 end;
 UnMakeMove;
 PVFromHash:=s;
end;
// Анализировать
Procedure EI_Analyse();stdcall;
var kolMov:Byte;
var i,j,j1,k:integer;
var BPusto1,BPusto2:Byte;
Var M1:Move;
Var BestScore,Score,Score1:Integer;
var minTime,NachTime:cardinal;
var Speed:Integer;
Var Potracheno:Cardinal;
Var MateSTR:String;
var NewRE:boolean;
var best1,best2:byte;
var depthbest:shortint;
var ScoreS,PV:pchar;
zn1,zn2,zn3:cardinal;
begin
  avaria:=false;
  initTree;
  NewHashLevel;
  NachTime:=TimeGetTime;
  AvariaT:=NachTime+100000000;
  BestScore:=0;
  kolMov:=genmove;
  if kolmov=0 then
    Begin
      exit;
    end;
  AddDrawScoreToHash;
  randomM;
  sortM;
  best1:=0;
  Best2:=0;
  zorb(zn1,zn2,zn3);
  BestmovefromHash(zn1,zn2,zn3,best1,best2,depthbest);
  if best2<>0 then PromoteNoSortMove(Best2);
  if best1<>0 then PromoteNoSortMove(Best1);
  for i:=0 to 2  do
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
  for i:=2 to 60 do
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
                          if avaria then  break;

       potracheno:=TimeGetTime-NachTime;
       if (i>10)or(potracheno>100) then
       Begin
        MateStr:='';
        if (BestScore>15000) or (BestScore<-15000) then
        Begin
          if BestScore>15000 then  MateSTR:=' +M'+Inttostr((20000-BestScore+1) div 2);
          if BestScore<-15000 then  MateSTR:=' -M'+Inttostr((BestScore+20000+1) div 2);
        end;
        if MateStr='' then ScoreS:=pchar(inttostr(round(BestScore/1.6))) Else ScoreS:=pchar(MateStr);
        PV:=pchar(''+PVFromHash(5));
        if (Potracheno>50) Then Speed:=Nodes div Potracheno Else Speed:=0;
        if @ProcEx=nil then
        procE(0+round(BestScore/1.6),0+i,Speed,pchar(''+string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]]))+' d='+inttostr(i-1)+'/'+inttostr(maxPLY)+Matestr),pchar('1/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[1]]))))
        Else
        procEX(ScoreS,pchar(inttostr(i)+'/'+inttostr(MaxPly)),pchar(''+inttostr(Speed)),@PV,pchar('1/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[1]]))));
       end;

       BestScore:=-100000;
      for j:=1 to kolMov do
         Begin
         if (j>1)and(i>10) then
         Begin
           potracheno:=TimeGetTime-NachTime;
           MateStr:='';
           if (BestScore>15000) or (BestScore<-15000) then
            Begin
              if BestScore>15000 then  MateSTR:=' +M'+Inttostr((20000-BestScore+1) div 2);
              if BestScore<-15000 then  MateSTR:=' -M'+Inttostr((BestScore+20000+1) div 2);
            end;
        if MateStr='' then ScoreS:=pchar(inttostr(round(BestScore/1.6))) Else ScoreS:=pchar(MateStr);
        PV:=pchar(''+PVFromHash(5));
        if (Potracheno>50) Then Speed:=Nodes div Potracheno Else Speed:=0;
        if @ProcEx=nil then
        procE(0+round(BestScore/1.6),0+i,Speed,pchar(''+string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]]))+' d='+inttostr(i)+'/'+inttostr(maxPLY)+Matestr),pchar(inttostr(j)+'/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[j]]))))
        Else
        procEX(ScoreS,pchar(inttostr(i)+'/'+inttostr(MaxPly)),pchar(''+inttostr(Speed)),@PV,pchar(inttostr(j)+'/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[j]]))));
         End;
           if (TekMoves.Mov[1].kolCap>0)or ((TekMoves.Mov[tekmoves.sortmov[j]].Kto and 8)=0)
        then NewRE:=true Else NewRe:=false;
           MakeMoveSort(j);
           if j=1 then Score:=-AB(-100000,-BestScore,i-1,true,true,NewRE,trunc(i*0.49-0.5))
             Else
               Begin
                 Score:=-AB(-BestScore-1,-BestScore,i-1,false,false,NewRE,trunc(i*0.49-0.5));
                if Score>BestScore then
                 Score:=-AB(-100000,-BestScore,i-1,true,false,NewRE,trunc(i*0.49-0.5));
               end;
           unmakeMove;
           if avaria then break;
           if Score>BestScore then
            Begin
              Promote(j);
              BestScore:=Score;  potracheno:=TimeGetTime-NachTime;
                if (i>10)or(potracheno>100) then
                  Begin
                     MateStr:='';
                     if (BestScore>15000) or (BestScore<-15000) then
                     Begin
                        if BestScore>15000 then  MateSTR:=' +M'+Inttostr((20000-BestScore+1) div 2);
                        if BestScore<-15000 then  MateSTR:=' -M'+Inttostr((BestScore+20000+1) div 2);
                      end;
                    if MateStr='' then ScoreS:=pchar(inttostr(round(BestScore/1.6))) Else ScoreS:=pchar(MateStr);
                    PV:=pchar(''+PVFromHash(5));
                    if (Potracheno>50) Then Speed:=Nodes div Potracheno Else Speed:=0;
                    if @ProcEx=nil then
                    procE(0+round(BestScore/1.6),0+i,Speed,pchar(''+string(Movestr(TekMoves^.Mov[TekMoves^.Sortmov[1]]))+' d='+inttostr(i)+'/'+inttostr(maxPLY)+Matestr),pchar(inttostr(j)+'/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[1]]))))
                    Else
                    procEX(ScoreS,pchar(inttostr(i)+'/'+inttostr(MaxPly)),pchar(''+inttostr(Speed)),@PV,pchar(inttostr(j)+'/'+inttostr(kolMov)+' '+string(Movestr(TekMoves^.Mov[TekMoves^.sortmov[1]]))));
                  end;

            end;
         end;
     // Writeln(BestScore);
     // Writeln('Score= ',BestScore,' depth=',i,'  Time=',TimeGetTime-t1:10,'  Nodes=',Nodes:12, Round(Nodes/(Timegettime-t1+1)):10, MaxPly:6);
   end;
end;

// Обдумывание за счет времени противника
Procedure EI_Ponder();stdcall;
Begin
  AddDrawScoreToHash;
end;

Function EI_PonderHit(move:Pchar):Pchar; stdcall;
Begin
  AddDrawScoreToHash;
	EI_MakeMove(move);
  AddDrawScoreToHash;
	EI_PonderHit:=EI_Think();
End;

Procedure  EI_OnExit(); stdcall;
Begin
  EdPieces:=0;
  Avaria:=true;
  stop_r:=true;
  if Handle01<>0 then
  Begin
    FreeLibrary(Handle01);
    Handle01:=0;
  end;
End;

Procedure   EI_Stop(); stdcall;
Begin
  stop_r:=true;
  Avaria:=true;
End;

exports
EI_GetName,
EI_Analyse,
EI_Initialization,
EI_NewGame,EI_Think,
EI_SetupBoard,
EI_SetTime,
EI_MakeMove,
EI_Ponder,
EI_PonderHit,
EI_OnExit,
EI_Stop,
EI_SetTimeControl,
EI_SetSearchInfoEx,
EI_EGDB;
{$R *.res}
begin
end.


