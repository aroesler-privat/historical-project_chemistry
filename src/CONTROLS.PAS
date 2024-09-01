UNIT Controls; INTERFACE USES Crt, Graph, Graphics, Mouse, Logo;

TYPE CharSet     = SET OF CHAR;
     Pointers    = (Left,Right,Block);
     PListe      = ^TListe;
     TListe      = ARRAY[Pointers]OF Pointer;
     PColumnList = ^TColumnList;
     TColumnList = RECORD
                     Chars                       : CharSet;
                     Title                       : STRING[30];
                     Width                       : WORD;
                     Len                         : BYTE;
                     ReadOnly, ZahlenTiefgesetzt : BOOLEAN;
                     Left, Right                 : POINTER;
                   END;
     SaveGrVars = OBJECT
                    TextSettings : TextSettingsType;
                    FillSettings : FillSettingsType;
                    LineSettings : LineSettingsType;
                    Color        : BYTE;
                    CONSTRUCTOR Save;
                    DESTRUCTOR  Restore;
                  END;
     ODialog = OBJECT
                 x, y, x1, y1 : WORD;
                 CONSTRUCTOR Init(px, py, px1, py1 : WORD; pTitle : STRING);
                 FUNCTION    HasPosChanged : BOOLEAN;
                 FUNCTION    Exit : BOOLEAN;
                 DESTRUCTOR  Done;
                 PRIVATE
                 Screen     : ARRAY[1..3] OF RECORD
                                Data : POINTER;
                                YRes : WORD;
                              END;
                 NrMax      : WORD;
                 Title      : STRING;
                 PosChanged : BOOLEAN;
                 PROCEDURE   Move;
               END;
     OButton = OBJECT
                 CONSTRUCTOR Init(px, py, px1, py1 : WORD; pText : STRING);
                 PROCEDURE   SetNewPos(px, py, px1, py1 : WORD);
                 FUNCTION    Pressed : BOOLEAN;
                 DESTRUCTOR  Done;
                 PRIVATE
                 x, y, x1, y1, mx, my, mx1, my1 : WORD;
                 Text                           : STRING;
                 Marked                         : BOOLEAN;
               END;
     OEditField = OBJECT
                    ZahlenTiefgesetzt, ReadOnly : BOOLEAN;
                    CONSTRUCTOR Init(px, py, px1, py1 : WORD);
                    PROCEDURE   SetNewPos(px, py, px1, py1 : WORD);
                    PROCEDURE   SetTexts(Title, Info : STRING);
                    PROCEDURE   SetPetition(Text : STRING; Len : BYTE; Chars : CharSet);
                    FUNCTION    GetPetition : STRING;
                    FUNCTION    Run : BOOLEAN;
                    DESTRUCTOR  Done;
                    PRIVATE
                    x, y, x1, y1, ex, ey, ex1, ey1    : WORD;
                    MaxLen, Pos, SPos, SWidth         : BYTE;
                    StrTitle, StrInfo, StrText, First : STRING;
                    AvaibleChars                      : CharSet;
                    HasFocus, InsertMode, BuildNew    : BOOLEAN;
                    PROCEDURE WriteText(Focus, New : BOOLEAN);
                    PROCEDURE ReadText;
                  END;
     OComboField = OBJECT
                     List : BOOLEAN;
                     CONSTRUCTOR Init(px, py, px1, py1 : WORD; VLines : BYTE);
                     PROCEDURE   SetNewPos(px, py, px1, py1 : WORD);
                     PROCEDURE   SetTexts(Title, Info : STRING);
                     PROCEDURE   SetAvaibleChars(Chars : CharSet);
                     PROCEDURE   SetChoose(Nr : WORD);
                     PROCEDURE   InsertString(Text : STRING);
                     FUNCTION    GetResult : STRING;
                     FUNCTION    GetAktChoose : WORD;
                     FUNCTION    GetString(StrPos : WORD) : STRING;
                     FUNCTION    Run : BOOLEAN;
                     DESTRUCTOR  Done;
                     PRIVATE
                     x, y, x1, y1, ex, ey, ex1, ey1, lx, ly, lx1, ly1 : WORD;
                     Help1, Help2                   : PListe;
                     First, Last, Screen            : POINTER;
                     HasFocus, InsertMode, BuildNew : BOOLEAN;
                     StrTitle, StrInfo, StrText     : STRING;
                     AktChoose, MaxPos, MaxHeight   : WORD;
                     ListPosStart, ListPosMarked    : WORD;
                     Pos, SPos, SWidth, MaxLen      : BYTE;
                     AvaibleChars                   : CharSet;
                     PROCEDURE SetString(StrPos : WORD; Text : STRING);
                     PROCEDURE WriteText(Focus, New : BOOLEAN);
                     PROCEDURE ReadText;
                     PROCEDURE DoListProc(Switch : BOOLEAN);
                   END;
     PCellList  = ^TCellList;
     TCellList  = RECORD
                    EditField   : OEditField;
                    Left, Right : POINTER;
                  END;
     OListField = OBJECT
                    CONSTRUCTOR Init(px, py, VisibleLines : WORD);
                    PROCEDURE   SetNewPos(px, py : WORD);
                    PROCEDURE   NewColumn(Title : STRING; Len : BYTE; Width : WORD; Chars : CharSet;
                                ReadOnly, ZahlenTiefgesetzt: BOOLEAN);
                    PROCEDURE   SetText(Column, Line : WORD; Text : STRING);
                    FUNCTION    GetText(Column, Line : WORD) : STRING;
                    PROCEDURE   DrawField;
                    PROCEDURE   Run;
                    DESTRUCTOR  Done;
                    PRIVATE
                    x, y, x1, y1, VisLines   : WORD;
                    Columns, Lines, AktLine  : WORD;
                    YPos, YRes               : WORD;
                    FirstColumn, LastColumn  : POINTER;
                    ColumnHelp1, ColumnHelp2 : PColumnList;
                    FirstText, LastText      : POINTER;
                    TextHelp1, TextHelp2     : PListe;
                    FirstCell, LastCell      : POINTER;
                    CellHelp1, CellHelp2     : PCellList;
                    Button                   : ARRAY[1..2]OF OButton;
                    ArrowCursor              : BOOLEAN;
                    PROCEDURE SetEditFieldText(Line, Column : WORD; p : POINTER);
                    PROCEDURE DrawScroller;
                    PROCEDURE RunScroller;
                    PROCEDURE ViewList;
                    FUNCTION  SetColumnWidth(pFrom, pTo : WORD) : INTEGER;
                    PROCEDURE SetResizeCursor;
                    PROCEDURE SetArrowCursor;
                  END;
IMPLEMENTATION

{ -------------------------------------------------------------------------- }
CONSTRUCTOR SaveGrVars.Save;
BEGIN
  GetTextSettings(TextSettings);
  GetFillSettings(FillSettings);
  GetLineSettings(LineSettings);
  Color:=GetColor;
END;

DESTRUCTOR SaveGrVars.Restore;
BEGIN
  SetColor(Color);
  SetTextStyle(TextSettings.Font,TextSettings.Direction,TextSettings.CharSize);
  SetTextJustify(TextSettings.Horiz,TextSettings.Vert);
  SetFillStyle(FillSettings.Pattern,FillSettings.Color);
  SetLineStyle(LineSettings.LineStyle,LineSettings.Pattern,LineSettings.Thickness);
END;
{ -------------------------------------------------------------------------- }
CONSTRUCTOR ODialog.Init(px, py, px1, py1 : WORD; pTitle : STRING);
VAR GrVars : SaveGrVars;
    YPos   : WORD;
