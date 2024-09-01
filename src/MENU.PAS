UNIT Menu; INTERFACE
USES Crt, Graph, Graphics, Mouse, Controls, PSE, Infos, Tabellen, Logo;

PROCEDURE InsertItem(ProcName : STRING; Proc : POINTER);
PROCEDURE RunMenu;

IMPLEMENTATION

TYPE PRunRec = ^TRunRec;
     TRunRec = RECORD
                 ProcName          : STRING;
                 Button            : OButton;
                 Proc, Left, Right : POINTER;
               END;

VAR First, Last            : POINTER;
    Help1, Help2           : PRunRec;
    Button                 : OButton;
    OptionsCount, MaxWidth : WORD;

CONST Gray50 : FillPatternType = ($77,$DD,$77,$DD,$77,$DD,$77,$DD);

PROCEDURE EGAVGA; external; {$L EGAVGA.OBJ}
PROCEDURE Little; external; {$L LITT.OBJ}

PROCEDURE InsertItem(ProcName : STRING; Proc : POINTER);
BEGIN
  new(Help1); Help2:=Last; Last:=Help1;
  if Help2=nil then First:=Help1 else Help2^.Right:=Help1;
  Help1^.Left     := Help2;
  Help1^.Right    := nil;
  Help1^.ProcName := ProcName;
  Help1^.Proc     := Proc;
  inc(OptionsCount);
  if (Length(ProcName)*8)+10>MaxWidth then MaxWidth:=(Length(ProcName)*8)+10;
  if MaxWidth>620 then MaxWidth:=620;
END;

PROCEDURE DrawMenu;
VAR x, y, x1 : WORD;
    GrVars   : SaveGrVars;
BEGIN
  InitGraph16; GrVars.Save;
  SetFillStyle(1,7); Bar(0,0,640,480);
  Bar3D(5,5,635,19,TRUE);
  SetFillStyle(1,1); Bar(6,6,634,18);
  SetTextStyle(0,0,0); SetTextJustify(0,1);
  SetColor( 8); OutTextXY(12,14,'PROJEKT CHEMIE 1.1');
  SetColor(15); OutTextXY(10,12,'PROJEKT CHEMIE 1.1');
  SetColor( 7); OutTextXY(11,13,'PROJEKT CHEMIE 1.1');
  SetTextJustify(2,1);
  SetColor( 8); OutTextXY(630,14,'(C) Andreas R”sler, Juni 1996');
  SetColor(15); OutTextXY(628,12,'(C) Andreas R”sler, Juni 1996');
  SetColor( 7); OutTextXY(629,13,'(C) Andreas R”sler, Juni 1996');
  Bar3D(5,30,635,475,TRUE);
  SetFillStyle(12,7); SetFillPattern(Gray50,7); Bar(6,31,634,474);
  GrVars.Restore; ShowMouseCursor;
  Button.Init(530,454,629,469,'Beenden');
  x:=320-(MaxWidth div 2); x1:=320+(MaxWidth div 2); y:=220-(OptionsCount*10);
  Help1:=First;
  while Help1<>nil do begin
    Help1^.Button.Init(x,y,x1,y+15,Help1^.ProcName); inc(y,20);
    Help1:=Help1^.Right;
  end;
END;

PROCEDURE DoneMenu;
BEGIN
  Help1:=First;
  while Help1<>nil do begin
    Help2:=Help1^.Right;
    Help1^.Button.Done;
    Dispose(Help1);
    Help1:=Help2;
  end;
END;

PROCEDURE RunMenu;
VAR Proc : POINTER;
BEGIN
  DrawMenu;
  repeat
    Help1:=First;
    while Help1<>nil do begin
      if Help1^.Button.Pressed then begin
        Proc:=Help1^.Proc; if Proc=nil then continue;
        CloseGraph; Button.Done; Help2:=First;
        while Help2<>nil do begin Help2^.Button.Done; Help2:=Help2^.Right; end;
        asm call Proc end; DrawMenu;
      end;
      Help1:=Help1^.Right;
    end;
    if KeyPressed then ReadKey;
  until Button.Pressed;
  DoneMenu; CloseGraph;
END;

BEGIN
  if not InitMouse then begin
    textbackground(4); textcolor(15);
    write  (' Fehler beim Starten von "Projekt Chemie"                                        ');
    textbackground(0); textcolor(4); writeln;
    write  (' Error: Sie haben keinen Maustreiber installiert oder der installierte Treiber  ');
    write  ('        konnte nicht gefunden werden. Dieses Programm wird aber fast vollst„ndig');
    write  ('        mit der Maus gesteuert. Versuchen Sie also, sofern vorhanden, Ihren     ');
    write  ('        eigenen Maustreiber zu starten oder starten Sie die Datei "MOUSE.COM" in');
    writeln('        diesem Verzeichnis!');
    textcolor(7); writeln;
    halt;
  end;
  RegisterBgiDriver(@EGAVGA);
  RegisterBgiFont(@Little);
  First:=nil; Last:=nil; OptionsCount:=0; MaxWidth:=0;
  InsertItem('Periodensystem der Elemente (mit Energieniveauschemen)',Addr(RunPSE));
  InsertItem('Informationen zu chemischen Verbindungen (Datenbank)',Addr(RunInfos));
  InsertItem('Tabellarische Darstellung aller bekannten chemischen Elemente',Addr(RunTabElements));
  InsertItem('Tabellarische Darstellung aller bekannten chemischen Verbindungen',Addr(RunTabSubstances));
END.