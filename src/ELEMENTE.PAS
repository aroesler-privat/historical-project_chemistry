UNIT Elemente; INTERFACE USES Crt, Graph, Graphics, Mouse, Controls, Logo;

CONST Genauigkeit = 5;

      AggregatMask: WORD =    24; { 00000000 00011000 Bin }
      MetallMask  : WORD =    96; { 00000000 01100000 Bin }

      NebenGruppe : WORD = 16384; { 01000000 00000000 Bin }
      Fest        : WORD =     8; { 00000000 00001000 Bin }
      Fluessig    : WORD =    16; { 00000000 00010000 Bin }
      Gas         : WORD =     0; { 00000000 00000000 Bin }
      Metall      : WORD =    32; { 00000000 00100000 Bin }
      HalbMetall  : WORD =    64; { 00000000 01000000 Bin }
      NichtMetall : WORD =     0; { 00000000 00000000 Bin }
      RadioAktiv  : WORD =   128; { 00000000 10000000 Bin }

TYPE PElementRec = ^TElementRec;
     TElementRec = RECORD
                     Name                : string[30];
                     Symbol              : string[2];
                     Ordnungszahl        : BYTE;
                     Schmelz, Siede      : REAL;
                     eNeg, Masse, Dichte : REAL;
                     Eigenschaften       : WORD;
                   END;
     ElementInfos = OBJECT
                      Element           : PElementRec;
                      Orbitale          : ARRAY[1..7,1..4]OF BYTE;
                      AussenEl, Schalen : BYTE;
                      Lines             : WORD;
                      CONSTRUCTOR Init(ElementData : PElementRec);
                      PROCEDURE   ShowEnergieNiveauSchema;
                      PROCEDURE   ShowInfoDialog;
                      DESTRUCTOR  Done;
                  END;

IMPLEMENTATION

CONSTRUCTOR ElementInfos.Init(ElementData : PElementRec);
VAR n, l, el : BYTE;
BEGIN
  Element:=ElementData; Lines:=0;
  el:=Element^.Ordnungszahl; Schalen:=0; n:=1; l:=1;
  repeat
    if n>Schalen then Schalen:=n;
    case l of
      1: if el>= 2 then begin Orbitale[n,l]:=2; dec(el,2); end
                   else begin Orbitale[n,l]:=el; el:=0; end;
      2: if el>= 6 then begin Orbitale[n,l]:=6; dec(el,6); end
                   else begin Orbitale[n,l]:=el; el:=0; end;
      3: if el>=10 then begin Orbitale[n,l]:=10; dec(el,10); end
                   else begin Orbitale[n,l]:=el; el:=0; end;
      4: if el>=14 then begin Orbitale[n,l]:=14; dec(el,14); end
                   else begin Orbitale[n,l]:=el; el:=0; end;
    end;
    if n=Schalen then AussenEl:=Orbitale[n,l];
    inc(Lines,10); if el=0 then break;
    if (n=1) then n:=2 else
    if (n=2)and(l=1) then l:=2 else
    if (n=2)and(l=2) then begin n:=3; l:=1; end else
    if (n=3)and(l=1) then l:=2 else
    if (n=3)and(l=2) then begin n:=4; l:=1; end else
    if (n=4)and(l=1) then begin n:=3; l:=3; end else
    if (n=3)and(l=3) then begin n:=4; l:=2; end else
    if (n=4)and(l=2) then begin n:=5; l:=1; end else
    if (n=5)and(l=1) then begin n:=4; l:=3; end else
    if (n=4)and(l=3) then begin n:=5; l:=2; end else
    if (n=5)and(l=2) then begin n:=6; l:=1; end else
    if (n=6)and(l=1) then begin n:=4; l:=4; end else
    if (n=4)and(l=4) then begin n:=5; l:=3; end else
    if (n=5)and(l=3) then begin n:=6; l:=2; end else
    if (n=6)and(l=2) then begin n:=7; l:=1; end else
    if (n=7)and(l=1) then begin n:=5; l:=4; end else
    if (n=5)and(l=4) then begin n:=6; l:=3; end else
    if (n=6)and(l=3) then begin n:=7; l:=2; end else
    if (n=7)and(l=2) then begin n:=6; l:=4; end else
    if (n=6)and(l=4) then begin n:=7; l:=3; end;
  until false;
  case Schalen of
    1: if Lines< 10 then Lines:= 10;    2: if Lines< 35 then Lines:= 35;
    3: if Lines< 60 then Lines:= 60;    4: if Lines< 95 then Lines:= 95;
    5: if Lines<125 then Lines:=125;    6: if Lines<165 then Lines:=165;
    7: if Lines<200 then Lines:=200;
  end;
