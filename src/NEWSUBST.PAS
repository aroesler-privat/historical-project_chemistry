UNIT NewSubst; INTERFACE USES Infos, ReadFile;

PROCEDURE WriteNewSubst;

IMPLEMENTATION

VAR Classes     : ARRAY[1..7] OF PSubstanceClass;
    Substances  : ARRAY[1..14]OF PSubstanceRec;

PROCEDURE EraseIfExists(Name : STRING);
VAR f   : FILE;
    Err : INTEGER;
BEGIN
  Assign(f,Name);
  {$I-} Erase(f); {$I+}
  Err:=IOResult; { Datei existierte noch nicht - kein Problem }
END;

PROCEDURE SetClasses;
VAR b : BYTE;
BEGIN
  for b:=1 to 7 do begin
    new(Classes[b]); FillChar(Classes[b]^,SizeOf(TSubstanceClass),0);
    Classes[b]^.ID := b;
  end;
  Classes[1]^.Name   := 'SÑure[organisch]';
  Classes[1]^.Konst1 := 'Ks-Wert';
  Classes[1]^.Einh1  := 'mol/l';
  Classes[2]^.Name   := 'SÑure[anorganisch]';
  Classes[2]^.Konst1 := 'pKs-Wert';
  Classes[3]^.Name   := 'Base';
  Classes[3]^.Konst1 := 'pKb-Wert';
  Classes[4]^.Name   := 'Salz';
  Classes[4]^.Konst1 := 'pKL';
  Classes[5]^.Name   := 'Hydroxid';
  Classes[5]^.Konst1 := 'pKL';
  Classes[6]^.Name   := 'Sonstige[organisch]';
  Classes[7]^.Name   := 'Sonstige[anorg.]';
END;