BEGIN
  x:=px; y:=py; x1:=px1; y1:=py1; Title:=pTitle; YPos:=y; NrMax:=0;
  PosChanged:=FALSE; HideMouseCursor;
  repeat
    inc(NrMax); Screen[NrMax].YRes:=y1-YPos;
    while ImageSize(x,YPos,x1,YPos+Screen[NrMax].YRes)=0 do dec(Screen[NrMax].YRes);
    GetMem(Screen[NrMax].Data,ImageSize(x,YPos,x1,YPos+Screen[NrMax].YRes));
    GetImage(x,YPos,x1,YPos+Screen[NrMax].YRes,Screen[NrMax].Data^);
    inc(YPos,Screen[NrMax].YRes);
  until YPos=y1;
  GrVars.Save;
  SetFillStyle(1,0); Bar(x,y,x1,y1); Bar3D(x+1,y+1,x1-1,y1-1,FALSE);
  Bar3D(x+3,y+3,x1-3,y+16,TRUE); SetFillStyle(1,1); Bar(x+15,y+4,x1-4,y+15);
  SetFillStyle(1,8); Bar(x+6,y+9,x+13,y+11);
  SetColor(0); Rectangle(x+5,y+8,x+12,y+10);
  SetFillStyle(1,15); Bar(x+6,y+9,x+11,y+9);
  SetTextStyle(0,0,0); SetTextJustify(1,1);
  SetColor( 8); OutTextXY(((x1-x-10)div 2)+x+6,y+11,Title);
  SetColor(15); OutTextXY(((x1-x-10)div 2)+x+5,y+10,Title);
  GrVars.Restore; ShowMouseCursor;
END;

PROCEDURE ODialog.Move;
VAR GrVars                    : SaveGrVars;
    nx, ny, cx, cy, ox, oy, w : WORD;
    mx, my                    : INTEGER;
    Dialog                    : ARRAY[1..3]OF Pointer;
BEGIN
  GetMouseStatus(nx,ny,w); mx:=nx-x; my:=ny-y;
  SetMousePosition(x,y);
  cx:=x1-x; cy:=y1-y; nx:=x; ny:=y; ox:=x; oy:=y;
  GrVars.Save; HideMouseCursor;
  SetWriteMode(XorPut); SetLineStyle(4,$AAAA,1); SetColor(15);
  Rectangle(nx,ny,nx+cx,ny+cy);
  while GetButtonStatus(1) do begin
    while (ox=nx)and(oy=ny)and(GetButtonStatus(1)) do GetMouseStatus(nx,ny,w);
    Rectangle(ox,oy,ox+cx,oy+cy);
    if nx+cx>GetMaxX then nx:=GetMaxX-cx;
    if ny+cy>GetMaxY then ny:=GetMaxY-cy;
    SetMousePosition(nx,ny); ox:=nx; oy:=ny;
    Rectangle(nx,ny,nx+cx,ny+cy);
  end;
  Rectangle(nx,ny,nx+cx,ny+cy); oy:=y;
  for w:=1 to NrMax do begin
    GetMem(Dialog[w],ImageSize(x,oy,x1,oy+Screen[w].YRes));
    GetImage(x,oy,x1,oy+Screen[w].YRes,Dialog[w]^);
    PutImage(x,oy,Screen[w].Data^,NormalPut); inc(oy,Screen[w].YRes);
  end;
  x:=nx; y:=ny; x1:=nx+cx; y1:=ny+cy; oy:=y;
  for w:=1 to NrMax do begin
    GetImage(x,oy,x1,oy+Screen[w].YRes,Screen[w].Data^);
    PutImage(x,oy,Dialog[w]^,NormalPut);
    FreeMem(Dialog[w],ImageSize(x,oy,x1,oy+Screen[w].YRes));
    inc(oy,Screen[w].YRes);
  end;
  SetMousePosition(x+mx,y+my);
  SetWriteMode(NormalPut); GrVars.Restore; ShowMouseCursor;
  PosChanged:=TRUE;
END;

FUNCTION ODialog.HasPosChanged : BOOLEAN;
BEGIN
  HasPosChanged:=PosChanged;
  PosChanged:=FALSE;
END;

FUNCTION ODialog.Exit : BOOLEAN;
VAR GrVars : SaveGrVars;
BEGIN
  if (MouseIn(x+15,y+4,x1-4,y+15))and(GetButtonStatus(1)) then Move;
  if (MouseIn(x+4,y+4,x+15,y+15))and(GetButtonStatus(1)) then begin
    GrVars.Save; HideMouseCursor;
    SetFillStyle(1,7); Bar(x+4,y+4,x+14,y+15);
    SetColor(0); Rectangle(x+6,y+9,x+13,y+11);
    SetFillStyle(1,15); Bar(x+7,y+10,x+12,y+10);
    GrVars.Restore; ShowMouseCursor;
    while (MouseIn(x+4,y+4,x+15,y+15))and(GetButtonStatus(1)) do;
    GrVars.Save; HideMouseCursor;
    SetFillStyle(1,7); Bar(x+4,y+4,x+14,y+15);
    SetFillStyle(1,8); Bar(x+6,y+9,x+13,y+11);
    SetColor(0); Rectangle(x+5,y+8,x+12,y+10);
    SetFillStyle(1,15); Bar(x+6,y+9,x+11,y+9);
    GrVars.Restore; ShowMouseCursor;
    Exit:=MouseIn(x+4,y+4,x+15,y+15);
  end else Exit:=FALSE;
END;

DESTRUCTOR ODialog.Done;
VAR Nr, YPos : WORD;
BEGIN
  HideMouseCursor; YPos:=y;
  for Nr:=1 to NrMax do begin
    PutImage(x,YPos,Screen[Nr].Data^,NormalPut);
    FreeMem(Screen[Nr].Data,ImageSize(x,YPos,x1,YPos+Screen[Nr].YRes));
    inc(YPos,Screen[Nr].YRes);
  end;
  ShowMouseCursor;
END;
{ -------------------------------------------------------------------------- }
CONSTRUCTOR OButton.Init(px, py, px1, py1 : WORD; pText : STRING);
VAR GrVars : SaveGrVars;
BEGIN
  x:=px; y:=py; x1:=px1; y1:=py1; Text:=pText; Marked:=FALSE;
  mx :=((x1-x)div 2)+x-(TextWidth(Text)div 2)-2; if mx -2<x  then mx :=x +2;
  mx1:=((x1-x)div 2)+x+(TextWidth(Text)div 2)+2; if mx1+2>x1 then mx1:=x1-2;
  my :=((y1-y)div 2)+y-(TextHeight('Û')div 2)-2; if my -2<y  then my :=y +2;
  my1:=((y1-y)div 2)+y+(TextHeight('Û')div 2)+2; if my1+2>y1 then my1:=y1-2;
  GrVars.Save; HideMouseCursor;
  Bar3D(x,y,x1,y1,FALSE);
  SetTextStyle(2,0,4); SetTextJustify(1,1); SetColor(0);
  OutTextXY(((x1-x)div 2)+x,((y1-y)div 2)+y,Text);
  GrVars.Restore; ShowMouseCursor;
END;

PROCEDURE OButton.SetNewPos(px, py, px1, py1 : WORD);
BEGIN
  mx:=mx+INTEGER(px-x); mx1:=mx1+INTEGER(px1-x1);
  my:=my+INTEGER(py-y); my1:=my1+INTEGER(py1-y1);
  x:=px; y:=py; x1:=px1; y1:=py1;
END;

