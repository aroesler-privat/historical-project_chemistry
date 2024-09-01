UNIT Infos; INTERFACE
USES Crt, Graph, Graphics, Mouse, Elemente, Controls, ReadFile, Logo;

TYPE PSubstanceRec = ^TSubstanceRec;
     TSubstanceRec = RECORD
                       Name   : STRING[30];
                       Formel : STRING[20];
                       Stoffklasse, Aggregat  : BYTE;
                       Schmelz, Siede, Dichte : REAL;
                       SEnthalpie, SEntropie  : REAL;
                       Konst1, Konst2         : REAL;
                     END;
     PSubstanceClass = ^TSubstanceClass;
     TSubstanceClass = RECORD
                         ID             : BYTE;
                         Name           : STRING[20];
                         Konst1, Konst2 : STRING[10];
                         Einh1, Einh2   : STRING[10];
                       END;

PROCEDURE RunInfos;

IMPLEMENTATION

TYPE PElements = ^TElements;
     TElements = RECORD
                   Nr          : WORD;
                   Anz         : BYTE;
                   Dlg         : ElementInfos;
                   Left, Right : POINTER;
                 END;
     OElements = OBJECT
                   Formel       : STRING;
                   First, Last  : POINTER;
                   Help1, Help2 : PElements;
                   ElementsFile : OFile;
                   CONSTRUCTOR Init(sFormel : STRING);
                   FUNCTION    InsertItem(Symbol : STRING; Anz : BYTE) : BOOLEAN;
                   PROCEDURE   FormelError(Msg : STRING);
                   PROCEDURE   Substance2Elements(Form : STRING; Anz : BYTE);
                   PROCEDURE   FillElementField;
                   PROCEDURE   ShowInfos;
                   PROCEDURE   CalcMasse;
                   DESTRUCTOR  Done;
                 END;

VAR ClassesFile, SubstancesFile : OFile;
    EditField      : ARRAY[1..9]OF OEditField;
    ComboField     : ARRAY[1..3]OF OComboField;
    Button         : ARRAY[1..9]OF OButton;

CONST NameChars   : CharSet = ['a'..'z','A'..'Z','0'..'9','[',']','(',')',',','.','-','/','*','é','ô','ö','Ñ','î','Å'];
      Substance   : PSubstanceRec = nil;
      Elements    : ^OElements = nil;
      SubstanceNr : WORD = 0;
      Const1      : BOOLEAN = FALSE;
      Const2      : BOOLEAN = FALSE;

{ -------------------------------------------------------------------------- }
CONSTRUCTOR OElements.Init(sFormel : STRING);
BEGIN
  Formel:=sFormel; First:=nil; Last:=nil;
  ElementsFile.Init('ELEMENTS.DAT');
  ElementsFile.ReadBlocks(0,118,SizeOf(TElementRec));
  Substance2Elements(Formel,1);
END;

FUNCTION OElements.InsertItem(Symbol : STRING; Anz : BYTE) : BOOLEAN;
VAR Nr : WORD;
BEGIN
  Help1:=First; if Length(Symbol)=1 then Symbol[2]:=#0;
  Nr:=ElementsFile.SearchString(32,2,Symbol[1]);
  if Nr=0 then begin InsertItem:=FALSE; exit; end else InsertItem:=TRUE;
  while Help1<>nil do begin
    if Help1^.Nr=Nr then begin inc(Help1^.Anz,Anz); exit; end;
    Help1:=Help1^.Right;
  end;
  new(Help1); Help2:=Last; Last:=Help1;
  if Help2=nil then First:=Help1 else Help2^.Right:=Help1;
  Help1^.Left := Help2;  Help1^.Right := nil;
  Help1^.Nr   := Nr;     Help1^.Anz   := Anz;
  Help1^.Dlg.Init(ElementsFile.GetblockNr(Nr));
END;