END;

PROCEDURE ElementInfos.ShowEnergieNiveauSchema;
VAR GrVars : SaveGrVars;
    Dialog : ODialog;
    n, l   : BYTE;
    s      : STRING;
    y, el  : INTEGER;

  PROCEDURE DrawArrows;
  VAR xPos : WORD;
      b    : BYTE;
  BEGIN
    xPos:=Dialog.x+105-WORD(Orbitale[n,l])*5;
    for b:=1 to Orbitale[n,l] do begin
      Line(xPos,y-4,xPos,y+4);
      if b mod 2 = 0 then begin
        Line(xPos-1,y-3,xPos+1,y-3);
        Line(xPos-2,y-2,xPos+2,y-2);
      end else begin
        Line(xPos-1,y+3,xPos+1,y+3);
        Line(xPos-2,y+2,xPos+2,y+2);
      end;
      inc(xPos,10);
    end;
  END;

BEGIN
  Dialog.Init(220,120,420,150+Lines,'Energieniveauschema');
  GrVars.Save; HideMouseCursor;
  SetTextJustify(0,1);
  n:=1; l:=1; y:=Dialog.y+20+Lines; el:=Element^.Ordnungszahl;
  repeat
    case n of
      1: begin
           SetColor(6);
           Line(Dialog.x+5,y,Dialog.x+20,y);
           OutTextXY(Dialog.x+5,y-5,'1');
         end;
      2: begin
           SetColor(1);
           Line(Dialog.x+5,125+Lines,Dialog.x+13,125+Lines);
           OutTextXY(Dialog.x+5,120+Lines,'2');
           Line(Dialog.x+13,125+Lines,Dialog.x+20,y);
         end;
      3: begin
           SetColor(14);
           Line(Dialog.x+5,100+Lines,Dialog.x+13,100+Lines);
           OutTextXY(Dialog.x+5,95+Lines,'3');
           Line(Dialog.x+13,100+Lines,Dialog.x+20,y);
         end;
      4: begin
           SetColor(2);
           Line(Dialog.x+5,75+Lines,Dialog.x+13,75+Lines);
           OutTextXY(Dialog.x+5,70+Lines,'4');
           Line(Dialog.x+13,75+Lines,Dialog.x+20,y);
         end;
      5: begin
           SetColor(5);
           Line(Dialog.x+5,35+Lines,Dialog.x+13,35+Lines);
           OutTextXY(Dialog.x+5,30+Lines,'5');
           Line(Dialog.x+13,35+Lines,Dialog.x+20,y);
         end;
      6: begin
           SetColor(8);
           Line(Dialog.x+5,-5+Lines,Dialog.x+13,-5+Lines);
           OutTextXY(Dialog.x+5,-10+Lines,'6');
           Line(Dialog.x+13,-5+Lines,Dialog.x+20,y);
         end;
      7: begin
           SetColor(9);
           Line(Dialog.x+5,-40+Lines,Dialog.x+13,-40+Lines);
           OutTextXY(Dialog.x+5,-45+Lines,'7');
           Line(Dialog.x+13,-40+Lines,Dialog.x+20,y);
         end;
    end;
    Line(Dialog.x+20,y,Dialog.x1-20,y);
    case l of
      1: begin str(n,s); OutTextXY(Dialog.x1-19,y,s+'s'); dec(el,2); end;
      2: begin str(n,s); OutTextXY(Dialog.x1-19,y,s+'p'); dec(el,6); end;
      3: begin str(n,s); OutTextXY(Dialog.x1-19,y,s+'d'); dec(el,10); end;
      4: begin str(n,s); OutTextXY(Dialog.x1-19,y,s+'f'); dec(el,14); end;
    end;
    DrawArrows; dec(y,10);
    if (n=1) then n:=2 else
    if (n=2)and(l=1) then l:=2 else
    if (n=2)and(l=2) then begin n:=3; l:=1; end else
    if (n=3)and(l=1) then l:=2 else
    if (n=3)and(l=2) then begin n:=4; l:=1; end else
    if (n=4)and(l=1) then begin n:=3; l:=3; end else
    if (n=3)and(l=3) then begin n:=4; l:=2; end else
    if (n=4)and(l=2) then begin n:=5; l:=1; end else
    if (n=5)and(l=1) then begin n:=4; l:=3; end else
    if (n=4)and(l=3) then begin n:=5; l:=2; end else
    if (n=5)and(l=2) then begin n:=6; l:=1; end else
    if (n=6)and(l=1) then begin n:=4; l:=4; end else
    if (n=4)and(l=4) then begin n:=5; l:=3; end else
    if (n=5)and(l=3) then begin n:=6; l:=2; end else
    if (n=6)and(l=2) then begin n:=7; l:=1; end else
    if (n=7)and(l=1) then begin n:=5; l:=4; end else
    if (n=5)and(l=4) then begin n:=6; l:=3; end else
    if (n=6)and(l=3) then begin n:=7; l:=2; end else
    if (n=7)and(l=2) then begin n:=6; l:=4; end else
    if (n=6)and(l=4) then begin n:=7; l:=3; end;
  until el<=0;
  GrVars.Restore; ShowMouseCursor;
  repeat until Dialog.Exit;
  if keypressed then readkey;
  Dialog.Done;