FUNCTION OButton.Pressed : BOOLEAN;
VAR GrVars : SaveGrVars;
BEGIN
  if MouseIn(x,y,x1,y1) then begin
    if GetButtonStatus(1) then begin
      GrVars.Save; HideMouseCursor;
      Bar3D(x,y,x1,y1,TRUE);
      SetTextStyle(2,0,4); SetTextJustify(1,1); SetColor(0);
      OutTextXY(((x1-x)div 2)+x,((y1-y)div 2)+y,Text);
      SetLineStyle(4,$AAAA,1); Rectangle(mx,my,mx1,my1);
      GrVars.Restore; ShowMouseCursor; Pressed:=FALSE;
      while (GetButtonStatus(1))and(MouseIn(x,y,x1,y1)) do;
      if MouseIn(x,y,x1,y1) then Pressed:=TRUE else Marked:=FALSE;
      GrVars.Save; HideMouseCursor;
      Bar3D(x,y,x1,y1,FALSE);
      SetTextStyle(2,0,4); SetTextJustify(1,1); SetColor(0);
      OutTextXY(((x1-x)div 2)+x,((y1-y)div 2)+y,Text);
      if Marked then begin SetLineStyle(4,$AAAA,1); Rectangle(mx,my,mx1,my1); end;
      GrVars.Restore; ShowMouseCursor;
    end else begin
      Pressed:=FALSE; if Marked then exit;
      GrVars.Save; HideMouseCursor;
      SetTextStyle(2,0,4); SetTextJustify(1,1); SetColor(0);
      OutTextXY(((x1-x)div 2)+x,((y1-y)div 2)+y,Text);
      SetLineStyle(4,$AAAA,1); Rectangle(mx,my,mx1,my1);
      GrVars.Restore; ShowMouseCursor; Marked:=TRUE;
    end;
  end else begin
    Pressed:=FALSE; if not Marked then exit;
    GrVars.Save; HideMouseCursor;
    Bar3D(x,y,x1,y1,FALSE);
    SetTextStyle(2,0,4); SetTextJustify(1,1); SetColor(0);
    OutTextXY(((x1-x)div 2)+x,((y1-y)div 2)+y,Text);
    GrVars.Restore; ShowMouseCursor; Marked:=FALSE;
  end;
END;

DESTRUCTOR OButton.Done;
BEGIN
END;
{ -------------------------------------------------------------------------- }
CONSTRUCTOR OEditField.Init(px, py, px1, py1 : WORD);
BEGIN
  x:=px; y:=py; x1:=px1; y1:=py1; ex:=px+2; ex1:=px1-2;
  ey :=((y1-y)div 2)+y-(TextHeight('Û')div 2)-3;
  ey1:=((y1-y)div 2)+y+(TextHeight('Û')div 2)+2;
  StrTitle:=''; StrInfo:=''; StrText:='';
  SWidth:=(ex1-ex-4)div 8;
  MaxLen:=0; Pos:=0; SPos:=0;
  AvaibleChars:=[#0..#255];
  HasFocus:=TRUE; InsertMode:=FALSE; BuildNew:=TRUE;
  ZahlenTiefgesetzt:=FALSE; ReadOnly:=FALSE;
END;

PROCEDURE OEditField.SetNewPos(px, py, px1, py1 : WORD);
BEGIN
  ex:=ex+INTEGER(px-x); ex1:=ex1+INTEGER(px1-x1);
  ey:=ey+INTEGER(py-y); ey1:=ey1+INTEGER(py1-y1);
  x:=px; y:=py; x1:=px1; y1:=py1;
END;

PROCEDURE OEditField.SetTexts(Title, Info : STRING);
BEGIN
  if Title<>#0 then StrTitle:=Title;
  if Info <>#0 then StrInfo :=Info;
  ex:=x+TextWidth(StrTitle)+2; ex1:=x1-TextWidth(StrInfo)-2;
  SWidth:=(ex1-ex-4)div 8;
  if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth+1;
  WriteText(FALSE,FALSE);
END;

PROCEDURE OEditField.SetPetition(Text : STRING; Len : BYTE; Chars : CharSet);
VAR b  : BYTE;
BEGIN
  if Text<>#0 then begin StrText:=Text; First:=Text; end;
  if Len <> 0 then MaxLen:=Len;
  AvaibleChars:=Chars;
  for b:=1 to Length(StrText) do
    if not(StrText[b] in AvaibleChars) then delete(StrText,b,1);
  Pos:=Length(StrText)+1;
  if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth+1;
  WriteText(FALSE,FALSE);
END;

FUNCTION OEditField.GetPetition : STRING;
BEGIN
  GetPetition:=StrText;
END;

PROCEDURE OEditField.WriteText(Focus, New : BOOLEAN);
VAR Text     : STRING;
    GrVars   : SaveGrVars;
    w, px, p : WORD;
CONST Trenn : CharSet = [' ','-',':',',',';','.','|','&','/','*','+','\','?','!','%',')',']','}'];
BEGIN
  GrVars.Save; HideMouseCursor;
  SetTextStyle(0,0,0);
  if Focus then begin
    Text:=Copy(StrText,SPos,SWidth);
    SetFillStyle(1,7); SetTextJustify(0,1);
    if New then begin
      Bar(x,y,x1,y1); Bar3D(ex,ey,ex1,ey1,TRUE); SetColor(0);
      if StrTitle<>'' then OutTextXY(x+1  ,((y1-y)div 2)+y,StrTitle);
      if StrInfo <>'' then OuttextXY(ex1+2,((y1-y)div 2)+y,StrInfo);
    end else begin Bar(ex+1,ey+1,ex1-1,ey1-1); SetColor(0); end;
    if ReadOnly then SetColor(8);
    OutTextXY(ex+2,((y1-y)div 2)+y,Text);
  end else begin
    Text:=StrText;
    while TextWidth(Text)>ex1-ex-4 do delete(Text,Length(Text),1);
    SetFillStyle(1,7); Bar(x,y,x1,y1); SetColor(0); SetTextJustify(0,1);
    MoveTo(x+1,((y1-y)div 2)+y);
    if StrTitle<>'' then begin OutText(StrTitle); MoveTo(GetX+3,GetY); end;
    if StrText <>'' then begin
      for w:=1 to Length(Text) do
        if (Text[w]in['0'..'9'])and(ZahlenTiefgesetzt) then begin
          MoveTo(GetX,GetY+3); OutText(Text[w]); MoveTo(GetX,GetY-3);
        end else OutText(Text[w]);
      MoveTo(GetX+2,GetY);
      if Text<>StrText then begin
        PutPixel(GetX-3,GetY+2,0);
        PutPixel(GetX-1,GetY+2,0);
        PutPixel(GetX+1,GetY+2,0);
        MoveTo(GetX+5,GetY);
      end;
    end;
    OutText(StrInfo);
  end;
  GrVars.Restore; ShowMouseCursor; HasFocus:=Focus;
END;

PROCEDURE OEditField.ReadText;
VAR Key    : CHAR;
    Count  : BYTE;
    GrVars : SaveGrVars;
BEGIN
  GrVars.Save;
  SetTextStyle(0,0,0);
  if InsertMode then begin
    SetWriteMode(XORPut); SetColor(15);
    for Count:=0 to 7 do Line(ex+1+8*(Pos-SPos)+Count,ey+1,ex+1+8*(Pos-SPos)+Count,ey1-1);
    Delay(10); SetColor(15);
    for Count:=0 to 7 do Line(ex+1+8*(Pos-SPos)+Count,ey+1,ex+1+8*(Pos-SPos)+Count,ey1-1);
    Delay(10); SetWriteMode(NormalPut);
  end else begin
    SetColor(0); Line(ex+1+8*(Pos-SPos),ey+1,ex+1+8*(Pos-SPos),ey1-1); Delay(10);
    SetColor(7); Line(ex+1+8*(Pos-SPos),ey+1,ex+1+8*(Pos-SPos),ey1-1); Delay(10);
  end;
  if not keypressed then begin GrVars.Restore; exit; end;
  GrVars.Restore;
  Key:=Readkey;
  case Key of
    #00: case Readkey of
           #71: begin
                  Pos:=1; SPos:=1; WriteText(TRUE,FALSE);
                end;
           #75: if Pos>1 then begin
                  dec(Pos);
                  if Pos<SPos then begin
                    if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth+1;
                    WriteText(TRUE,FALSE);
                  end;
                end;
           #77: if Pos<=Length(StrText) then begin
                  inc(Pos);
                  if Pos>SPos+SWidth then begin
                    SPos:=Pos-SWidth+1; WriteText(TRUE,FALSE);
                  end;
                end;
           #79: begin
                  Pos:=Length(StrText)+1;
                  if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth+1;
                  WriteText(TRUE,FALSE);
                end;
           #82: if not ReadOnly then InsertMode:=not InsertMode;
           #83: begin
                  if not ReadOnly then StrText:='';
                  Pos:=1; SPos:=1; WriteText(TRUE,FALSE);
                end;
           else exit;
         end;
    #08: if (Pos>1)and(not ReadOnly) then begin
           delete(StrText,Pos-1,1);
           dec(Pos);
           if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth;
           WriteText(TRUE,FALSE);
         end;
    else if (Key in AvaibleChars)and((Length(StrText)<MaxLen)or((InsertMode)and(Pos<=Length(StrText))))
         and(not ReadOnly) then begin
           if (InsertMode)and(Pos<=Length(StrText)) then StrText[Pos]:=Key
           else begin
             if Pos=Length(StrText)+1 then StrText:=StrText+Key
                                      else Insert(Key,StrText,Pos);
           end;
           inc(Pos);
           if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth;
           WriteText(TRUE,FALSE);
         end;
  end;
