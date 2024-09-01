UNIT Graphics; INTERFACE USES crt, graph, Mouse, Logo;

PROCEDURE InitGraph16;
PROCEDURE Bar3D(x, y, x1, y1 : WORD; On : BOOLEAN);
PROCEDURE Line3D(x, y, x1, y1 : WORD; On : BOOLEAN);

IMPLEMENTATION

PROCEDURE InitGraph16;
VAR gd, gm : INTEGER;
BEGIN
  gd:=Detect; initgraph(gd,gm,'');
  if GraphResult<>0 then begin
    textcolor(4);
    writeln(' ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
    writeln(' บ Error: Grafikmodus konnte nicht initialisiert werden. บ');
    writeln(' ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');
    textcolor(7); halt;
  end;
  if not InitMouse then begin
    textcolor(4);
    writeln(' ษอออออออออออออออออออออออออออออออออออออออออออออป');
    writeln(' บ Error: Es ist kein Maustreiber installiert. บ');
    writeln(' ศอออออออออออออออออออออออออออออออออออออออออออออผ');
    textcolor(7); halt;
  end;
END;

PROCEDURE Bar3D(x, y, x1, y1 : WORD; On : BOOLEAN);
BEGIN
  if On then SetColor(8) else SetColor(15);
  Line(x,y,x1,y); Line(x,y,x,y1);
  if On then SetColor(15) else SetColor(8);
  Line(x1,y,x1,y1); Line(x,y1,x1,y1);
  SetFillStyle(1,7); Bar(x+1,y+1,x1-1,y1-1);
END;

PROCEDURE Line3D(x, y, x1, y1 : WORD; On : BOOLEAN);
BEGIN
  if On then SetColor(8) else SetColor(15); Line(x,y  ,x1,y1  );
  if On then SetColor(15) else SetColor(8); Line(x+1,y+1,x1+1,y1+1);
END;

END.