unit EvalUnit;

interface

Function Eval:Integer;
implementation
uses BoardUnit, EdAccess;
var kolWD,kolBD,wlGL,Wl21,Wl22,Wl31,WL32:byte;
var ET:array[0..27]of Byte=
(158, 200, 208, 217,
   123, 195, 186, 153,
 167, 153, 163, 141,
   148, 152, 179, 164,
 170, 177,  93, 160,
   158, 188, 242, 146,
 162, 184, 100, 210
);
var ED:array[0..31]of integer=
(
  481, 446, 517, 502,
   477, 497, 474, 485,
 407, 554, 472, 431,
   501, 446, 471, 472,
 438, 480, 474, 446,
   512, 481, 399, 487,
 530, 463, 511, 463,
   498, 532, 483, 447
);

var ED1:array[0..31]of integer=
(
 500, 504, 500, 508,
   500, 504, 508, 508,
 504, 500, 512, 508,
   504, 508, 512, 500,
 500, 512, 508, 504,
   508, 512, 500, 504,
 508, 508, 504, 500,
   508, 500, 504, 500
);

Function Eval:Integer;
Var  Score,Score1:Integer;
Var i:Byte;
Var l:shortint;
Var kto:Byte;
Begin
Score:=0;
KolWD:=0;
kolBD:=0;
WlGL:=0;
L:=0; //продвинутость простых
for i:=0 to 31 do
  Begin
  kto:=pole[poleDosk[i]];
  if kto<>0 then
  case kto of
    WP:Begin Score:=Score+ET[i];L:=L+(i shr 2)-3 end;
    BP:Begin Score:=Score-ET[31-i];L:=L+(i shr 2)-4 end;
    WD:Begin Score:=Score+ED[i];inc(kolWD) end;
    BD:Begin Score:=Score-ED[31-i];inc(kolBD) end;
  end;
  end;
  if (kolWhite+kolBlack-kolBD-kolWD)<=4 then Score:=score+L*5*(5-(kolWhite+kolBlack-kolBD-kolWD));

  if (kolWD+kolBD)<>0 then
    Begin // Если на доске не только дамки
    if (kolWD+kolBD)<>(kolWhite+kolBlack) then
     begin

      wlGL:=pole[34] or pole[51] or pole [68] or pole[85]
        or pole[102] or pole[119] or pole [136] or pole[153];

      wl21:=pole[40] or pole[55] or pole [70] or pole[85]
        or pole[100] or pole[115] or pole [130];
      wl22:=pole[57] or pole[72] or pole [87] or pole[102]
        or pole[117] or pole[132] or pole [147];

      if WLGl=11 then Score:=Score+94;
      if WLGl=13 then Score:=Score-94;
      if (wl21=11)and(wl22=11) then Score:=Score+40;
      if (wl21=13)and(wl22=13) then Score:=Score-40;

     end
     Else //  на доске только дамки
      Begin
        if (kolWhite=kolBlack)or(kolwhite=kolblack+1)or(kolwhite=kolBlack-1) then
          Begin
            Score:=EdProbe;
            if Score<>32000 then Eval:=Round(Score*0.5) Else eval:=0;
            exit;
          end;

          Score:=0;
          for i:=0 to 31 do
            Begin
              kto:=pole[poleDosk[i]];
              if kto<>0 then
                case kto of
                  WD:Score:=Score+ED1[i];
                  BD:Score:=Score-ED1[31-i];
                end;
            end;

      wlGL:=pole[34] or pole[51] or pole [68] or pole[85]
        or pole[102] or pole[119] or pole [136] or pole[153];

      wl21:=pole[40] or pole[55] or pole [70] or pole[85]
        or pole[100] or pole[115] or pole [130];
      wl22:=pole[57] or pole[72] or pole [87] or pole[102]
        or pole[117] or pole[132] or pole [147];

      wl31:=pole[36] or pole[53] or pole [70] or pole[87]
        or pole[104] or pole[121];

      wl32:=pole[66] or pole[83] or pole [100] or pole[117]
        or pole[134] or pole[151];

      // главная
      if WLGl=11 then Score:=Score+200;
      if WLGl=13 then Score:=Score-200;

      // двойник
      if (wl21=11)and(wl22=11) then Score:=Score+100;
      if (wl21=13)and(wl22=13) then Score:=Score-100;

      // тройник
      if (wL31=11)and(wL32=11)and(WLGl=11) then Score:=Score+50;
      if (wL31=13)and(wl32=13)and(WLGl=13) then Score:=Score-50;

      // выигрывающий бонус 1000
      if (kolWD>(kolBlack+2))or((kolWD=3)and(kolBlack=1)and(WLGL=11)) then Score:=Score+1000;
      if (kolBD>(kolWhite+2))or((kolBD=3)and(kolWhite=1)and(WLGL=13)) then Score:=Score-1000;
      end;
       // обнулим оценку если у соперника недостаточно шашек
     if (kolWhite<(kolBD+2))and(score>0)and(kolBD>0) then Score:=0;
     if (kolBlack<(kolWD+2))and(score<0)and(kolWD>0) then Score:=0;
     if (kolWhite<4)and(kolBD=1)and(kolBlack=1)and(Score>0)and(wlGl=13) then score:=0;
     if (kolBlack<4)and(kolWD=1)and(kolWhite=1)and(Score<0)and(wlGl=11) then score:=0;

     Score:=round(Score*0.7);
    end;



    // оценка за сторону чья очередь хода
    if ochod=False then  Score:=-Score;

    Score1:=EdProbe;
    if Score1=0 then  Score:=0;
    if Score1<>32000 then Score:=Round(Score1*0.5)+score;

    Eval:=score;
end;


end.
