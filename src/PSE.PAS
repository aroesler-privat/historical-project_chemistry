UNIT PSE; INTERFACE
USES Crt, Graph, Mouse, Graphics, Controls, Elemente, ReadFile, Logo;

TYPE PSEEintrag = OBJECT
                    x, y          : WORD;
                    Element       : PElementRec;
                    Marked        : BOOLEAN;
                    CONSTRUCTOR Init(El : PElementRec);
                    PROCEDURE   Draw;
                    FUNCTION    Run : BOOLEAN;
                    DESTRUCTOR  Done;
                  END;

PROCEDURE RunPSE;

IMPLEMENTATION

VAR ElementsDlg : ElementInfos;
    Elements    : OFile;
    Eintrag     : ARRAY[0..118]OF ^PSEEintrag;
{----------------------------------------------------------------------------}
CONSTRUCTOR PSEEintrag.Init(El : PElementRec);
BEGIN
  Element:=El; Marked:=FALSE;
  case El^.Ordnungszahl of
           1: begin x:= 10; y:=105; end;
           2: begin x:=605; y:=105; end;
      3..  4: begin x:= 10+(El^.Ordnungszahl-  3)*35; y:=140; end;
      5.. 10: begin x:=430+(El^.Ordnungszahl-  5)*35; y:=140; end;
     11.. 12: begin x:= 10+(El^.Ordnungszahl- 11)*35; y:=175; end;
     13.. 18: begin x:=430+(El^.Ordnungszahl- 13)*35; y:=175; end;
     19.. 36: begin x:= 10+(El^.Ordnungszahl- 19)*35; y:=210; end;
     37.. 54: begin x:= 10+(El^.Ordnungszahl- 37)*35; y:=245; end;
     55.. 56: begin x:= 10+(El^.Ordnungszahl- 55)*35; y:=280; end;
     57.. 71: begin x:= 80+(El^.Ordnungszahl- 57)*35; y:=370; end;
     72.. 86: begin x:=115+(El^.Ordnungszahl- 72)*35; y:=280; end;
     87.. 88: begin x:= 10+(El^.Ordnungszahl- 87)*35; y:=315; end;
     89..103: begin x:= 80+(El^.Ordnungszahl- 89)*35; y:=425; end;
    104..118: begin x:=115+(El^.Ordnungszahl-104)*35; y:=315; end;
  end;
END;

PROCEDURE PSEEintrag.Draw;
VAR GrVars : SaveGrVars;
    s      : STRING;
BEGIN
  GrVars.Save; HideMouseCursor;
  if (Element^.Eigenschaften and Metall)=Metall then begin
    if (Element^.Eigenschaften and Nebengruppe)=0 then SetFillStyle(1,1)
                                                     else SetFillStyle(1,9);
  end else if (Element^.Eigenschaften and HalbMetall)=HalbMetall then SetFillStyle(1,2)
  else SetFillStyle(1,12);
  Bar(x+1,y+1,x+34,y+34);
  if (Element^.Eigenschaften and Fluessig)=Fluessig then SetColor(14) else
  if (Element^.Eigenschaften and Fest)=Fest then SetColor(0) else SetColor(4);
  SetTextStyle(2,0,6); SetTextJustify(2,1);
  if Element^.Eigenschaften and Radioaktiv = Radioaktiv then begin
    OutTextXY(x+30,y+16,Element^.Symbol);
    SetTextStyle(2,0,3); OutTextXY(x+33,y+12,'*');
  end else OutTextXY(x+33,y+16,Element^.Symbol);
  SetColor(0); SetTextStyle(0,0,0); SetTextJustify(0,2);
  str(Element^.Ordnungszahl,s); OutTextXY(x+3,y+3,s);
  SetTextStyle(2,0,1); SetTextJustify(1,1);
  OutTextXY(x+19,y+30,Element^.Name);
  if Marked then begin
    HideMouseCursor; SetWriteMode(XorPut);
    SetColor(7); Rectangle(x+1,y+1,x+34,y+34);
    SetWriteMode(NormalPut); ShowMouseCursor;
  end;
  GrVars.Restore; ShowMouseCursor;
END;

FUNCTION PSEEintrag.Run : BOOLEAN;
VAR GrVars : SaveGrVars;
BEGIN
  if MouseIn(x,y,x+34,y+34) then begin
    Run:=GetButtonStatus(1);
    if Marked then exit; Marked:=TRUE;
    GrVars.Save; HideMouseCursor;
    SetWriteMode(XorPut); SetColor(7); Rectangle(x+1,y+1,x+34,y+34);
    SetWriteMode(NormalPut); GrVars.Restore; ShowMouseCursor;
  end else begin
    Run:=FALSE;
    if not Marked then exit; Marked:=FALSE;
    GrVars.Save; HideMouseCursor;
    SetWriteMode(XorPut); SetColor(7); Rectangle(x+1,y+1,x+34,y+34);
    SetWriteMode(NormalPut); GrVars.Restore; ShowMouseCursor;
  end;
END;

DESTRUCTOR PSEEintrag.Done;
BEGIN
END;
{----------------------------------------------------------------------------}
PROCEDURE DrawPSE;
VAR GrVars : SaveGrVars;
    x      : WORD;
    s      : STRING;