END;

PROCEDURE ElementInfos.ShowInfoDialog;
VAR Dialog     : ODialog;
    Button     : ARRAY[1..2]OF OButton;
    EditField  : ARRAY[1..7]OF OEditField;
    ComboField : ARRAY[1..2]OF OComboField;
    GrVars     : SaveGrVars;
    s          : STRING;
    b          : BYTE;
    r          : REAL;
    i          : INTEGER;
LABEL Weiter;
BEGIN
  Dialog.Init(160,120,480,348,Element^.Name);
  GrVars.Save; HideMouseCursor; SetTextJustify(0,1); SetColor(0);
  Str(Element^.Ordnungszahl,s); MoveTo(164,149); OutText('Ordnungszahl: '+s);
  if (Element^.Eigenschaften and Nebengruppe)=0 then
    OutText(' [Hauptgruppe]') else OutText(' [Nebengruppe]');
  Line3D(164,156,475,156,TRUE); SetColor(0);
  OutTextXY(164,166,'Anzahl der Elektronen/Protonen: '+s);
  Str(Orbitale[Schalen,1]+Orbitale[Schalen,2]+Orbitale[Schalen,3]+Orbitale[Schalen,4],s);
  OutTextXY(164,180,'Anzahl der Auáenelektronen    : '+s);
  Str(Schalen,s);
  OutTextXY(164,194,'Anzahl der Energieniveaus     : '+s);
  Line3D(164,202,475,202,TRUE); SetColor(0);
  EditField[1].Init(164,205,255,219);
  EditField[1].SetTexts('Symbol:','');
  EditField[1].SetPetition(Element^.Symbol,2,['a'..'z','A'..'Z']);
  EditField[2].Init(260,205,475,219);
  EditField[2].SetTexts('Name:','');
  EditField[2].SetPetition(Element^.Name,20,['a'..'z','A'..'Z']);
  EditField[3].Init(164,220,475,234);
  EditField[3].SetTexts('Schmelztemperatur :','øC');
  str(Element^.Schmelz:0:Genauigkeit,s);
  EditField[3].SetPetition(s,20,['0'..'9','.','-']);
  EditField[4].Init(164,235,475,249);
  EditField[4].SetTexts('Siedetemperatur   :','øC');
  str(Element^.Siede:0:Genauigkeit,s);
  EditField[4].SetPetition(s,20,['0'..'9','.','-']);
  EditField[5].Init(164,250,475,264);
  EditField[5].SetTexts('Dichte (23øC)     :','g/cm^3');
  str(Element^.Dichte:0:Genauigkeit,s);
  EditField[5].SetPetition(s,20,['0'..'9','.','-']);
  EditField[6].Init(164,265,475,279);
  EditField[6].SetTexts('relative Atommasse:','u');
  str(Element^.Masse:0:Genauigkeit,s);
  EditField[6].SetPetition(s,20,['0'..'9','.','-']);
  EditField[7].Init(164,280,475,294);
  EditField[7].SetTexts('Elektronegativit„t:','');
  str(Element^.eNeg:0:Genauigkeit,s);
  EditField[7].SetPetition(s,20,['0'..'9','.','-']);
  ComboField[1].Init(164,295,475,309,3);
  ComboField[1].InsertString('fest');
  ComboField[1].InsertString('flssig');
  ComboField[1].InsertString('gasf”rmig');
  ComboField[1].SetTexts('Aggregatzustand   :','');
  ComboField[1].SetAvaibleChars(['a'..'z','A'..'Z']);
  if Element^.Eigenschaften and Fest = Fest then ComboField[1].SetChoose(1) else
    if Element^.Eigenschaften and Fluessig = Fluessig then ComboField[1].SetChoose(2) else
      ComboField[1].SetChoose(3);
  ComboField[2].Init(164,310,475,324,3);
  ComboField[2].InsertString('Halbmetall');
  ComboField[2].InsertString('Metall');
  ComboField[2].InsertString('Nichtmetall');
  ComboField[2].SetTexts('Metall/Nichtmetall:','');
  ComboField[2].SetAvaibleChars(['a'..'z','A'..'Z']);
  if Element^.Eigenschaften and Metall     = Metall     then ComboField[2].SetChoose(2) else
    if Element^.Eigenschaften and Halbmetall = Halbmetall then ComboField[2].SetChoose(1) else
      ComboField[2].SetChoose(3);
  Line3D(164,326,475,326,TRUE); SetColor(0);
  Button[1].Init(165,330,335,345,'Energieniveauschema');
  Button[2].Init(345,330,475,345,'Zurck');
  GrVars.Restore; ShowMouseCursor;
  Weiter:
  repeat
    if Dialog.HasPosChanged then begin
      EditField[1].SetNewPos(Dialog.x+4,Dialog.y+85,Dialog.x1-225,Dialog.y+99);
      EditField[2].SetNewPos(Dialog.x+100,Dialog.y+85,Dialog.x1-5,Dialog.y+99);
      EditField[3].SetNewPos(Dialog.x+4,Dialog.y+100,Dialog.x1-5,Dialog.y+114);
      EditField[4].SetNewPos(Dialog.x+4,Dialog.y+115,Dialog.x1-5,Dialog.y+129);
      EditField[5].SetNewPos(Dialog.x+4,Dialog.y+130,Dialog.x1-5,Dialog.y+144);
      EditField[6].SetNewPos(Dialog.x+4,Dialog.y+145,Dialog.x1-5,Dialog.y+159);
      EditField[7].SetNewPos(Dialog.x+4,Dialog.y+160,Dialog.x1-5,Dialog.y+174);
      ComboField[1].SetNewPos(Dialog.x+4,Dialog.y+175,Dialog.x1-5,Dialog.y+189);
      ComboField[2].SetNewPos(Dialog.x+4,Dialog.y+190,Dialog.x1-5,Dialog.y+204);
      Button[1].SetNewPos(Dialog.x+5,Dialog.y+210,Dialog.x1-145,Dialog.y+225);
      Button[2].SetNewPos(Dialog.x1-135,Dialog.y+210,Dialog.x1-5,Dialog.y+225);
    end;
    for b:=1 to 7 do EditField[b].Run;
    ComboField[1].Run; if ComboField[1].List then goto Weiter;
    ComboField[2].Run; if ComboField[2].List then goto Weiter;
    if Button[1].Pressed then ShowEnergieniveauschema;
    if Button[2].Pressed then break;
  until Dialog.Exit;
  for b:=1 to 2 do Button[b].Done;
  Element^.Symbol := EditField[1].GetPetition;
  Element^.Name   := EditField[2].GetPetition;
  s:=EditField[3].GetPetition; val(s,r,i); if i=0 then Element^.Schmelz:=r;
  s:=EditField[4].GetPetition; val(s,r,i); if i=0 then Element^.Siede:=r;
  s:=EditField[5].GetPetition; val(s,r,i); if i=0 then Element^.Dichte:=r;
  s:=EditField[6].GetPetition; val(s,r,i); if i=0 then Element^.Masse:=r;
  s:=EditField[7].GetPetition; val(s,r,i); if i=0 then Element^.eNeg:=r;
  for b:=1 to 7 do EditField[b].Done;
  Element^.Eigenschaften:=Element^.Eigenschaften and (65535-AggregatMask);
  case ComboField[1].GetAktChoose of
    1: Element^.Eigenschaften:=Element^.Eigenschaften or Fest;
    2: Element^.Eigenschaften:=Element^.Eigenschaften or Fluessig;
    3: Element^.Eigenschaften:=Element^.Eigenschaften or Gas;
  end;
  Element^.Eigenschaften:=Element^.Eigenschaften and (65535-MetallMask);
  case ComboField[2].GetAktChoose of
    1: Element^.Eigenschaften:=Element^.Eigenschaften or HalbMetall;
    2: Element^.Eigenschaften:=Element^.Eigenschaften or Metall;
    3: Element^.Eigenschaften:=Element^.Eigenschaften or NichtMetall;
  end;
  for b:=1 to 2 do ComboField[b].Done;
  if keypressed then readkey;
  Dialog.Done;
END;

DESTRUCTOR ElementInfos.Done;
BEGIN
END;

END.