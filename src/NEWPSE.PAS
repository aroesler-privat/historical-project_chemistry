UNIT NewPSE; INTERFACE USES Elemente, ReadFile;

PROCEDURE WriteNewPSE;

IMPLEMENTATION

VAR El : ARRAY[1..118]OF PElementRec;

PROCEDURE SetNames;
VAR b : BYTE;
BEGIN
  for b:=1 to 118 do begin
    new(el[b]); FillChar(el[b]^,SizeOf(TElementRec),0);
    el[b]^.Ordnungszahl  := b;
  end;
  el[1]^.Name          := 'Wasserstoff';
  el[1]^.Symbol        := 'H';
  el[1]^.Eigenschaften := Gas or NichtMetall;
  el[2]^.Name          := 'Helium';
  el[2]^.Symbol        := 'He';
  el[2]^.Eigenschaften := Gas or NichtMetall;
  el[3]^.Name          := 'Lithium';
  el[3]^.Symbol        := 'Li';
  el[4]^.Eigenschaften := Fest or Metall;
  el[4]^.Name          := 'Beryllium';
  el[4]^.Symbol        := 'Be';
  el[4]^.Eigenschaften := Fest or Metall;
  el[5]^.Name          := 'Bor';
  el[5]^.Symbol        := 'B';
  el[5]^.Eigenschaften := Fest or Halbmetall;
  el[6]^.Name          := 'Kohlenstoff';
  el[6]^.Symbol        := 'C';
  el[6]^.Eigenschaften := Fest or Nichtmetall;
  el[7]^.Name          := 'Stickstoff';
  el[7]^.Symbol        := 'N';
  el[7]^.Eigenschaften := Gas or Nichtmetall;
  el[8]^.Name          := 'Sauerstoff';
  el[8]^.Symbol        := 'O';
  el[8]^.Eigenschaften := Gas or Nichtmetall;
  el[9]^.Name          := 'Flour';
  el[9]^.Symbol        := 'F';
  el[9]^.Eigenschaften := Gas or Nichtmetall;
  el[10]^.Name          := 'Neon';
  el[10]^.Symbol        := 'Ne';
  el[10]^.Eigenschaften := Gas or Nichtmetall;
  el[11]^.Name          := 'Natrium';
  el[11]^.Symbol        := 'Na';
  el[11]^.Eigenschaften := Fest or Metall;
  el[12]^.Name          := 'Magnesium';
  el[12]^.Symbol        := 'Mg';
  el[12]^.Eigenschaften := Fest or Metall;
  el[13]^.Name          := 'Aluminium';
  el[13]^.Symbol        := 'Al';
  el[13]^.Eigenschaften := Fest or Metall;
  el[14]^.Name          := 'Silizium';
  el[14]^.Symbol        := 'Si';
  el[14]^.Eigenschaften := Fest or HalbMetall;
  el[15]^.Name          := 'Phosphor';
  el[15]^.Symbol        := 'P';
  el[15]^.Eigenschaften := Fest or NichtMetall;
  el[16]^.Name          := 'Schwefel';
  el[16]^.Symbol        := 'S';
  el[16]^.Eigenschaften := Fest or NichtMetall;
  el[17]^.Name          := 'Chlor';
  el[17]^.Symbol        := 'Cl';
  el[17]^.Eigenschaften := Gas or NichtMetall;
  el[18]^.Name          := 'Argon';
  el[18]^.Symbol        := 'Ar';
  el[18]^.Eigenschaften := Gas or NichtMetall;
  el[19]^.Name          := 'Kalium';
  el[19]^.Symbol        := 'K';
  el[19]^.Eigenschaften := Fest or Metall;
  el[20]^.Name          := 'Calcium';
  el[20]^.Symbol        := 'Ca';
  el[20]^.Eigenschaften := Fest or Metall;
  el[21]^.Name          := 'Scandium';
  el[21]^.Symbol        := 'Sc';
  el[21]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[22]^.Name          := 'Titanium';
  el[22]^.Symbol        := 'Ti';
  el[22]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[23]^.Name          := 'Vanadium';
  el[23]^.Symbol        := 'V';
  el[23]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[24]^.Name          := 'Chromium';
  el[24]^.Symbol        := 'Cr';
  el[24]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[25]^.Name          := 'Mangan';
  el[25]^.Symbol        := 'Mn';
  el[25]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[26]^.Name          := 'Eisen';
  el[26]^.Symbol        := 'Fe';
  el[26]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[27]^.Name          := 'Cobalt';
  el[27]^.Symbol        := 'Co';
  el[27]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[28]^.Name          := 'Nickel';
  el[28]^.Symbol        := 'Ni';
  el[28]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[29]^.Name          := 'Kupfer';
  el[29]^.Symbol        := 'Cu';
  el[29]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[30]^.Name          := 'Zink';
  el[30]^.Symbol        := 'Zn';
  el[30]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[31]^.Name          := 'Galium';
  el[31]^.Symbol        := 'Ga';
  el[31]^.Eigenschaften := Fest or Metall;
  el[32]^.Name          := 'Germanium';
  el[32]^.Symbol        := 'Ge';
  el[32]^.Eigenschaften := Fest or HalbMetall;
  el[33]^.Name          := 'Arsen';
  el[33]^.Symbol        := 'As';
  el[33]^.Eigenschaften := Fest or HalbMetall;
  el[34]^.Name          := 'Selen';
  el[34]^.Symbol        := 'Se';
  el[34]^.Eigenschaften := Fest or NichtMetall;
  el[35]^.Name          := 'Brom';
  el[35]^.Symbol        := 'Br';
  el[35]^.Eigenschaften := Fluessig or NichtMetall;
  el[36]^.Name          := 'Krypton';
  el[36]^.Symbol        := 'Kr';
  el[36]^.Eigenschaften := Gas or NichtMetall;
  el[37]^.Name          := 'Rubidium';
  el[37]^.Symbol        := 'Rb';
  el[37]^.Eigenschaften := Fest or Metall;
  el[38]^.Name          := 'Strontium';
  el[38]^.Symbol        := 'Sr';
  el[38]^.Eigenschaften := Fest or Metall;
  el[39]^.Name          := 'Yttrium';
  el[39]^.Symbol        := 'Y';
  el[39]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[40]^.Name          := 'Zirconium';
  el[40]^.Symbol        := 'Zr';
  el[40]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[41]^.Name          := 'Niobium';
  el[41]^.Symbol        := 'Nb';
  el[41]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[42]^.Name          := 'Molybd�n';
  el[42]^.Symbol        := 'Mo';
  el[42]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[43]^.Name          := 'Technetium';
  el[43]^.Symbol        := 'Tc';
  el[43]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[44]^.Name          := 'Ruthenium';
  el[44]^.Symbol        := 'Ru';
  el[44]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[45]^.Name          := 'Rhodium';
  el[45]^.Symbol        := 'Rh';
  el[45]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[46]^.Name          := 'Palladium';
  el[46]^.Symbol        := 'Pd';
  el[46]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[47]^.Name          := 'Silber';
  el[47]^.Symbol        := 'Ag';
  el[47]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[48]^.Name          := 'Cadmium';
  el[48]^.Symbol        := 'Cd';
  el[48]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[49]^.Name          := 'Indium';
  el[49]^.Symbol        := 'In';
  el[49]^.Eigenschaften := Fest or Metall;
  el[50]^.Name          := 'Zinn';
  el[50]^.Symbol        := 'Sn';
  el[50]^.Eigenschaften := Fest or Metall;
  el[51]^.Name          := 'Antimon';
  el[51]^.Symbol        := 'Sb';
  el[51]^.Eigenschaften := Fest or HalbMetall;
  el[52]^.Name          := 'Tellur';
  el[52]^.Symbol        := 'Te';
  el[52]^.Eigenschaften := Fest or HalbMetall;
  el[53]^.Name          := 'Iod';
  el[53]^.Symbol        := 'I';
  el[53]^.Eigenschaften := Gas or NichtMetall;
  el[54]^.Name          := 'Xenon';
  el[54]^.Symbol        := 'Xe';
  el[54]^.Eigenschaften := Gas or NichtMetall;
  el[55]^.Name          := 'Caesium';
  el[55]^.Symbol        := 'Cs';
  el[55]^.Eigenschaften := Fest or Metall;
  el[56]^.Name          := 'Barium';
  el[56]^.Symbol        := 'Ba';
  el[56]^.Eigenschaften := Fest or Metall;
  el[57]^.Name          := 'Lanthan';
  el[57]^.Symbol        := 'La';
  el[57]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[58]^.Name          := 'Cerium';
  el[58]^.Symbol        := 'Ce';
  el[58]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[59]^.Name          := 'Praseodymium';
  el[59]^.Symbol        := 'Pr';
  el[59]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[60]^.Name          := 'Neodymium';
  el[60]^.Symbol        := 'Nd';
  el[60]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[61]^.Name          := 'Promethium';
  el[61]^.Symbol        := 'Pm';
  el[61]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[62]^.Name          := 'Samarium';
  el[62]^.Symbol        := 'Sm';
  el[62]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[63]^.Name          := 'Europium';
  el[63]^.Symbol        := 'Eu';
  el[63]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[64]^.Name          := 'Gadolinium';
  el[64]^.Symbol        := 'Gd';
  el[64]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[65]^.Name          := 'Terbium';
  el[65]^.Symbol        := 'Tb';
  el[65]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[66]^.Name          := 'Dysprosium';
  el[66]^.Symbol        := 'Dy';
  el[66]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[67]^.Name          := 'Holmium';
  el[67]^.Symbol        := 'Ho';
  el[67]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[68]^.Name          := 'Erbium';
  el[68]^.Symbol        := 'Er';
  el[68]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[69]^.Name          := 'Thulium';
  el[69]^.Symbol        := 'Tm';
  el[69]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[70]^.Name          := 'Ytterbium';
  el[70]^.Symbol        := 'Yb';
  el[70]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[71]^.Name          := 'Lutetium';
  el[71]^.Symbol        := 'Lu';
  el[71]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[72]^.Name          := 'Hafnium';
  el[72]^.Symbol        := 'Hf';
  el[72]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[73]^.Name          := 'Tantal';
  el[73]^.Symbol        := 'Ta';
  el[73]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[74]^.Name          := 'Wolfram';
  el[74]^.Symbol        := 'W';
  el[74]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[75]^.Name          := 'Rhenium';
  el[75]^.Symbol        := 'Re';
  el[75]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[76]^.Name          := 'Osmium';
  el[76]^.Symbol        := 'Os';
  el[76]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[77]^.Name          := 'Iridium';
  el[77]^.Symbol        := 'Ir';
  el[77]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[78]^.Name          := 'Platin';
  el[78]^.Symbol        := 'Pt';
  el[78]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[79]^.Name          := 'Gold';
  el[79]^.Symbol        := 'Au';
  el[79]^.Eigenschaften := Fest or Metall or Nebengruppe;
  el[80]^.Name          := 'Quecksilber';
  el[80]^.Symbol        := 'Hg';
  el[80]^.Eigenschaften := Fluessig or Metall or Nebengruppe;
  el[81]^.Name          := 'Thalium';
  el[81]^.Symbol        := 'Tl';
  el[81]^.Eigenschaften := Fest or Metall;
  el[82]^.Name          := 'Blei';
  el[82]^.Symbol        := 'Pb';
  el[82]^.Eigenschaften := Fest or Metall;
  el[83]^.Name          := 'Bismut';
  el[83]^.Symbol        := 'Bi';
  el[83]^.Eigenschaften := Fest or Metall;
  el[84]^.Name          := 'Polonium';
  el[84]^.Symbol        := 'Po';
  el[84]^.Eigenschaften := Fest or HalbMetall or Radioaktiv;
  el[85]^.Name          := 'Astat';
  el[85]^.Symbol        := 'At';
  el[85]^.Eigenschaften := Fest or HalbMetall or Radioaktiv;
  el[86]^.Name          := 'Radon';
  el[86]^.Symbol        := 'Rd';
  el[86]^.Eigenschaften := Gas or NichtMetall or Radioaktiv;
  el[87]^.Name          := 'Francium';
  el[87]^.Symbol        := 'Fr';
  el[87]^.Eigenschaften := Fest or Metall or Radioaktiv;
  el[88]^.Name          := 'Radium';
  el[88]^.Symbol        := 'Ra';
  el[88]^.Eigenschaften := Fest or Metall or Radioaktiv;
  el[89]^.Name          := 'Actinium';
  el[89]^.Symbol        := 'Ac';
  el[89]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[90]^.Name          := 'Thorium';
  el[90]^.Symbol        := 'Th';
  el[90]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[91]^.Name          := 'Protactinium';
  el[91]^.Symbol        := 'Pa';
  el[91]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[92]^.Name          := 'Uranium';
  el[92]^.Symbol        := 'U';
  el[92]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[93]^.Name          := 'Neptunium';
  el[93]^.Symbol        := 'Np';
  el[93]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[94]^.Name          := 'Plutonium';
  el[94]^.Symbol        := 'Pu';
  el[94]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[95]^.Name          := 'Americium';
  el[95]^.Symbol        := 'Am';
  el[95]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[96]^.Name          := 'Curium';
  el[96]^.Symbol        := 'Cm';
  el[96]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[97]^.Name          := 'Berkelium';
  el[97]^.Symbol        := 'Bk';
  el[97]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[98]^.Name          := 'Californium';
  el[98]^.Symbol        := 'Cf';
  el[98]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[99]^.Name          := 'Einsteinium';
  el[99]^.Symbol        := 'Es';
  el[99]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[100]^.Name          := 'Fermium';
  el[100]^.Symbol        := 'Fm';
  el[100]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[101]^.Name          := 'Medelevium';
  el[101]^.Symbol        := 'Md';
  el[101]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[102]^.Name          := 'Nobelium';
  el[102]^.Symbol        := 'No';
  el[102]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[103]^.Name          := 'Lawrencium';
  el[103]^.Symbol        := 'Lr';
  el[103]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[104]^.Name          := 'Kurtschatovium';
  el[104]^.Symbol        := 'Ku';
  el[104]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[105]^.Name          := 'Nielsbohrium';
  el[105]^.Symbol        := 'Ns';
  el[105]^.Eigenschaften := Fest or Metall or Nebengruppe or Radioaktiv;
  el[106]^.Eigenschaften := Nebengruppe;
  el[107]^.Eigenschaften := Nebengruppe;
  el[108]^.Eigenschaften := Nebengruppe;
  el[109]^.Eigenschaften := Nebengruppe;
  el[110]^.Eigenschaften := Nebengruppe;
  el[111]^.Eigenschaften := Nebengruppe;
  el[112]^.Eigenschaften := Nebengruppe;
END;

PROCEDURE WriteNewPSE;
VAR PSE      : OFile;
    b        : BYTE;
BEGIN
  PSE.Init('ELEMENTS.DAT');
  SetNames;
  for b:=1 to 118 do PSE.InsertBlock(el[b],SizeOf(TElementRec));
  PSE.Done(TRUE);
END;

END.