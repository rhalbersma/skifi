unit EdAccess;

interface

  uses BoardUnit,sysutils,windows;
  Var EdPieces:integer=0;
  Var EdBoard:array[0..31] of Byte;
  Function EdProbe():integer;

  type
  { определ€ем процедурный тип, отражающий экспортируемую процедуру или ф-ию }
  EI_EGDB_I_TYPE = Function(game_type:pchar;P:Pointer):integer; stdcall;
  EdProbe_I_TYPE = Function(P:Pointer):integer; stdcall;
Var
  EI_EGDB_I: EI_EGDB_I_TYPE;
  EdProbe_I: EdProbe_I_TYPE;

  Handle01: HWND=0; { дескрипторы, загружаемых библиотек }
implementation

  Function EdProbe():integer;
  var i:byte;
  Begin
    if ((kolWhite+kolBlack)<=EdPieces ) then
     Begin
       if ochod then
        Begin

          for i:=0 to 31 do EdBoard[i]:=PWtoED[pole[MapED[i]]];
          EdProbe:= EdProbe_I(@EdBoard);

        end Else

        // ход черных, переворачиваем доску
        Begin

          for i:=0 to 31 do EdBoard[i]:=PBtoED[pole[MapED[31-i]]];
          EdProbe:= EdProbe_I(@EdBoard);
        end;
     end else // нет позиции в ЁЅ
      Begin
         EdProbe:=32000;
      end;
  end;
end.