PROCEDURE OElements.FormelError(Msg : STRING);
VAR GrVars    : SaveGrVars;
    Dialog    : ODialog;
    EditField : OEditField;
    Button    : OButton;
BEGIN
  Dialog.Init(160,200,480,290,'Fehler in der Formel');
  GrVars.Save; HideMouseCursor;
  SetTextStyle(0,0,0); SetTextJustify(1,1); SetColor(0);
  OutTextXY(320,230,Msg);
  GrVars.Restore; ShowMouseCursor;
  EditField.Init(170,240,470,254);
  EditField.SetTexts('','');
  EditField.SetPetition(Formel,20,['a'..'z','A'..'Z','0'..'9','(',')']);
  Button.Init(280,260,360,280,'OK');
  repeat
    EditField.Run;
    if Dialog.HasPosChanged then begin
      Button.SetNewPos(Dialog.x+120,Dialog.y1-30,Dialog.x1-120,Dialog.y1-10);
      EditField.SetNewPos(Dialog.x+10,Dialog.y+40,Dialog.x1-10,Dialog.y+54);
    end;
  until (Dialog.Exit)or(Button.Pressed);
  Formel:=EditField.GetPetition; EditField.Done; Button.Done; Dialog.Done;
END;

PROCEDURE OElements.Substance2Elements(Form : STRING; Anz : BYTE);
VAR Pos, AnzByte, b : BYTE;
    Symbol          : STRING[2];
    AnzStr, s       : STRING;
    Err             : INTEGER;
BEGIN
  Pos:=1;
  while Pos<=Length(Form) do case Form[Pos] of
    'A'..'Z': begin
                Symbol:=Form[Pos]; AnzStr:='';
                if Pos<=Length(Form) then inc(Pos);
                if (pos<=Length(Form))and(Form[Pos]in['a'..'z']) then begin
                  Symbol:=Symbol+Form[Pos];
                  if Pos<=Length(Form) then inc(Pos);
                end;
                while (pos<=Length(Form))and(Form[Pos]in['0'..'9']) do begin
                  AnzStr:=AnzStr+Form[Pos]; inc(Pos);
                end;
                if AnzStr<>'' then val(AnzStr,AnzByte,Err)
                              else begin AnzByte:=1; Err:=0; end;
                if Err<>0 then begin
                  Str(Pos-1,AnzStr); FormelError('Fehler bei Position '+AnzStr);
                  Substance2Elements(Form,1); exit;
                end;
                if not InsertItem(Symbol,AnzByte*Anz) then begin
                  FormelError('unbekanntes Element '+Symbol);
                  Substance2Elements(Form,1); exit;
                end;
              end;
    '(': begin
           b:=1; s:=''; inc(pos);
           while b<>0 do begin
             if Form[pos]='(' then inc(b) else if Form[pos]=')' then dec(b);
             if b<>0 then s:=s+Form[pos];
             inc(pos);
           end;
           AnzStr:='';
           while (pos<=Length(Form))and(Form[Pos]in['0'..'9']) do begin
             AnzStr:=AnzStr+Form[Pos]; inc(Pos);
           end;
           if AnzStr<>'' then val(AnzStr,AnzByte,Err)
                         else begin AnzByte:=1; Err:=0; end;
           if Err<>0 then begin
             Str(Pos-1,AnzStr); FormelError('Fehler bei Position '+AnzStr);
             Substance2Elements(Form,1); exit;
           end;
           Substance2Elements(s,AnzByte*Anz);
         end;
    else begin
           Str(Pos,AnzStr); FormelError('Fehler bei Position '+AnzStr);
           Substance2Elements(Formel,1); exit;
         end;
  end;
END;

PROCEDURE OElements.FillElementField;
BEGIN
  Help1:=First;
  while Help1<>nil do begin
    ComboField[3].InsertString(Help1^.Dlg.Element^.Name);
    Help1:=Help1^.Right;
  end;
