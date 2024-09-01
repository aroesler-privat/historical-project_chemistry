UNIT Logo; INTERFACE uses crt;

IMPLEMENTATION

FUNCTION KeyPressed : BOOLEAN; NEAR; ASSEMBLER;
ASM
  mov ah, 1; int $16;
  jz @@FALSE; mov ax, 1; jmp @@TRUE;
  @@FALSE: mov ax, 0; @@TRUE:
END;

PROCEDURE Chain4Off; ASSEMBLER;
ASM
  mov dx, $3C4; mov al, $04; out dx, al;
  mov dx, $3C5; in al, dx; and al, 11110111b; out dx, al;
  mov dx, $3D4; mov al, $14; out dx, al;
  mov dx, $3D5; in al, dx; and al, 10111111b; out dx, al;
  mov dx, $3D4; mov al, $17; out dx, al;
  mov dx, $3D5; in al, dx; or al, 01000000b; out dx, al;
END;

PROCEDURE PutPixel(x, y : WORD; col : BYTE); NEAR; ASSEMBLER;
ASM
  mov cx, x; mov dx, y;
  mov ax, segA000; mov es, ax;
  push dx; push cx;
  mov dx, $3C4; mov al, $02; out dx, al;
  and cx, 3; mov al, 1; shl al, cl; inc dx; out dx, al;
  pop cx; pop dx;
  mov ax, 80; mul dx; shr cx, 1; shr cx, 1; add ax, cx; adc dx, 0;
  mov di, ax; mov bl, col; mov es:[di], bl;
END;

PROCEDURE LoadBitmap;
VAR f           : FILE;
    buf         : ARRAY[1..1024]OF BYTE;
    pal, logpal : ARRAY[1..768]OF BYTE;
    w, v        : WORD;
BEGIN
  {$I-} Assign(f,'Logo256.BMP'); Reset(f,1); {$I+}
  if IOResult<>0 then begin
    asm mov ah, $00; mov al, 2; int $10; end;
    textbackground(4); textcolor(15);
    write  (' Fehler beim Starten von "Projekt Chemie"                                        ');
    textbackground(0); textcolor(4); writeln;
    writeln(' Die Datei "LOGO256.BMP" ist nicht im Programmverzeichnis enthalten.');
    textcolor(7); writeln; halt;
  end;
  BlockRead(f,buf,54); BlockRead(f,buf,1024);
  for w:=0 to 255 do begin
    pal[(w*3)+3]:=buf[(w*4)+1] shr 2;
    pal[(w*3)+2]:=buf[(w*4)+2] shr 2;
    pal[(w*3)+1]:=buf[(w*4)+3] shr 2;
  end;
  port[$3C8]:=0; for w:=1 to 768 do port[$3C9]:=0;
  Chain4Off;
  for w:=399 downto 0 do begin
    blockread(f,buf,320);
    for v:=0 to 319 do PutPixel(v,w,buf[v+1]);
  end;
  Close(f);
  asm
    mov dx, $3DA;                                     { -\                   }
    @r1: in al, dx; and al, 8; jne @r1;               {   |-StrahlenrÅcklauf }
    @r2: in al, dx; and al, 8; je @r2;                { -/                   }
    mov cx, 16000;                                    { -\                   }
    mov dx, $3D4; mov ah, cl; mov al, $D; out dx, ax; {   |-CRT-Start setzen }
                  mov ah, ch; mov al, $C; out dx, ax; { -/                   }
  end;
  for w:=1 to 768 do logpal[w]:=0;
  for v:=0 to 63 do begin
    for w:=1 to 768 do if logpal[w]<pal[w] then inc(logpal[w]);
    asm
      mov dx, $3DA;
      @r1: in al, dx; and al, 8; jne @r1;
      @r2: in al, dx; and al, 8; je @r2;
    end;
    port[$3C8]:=0; for w:=1 to 768 do port[$3C9]:=logpal[w];
  end;
END;

PROCEDURE Scroll(CrtStart : WORD); NEAR; ASSEMBLER;
ASM
  mov dx, $3DA;
  @r1: in al, dx; and al, 8; jne @r1;
  @r2: in al, dx; and al, 8; je @r2;
  mov cx, CrtStart;
  mov dx, $3D4; mov ah, cl; mov al, $D; out dx, ax;
                mov ah, ch; mov al, $C; out dx, ax;
END;

PROCEDURE Bumper;
VAR h, t, v0, hPrev : REAL;
    CrtPos, CrtMax  : INTEGER;
CONST g : REAL = 9.81;
BEGIN
  CrtPos:=16000;
  repeat
    CrtMax:=CrtPos; t:=0; h:=0;
    repeat
      h:=(g/2)*t*t; t:=t+0.1;
      CrtPos:=CrtMax-(80*round(h)); if CrtPos<0 then CrtPos:=0;
      Scroll(CrtPos);
    until (CrtPos<=0)or(keypressed);
    v0:=g*t-7.5; t:=0; h:=v0*t;
    if not keypressed then repeat
      hPrev:=h; h:=v0*t-(g/2)*t*t; t:=t+0.1;
      CrtPos:=80*round(h); if CrtPos<0 then CrtPos:=0;
      Scroll(CrtPos);
    until (h<hPrev)or(keypressed);
  until keypressed;
END;

VAR v, w : WORD;
    pal  : ARRAY[1..768]OF BYTE;
BEGIN
  asm mov ah, 0; mov al, $13; int $10; end;
  LoadBitmap; Bumper;
  port[$3C7]:=0; for w:=1 to 768 do pal[w]:=port[$3C9];
  for v:=0 to 63 do begin
    for w:=1 to 768 do if pal[w]>0 then dec(pal[w]);
    asm
      mov dx, $3DA;
      @r1: in al, dx; and al, 8; jne @r1;
      @r2: in al, dx; and al, 8; je @r2;
    end;
    port[$3C8]:=0; for w:=1 to 768 do port[$3C9]:=pal[w];
  end;
  asm
    mov ah, $00; mov al, 2; int $10; { Text-Modus       }
    mov ah, $0C; mov al, 0; int $21; { Clear Key Buffer }
  end;
END.