PROCEDURE SetSubstances;
VAR b : BYTE;
BEGIN
  for b:=1 to 14 do begin
    new(Substances[b]); FillChar(Substances[b]^,SizeOf(TSubstanceRec),0);
  end;
  { Stoffklasse: 1=SÑure[organisch] 2=SÑure[anorganisch] 3=Base 4=Salz      }
  {              5=Hydroxid 6=Sonstige[organisch] 7=Sonstige[anorg.]       }
  { Aggregat   : 1=fest 2=flÅssig 3=gasfîrmig                              }
  Substances[1]^.Name        := 'EthansÑure';
  Substances[1]^.Formel      := 'CH3COOH';
  Substances[1]^.Stoffklasse := 1;
  Substances[1]^.Aggregat    := 2;
  Substances[1]^.Schmelz     := 16.6;
  Substances[1]^.Siede       := 118.0;
  Substances[1]^.Dichte      := 1.049;
  Substances[1]^.SEnthalpie  := -484.5;
  Substances[1]^.SEntropie   := 159.8;
  Substances[1]^.Konst1      := 1.8E-5;
  Substances[2]^.Name        := 'Natriumhydroxid';
  Substances[2]^.Formel      := 'NaOH';
  Substances[2]^.Stoffklasse := 3;
  Substances[2]^.Aggregat    := 1;
  Substances[2]^.Schmelz     := 318.0;
  Substances[2]^.Siede       := 1388.0;
  Substances[2]^.Dichte      := 2.13;
  Substances[2]^.SEnthalpie  := -425.8;
  Substances[2]^.SEntropie   := 64.4;
  Substances[3]^.Name        := 'Calciumhydroxid';
  Substances[3]^.Formel      := 'Ca(OH)2';
  Substances[3]^.Stoffklasse := 3;
  Substances[3]^.Aggregat    := 1;
  Substances[3]^.Schmelz     := 580.0;  { Zersetzung }
  Substances[3]^.Dichte      := 2.24;
  Substances[3]^.SEnthalpie  := -985.2;
  Substances[3]^.SEntropie   := 83.4;
  Substances[4]^.Name        := 'Glucose';
  Substances[4]^.Formel      := 'C6H12O6';
  Substances[4]^.Stoffklasse := 6;
  Substances[4]^.Aggregat    := 1;
  Substances[4]^.Schmelz     := 146.0;
  Substances[4]^.Dichte      := 1.54;
  Substances[4]^.SEnthalpie  := -1273.0;
  Substances[4]^.SEntropie   := 212.1;
  Substances[5]^.Name        := 'SalzsÑure';
  Substances[5]^.Formel      := 'HCl';
  Substances[5]^.Stoffklasse := 2;
  Substances[5]^.Aggregat    := 3;
  Substances[5]^.Schmelz     := -114.8;
  Substances[5]^.Siede       := -85.0;
  Substances[5]^.Dichte      := 0.00164;
  Substances[5]^.SEnthalpie  := -92.3;
  Substances[5]^.SEntropie   := 186.9;
  Substances[5]^.Konst1      := -7.0;
  Substances[6]^.Name        := 'Wasser';
  Substances[6]^.Formel      := 'H2O';
  Substances[6]^.Stoffklasse := 7;
  Substances[6]^.Aggregat    := 2;
  Substances[6]^.Siede       := 100.0;
  Substances[6]^.Dichte      := 0.998;
  Substances[6]^.SEnthalpie  := -285.8;
  Substances[6]^.SEntropie   := 70.0;
  Substances[7]^.Name        := 'SchwefelsÑure';
  Substances[7]^.Formel      := 'H2SO4';
  Substances[7]^.Stoffklasse := 2;
  Substances[7]^.Aggregat    := 2;
  Substances[7]^.Schmelz     := 10.0;
  Substances[7]^.Siede       := 290.0;
  Substances[7]^.Dichte      := 1.84;
  Substances[7]^.SEnthalpie  := -814.0;
  Substances[7]^.SEntropie   := 157.0;
  Substances[7]^.Konst1      := -3.0;
  Substances[8]^.Name        := 'Kohlendioxid';
  Substances[8]^.Formel      := 'CO2';
  Substances[8]^.Stoffklasse := 7;
  Substances[8]^.Aggregat    := 3;
  Substances[8]^.Siede       := -78.5;  { Sublimationspunkt }
  Substances[8]^.Dichte      := 0.001977;
  Substances[8]^.SEnthalpie  := -393.5;
  Substances[8]^.SEntropie   := 213.8;
  Substances[9]^.Name        := 'Natriumchlorid';
  Substances[9]^.Formel      := 'NaCl';
  Substances[9]^.Stoffklasse := 4;
  Substances[9]^.Aggregat    := 1;
  Substances[9]^.Schmelz     := 801.0;
  Substances[9]^.Siede       := 1465.0;
  Substances[9]^.Dichte      := 2.16;
  Substances[9]^.SEnthalpie  := -411.2;
  Substances[9]^.SEntropie   := 72.1;
  Substances[10]^.Name        := 'Ammoniak';
  Substances[10]^.Formel      := 'NH3';
  Substances[10]^.Stoffklasse := 3;
  Substances[10]^.Aggregat    := 3;
  Substances[10]^.Schmelz     := -77.7;
  Substances[10]^.Siede       := -33.3;
  Substances[10]^.Dichte      := 0.000769;
  Substances[10]^.SEnthalpie  := -45.9;
  Substances[10]^.SEntropie   := 192.8;
  Substances[10]^.Konst1      := 4.75;
  Substances[11]^.Name        := 'Calciumcarbonat';
  Substances[11]^.Formel      := 'CaCO3';
  Substances[11]^.Stoffklasse := 4;
  Substances[11]^.Aggregat    := 1;
  Substances[11]^.Schmelz     := 825.0;  { Zersetzung }
  Substances[11]^.Dichte      := 2.71;
  Substances[11]^.SEnthalpie  := -1207.6;
  Substances[11]^.SEntropie   := 92.9;
  Substances[11]^.Konst1      := 8.48;
  Substances[12]^.Name        := 'Kaliumhydroxid';
  Substances[12]^.Formel      := 'KOH';
  Substances[12]^.Stoffklasse := 3;
  Substances[12]^.Aggregat    := 1;
  Substances[12]^.Schmelz     := 360.0;
  Substances[12]^.Siede       := 1327.0;
  Substances[12]^.Dichte      := 2.04;
  Substances[12]^.SEnthalpie  := -424.6;
  Substances[12]^.SEntropie   := 81.2;
  Substances[13]^.Name        := 'Ethanol';
  Substances[13]^.Formel      := 'C2H5OH';
  Substances[13]^.Stoffklasse := 6;
  Substances[13]^.Aggregat    := 2;
  Substances[13]^.Schmelz     := -114.1;
  Substances[13]^.Siede       := 78.3;
  Substances[13]^.Dichte      := 0.789;
  Substances[13]^.SEnthalpie  := -277.6;
  Substances[13]^.SEntropie   := 160.7;
  Substances[14]^.Name        := 'Wasserstoffperoxid';
  Substances[14]^.Formel      := 'H2O2';
  Substances[14]^.Stoffklasse := 7;
  Substances[14]^.Aggregat    := 2;
  Substances[14]^.Schmelz     := -0.41;
  Substances[14]^.Siede       := 150.2;
  Substances[14]^.Dichte      := 1.45;
  Substances[14]^.SEnthalpie  := -187.8;
  Substances[14]^.SEntropie   := 109.6;
END;

PROCEDURE WriteNewSubst;
VAR ClassesFile, SubstancesFile : OFile;
    b                           : BYTE;
BEGIN
  SetClasses;
  EraseIfExists('CLASSES.DAT');
  ClassesFile.Init('CLASSES.DAT');
  ClassesFile.ReadBlocks(0,0,SizeOf(TSubstanceClass)); { stellt den BlockzÑhler auf 0 }
  for b:=1 to 7 do ClassesFile.InsertBlock(Classes[b],SizeOf(TSubstanceClass));
  ClassesFile.Done(TRUE);

  SetSubstances;
  EraseIfExists('SUBSTANC.DAT');
  SubstancesFile.Init('SUBSTANC.DAT');
  SubstancesFile.ReadBlocks(0,0,SizeOf(TSubstanceRec)); { stellt den BlockzÑhler auf 0 }
  for b:=1 to 14 do SubstancesFile.InsertBlock(Substances[b],SizeOf(TSubstanceRec));
  SubstancesFile.Done(TRUE);
END;

END.