END;

PROCEDURE OElements.ShowInfos;
VAR s  : STRING;
    b  : BYTE;
    Nr : WORD;
BEGIN
  s:=ComboField[3].GetResult;
  if Length(s)<30 then for b:=Length(s)+1 to 30 do s[b]:=#0;
  Nr:=ElementsFile.SearchString(1,30,s[1]);
  if Nr=0 then exit;
  Help1:=First;
  while Help1<>nil do begin
    if Help1^.Nr=Nr then begin Help1^.Dlg.ShowInfoDialog; exit; end;
    Help1:=Help1^.Right;
  end;
END;

PROCEDURE OElements.CalcMasse;
VAR GrVars : SaveGrVars;
    y, w   : WORD;
    Mass   : REAL;
    s      : STRING;
BEGIN
  GrVars.Save; HideMouseCursor;
  SetFillStyle(1,7); Bar(0,251,640,480);
  SetTextStyle(0,0,0); SetTextJustify(0,2); SetColor(0);
  OutTextXY(10,258,'molare Masse:'); y:=258;
  Help1:=First; Mass:=0;
  while Help1<>nil do begin
    MoveTo(100,y);
    Str(Help1^.Anz:3,s); OutText(s+'*'+Help1^.Dlg.Element^.Name);
    if Length(Help1^.Dlg.Element^.Name)<30 then
      for w:=Length(Help1^.Dlg.Element^.Name)+1 to 30 do OutText('.');
    Str((Help1^.Dlg.Element^.Masse*Help1^.Anz):0:Genauigkeit,s);
    while Length(s)<Genauigkeit+4 do s:=' '+s; OutText(s+' g/mol');
    Mass:=Mass+(Help1^.Dlg.Element^.Masse*Help1^.Anz);
    inc(y,14); Help1:=Help1^.Right;
  end;
  Line(372,y-3,420+(Genauigkeit+5)*8,y-3);
  Str(Mass:0:Genauigkeit,s); while Length(s)<Genauigkeit+5 do s:=' '+s;
  OutTextXY(364,y+1,s+' g/mol');
  GrVars.Restore; ShowMouseCursor;
END;

DESTRUCTOR OElements.Done;
BEGIN
  Help1:=First;
  while Help1<>nil do begin Help2:=Help1^.Right; Dispose(Help1); Help1:=Help2; end;
  ElementsFile.Done(TRUE);
END;
{ -------------------------------------------------------------------------- }
PROCEDURE LoadSubstanceClasses;
VAR Nr        : WORD;
    TempClass : PSubstanceClass;
BEGIN
  ClassesFile.Init('CLASSES.DAT');
  ClassesFile.ReadBlocks(0,0,SizeOf(TSubstanceClass));
  Nr:=1; TempClass:=ClassesFile.GetBlockNr(1);
  while TempClass<>nil do begin
    ComboField[1].InsertString(TempClass^.Name);
    inc(Nr); TempClass:=ClassesFile.GetBlockNr(Nr);
  end;
END;

FUNCTION GetChoosenClassNr : WORD;
VAR s : STRING;
    b : BYTE;
BEGIN
  s:=ComboField[1].GetResult;
  if Length(s)<20 then for b:=Length(s)+1 to 20 do s[b]:=#0;
  GetChoosenClassNr:=ClassesFile.SearchString(2,20,s[1]);
END;

FUNCTION GetChoosenClassID : BYTE;
VAR Nr        : WORD;
    TempClass : PSubstanceClass;
BEGIN
  Nr:=GetChoosenClassNr; if Nr=0 then begin GetChoosenClassID:=0; exit; end;
  TempClass:=ClassesFile.GetBlockNr(Nr);
  GetChoosenClassID:=TempClass^.ID;
END;

PROCEDURE ChooseClassID(ID : BYTE);
VAR w, v      : WORD;
    s         : STRING;
    TempClass : PSubstanceClass;