END;

FUNCTION OEditField.Run : BOOLEAN;
BEGIN
  Run:=FALSE;
  if BuildNew then begin BuildNew:=FALSE; WriteText(FALSE,FALSE); end;
  if MouseIn(x,y,x1,y1) then case HasFocus of
    TRUE : while MouseIn(x,y,x1,y1) do ReadText;
    FALSE: WriteText(TRUE,TRUE);
  end else if HasFocus then begin WriteText(FALSE,FALSE); Run:=TRUE; end;
END;

DESTRUCTOR OEditField.Done;
BEGIN
END;
{ -------------------------------------------------------------------------- }
CONSTRUCTOR OComboField.Init(px, py, px1, py1 : WORD; VLines : BYTE);
BEGIN
  x:=px; y:=py; x1:=px1; y1:=py1;
  ex:=px+2; ex1:=px1-2;
  ey :=((y1-y)div 2)+y-(TextHeight('Û')div 2)-3;
  ey1:=((y1-y)div 2)+y+(TextHeight('Û')div 2)+2;
  MaxHeight:=VLines;
  lx:=ex; ly:=ey1+2; lx1:=ex1-10; ly1:=ly+(MaxHeight*(TextHeight('Û')+4))+18;
  First:=nil; Last:=nil; Help1:=nil; Help2:=nil; Screen:=nil;
  MaxLen:=0; Pos:=0; SPos:=0; SWidth:=0; AktChoose:=1; MaxPos:=0;
  AvaibleChars:=[#0..#255];
  StrTitle:=''; StrInfo:=''; StrText:='';
  HasFocus:=TRUE; InsertMode:=FALSE; List:=FALSE;
  ListPosStart:=1; ListPosMarked:=1; BuildNew:=TRUE;
END;

PROCEDURE OComboField.SetNewPos(px, py, px1, py1 : WORD);
BEGIN
  ex:=ex+INTEGER(px-x); ex1:=ex1+INTEGER(px1-x1);
  ey:=ey+INTEGER(py-y); ey1:=ey1+INTEGER(py1-y1);
  lx:=lx+INTEGER(px-x); lx1:=lx1+INTEGER(px1-x1);
  ly:=ly+INTEGER(py-y); ly1:=ly1+INTEGER(py1-y1);
  x:=px; y:=py; x1:=px1; y1:=py1;
END;

PROCEDURE OComboField.SetTexts(Title, Info : STRING);
BEGIN
  if Title<>#0 then StrTitle:=Title;
  if Info <>#0 then StrInfo :=Info;
  ex:=x+TextWidth(StrTitle)+2; ex1:=x1-TextWidth(StrInfo)-2;
  lx:=ex; lx1:=ex1-10;
  SWidth:=(ex1-ex-14)div 8;
  if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth+1;
  WriteText(FALSE,FALSE);
END;

PROCEDURE OComboField.SetAvaibleChars(Chars : CharSet);
VAR s : STRING;
    w : WORD;
    b : BYTE;
BEGIN
  AvaibleChars:=Chars; w:=1;
  repeat
    s:=GetString(w); inc(w);
    for b:=1 to Length(s) do if not(s[b] in AvaibleChars) then delete(s,b,1);
  until s='';
END;

PROCEDURE OComboField.SetChoose(Nr : WORD);
VAR Text : STRING;
BEGIN
  Text:=GetString(Nr); if Text='' then exit;
  AktChoose     := Nr;
  ListPosMarked := Nr;
  Pos:=Length(Text)+1;
  if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth;
  StrText:=GetString(AktChoose);
  WriteText(FALSE,FALSE);
END;

PROCEDURE OComboField.InsertString(Text : STRING);
VAR b        : BYTE;
    Nr       : WORD;
    sText, s : STRING;
BEGIN
  sText:=Text; Nr:=1;
  if length(sText)<>0 then for b:=1 to length(sText) do sText[b]:=upcase(sText[b]);
  new(Help1);
  if First=nil then begin
    Help1^[Left]  := nil;
    Help1^[Right] := nil;
    First         := Help1;
    Last          := Help1;
  end else begin
    Help2:=First;
    while Help2<>nil do begin
      Move(Help2^[Block]^,s[0],1); Move(Help2^[Block]^,s[0],ord(s[0])+1);
      if length(s)<>0 then for b:=1 to length(s) do s[b]:=upcase(s[b]);
      if s>sText then break;
      Inc(Nr); Help2:=Help2^[Right];
    end;
    if Help2=nil then begin
      Help2         := Last;
      Help2^[Right] := Help1;
      Help1^[Left]  := Help2;
      Help1^[Right] := nil;
      Last          := Help1;
    end else begin
      Help1^[Left]  := Help2^[Left];
      Help2^[Left]  := Help1;
      Help1^[Right] := Help2;
      Help2         := Help1^[Left];
      if Help2=nil then begin
        First := Help1;
      end else Help2^[Right] := Help1;
    end;
  end;
  GetMem(Help1^[Block],Length(Text)+1);
  Move(Text[0],Help1^[Block]^,Length(Text)+1);
  inc(MaxPos);
  if Length(Text)>MaxLen then begin
    if lx+TextWidth(Text)+6>GetMaxX then lx:=GetMaxX-TextWidth(Text)-6;
    if lx+TextWidth(Text)+6>lx1 then lx1:=lx+TextWidth(Text)+6;
    MaxLen:=Length(Text);
  end;
  if Nr=AktChoose then begin
    Pos:=Length(Text)+1;
    if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth;
  end;
END;

FUNCTION OComboField.GetString(StrPos : WORD) : STRING;
VAR s : STRING;
    w : WORD;
BEGIN
  GetString:=''; Help1:=First;
  if StrPos>1 then for w:=2 to StrPos do if Help1<>nil then Help1:=Help1^[Right];
  if Help1<>nil then begin
    Move(Help1^[Block]^,s[0],1); Move(Help1^[Block]^,s[0],ord(s[0])+1);
    GetString:=s;
  end;
END;

PROCEDURE OComboField.SetString(StrPos : WORD; Text : STRING);
VAR b : BYTE;
BEGIN
  Help1:=First;
  if b>1 then for b:=2 to StrPos do if Help1<>nil then Help1:=Help1^[Right];
  if Help1<>nil then begin
    Move(Text[0],Help1^[Block]^,Length(Text)+1);
  end;
END;

FUNCTION OComboField.GetResult : STRING;
BEGIN
  GetResult:=GetString(AktChoose);
END;

FUNCTION OComboField.GetAktChoose : WORD;
BEGIN
  GetAktChoose:=AktChoose;
END;

PROCEDURE OComboField.WriteText(Focus, New : BOOLEAN);
VAR Text, Text1 : STRING;
    GrVars      : SaveGrVars;
    NewChoose   : WORD;
    b           : BYTE;
BEGIN
  GrVars.Save; HideMouseCursor;
  SetTextStyle(0,0,0);
  if Focus then begin
    SetFillStyle(1,7); SetTextJustify(0,1);
    if New then begin
      StrText:=GetString(AktChoose);
      Bar(x,y,x1,y1); Bar3D(ex,ey,ex1,ey1,TRUE);
      Bar3d(ex1-11,ey+1,ex1-1,ey1-1,List); SetColor(0);
      if StrTitle<>'' then OutTextXY(x+1  ,((y1-y)div 2)+y,StrTitle);
      if StrInfo <>'' then OuttextXY(ex1+2,((y1-y)div 2)+y,StrInfo);
    end else begin Bar(ex+1,ey+1,ex1-12,ey1-1); SetColor(0); end;
    Text:=Copy(StrText,SPos,SWidth);
    OutTextXY(ex+2,((y1-y)div 2)+y,Text);
  end else begin
    Text1:=StrText;
    for b:=1 to Length(Text1) do Text1[b]:=UpCase(Text1[b]);
    Help1:=First; NewChoose:=1;
    if StrText<>'' then while Help1<>nil do begin
      Move(Help1^[Block]^,Text[0],1); Move(Help1^[Block]^,Text[0],ord(Text[0])+1);
      for b:=1 to Length(Text) do Text[b]:=UpCase(Text[b]);
      if Text=Text1 then begin AktChoose:=NewChoose; ListPosMarked:=NewChoose; break; end;
      Help1:=Help1^[Right]; inc(NewChoose);
    end;
    Text:=GetString(AktChoose);
    if Pos>Length(Text)+1 then Pos:=Length(Text)+1;
    while TextWidth(Text)>ex1-ex-4 do delete(Text,Length(Text),1);
    SetFillStyle(1,7); Bar(x,y,x1,y1); SetColor(0); SetTextJustify(0,1);
    MoveTo(x+1,((y1-y)div 2)+y);
    if StrTitle<>'' then begin OutText(StrTitle); MoveTo(GetX+3,GetY); end;
    if Text    <>'' then begin
      OutText(Text); MoveTo(GetX+2,GetY);
      if Text<>GetString(AktChoose) then begin
        PutPixel(GetX-3,GetY+2,0);
        PutPixel(GetX-1,GetY+2,0);
        PutPixel(GetX+1,GetY+2,0);
        MoveTo(GetX+5,GetY);
      end;
    end;
    OutText(StrInfo);
  end;
  GrVars.Restore; ShowMouseCursor; HasFocus:=Focus;
END;

PROCEDURE OComboField.ReadText;
VAR Key    : CHAR;
    Count  : BYTE;
    GrVars : SaveGrVars;
BEGIN
  GrVars.Save;
  if InsertMode then begin
    SetWriteMode(XORPut); SetColor(15);
    for Count:=0 to 7 do Line(ex+1+8*(Pos-SPos)+Count,ey+1,ex+1+8*(Pos-SPos)+Count,ey1-1);
    Delay(10); SetColor(15);
    for Count:=0 to 7 do Line(ex+1+8*(Pos-SPos)+Count,ey+1,ex+1+8*(Pos-SPos)+Count,ey1-1);
    Delay(10); SetWriteMode(NormalPut);
  end else begin
    SetColor(0); Line(ex+1+8*(Pos-SPos),ey+1,ex+1+8*(Pos-SPos),ey1-1); Delay(10);
    SetColor(7); Line(ex+1+8*(Pos-SPos),ey+1,ex+1+8*(Pos-SPos),ey1-1); Delay(10);
  end;
  if not keypressed then begin GrVars.Restore; exit; end;
  Key:=Readkey;
  case Key of
    #00: case Readkey of
           #71: begin
                  Pos:=1; SPos:=1; WriteText(TRUE,FALSE);
                end;
           #75: if Pos>1 then begin
                  dec(Pos);
                  if Pos<SPos then begin
                    if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth+1;
                    WriteText(TRUE,FALSE);
                  end;
                end;
           #77: if Pos<=Length(StrText) then begin
                  inc(Pos);
                  if Pos>SPos+SWidth then begin
                    SPos:=Pos-SWidth+1; WriteText(TRUE,FALSE);
                  end;
                end;
           #79: begin
                  Pos:=Length(StrText)+1;
                  if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth+1;
                  WriteText(TRUE,FALSE);
                end;
           #82: InsertMode:=not InsertMode;
           #83: begin
                  StrText:=''; Pos:=1; SPos:=1; WriteText(TRUE,FALSE);
                end;
         end;
    #08: if Pos>1 then begin
           delete(StrText,Pos-1,1);
           dec(Pos);
           if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth;
           WriteText(TRUE,FALSE);
         end;
    else if (Key in AvaibleChars)and((Length(StrText)<MaxLen)or((InsertMode)and(Pos<=Length(StrText)))) then begin
           if (InsertMode)and(Pos<=Length(StrText)) then StrText[Pos]:=Key
           else begin
             if Pos=Length(StrText)+1 then StrText:=StrText+Key
                                      else Insert(Key,StrText,Pos);
           end;
           inc(Pos);
           if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth;
           WriteText(TRUE,FALSE);
         end;
  end;
  GrVars.Restore;
END;

PROCEDURE OComboField.DoListProc(Switch : BOOLEAN);

 PROCEDURE PaintList;
 VAR GrVars : SaveGrVars;
     w      : WORD;
 BEGIN
   GrVars.Save; HideMouseCursor; SetTextJustify(1,1);
   Bar3D(lx,ly,lx1,ly1,FALSE);
   if ListPosStart=1 then SetColor(8) else SetColor(0);
   OutTextXY(((lx1-lx)div 2)+lx,ly+6,'');
   if ListPosStart+MaxHeight>MaxPos then SetColor(8) else SetColor(0);
   OutTextXY(((lx1-lx)div 2)+lx,ly1-4,'');
   SetColor(0); SetTextJustify(0,1);
   for w:=ListPosStart to ListPosStart+MaxHeight-1 do if GetString(w)<>'' then begin
     if w=ListPosMarked then begin
       Bar3D(lx+2,ly+9+((w-ListPosStart)*(TextHeight('Û')+4)),lx1-2,
             ly+9+((w-ListPosStart+1)*(TextHeight('Û')+4)),TRUE);
       SetColor(0);
     end;
     OutTextXY(lx+4,ly+11+((w-ListPosStart)*(TextHeight('Û')+4))+(TextHeight('Û')div 2),
               GetString(w));
   end;
   GrVars.Restore; ShowMouseCursor;
 END;

VAR GrVars      : SaveGrVars;
    mx, my      : WORD;
    Text, Text1 : STRING;
BEGIN
  if Switch then begin
    GrVars.Save; HideMouseCursor;
    List:=not List; Bar3d(ex1-11,ey+1,ex1-1,ey1-1,List);
    if List then begin
      GetMem(Screen,ImageSize(lx,ly,lx1,ly1));
      GetImage(lx,ly,lx1,ly1,Screen^);
      while not((ListPosMarked>=ListPosStart)and(ListPosMarked<=ListPosStart+MaxHeight))
        do if ListPosMarked>ListPosStart then inc(ListPosStart) else dec(ListPosStart);
      PaintList;
    end else if Screen<>nil then begin
      PutImage(lx,ly,Screen^,NormalPut);
      FreeMem(Screen,ImageSize(lx,ly,lx1,ly1));
      Screen:=nil;
    end;
    ShowMouseCursor; delay(100); GrVars.Restore; exit;
  end;
  Text:=StrText; for mx:=1 to Length(Text) do Text[mx]:=UpCase(Text[mx]); my:=0;
  repeat
    inc(my); Text1:=GetString(my);
    if Text1<>'' then for mx:=1 to Length(Text1) do Text1[mx]:=UpCase(Text1[mx]);
  until (Text1='')or(Text1=Text);
  if (Text1<>'')and(my<>ListPosMarked) then begin
    ListPosMarked:=my; AktChoose:=my;
    while not((ListPosMarked>ListPosStart)and(ListPosMarked<ListPosStart+MaxHeight))
      do if ListPosMarked>ListPosStart then inc(ListPosStart) else dec(ListPosStart);
    PaintList;
  end;
  if (not MouseIn(lx,ly,lx1,ly1))or(not List) then exit;
  if (MouseIn(lx,ly,lx1,ly+9))and(ListPosStart>1) then begin
    dec(ListPosStart); PaintList; delay(150);
  end;
  if (MouseIn(lx,ly1-9,lx1,ly1))and(ListPosStart<=MaxPos-MaxHeight) then begin
    inc(ListPosStart); PaintList; delay(150);
  end;
  if (MouseIn(lx,ly+9,lx1,ly1-9))and(GetButtonStatus(1)) then begin
    GetMouseStatus(mx,my,mx);
    my:=(my-ly-9)div(TextHeight('Û')+4);
    ListPosMarked:=ListPosStart+my; PaintList; delay(100);
    AktChoose:=ListPosMarked; StrText:=GetString(AktChoose);
    Pos:=Length(StrText)+1;
    if INTEGER(Pos-SWidth)<=0 then SPos:=1 else SPos:=Pos-SWidth;
    WriteText(TRUE,FALSE);
  end;
END;

FUNCTION OComboField.Run : BOOLEAN;
BEGIN
  Run:=FALSE;
  if BuildNew then begin BuildNew:=FALSE; WriteText(FALSE,FALSE); end;
  if MouseIn(x,y,x1,y1) then case HasFocus of
    TRUE : begin
             ReadText; DoListProc(FALSE);
             if (MouseIn(ex1-11,ey+1,ex1-1,ey1-1))and(GetButtonStatus(1))
               then DoListProc(TRUE);
           end;
    FALSE: WriteText(TRUE,TRUE)
  end else if HasFocus then begin
    if (List)and(MouseIn(lx,ly-3,lx1,ly1)) then begin DoListProc(FALSE); exit; end;
    if List then DoListProc(TRUE);
    WriteText(FALSE,FALSE); Run:=TRUE;
  end;
END;

DESTRUCTOR OComboField.Done;
VAR B : Byte;
BEGIN
  Help1:=First;
  while Help1<>nil do begin
    Help2:=Help1^[Right];
    Move(Help1^[Block]^,B,1); FreeMem(Help1^[Block],b+1);
    Dispose(Help1);
    Help1:=Help2;
  end;
END;
{ -------------------------------------------------------------------------- }
CONSTRUCTOR OListField.Init(px, py, VisibleLines : WORD);
BEGIN
  x:=px; y:=py; x1:=px+14; y1:=py+(VisibleLines*15)+17; VisLines:=VisibleLines;
  while y1>GetMaxY do begin dec(y1,14); dec(VisLines,1); end;
  Columns:=0; Lines:=0; AktLine:=0;
  FirstColumn:=nil; LastColumn:=nil; FirstText:=nil; LastText:=nil;
  FirstCell:=nil; LastCell:=nil; ArrowCursor:=TRUE;
END;

PROCEDURE OListField.NewColumn(Title : STRING; Len : BYTE; Width : WORD; Chars : CharSet; ReadOnly,ZahlenTiefgesetzt: BOOLEAN);
VAR Col, Lin : WORD;
BEGIN
  if x1+2+Width>GetMaxX then begin
    Width:=GetMaxX-x1-2; if Width=0 then exit;
  end;
  x1:=x1+1+Width; inc(Columns);
  new(ColumnHelp1); ColumnHelp2:=LastColumn; LastColumn:=ColumnHelp1;
  if ColumnHelp2=nil then FirstColumn:=ColumnHelp1
                     else ColumnHelp2^.Right:=ColumnHelp1;
  ColumnHelp1^.Left              := ColumnHelp2;
  ColumnHelp1^.Right             := nil;
  ColumnHelp1^.Title             := Title;
  ColumnHelp1^.Width             := Width;
  ColumnHelp1^.Len               := Len;
  ColumnHelp1^.Chars             := Chars;
  ColumnHelp1^.ReadOnly          := ReadOnly;
  ColumnHelp1^.ZahlenTiefgesetzt := ZahlenTiefgesetzt;
  if FirstText<>nil then begin
    TextHelp1:=FirstText; Col:=1;
    while TextHelp1<>nil do begin
      if Col+1=Columns then begin
        Col:=1; new(TextHelp2);
        TextHelp2^[Block] := nil;
        TextHelp2^[Left]  := TextHelp1;
        TextHelp2^[Right] := TextHelp1^[Right];
        TextHelp1^[Right] := TextHelp2;
        TextHelp1         := TextHelp2^[Right];
        if TextHelp1<>nil then TextHelp1^[Left]:=TextHelp2 else LastText:=TextHelp2;
      end else begin TextHelp1:=TextHelp1^[Right]; inc(Col); end;
    end;
  end;
  if FirstCell<>nil then begin
    CellHelp1:=FirstCell; Col:=1; Lin:=1;
    while CellHelp1<>nil do begin
      SetText(Col,AktLine+Lin,CellHelp1^.EditField.GetPetition);
      CellHelp2:=CellHelp1^.Right;
      CellHelp1^.EditField.Done;
      Dispose(CellHelp1);
      CellHelp1:=CellHelp2;
      if Lin<VisLines then inc(Lin) else begin inc(Col); Lin:=1; end;
    end;
    FirstCell:=nil; LastCell:=nil; DrawField;
  end;
END;

PROCEDURE OListField.SetText(Column, Line : WORD; Text : STRING);
VAR Lin, Col, Len : WORD;
BEGIN
  ColumnHelp1:=FirstColumn;
  if Column>1 then for Col:=2 to Column do ColumnHelp1:=ColumnHelp1^.Right
              else Column:=1;
  Len:=ColumnHelp1^.Len;
  TextHelp1:=FirstText; if Line<1 then Line:=1; Lin:=1;
  while (TextHelp1<>nil)and(Lin<>Line) do begin
    for Col:=1 to Columns do TextHelp1:=TextHelp1^[Right];
    inc(Lin);
  end;
  if TextHelp1=nil then begin
    for Lin:=Lin to Line do for Col:=1 to Columns do begin
      new(TextHelp1); TextHelp2:=LastText; LastText:=TextHelp1;
      if TextHelp2=nil then FirstText:=TextHelp1
                       else TextHelp2^[Right]:=TextHelp1;
      TextHelp1^[Left]  := TextHelp2;
      TextHelp1^[Right] := nil;
      TextHelp1^[Block] := nil;
    end;
    if Line>Lines then Lines:=Line;
    SetText(Column,Line,Text);
    exit;
  end;
  if Column<>1 then for Col:=2 to Column do TextHelp1:=TextHelp1^[Right];
  if TextHelp1^[Block]=nil then GetMem(TextHelp1^[Block],Len+1);
  while Length(Text)>Len do Delete(Text,Length(Text),1);
  Move(Text[0],TextHelp1^[Block]^,Len+1);
END;

FUNCTION OListField.GetText(Column, Line : WORD) : STRING;
VAR Lin, Col, Len : WORD;
    Text          : STRING;
BEGIN
  ColumnHelp1:=FirstColumn;
  if Column>1 then for Col:=2 to Column do ColumnHelp1:=ColumnHelp1^.Right
              else Column:=1;
  Len:=ColumnHelp1^.Len;
  TextHelp1:=FirstText; if Line<1 then Line:=1; Lin:=1;
  while (TextHelp1<>nil)and(Lin<>Line) do begin
    for Col:=1 to Columns do TextHelp1:=TextHelp1^[Right];
    inc(Lin);
  end;
  if TextHelp1=nil then exit;
  if Column<>1 then for Col:=2 to Column do TextHelp1:=TextHelp1^[Right];
  if TextHelp1^[Block]=nil then begin GetText:=''; exit; end;
  Move(TextHelp1^[Block]^,Text[0],Len+1); GetText:=Text;
END;

PROCEDURE OListField.DrawScroller;
VAR GrVars     : SaveGrVars;
BEGIN
  if Lines<=VisLines then exit;
  GrVars.Save; HideMouseCursor;
  SetFillStyle(1,7); Bar(x1-12,y+28,x1-1,y1-13);
  YRes:=Round((VisLines/Lines)*(y1-y-41)); if YRes<3 then YRes:=3;
  YPos:=Round((AktLine/Lines)*(y1-y-41))+y+28;
  Bar3D(x1-12,YPos,x1-1,YPos+YRes,FALSE);
  GrVars.Restore; ShowMouseCursor;
END;

PROCEDURE OListField.RunScroller;
VAR GrVars    : SaveGrVars;
    mx, my, w : WORD;
    pmx, pmy  : INTEGER;
BEGIN
  if Lines<=VisLines then exit;
  if (Button[1].Pressed)and(AktLine>0) then begin
    dec(AktLine); ViewList;
  end else if (Button[2].Pressed)and(AktLine<INTEGER(Lines-VisLines)) then begin
    inc(AktLine); ViewList;
  end else if (MouseIn(x1-12,y+28,x1-1,YPos))and(GetButtonStatus(1)) then begin
    while (MouseIn(x1-12,y+28,x1-1,YPos))and(GetButtonStatus(1)) do;
    if not MouseIn(x1-12,y+28,x1-1,YPos) then exit;
    if INTEGER(AktLine-VisLines)<0 then AktLine:=0 else dec(AktLine,VisLines);
    ViewList;
  end else if (MouseIn(x1-12,YPos+YRes,x1-1,y1-13))and(GetButtonStatus(1)) then begin
    while (MouseIn(x1-12,YPos+YRes,x1-1,y1-13))and(GetButtonStatus(1)) do;
    if not MouseIn(x1-12,YPos+YRes,x1-1,y1-13) then exit;
    if AktLine+(2*VisLines)>Lines then AktLine:=Lines-VisLines else inc(AktLine,VisLines);
    ViewList;
  end else if (MouseIn(x1-12,YPos,x1-1,YPos+YRes))and(GetButtonStatus(1)) then begin
    GrVars.Save;
    GetMouseStatus(mx,my,w); pmx:=mx-x1+12; pmy:=my-YPos; mx:=x1-12; my:=YPos;
    SetMousePosition(mx,my); HideMouseCursor;
    while GetButtonStatus(1) do begin
      GetMouseStatus(w,my,w);
      if my<>YPos then begin
        SetFillStyle(1,7); Bar(x1-12,YPos,x1-1,YPos+YRes); YPos:=my;
        if YPos+YRes>y1-13 then begin
          YPos:=y1-13-YRes; my:=YPos; SetMousePosition(mx,my);
        end;
        if YPos<y+28 then begin
          YPos:=y+28; my:=YPos; SetMousePosition(mx,my);
        end;
        Bar3D(x1-12,YPos,x1-1,YPos+YRes,FALSE);
      end;
    end;
    AktLine:=Round(((YPos-y-28)/(y1-y-41))*Lines);
    if AktLine>Lines-VisLines then AktLine:=Lines-VisLines;
    GrVars.Restore; SetMousePosition(mx+pmx,my+pmy); ShowMouseCursor;
    ViewList;
  end;
END;

PROCEDURE OListField.SetEditFieldText(Line, Column : WORD; p : POINTER);
VAR Col, Lin : WORD;
    s        : STRING;
    b : pointer;
BEGIN
  if p=nil then exit;
  CellHelp1:=FirstCell;
  if Column<>1 then for Col:=2 to Column do
    for Lin:=1 to VisLines do CellHelp1:=CellHelp1^.Right;
  if Line<>1 then for Lin:=2 to Line do CellHelp1:=CellHelp1^.Right;
  ColumnHelp1:=FirstColumn;
  if Column<>1 then for Col:=2 to Column do ColumnHelp1:=ColumnHelp1^.Right;
  move(p^,s[0],ColumnHelp1^.Len+1);
  CellHelp1^.EditField.SetPetition(s,ColumnHelp1^.Len,ColumnHelp1^.Chars);
END;

PROCEDURE OListField.ViewList;
VAR Col, Lin : WORD;
BEGIN
  CellHelp1:=FirstCell; ColumnHelp1:=FirstColumn;
  if Lines<VisLines then for Col:=1 to Columns do begin
    for Lin:=1 to VisLines do begin
      CellHelp1^.EditField.SetPetition('',ColumnHelp1^.Len,ColumnHelp1^.Chars);
      CellHelp1:=CellHelp1^.Right;
    end;
    ColumnHelp1:=ColumnHelp1^.Right;
  end;
  DrawScroller;
  TextHelp1:=FirstText;
  if AktLine<>0 then for Lin:=1 to AktLine*Columns do begin
    if TextHelp1=nil then break else TextHelp1:=TextHelp1^[Right];
  end;
  for Lin:=1 to VisLines do for Col:=1 to Columns do begin
    if TextHelp1=nil then exit;
    SetEditFieldText(Lin,Col,TextHelp1^[Block]);
    TextHelp1:=TextHelp1^[Right];
  end;
END;

PROCEDURE OListField.DrawField;
VAR GrVars                : SaveGrVars;
    XPrev, LineNr, Points : WORD;
    Title                 : STRING;
BEGIN
  GrVars.Save; HideMouseCursor;
  Bar3D(x,y,x1,y1,TRUE);
  Line3D(x,y+14,x1-1,y+14,FALSE); Line3D(x1-14,y,x1-14,y1-1,FALSE);
  Button[1].Init(x1-12,y+16,x1-1,y+27,'');
  Button[2].Init(x1-12,y1-12,x1-1,y1-1,'');
  SetTextStyle(0,0,0); SetTextJustify(0,1);
  ColumnHelp1:=FirstColumn; XPrev:=x+1;
  while ColumnHelp1<>nil do begin
    Title:=ColumnHelp1^.Title;
    while TextWidth(Title)+8>ColumnHelp1^.Width do Delete(Title,Length(Title),1);
    if Title<>ColumnHelp1^.Title then Points:=3 else Points:=0;
    SetColor(0);
    MoveTo(XPrev+(ColumnHelp1^.Width div 2)-(TextWidth(Title)div 2)-Points,y+7);
    OutText(Title);
    if Points<>0 then begin
      PutPixel(GetX+1,y+10,0); PutPixel(GetX+3,y+10,0); PutPixel(GetX+5,y+10,0);
    end;
    for LineNr:=1 to VisLines do begin
      new(CellHelp1); CellHelp2:=LastCell; LastCell:=CellHelp1;
      if CellHelp2=nil then FirstCell:=CellHelp1 else CellHelp2^.Right:=CellHelp1;
      CellHelp1^.Left  := CellHelp2;
      CellHelp1^.Right := nil;
      CellHelp1^.EditField.Init(XPrev+1,y+2+(LineNr*15),XPrev+ColumnHelp1^.Width-1,y+16+(LineNr*15));
      CellHelp1^.EditField.ReadOnly          := ColumnHelp1^.ReadOnly;
      CellHelp1^.EditField.ZahlenTiefgesetzt := ColumnHelp1^.ZahlenTiefgesetzt;
      CellHelp1^.EditField.SetTexts('','');
      CellHelp1^.EditField.SetPetition('',ColumnHelp1^.Len,ColumnHelp1^.Chars);
    end;
    XPrev:=XPrev+ColumnHelp1^.Width+1;
    Line3D(XPrev-1,y,XPrev-1,y1-1,FALSE);
    ColumnHelp1:=ColumnHelp1^.Right;
  end;
  GrVars.Restore; ShowMouseCursor;
  ViewList;
END;

PROCEDURE OListField.SetNewPos(px, py : WORD);
VAR XPrev, LineNr : WORD;
BEGIN
  YPos:=YPos+INTEGER(py-y);
  x1:=x1+INTEGER(px-x); y1:=y1+INTEGER(py-y); x:=px; y:=py;
  ColumnHelp1:=FirstColumn; CellHelp1:=FirstCell; XPrev:=x+1;
  while ColumnHelp1<>nil do begin
    for LineNr:=1 to VisLines do begin
      CellHelp1^.EditField.SetNewPos(XPrev+1,y+2+(LineNr*15),XPrev+ColumnHelp1^.Width-1,y+16+(LineNr*15));
      CellHelp1:=CellHelp1^.Right;
    end;
    XPrev:=XPrev+ColumnHelp1^.Width+1;
    ColumnHelp1:=ColumnHelp1^.Right;
  end;
  Button[1].SetNewPos(x1-12,y+16,x1-1,y+27);
  Button[2].SetNewPos(x1-12,y1-12,x1-1,y1-1);
END;

FUNCTION OListField.SetColumnWidth(pFrom, pTo : WORD) : INTEGER;
VAR GrVars                : SaveGrVars;
    Pos, Start, mx, my, w : WORD;
    pmy                   : INTEGER;
BEGIN
  GrVars.Save; HideMouseCursor;
  GetMouseStatus(mx,my,Pos); pmy:=my-y; Pos:=mx; Start:=mx;
  SetWriteMode(XorPut); SetLineStyle(4,$AAAA,1); SetColor(15);
  Line(Pos,y+15,Pos,y1-1);
  while GetButtonStatus(1) do begin
    GetMouseStatus(mx,my,w);
    if mx<>Pos then begin
      Line(Pos,y+15,Pos,y1-1);
      if mx<pFrom then begin mx:=pFrom; SetMousePosition(mx,my); end;
      if mx>pTo   then begin mx:=pTo;   SetMousePosition(mx,my); end;
      Pos:=mx; Line(Pos,y+15,Pos,y1-1);
    end;
  end;
  Line(Pos,y+15,Pos,y1-1); SetWriteMode(NormalPut);
  GrVars.Restore; SetMousePosition(mx,y+pmy); ShowMouseCursor;
  SetColumnWidth:=Pos-Start;
END;

PROCEDURE OListField.SetResizeCursor; ASSEMBLER;
ASM
  jmp @@Start
  @Zeiger: dw 1111111111111111b
           dw 1111111111111111b
           dw 1111110110111111b
           dw 1111110110111111b
           dw 1110110110110111b
           dw 1100110110110011b
           dw 1000110110110001b
           dw 0000000110000000b
           dw 1000110110110001b
           dw 1100110110110011b
           dw 1110110110110111b
           dw 1111110110111111b
           dw 1111110110111111b
           dw 1111111111111111b
           dw 1111111111111111b
           dw 1111111111111111b

           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
           dw 0000000000000000b
  @@Start:
  mov ax, 9
  mov bx, 7
  mov cx, 7
  mov dx, seg @Zeiger
  mov es, dx
  mov dx, offset @Zeiger
  int $33
END;

PROCEDURE OListField.SetArrowCursor; ASSEMBLER;
ASM
  mov ax, 3
  int $33
  push cx
  push dx
  mov ax, 0
  int $33
  pop dx
  pop cx
  mov ax, 4
  int $33
  mov ax, 1
  int $33
END;

PROCEDURE OListField.Run;
VAR Col, Lin, XPrev : WORD;
    Res             : INTEGER;
    NewText         : STRING;
    SetCursor       : BOOLEAN;
BEGIN
  CellHelp1:=FirstCell; Col:=1; Lin:=1;
  while CellHelp1<>nil do begin
    if CellHelp1^.EditField.Run then begin
      NewText:=CellHelp1^.EditField.GetPetition;
      if NewText<>GetText(Col,AktLine+Lin) then begin
        SetText(Col,AktLine+Lin,NewText); ViewList;
      end;
    end;
    CellHelp1:=CellHelp1^.Right;
    if Lin<VisLines then inc(Lin) else begin inc(Col); Lin:=1; end;
  end;
  RunScroller; if FirstColumn=nil then exit;
  ColumnHelp1:=FirstColumn; XPrev:=x+ColumnHelp1^.Width+2;
  ColumnHelp2:=ColumnHelp1^.Right; SetCursor:=FALSE;
  while ColumnHelp2<>nil do begin
    if MouseIn(XPrev-2,y+14,XPrev+2,y1) then SetCursor:=TRUE;
    XPrev:=XPrev+ColumnHelp2^.Width+1;
    ColumnHelp1:=ColumnHelp1^.Right;
    if ColumnHelp1<>nil then ColumnHelp2:=ColumnHelp1^.Right else break;
    if ColumnHelp2=nil then break;
  end;
  if (ArrowCursor)and(SetCursor) then begin
    SetResizeCursor; ArrowCursor:=FALSE;
  end else if (not ArrowCursor)and(not SetCursor) then begin
    SetArrowCursor; ArrowCursor:=TRUE;
  end;
  ColumnHelp1:=FirstColumn; XPrev:=x+ColumnHelp1^.Width+2;
  ColumnHelp2:=ColumnHelp1^.Right;
  while ColumnHelp2<>nil do begin
    if ((MouseIn(XPrev-2,y+14,XPrev+2,y1))and(GetButtonStatus(1))) then begin
      Res:=SetColumnWidth(XPrev-ColumnHelp1^.Width+20,XPrev+ColumnHelp2^.Width-20);
      inc(ColumnHelp1^.Width,Res); dec(ColumnHelp2^.Width,Res);
      if FirstCell<>nil then begin
        CellHelp1:=FirstCell; Col:=1; Lin:=1;
        while CellHelp1<>nil do begin
          SetText(Col,AktLine+Lin,CellHelp1^.EditField.GetPetition);
          CellHelp2:=CellHelp1^.Right;
          CellHelp1^.EditField.Done;
          Dispose(CellHelp1);
          CellHelp1:=CellHelp2;
          if Lin<VisLines then inc(Lin) else begin inc(Col); Lin:=1; end;
        end;
        FirstCell:=nil; LastCell:=nil; DrawField;
      end;
    end;
    XPrev:=XPrev+ColumnHelp2^.Width+1;
    ColumnHelp1:=ColumnHelp1^.Right;
    if ColumnHelp1<>nil then ColumnHelp2:=ColumnHelp1^.Right else exit;
    if ColumnHelp2=nil then exit;
  end;
END;

DESTRUCTOR OListField.Done;
BEGIN
  TextHelp1:=FirstText; ColumnHelp1:=FirstColumn;
  while TextHelp1<>nil do begin
    TextHelp2:=TextHelp1^[Right];
    if TextHelp1^[Block]<>nil then FreeMem(TextHelp1^[Block],ColumnHelp1^.Len);
    Dispose(TextHelp1); TextHelp1:=TextHelp2;
    if ColumnHelp1^.Right=nil then ColumnHelp1:=FirstColumn
                              else ColumnHelp1:=ColumnHelp1^.Right;
  end;
  ColumnHelp1:=FirstColumn;
  while ColumnHelp1<>nil do begin
    ColumnHelp2:=ColumnHelp1^.Right; Dispose(ColumnHelp1); ColumnHelp1:=ColumnHelp2;
  end;
  CellHelp1:=FirstCell;
  while CellHelp1<>nil do begin
    CellHelp1^.EditField.Done;
    CellHelp2:=CellHelp1^.Right;
    Dispose(CellHelp1);
    CellHelp1:=CellHelp2;
  end;
  Button[1].Done; Button[2].Done;
END;
{ -------------------------------------------------------------------------- }

END.