BEGIN
  InitGraph16; GrVars.Save;
  SetFillStyle(1,7); Bar(0,0,640,480);
  SetTextStyle(0,0,2); SetTextJustify(1,1);
  SetColor(15); OutTextXY(320,20,'Periodensystem der Elemente');
  SetColor(01); OutTextXY(322,22,'Periodensystem der Elemente');
  SetColor(09); OutTextXY(321,21,'Periodensystem der Elemente');
  SetColor(0);
  for x:=0 to 8 do begin
    if x<3 then begin
      Line(0,70+(x*35),80,70+(x*35)); Line(430,70+(x*35),640,70+(x*35));
    end else Line(0,70+(x*35),640,70+(x*35));
  end;
  Line(10,70,10,350);
  for x:=1 to 18 do case x of
     1    : Line(45,95,45,350);
     2    : Line(80,70,80,350);
     3.. 7: Line(10+(x*35),200,10+(x*35),350);
     8.. 9: Line(10+(x*35),210,10+(x*35),350);
    10..11: Line(10+(x*35),200,10+(x*35),350);
    12    : Line(430,70,430,350);
    13..17: Line(10+(x*35),95,10+(x*35),350);
  end;
  Line(10,370,605,370); Line(10,405,605,405); Line(10,370,10,405);
  Line(10,425,605,425); Line(10,460,605,460); Line(10,425,10,460);
  for x:=0 to 15 do begin
    Line(80+(x*35),370,80+(x*35),405);
    Line(80+(x*35),425,80+(x*35),460);
  end;
  SetTextStyle(2,1,3); SetTextJustify(1,1);
  OutTextXY(3,87,'Periode'); SetTextStyle(2,0,4);
  for x:=1 to 7 do begin str(x,s); OutTextXY(5,87+(x*35),s); end;
  OutTextXY(45,80,'Hauptgruppe'); OutTextXY(535,80,'Hauptgruppe');
  OutTextXY( 27,97,  'I'); OutTextXY( 62,97,  'II'); OutTextXY(447,97,'III');
  OutTextXY(482,97, 'VI'); OutTextXY(517,97,   'V'); OutTextXY(552,97, 'VI');
  OutTextXY(587,97,'VII'); OutTextXY(622,97,'VIII');
  OutTextXY(255,185,'Nebengruppe');
  OutTextXY( 97,202,'III'); OutTextXY(132,202, 'IV'); OutTextXY(167,202,   'V');
  OutTextXY(202,202, 'VI'); OutTextXY(237,202,'VII'); OutTextXY(307,202,'VIII');
  OutTextXY(377,202,  'I'); OutTextXY(412,202, 'II');
  SetTextJustify(0,1);
  OutTextXY(13,387,'Lanthanoide'); OutTextXY(13,442,'Actinoide');
  OutTextXY(110, 78,': Gas');
  OutTextXY(110, 93,': Flssigkeit');
  OutTextXY( 98,108,'Mg: Feststoff');
  OutTextXY(110,123,': Nichtmetall');
  OutTextXY(110,138,': Halbmetall');
  OutTextXY(110,153,': Metall');
  OutTextXY( 98,168,'* : Alle Isotope dieses Elements sind radioaktiv');
  SetColor( 4); OutTextXY(98, 78,'H');
  SetColor(14); OutTextXY(98, 93,'Br');
  SetColor(12); OutTextXY(98,123,'Û');
  SetColor( 2); OutTextXY(98,138,'Û');
  SetColor( 9); OutTextXY(98,153,'ß');
  SetColor( 1); OutTextXY(98,153,'Ü');
  SetFillStyle(1,9); Bar(81,281,114,314); Bar(81,316,114,349);
  SetTextStyle(2,0,2); SetTextJustify(1,1);
  SetColor(0); OutTextXY(97,285,'57-71'); OutTextXY(97,320,'89-103');
  SetTextStyle(2,0,1);
  OutTextXY(100,310,'Lanthanoide'); OutTextXY(97,345,'Actinoide');
  Line(113,314,113,365); Line(113,365,7,365); Line(7,365,7,387); Line(7,387,11,387);
  Line(111,349,111,355); Line(111,355,3,355); Line(3,355,3,442); Line(3,442,11,442);
  Elements.Init('ELEMENTS.DAT');
  Elements.ReadBlocks(0,118,SizeOf(TElementRec));
  for x:=1 to 118 do Begin
    New(Eintrag[x],Init(Elements.GetBlockNr(x)));
    if Eintrag[x]^.Element^.Name<>'' then Eintrag[x]^.Draw;
  End;
  new(Eintrag[0],Init(Elements.GetBlockNr(5)));
  Eintrag[0]^.x:=385; Eintrag[0]^.y:=70;
  SetColor(0);
  Rectangle(Eintrag[0]^.x,Eintrag[0]^.y,Eintrag[0]^.x+35,Eintrag[0]^.y+35);
  Eintrag[0]^.Draw; Dispose(Eintrag[0],Done);
  SetColor(0); SetTextStyle(2,0,4); SetTextJustify(2,1);
  OutTextXY(370, 75,'Ordnungszahl'); Line(375,75,386,75);
  OutTextXY(370, 95,'Symbol'); Line(375,95,405,88);
  SetTextJustify(1,1);
  OutTextXY(390,120,'Name'); Line(393,115,400,104);
  GrVars.Restore;
END;

PROCEDURE RunPSE;
VAR w : WORD;
    p : pointer;
BEGIN
  DrawPSE; ShowMouseCursor;
  repeat
    for w:=1 to 118 do begin
      if (Eintrag[w]<>nil)and(Eintrag[w]^.Run) then begin
        ElementsDlg.Init(Eintrag[w]^.Element);
        ElementsDlg.ShowInfoDialog;
        ElementsDlg.Done;
        if Eintrag[w]^.Element^.Name<>'' then Eintrag[w]^.Draw;
      end;
    end;
  until keypressed;
  for w:=1 to 118 do if Eintrag[w]<>nil then dispose(Eintrag[w],done);
  Elements.Done(TRUE); HideMouseCursor; CloseGraph;
END;
{----------------------------------------------------------------------------}

END.