BEGIN
  w:=1;
  repeat
    s:=ComboField[1].GetString(w); if s='' then exit;
    if Length(s)<20 then for v:=Length(s)+1 to 20 do s[v]:=#0;
    TempClass:=ClassesFile.GetBlockNr(ClassesFile.SearchString(2,20,s[1]));
    if (TempClass<>nil)and(TempClass^.ID=ID) then begin
      ComboField[1].SetChoose(w); exit;
    end else inc(w);
  until TempClass=nil;
END;

PROCEDURE FillClassConsts(FillOut : BOOLEAN);
VAR TempClass : PSubstanceClass;
    GrVars    : SaveGrVars;
    s         : STRING;
BEGIN
  GrVars.Save;
  TempClass:=ClassesFile.GetBlockNr(GetChoosenClassNr);
  SetFillStyle(1,7); Bar(0,189,640,217);
  SetTextStyle(0,0,0); SetTextJustify(0,1); SetColor(0);
  OutTextXY(10,196,'1.Konstante:');
  if Const1=TRUE then EditField[8].done;
  if (Substance=nil)or(TempClass=nil)or(TempClass^.Konst1='') then begin
    OutTextXY(114,196,'nicht angegeben');
    Const1:=FALSE;
  end else begin
    EditField[8].Init(114,189,630,203);
    EditField[8].SetTexts(TempClass^.Konst1+'=',TempClass^.Einh1);
    Const1:=TRUE;
    if FillOut then begin
      Str(Substance^.Konst1:0:Genauigkeit,s);
      EditField[8].SetPetition(s,20,['0'..'9','.','-']);
    end;
  end;
  OutTextXY(10,210,'2.Konstante:');
  if Const2=TRUE then EditField[9].done;
  if (Substance=nil)or(TempClass=nil)or(TempClass^.Konst2='') then begin
    OutTextXY(114,210,'nicht angegeben');
    Const2:=FALSE;
  end else begin
    EditField[9].Init(114,204,630,218);
    EditField[9].SetTexts(TempClass^.Konst2+'=',TempClass^.Einh2);
    Const2:=TRUE;
    if FillOut then begin
      Str(Substance^.Konst2:0:Genauigkeit,s);
      EditField[9].SetPetition(s,20,['0'..'9','.','-']);
    end;
  end;
  GrVars.Restore;
END;

PROCEDURE SetSubstanceClasses(Action : BYTE);
VAR Nr, w     : WORD;
    NewID     : BYTE;
    s         : STRING;
    Dialog    : ODialog;
    EditField : ARRAY[1..5]OF OEditField;
    Button    : ARRAY[1..2]OF OButton;
    TempClass : PSubstanceClass;
