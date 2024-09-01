UNIT Tabellen; INTERFACE
USES Crt, Graph, Graphics, Mouse, Controls, ReadFile, Elemente, Infos, Logo;

PROCEDURE RunTabElements;
PROCEDURE RunTabSubstances;

IMPLEMENTATION

VAR ListField  : OListField;
    Substances : OFile;

{ -------------------------------------------------------------------------- }
PROCEDURE FillElementsField;
VAR w       : WORD;
    Element : PElementRec;
    s       : STRING;
BEGIN
  for w:=1 to 118 do begin
    Element:=Substances.GetBlockNr(w);
    ListField.SetText(1,w,Element^.Name);
    ListField.SetText(2,w,Element^.Symbol);
    Str(Element^.Ordnungszahl,s); ListField.SetText(3,w,s);
    Str(Element^.eNeg:0:Genauigkeit,s);         ListField.SetText(4,w,s);
    Str(Element^.Masse:0:Genauigkeit,s);        ListField.SetText(5,w,s);
    Str(Element^.Dichte:0:Genauigkeit,s);       ListField.SetText(6,w,s);
    Str(Element^.Schmelz:0:Genauigkeit,s);      ListField.SetText(7,w,s);
    Str(Element^.Siede:0:Genauigkeit,s);        ListField.SetText(8,w,s);
  end;
END;

PROCEDURE SaveElementsField;
VAR w       : WORD;
    Element : PElementRec;
    r       : REAL;
    Err     : INTEGER;
BEGIN
  for w:=1 to 118 do begin
    Element:=Substances.GetBlockNr(w);
    Element^.Name   := ListField.GetText(1,w);
    Element^.Symbol := ListField.GetText(2,w);
    val(ListField.GetText(4,w),r,Err); if Err=0 then Element^.eNeg    := r;
    val(ListField.GetText(5,w),r,Err); if Err=0 then Element^.Masse   := r;
    val(ListField.GetText(6,w),r,Err); if Err=0 then Element^.Dichte  := r;
    val(ListField.GetText(7,w),r,Err); if Err=0 then Element^.Schmelz := r;
    val(ListField.GetText(8,w),r,Err); if Err=0 then Element^.Siede   := r;
  end;
END;

