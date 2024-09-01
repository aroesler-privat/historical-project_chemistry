UNIT ReadFile; INTERFACE uses crt, logo;

TYPE PBlock = ^TBLOCK;
     TBlock = RECORD
                Pos   : ARRAY[(Left,Right)]OF POINTER;
                Data  : POINTER;
                Size  : WORD;
              END;
     OFile = OBJECT
               CONSTRUCTOR Init(FileName : STRING);
               PROCEDURE   ReadBlocks(Offset : LONGINT; Count, Size : WORD);
               PROCEDURE   InsertBlock(Data : POINTER; Size : WORD);
               FUNCTION    GetBlockNr(Nr : LONGINT) : POINTER;
               FUNCTION    SearchString(Offset, Len : WORD; VAR Block) : WORD;
               PROCEDURE   DelBlockNr(Nr : LONGINT);
               DESTRUCTOR  Done(WriteBack : BOOLEAN);
               PRIVATE
               Name              : STRING;
               f                 : FILE;
               Ready, WriteCount : BOOLEAN;
               First, Last       : POINTER;
               Counter, nOffset  : LONGINT;
               Help1, Help2      : PBlock;
             END;

IMPLEMENTATION

CONSTRUCTOR OFile.Init(FileName : STRING);
BEGIN
  Name:=FileName; First:=nil; Last:=nil; nOffset:=0; Counter:=0;
  {$I-}Assign(f,Name); Reset(f,1);{$I+} Ready:=(IOResult=0);
  WriteCount:=FALSE;
END;

PROCEDURE OFile.ReadBlocks(Offset : LONGINT; Count, Size : WORD);
VAR w, err : WORD;
BEGIN
  if Count=0 then begin WriteCount:=TRUE; Counter:=0; end;
  if (not Ready)or(FileSize(f)<(Offset+Count*Size))or(MaxAvail<Count*(Size+SizeOf(TBlock))) then exit;
  Seek(f,Offset); nOffset:=Offset;
  if Count=0 then begin BlockRead(f,Counter,4,Err); WriteCount:=TRUE; end
             else begin Counter:=Count; Err:=4; WriteCount:=FALSE; end;
  if Err<>4 then exit;
  if Counter>0 then for w:=1 to Counter do begin
    New(Help1); Help2 := Last; Last := Help1;
    if Help2<>nil then Help2^.Pos[Right]:=Help1 else First:=Help1;
    Help1^.Pos[Left]  := Help2;
    Help1^.Pos[Right] := nil;
    Help1^.Size       := Size;
    GetMem(Help1^.Data,Help1^.Size);
    BlockRead(f,Help1^.Data^,Size,err);
    if err<>Size then exit;
  end;
END;

PROCEDURE OFile.InsertBlock(Data : POINTER; Size : WORD);
BEGIN
  if (not Ready)or(MaxAvail<Size) then exit;
  if WriteCount then inc(Counter);
  New(Help1); Help2 := Last; Last := Help1;
  if Help2<>nil then Help2^.Pos[Right]:=Help1 else First:=Help1;
  Help1^.Pos[Left]  := Help2;
  Help1^.Pos[Right] := nil;
  Help1^.Size       := Size;
  Help1^.Data       := Data;
END;

FUNCTION OFile.GetBlockNr(Nr : LONGINT) : POINTER;
VAR l : LONGINT;
BEGIN
  Help1:=First;
  if Nr>1 then for l:=2 to Nr do if Help1<>nil then Help1:=Help1^.Pos[Right];
  if Help1=nil then GetBlockNr:=nil else GetBlockNr:=Help1^.Data;
END;

FUNCTION OFile.SearchString(Offset, Len : WORD; VAR Block) : WORD;
  FUNCTION Cmp(VAR p1, p2; ofs, size : WORD; up : BOOLEAN) : ShortInt; ASSEMBLER;
  ASM
    push ds
    push si
    les di, p1
    lds si, p2
    add di, ofs
    mov cx, size;
    @@Loop: mov al, byte ptr es:[di]
            mov ah, byte ptr ds:[si]
            cmp al, ah
            ja @@Bigger
            jb @@Smaller
            cmp up, 1
            jz @@Add
            dec di
            dec si
            jmp @@Loop1
            @@Add:
            inc di
            inc si
            @@Loop1:
            loop @@Loop
    mov al, 0
    jmp @@Ende
    @@Bigger:
    mov al, 1
    jmp @@Ende
    @@Smaller:
    mov al, 255
    @@Ende:
    pop si
    pop ds
  END;

VAR w : WORD;
BEGIN
  Help1:=First; w:=1;
  while Help1<>nil do begin
    if Cmp(Help1^.Data^,Block,Offset,Len,TRUE)=0 then begin
      SearchString:=w; exit;
    end;
    Help1:=Help1^.Pos[Right]; inc(w);
  end;
  SearchString:=0;
END;

PROCEDURE OFile.DelBlockNr(Nr : LONGINT);
VAR l : LONGINT;
BEGIN
  Help1:=First;
  if Nr>1 then for l:=2 to Nr do if Help1<>nil then Help1:=Help1^.Pos[Right];
  if Help1=nil then exit;
  Help2:=Help1^.Pos[Left];
  if Help2<>nil then Help2^.Pos[Right]:=Help1^.Pos[Right]
                else First:=Help1^.Pos[Right];
  Help2:=Help1^.Pos[Right];
  if Help2<>nil then Help2^.Pos[Left]:=Help1^.Pos[Left]
                else Last:=Help1^.Pos[Left];
  FreeMem(Help1^.Data,Help1^.Size); Dispose(Help1);
  if WriteCount then dec(Counter);
END;

DESTRUCTOR OFile.Done(WriteBack : BOOLEAN);
VAR Err : WORD;
BEGIN
  Help1:=First;
  if WriteBack then begin
    if nOffset=0 then ReWrite(f,1) else Reset(f,1); Seek(f,nOffset);
    if WriteCount then BlockWrite(f,Counter,4,Err);
  end;
  while Help1<>nil do begin
    if WriteBack then BlockWrite(f,Help1^.Data^,Help1^.Size,Err);
    Help2:=Help1^.Pos[Right];
    FreeMem(Help1^.Data,Help1^.Size);
    Dispose(Help1); Help1:=Help2;
  end;
  if WriteBack then close(f);
END;

END.