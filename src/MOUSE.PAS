UNIT Mouse; INTERFACE USES Logo;

FUNCTION  InitMouse : BOOLEAN;
PROCEDURE ShowMouseCursor;
PROCEDURE HideMouseCursor;
FUNCTION  GetButtonStatus(Button : WORD) : BOOLEAN;
PROCEDURE GetMouseStatus(VAR XPos, YPos, Buttons : WORD);
PROCEDURE SetMousePosition(XPos, YPos : WORD);
PROCEDURE SetMouseFrame(X, Y, X1, Y1 : WORD);
PROCEDURE DefineGraphicsCursor(HotX, HotY : WORD; MaskPtr : POINTER);
PROCEDURE DefineOffArea(X, Y, X1, Y1 : WORD);
PROCEDURE SetMouseSensity(MickeysHoriz, MickeysVert, DoubleSpeed : WORD);
PROCEDURE GetMouseSensity(VAR MickeysHoriz, MickeysVert, DoubleSpeed : WORD);
FUNCTION  MouseIn(x, y, x1, y1 : WORD) : BOOLEAN;

IMPLEMENTATION

VAR CursorOn : WORD;

FUNCTION InitMouse : BOOLEAN; ASSEMBLER;
ASM
  mov ax, 0
  int $33
  mov CursorOn, 0
END;

PROCEDURE ShowMouseCursor; ASSEMBLER;
ASM
  cmp CursorOn, 0
  jz @@Show
  dec CursorOn
  @@Show: mov ax, 1
          int $33
  @@Exit:
END;

PROCEDURE HideMouseCursor; ASSEMBLER;
ASM
  mov ax, 2
  int $33
  inc CursorOn
END;

FUNCTION GetButtonStatus(Button : WORD) : BOOLEAN; ASSEMBLER;
ASM
  mov bx, 1
  mov cx, Button
  @@SetBit: shl bx, 1
            loop @@SetBit
  shr bx, 1
  push bx
  mov ax, 5
  int $33
  pop bx
  and ax, bx
END;

PROCEDURE GetMouseStatus(VAR XPos, YPos, Buttons : WORD); ASSEMBLER;
ASM
  mov ax, 3
  int $33
  les di, Buttons
  mov es:[di], bx
  les di, XPos
  mov es:[di], cx
  les di, YPos
  mov es:[di], dx
END;

PROCEDURE SetMousePosition(XPos, YPos : WORD); ASSEMBLER;
ASM
  mov ax, 4
  mov cx, XPos
  mov dx, YPos
  int $33
END;

PROCEDURE SetMouseFrame(X, Y, X1, Y1 : WORD); ASSEMBLER;
ASM
  mov ax, 7
  mov cx, X
  mov dx, X1
  int $33
  mov ax, 8
  mov cx, Y
  mov dx, Y1
  int $33
END;

PROCEDURE DefineGraphicsCursor(HotX, HotY : WORD; MaskPtr : POINTER); ASSEMBLER;
ASM
  mov ax, 9
  mov bx, HotX
  and bx, $0F
  mov cx, HotY
  and cx, $0F
  les dx, MaskPtr
  int $33
END;

PROCEDURE DefineOffArea(X, Y, X1, Y1 : WORD); ASSEMBLER;
ASM
  push di
  push si
  mov ax, $10
  mov cx, X
  mov dx, Y
  mov si, X1
  mov di, Y1
  int $33
  pop si
  pop di
END;

PROCEDURE SetMouseSensity(MickeysHoriz, MickeysVert, DoubleSpeed : WORD); ASSEMBLER;
ASM
  mov ax, $1A
  mov bx, MickeysHoriz
  mov cx, MickeysVert
  mov dx, DoubleSpeed
  int $33
END;

PROCEDURE GetMouseSensity(VAR MickeysHoriz, MickeysVert, DoubleSpeed : WORD); ASSEMBLER;
ASM
  mov ax, $1B
  int $33
  les di, MickeysHoriz
  mov es:[di], bx
  les di, MickeysVert
  mov es:[di], cx
  les di, DoubleSpeed
  mov es:[di], dx
END;

FUNCTION MouseIn(x, y, x1, y1 : WORD) : BOOLEAN;
VAR XPos, YPos, Buttons : WORD;
BEGIN
  GetMouseStatus(XPos,YPos,Buttons);
  MouseIn:=(XPos>x)and(XPos<x1)and(YPos>y)and(YPos<y1);
END;

END.