BEGIN
  case Action of
    1: begin
         Nr:=GetChoosenClassNr; if Nr=0 then exit;
         TempClass:=ClassesFile.GetBlockNr(Nr);
       end;
    2: begin
         NewID:=0;
         repeat
           inc(NewID); Nr:=1; TempClass:=ClassesFile.GetBlockNr(Nr);
           while TempClass<>nil do begin
             if TempClass^.ID=NewID then break;
             TempClass:=ClassesFile.GetBlockNr(Nr); inc(nr);
           end;
         until TempClass=nil;
         new(TempClass); FillChar(TempClass^,SizeOf(TSubstanceClass),0);
         TempClass^.ID:=NewID;
       end;
    3: begin
         Nr:=GetChoosenClassNr;
         ClassesFile.DelBlockNr(Nr);
         ClassesFile.Done(TRUE);
         ComboField[1].Done;
         ComboField[1].Init(10,81,310,95,3);
         ComboField[1].SetTexts('Stoffklasse:','');
         LoadSubstanceClasses;
         exit;
       end;
  end;
  if Action=1 then s:=TempClass^.Name else s:='neue Stoffklasse';
  Dialog.Init(160,205,480,297,s);
  EditField[1].Init(165,225,475,239);
  EditField[1].SetTexts('Name:','');
  EditField[1].SetPetition(TempClass^.Name,20,NameChars);
  EditField[2].Init(165,240,315,254);
  EditField[2].SetTexts('1.Konstante:','');
  EditField[2].SetPetition(TempClass^.Konst1,20,NameChars);
  EditField[3].Init(325,240,475,254);
  EditField[3].SetTexts('Einheit  :','');
  EditField[3].SetPetition(TempClass^.Einh1,20,NameChars);
  EditField[4].Init(165,255,315,269);
  EditField[4].SetTexts('2.Konstante:','');
  EditField[4].SetPetition(TempClass^.Konst2,20,NameChars);
  EditField[5].Init(325,255,475,269);
  EditField[5].SetTexts('Einheit  :','');
  EditField[5].SetPetition(TempClass^.Einh2,20,NameChars);
  Button[1].Init(170,275,315,290,'OK');
  Button[2].Init(325,275,470,290,'Abbrechen');
  repeat
    for w:=1 to 5 do EditField[w].run;
    if Button[1].Pressed then break;
    if Button[2].Pressed then begin
      if Action=2 then Dispose(TempClass);
      for w:=1 to 5 do EditField[w].done;
      for w:=1 to 2 do Button[w].done;
      Dialog.Done; exit;
    end;
    if Dialog.HasPosChanged then begin
      EditField[1].SetNewPos(Dialog.x+5,Dialog.y+20,Dialog.x1-5,Dialog.y+34);
      EditField[2].SetNewPos(Dialog.x+5,Dialog.y+35,Dialog.x+155,Dialog.y+49);
      EditField[3].SetNewPos(Dialog.x1-155,Dialog.y+35,Dialog.x1-5,Dialog.y+49);
      EditField[4].SetNewPos(Dialog.x+5,Dialog.y+50,Dialog.x+155,Dialog.y+64);
      EditField[5].SetNewPos(Dialog.x1-155,Dialog.y+50,Dialog.x1-5,Dialog.y+64);
      Button[1].SetNewPos(Dialog.x+10,Dialog.y+70,Dialog.x+155,Dialog.y+85);
      Button[2].SetNewPos(Dialog.x1-155,Dialog.y+70,Dialog.x1-10,Dialog.y+85);
    end;
  until Dialog.Exit;
  TempClass^.Name   := EditField[1].GetPetition;
  TempClass^.Konst1 := EditField[2].GetPetition;
  TempClass^.Einh1  := EditField[3].GetPetition;
  TempClass^.Konst2 := EditField[4].GetPetition;
  TempClass^.Einh2  := EditField[5].GetPetition;
  for w:=1 to 5 do EditField[w].done;
  for w:=1 to 2 do Button[w].done;
  Dialog.Done;
  if Action=2 then ClassesFile.InsertBlock(TempClass,SizeOf(TSubstanceClass));
  NewID:=TempClass^.ID;
  ClassesFile.Done(TRUE);
  ComboField[1].Done;
  ComboField[1].Init(10,81,310,95,3);
  ComboField[1].SetTexts('Stoffklasse:','');
  LoadSubstanceClasses; ChooseClassID(NewID); FillClassConsts(TRUE);
END;
{ -------------------------------------------------------------------------- }
PROCEDURE ClearFields;
VAR b      : BYTE;
    GrVars : SaveGrVars;