PROCEDURE RunTabElements;
VAR GrVars : SaveGrVars;
BEGIN
  Substances.Init('ELEMENTS.DAT');
  Substances.ReadBlocks(0,118,SizeOf(TElementRec));
  InitGraph16; GrVars.Save;
  SetFillStyle(1,7); Bar(0,0,640,480);
  SetTextStyle(0,0,2); SetTextJustify(1,1);
  SetColor(15); OutTextXY(320,20,'Tabelle zu allen bekannten Elementen');
  SetColor(01); OutTextXY(322,22,'Tabelle zu allen bekannten Elementen');
  SetColor(09); OutTextXY(321,21,'Tabelle zu allen bekannten Elementen');
  SetTextStyle(0,0,0); SetTextJustify(0,1); SetColor(0);
  GrVars.Restore; ShowMouseCursor;
  ListField.Init(10,40,28);
  ListField.NewColumn('Name',30,130,['a'..'z','A'..'Z'],FALSE,FALSE);
  ListField.NewColumn('Symbol',2,34,['a'..'z','A'..'Z'],FALSE,FALSE);
  ListField.NewColumn('Ordnungszahl',3,42,['0'..'9'],TRUE,FALSE);
  ListField.NewColumn('ElektronegativitÑt',10,74,['-','0'..'9','.'],FALSE,FALSE);
  ListField.NewColumn('rel. Masse',10,79,['-','0'..'9','.'],FALSE,FALSE);
  ListField.NewColumn('Dichte',10,79,['-','0'..'9','.'],FALSE,FALSE);
  ListField.NewColumn('Schmelztemperatur',10,79,['-','0'..'9','.'],FALSE,FALSE);
  ListField.NewColumn('Siedetemperatur',10,79,['-','0'..'9','.'],FALSE,FALSE);
  FillElementsField;
  ListField.DrawField;
  repeat
    ListField.Run;
  until (KeyPressed)and(ReadKey=#27);
  SaveElementsField;
  ListField.Done;
  Substances.Done(TRUE);
  closegraph;
END;
{ -------------------------------------------------------------------------- }
PROCEDURE FillSubstancesField;
VAR w         : WORD;
    Substance : PSubstanceRec;
    s         : STRING;
BEGIN
  w:=1; Substance:=Substances.GetBlockNr(w);
  while Substance<>nil do begin
    ListField.SetText(1,w,Substance^.Name);
    ListField.SetText(2,w,Substance^.Formel);
    Str(Substance^.Dichte:0:Genauigkeit,s);     ListField.SetText(3,w,s);
    Str(Substance^.Schmelz:0:Genauigkeit,s);    ListField.SetText(4,w,s);
    Str(Substance^.Siede:0:Genauigkeit,s);      ListField.SetText(5,w,s);
    Str(Substance^.SEnthalpie:0:Genauigkeit,s); ListField.SetText(6,w,s);
    Str(Substance^.SEntropie:0:Genauigkeit,s);  ListField.SetText(7,w,s);
    inc(w); Substance:=Substances.GetBlockNr(w);
  end;
END;

PROCEDURE SaveSubstancesField;
VAR w         : WORD;
    Substance : PSubstanceRec;
    r         : REAL;
    Err       : INTEGER;
BEGIN
  w:=1; Substance:=Substances.GetBlockNr(w);
  while Substance<>nil do begin
    Substance^.Name   := ListField.GetText(1,w);
    Substance^.Formel := ListField.GetText(2,w);
    val(ListField.GetText(3,w),r,Err); if Err=0 then Substance^.Dichte     :=r;
    val(ListField.GetText(4,w),r,Err); if Err=0 then Substance^.Schmelz    :=r;
    val(ListField.GetText(5,w),r,Err); if Err=0 then Substance^.Siede      :=r;
    val(ListField.GetText(6,w),r,Err); if Err=0 then Substance^.SEnthalpie :=r;
    val(ListField.GetText(7,w),r,Err); if Err=0 then Substance^.SEntropie  :=r;
    inc(w); Substance:=Substances.GetBlockNr(w);
  end;
END;

PROCEDURE RunTabSubstances;
VAR GrVars : SaveGrVars;
BEGIN
  Substances.Init('SUBSTANC.DAT');
  Substances.ReadBlocks(0,0,SizeOf(TSubstanceRec));
  InitGraph16; GrVars.Save;
  SetFillStyle(1,7); Bar(0,0,640,480);
  SetTextStyle(0,0,2); SetTextJustify(1,1);
  SetColor(15); OutTextXY(320,20,'Tabelle zu allen bekannten Verbindungen');
  SetColor(01); OutTextXY(322,22,'Tabelle zu allen bekannten Verbindungen');
  SetColor(09); OutTextXY(321,21,'Tabelle zu allen bekannten Verbindungen');
  SetTextStyle(0,0,0); SetTextJustify(0,1); SetColor(0);
  GrVars.Restore; ShowMouseCursor;
  ListField.Init(10,40,28);
  ListField.NewColumn('Name',30,130,['a'..'z','A'..'Z','0'..'9','[',']','(',')',',','.','-','/','*','é','ô','ö','Ñ','î','Å'],
                      FALSE,FALSE);
  ListField.NewColumn('Formel',20,70,['a'..'z','A'..'Z','0'..'9','(',')'],FALSE,TRUE);
  ListField.NewColumn('Dichte',10,79,['-','0'..'9','.'],FALSE,FALSE);
  ListField.NewColumn('Schmelztemperatur',10,79,['-','0'..'9','.'],FALSE,FALSE);
  ListField.NewColumn('Siedetemperatur',10,79,['-','0'..'9','.'],FALSE,FALSE);
  ListField.NewColumn('Bildungs-Enthalpie',10,79,['-','0'..'9','.'],FALSE,FALSE);
  ListField.NewColumn('Entropie',10,79,['-','0'..'9','.'],FALSE,FALSE);
  FillSubstancesField;
  ListField.DrawField;
  repeat
    ListField.Run;
  until (KeyPressed)and(ReadKey=#27);
  SaveSubstancesField;
  ListField.Done;
  Substances.Done(TRUE);
  closegraph;
END;
{ -------------------------------------------------------------------------- }
END.