BEGIN
  GrVars.Save;
  EditField[1].SetPetition('',30,NameChars);
  EditField[2].SetPetition('',20,['a'..'z','A'..'Z','0'..'9','(',')']);
  for b:=3 to 7 do EditField[b].SetPetition('0',10,['0'..'9','.','-']);
  ComboField[2].SetChoose(1);
  ComboField[3].done;
  ComboField[3].Init(10,229,510,243,3);
  ComboField[3].SetTexts('Informationen zu den enthaltenen Elementen:','');
  SetFillStyle(1,7); Bar(0,251,640,480); Bar(0,189,640,217); SetColor(0);
  if Const1 then begin EditField[8].Done; Const1:=FALSE; end;
  if Const2 then begin EditField[9].Done; Const2:=FALSE; end;
  SetTextStyle(0,0,0); SetTextJustify(0,1); SetColor(0);
  OutTextXY(10,196,'1.Konstante: nicht angegeben');
  OutTextXY(10,210,'2.Konstante: nicht angegeben');
  GrVars.Restore;
END;

PROCEDURE FillFields;
VAR s : STRING;
BEGIN
  ClearFields; FillClassConsts(FALSE);
  if Substance=nil then exit;
  ComboField[3].done;
  ComboField[3].Init(10,229,510,243,3);
  ComboField[3].SetTexts('Informationen zu den enthaltenen Elementen:','');
  if Elements<>nil then Dispose(Elements,Done);
  New(Elements,Init(Substance^.Formel));
  Elements^.FillElementField;
  Elements^.CalcMasse;
  ComboField[3].SetTexts('Informationen zu den enthaltenen Elementen:','');
  EditField[1].SetPetition(Substance^.Name,30,NameChars);
  EditField[2].SetPetition(Substance^.Formel,20,['a'..'z','A'..'Z','0'..'9','(',')']);
  Str(Substance^.Schmelz:0:Genauigkeit,s);
  EditField[3].SetPetition(s,20,['0'..'9','.','-']);
  Str(Substance^.Siede:0:Genauigkeit,s);
  EditField[4].SetPetition(s,20,['0'..'9','.','-']);
  Str(Substance^.Dichte:0:Genauigkeit,s);
  EditField[5].SetPetition(s,20,['0'..'9','.','-']);
  Str(Substance^.SEnthalpie:0:Genauigkeit,s);
  EditField[6].SetPetition(s,20,['0'..'9','.','-']);
  Str(Substance^.SEntropie:0:Genauigkeit,s);
  EditField[7].SetPetition(s,20,['0'..'9','.','-']);
  ComboField[2].SetChoose(Substance^.Aggregat);
  ChooseClassID(Substance^.Stoffklasse);
  FillClassConsts(TRUE);
END;

PROCEDURE ReadFields;
VAR s : STRING;
    i : INTEGER;
    r : REAL;
BEGIN
  if Substance=nil then begin ClearFields; exit; end;
  Substance^.Name        := EditField[1].GetPetition;
  Substance^.Formel      := EditField[2].GetPetition;
  Substance^.Aggregat    := ComboField[2].GetAktChoose;
  Substance^.Stoffklasse := GetChoosenClassID;
  s:=EditField[3].GetPetition; val(s,r,i); if i=0 then Substance^.Schmelz   :=r;
  s:=EditField[4].GetPetition; val(s,r,i); if i=0 then Substance^.Siede     :=r;
  s:=EditField[5].GetPetition; val(s,r,i); if i=0 then Substance^.Dichte    :=r;
  s:=EditField[6].GetPetition; val(s,r,i); if i=0 then Substance^.SEnthalpie:=r;
  s:=EditField[7].GetPetition; val(s,r,i); if i=0 then Substance^.SEntropie :=r;
  if Const1 then begin
    s:=EditField[8].GetPetition; val(s,r,i); if i=0 then Substance^.Konst1 :=r;
  end;
  if Const2 then begin
    s:=EditField[9].GetPetition; val(s,r,i); if i=0 then Substance^.Konst2 :=r;
  end;
END;

PROCEDURE SetSubstance(Action : BYTE);
VAR GrVars       : SaveGrVars;
    Dialog       : ODialog;
    Button       : ARRAY[1..2]OF OButton;
    SearchString : STRING;
    Offset, Len  : BYTE;
    Nr           : WORD;
BEGIN
  case Action of
    1: begin Offset:= 1; Len:=30; end;
    2: begin Offset:=32; Len:=20; end;
    3: begin if Substance<>nil then FillFields else ClearFields; exit; end;
    4: if Substance<>nil then begin
         ReadFields; Nr:=SubstancesFile.SearchString(0,SizeOf(TSubstanceRec),Substance^);
         SubstancesFile.Done(TRUE);
         SubstancesFile.Init('SUBSTANC.DAT');
         SubstancesFile.ReadBlocks(0,0,SizeOf(TSubstanceRec));
         Substance:=SubstancesFile.GetBlockNr(Nr); FillFields;
         exit;
       end else exit;
    5: if Substance<>nil then begin
         SubstancesFile.DelBlockNr(SubstanceNr);
         SubstancesFile.Done(TRUE);
         SubstancesFile.Init('SUBSTANC.DAT');
         SubstancesFile.ReadBlocks(0,0,SizeOf(TSubstanceRec));
         ClearFields; Substance:=nil; SubstanceNr:=0; exit;
       end else exit;
    else exit;
  end;
  SearchString:=EditField[Action].GetPetition; if SearchString='' then exit;
  if Length(SearchString)<>Len then
    for Nr:=Length(SearchString)+1 to Len do SearchString[Nr]:=#0;
  Nr:=SubstancesFile.SearchString(Offset,Len,SearchString[1]);
  if Nr=0 then begin
    Dialog.Init(190,200,450,300,'Frage');
    GrVars.Save; HideMouseCursor;
    SetTextStyle(0,0,0); SetTextJustify(1,1); SetColor(0);
    OutTextXY(320,230,'Ein Objekt mit der Bezeichnung');
    OutTextXY(320,244,''''+SearchString+'''');
    OutTextXY(320,258,'existiert nicht. Neu erstellen?');
    Button[1].Init(200,270,315,290,'Ja');
    Button[2].Init(325,270,440,290,'Nein');
    GrVars.Restore; ShowMouseCursor;
    repeat
      if Dialog.HasPosChanged then begin
        Button[1].SetNewPos(Dialog.x +10,Dialog.y1-30,Dialog.x +125,Dialog.y1-10);
        Button[2].SetNewPos(Dialog.x1-125,Dialog.y1-30,Dialog.x1-10,Dialog.y1-10);
      end;
      if Button[1].Pressed then break;
      if (Button[2].Pressed)or(Dialog.Exit) then begin
        Button[1].done; Button[2].done; Dialog.Done; FillFields; exit;
      end;
    until false;
    Button[1].done; Button[2].done; Dialog.Done;
    New(Substance); FillChar(Substance^,SizeOf(TSubstanceRec),0);
    case Action of
      1: Substance^.Name   := SearchString;
      2: Substance^.Formel := SearchString;
    end;
    SubstancesFile.InsertBlock(Substance,SizeOf(TSubstanceRec));
    SetSubstance(Action); exit;
  end else SubstanceNr:=Nr;
  Substance:=SubstancesFile.GetBlockNr(Nr);
  FillFields;
END;
{ -------------------------------------------------------------------------- }
PROCEDURE RunInfos;
VAR GrVars : SaveGrVars;
    b      : BYTE;
LABEL Anfang;
BEGIN
  SubstancesFile.Init('SUBSTANC.DAT');
  SubstancesFile.ReadBlocks(0,0,SizeOf(TSubstanceRec));
  InitGraph16; GrVars.Save;
  SetFillStyle(1,7); Bar(0,0,640,480);
  SetTextStyle(0,0,2); SetTextJustify(1,1);
  SetColor(15); OutTextXY(320,20,'chemische Verbindungen');
  SetColor(01); OutTextXY(322,22,'chemische Verbindungen');
  SetColor(09); OutTextXY(321,21,'chemische Verbindungen');
  SetTextStyle(0,0,0); SetTextJustify(0,1); SetColor(0);
  EditField[1].Init(10,40,310,54);
  EditField[1].SetTexts('Name  :','');
  EditField[2].Init(10,55,310,69);
  EditField[2].SetTexts('Formel:','');
  EditField[2].ZahlenTiefGesetzt:=TRUE;
  Button[1].Init(320,40,419,54,'Name laden');
  Button[2].Init(320,55,419,69,'Formel laden');
  Button[3].Init(420,40,519,54,'ZurÅcksetzen');
  Button[4].Init(420,55,519,69,'Speichern');
  Button[5].Init(520,40,619,69,'Eintrag lîschen');
  Line3D(1,75,639,75,TRUE);
  ComboField[1].Init(10,81,310,95,3);
  ComboField[1].SetTexts('Stoffklasse:','');
  LoadSubstanceClasses;
  Button[6].Init(320,81,419,95,'Bearbeiten');
  Button[7].Init(420,81,519,95,'HinzufÅgen');
  Button[8].Init(520,81,619,95,'Lîschen');
  Line3D(1,101,639,101,TRUE);
  EditField[3].Init(10,107,310,121);
  EditField[3].SetTexts('Schmelztemperatur:','¯C');
  EditField[4].Init(10,122,310,136);
  EditField[4].SetTexts('Siedetemperatur  :','¯C');
  EditField[5].Init(320,107,620,121);
  EditField[5].SetTexts('Dichte         :','g/cm^3');
  ComboField[2].Init(320,122,620,136,3);
  ComboField[2].SetTexts('Aggregatzustand:','');
  ComboField[2].InsertString('fest[solid]');
  ComboField[2].InsertString('flÅssig[liquid]');
  ComboField[2].InsertString('gasfîrmig');
  Line3D(1,142,639,142,TRUE);
  EditField[6].Init(10,148,620,162);
  EditField[6].SetTexts('Standart-Bildungsenthalpie:','kJ/mol');
  EditField[7].Init(10,163,620,177);
  EditField[7].SetTexts('Standart-Entropie         :','J/mol*K');
  Line3D(1,183,639,183,TRUE); SetColor(0);
  OutTextXY(10,196,'1.Konstante: nicht angegeben');
  OutTextXY(10,210,'2.Konstante: nicht angegeben');
  Line3D(1,223,639,223,TRUE);
  ComboField[3].Init(10,229,510,243,3);
  ComboField[3].SetTexts('Informationen zu den enthaltenen Elementen:','');
  Button[9].Init(520,229,619,243,'Anzeigen');
  Line3D(1,249,639,249,TRUE);
  ClearFields; GrVars.Restore; ShowMouseCursor;
  Repeat
    Anfang:
    if ComboField[1].run then FillClassConsts(TRUE);
    if ComboField[1].List then goto Anfang;
    for b:=2 to 3 do begin
      ComboField[b].run;
      if ComboField[b].List then goto Anfang;
    end;
    for b:=1 to 7 do EditField[b].Run;
    if Const1 then EditField[8].Run;
    if Const2 then EditField[9].Run;
    for b:=1 to 5 do if Button[b].Pressed then SetSubstance(b);
    for b:=6 to 8 do if Button[b].Pressed then SetSubstanceClasses(b-5);
    if (Elements<>nil)and(Button[9].Pressed) then begin
      Elements^.ShowInfos; Elements^.CalcMasse;
    end;
  Until (KeyPressed)and(ReadKey=#27);
  for b:=1 to 3 do ComboField[b].Done;
  for b:=1 to 7 do EditField[b].Done;
  for b:=1 to 9 do Button[b].Done;
  if Const1 then EditField[8].Done;
  if Const2 then EditField[9].Done;
  SubstancesFile.Done(TRUE); ClassesFile.Done(TRUE); CloseGraph;
END;

END.