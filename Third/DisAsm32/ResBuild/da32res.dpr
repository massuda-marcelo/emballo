program da32res;

uses
  Windows,
  SysUtils,
  Classes,
  da32resc;

// Table loading information
type
  TTblItem          =  packed record
     N:             PChar;
     P:             Pointer;
     S:             Cardinal;
  end;

// Table array used for creating the RC data
const
  tblPersist:       Array [0..40] of TTblItem =
  ((N: 'tbl_Main'; P: @tbl_Main; S: SizeOf(tbl_Main)),
   (N: 'tbl_0F'; P: @tbl_0F; S: SizeOf(tbl_0F)),
   (N: 'tbl_0F00'; P: @tbl_0F00; S: SizeOf(tbl_0F00)),
   (N: 'tbl_0F01'; P: @tbl_0F01; S: SizeOf(tbl_0F01)),
   (N: 'tbl_0F18'; P: @tbl_0F18; S: SizeOf(tbl_0F18)),
   (N: 'tbl_0F71'; P: @tbl_0F71; S: SizeOf(tbl_0F71)),
   (N: 'tbl_0F72'; P: @tbl_0F72; S: SizeOf(tbl_0F72)),
   (N: 'tbl_0F73'; P: @tbl_0F73; S: SizeOf(tbl_0F73)),
   (N: 'tbl_0FAE'; P: @tbl_0FAE; S: SizeOf(tbl_0FAE)),
   (N: 'tbl_0FBA'; P: @tbl_0FBA; S: SizeOf(tbl_0FBA)),
   (N: 'tbl_0FC7'; P: @tbl_0FC7; S: SizeOf(tbl_0FC7)),
   (N: 'tbl_80'; P: @tbl_80; S: SizeOf(tbl_80)),
   (N: 'tbl_81'; P: @tbl_81; S: SizeOf(tbl_81)),
   (N: 'tbl_82'; P: @tbl_82; S: SizeOf(tbl_82)),
   (N: 'tbl_83'; P: @tbl_83; S: SizeOf(tbl_83)),
   (N: 'tbl_C0'; P: @tbl_C0; S: SizeOf(tbl_C0)),
   (N: 'tbl_C1'; P: @tbl_C1; S: SizeOf(tbl_C1)),
   (N: 'tbl_D0'; P: @tbl_D0; S: SizeOf(tbl_D0)),
   (N: 'tbl_D1'; P: @tbl_D1; S: SizeOf(tbl_D1)),
   (N: 'tbl_D2'; P: @tbl_D2; S: SizeOf(tbl_D2)),
   (N: 'tbl_D3'; P: @tbl_D3; S: SizeOf(tbl_D3)),
   (N: 'tbl_F6'; P: @tbl_F6; S: SizeOf(tbl_F6)),
   (N: 'tbl_F7'; P: @tbl_F7; S: SizeOf(tbl_F7)),
   (N: 'tbl_FE'; P: @tbl_FE; S: SizeOf(tbl_FE)),
   (N: 'tbl_FF'; P: @tbl_FF; S: SizeOf(tbl_FF)),
   (N: 'tbl_fpuD8_00BF'; P: @tbl_fpuD8_00BF; S: SizeOf(tbl_fpuD8_00BF)),
   (N: 'tbl_fpuD8_rest'; P: @tbl_fpuD8_rest; S: SizeOf(tbl_fpuD8_rest)),
   (N: 'tbl_fpuD9_00BF'; P: @tbl_fpuD9_00BF; S: SizeOf(tbl_fpuD9_00BF)),
   (N: 'tbl_fpuD9_rest'; P: @tbl_fpuD9_rest; S: SizeOf(tbl_fpuD9_rest)),
   (N: 'tbl_fpuDA_00BF'; P: @tbl_fpuDA_00BF; S: SizeOf(tbl_fpuDA_00BF)),
   (N: 'tbl_fpuDA_rest'; P: @tbl_fpuDA_rest; S: SizeOf(tbl_fpuDA_rest)),
   (N: 'tbl_fpuDB_00BF'; P: @tbl_fpuDB_00BF; S: SizeOf(tbl_fpuDB_00BF)),
   (N: 'tbl_fpuDB_rest'; P: @tbl_fpuDB_rest; S: SizeOf(tbl_fpuDB_rest)),
   (N: 'tbl_fpuDC_00BF'; P: @tbl_fpuDC_00BF; S: SizeOf(tbl_fpuDC_00BF)),
   (N: 'tbl_fpuDC_rest'; P: @tbl_fpuDC_rest; S: SizeOf(tbl_fpuDC_rest)),
   (N: 'tbl_fpuDD_00BF'; P: @tbl_fpuDD_00BF; S: SizeOf(tbl_fpuDD_00BF)),
   (N: 'tbl_fpuDD_rest'; P: @tbl_fpuDD_rest; S: SizeOf(tbl_fpuDD_rest)),
   (N: 'tbl_fpuDE_00BF'; P: @tbl_fpuDE_00BF; S: SizeOf(tbl_fpuDE_00BF)),
   (N: 'tbl_fpuDE_rest'; P: @tbl_fpuDE_rest; S: SizeOf(tbl_fpuDE_rest)),
   (N: 'tbl_fpuDF_00BF'; P: @tbl_fpuDF_00BF; S: SizeOf(tbl_fpuDF_00BF)),
   (N: 'tbl_fpuDF_rest'; P: @tbl_fpuDF_rest; S: SizeOf(tbl_fpuDF_rest)));

var
  tsRes:         TStringList;
  dwCount:       Integer;

procedure DumpTable(Index: Integer);
var  dwSize:     Integer;
     dwTotal:    Integer;
     dwCount:    Integer;
     dwIndex:    Integer;
     lpszData:   PChar;
     szLine:     String;
begin

  // Dump the table header
  tsRes.Add(Format('%s RCDATA', [tblPersist[Index].N]));
  tsRes.Add('{');

  // Prepare for dumping as hex
  lpszData:=tblPersist[Index].P;
  dwSize:=tblPersist[Index].S;
  dwTotal:=0;

  // Dump the data
  while (dwTotal < dwSize) do
  begin
     // Calculate the next 16 bytes (or whatever remains)
     if (dwSize-dwTotal < 16) then
        dwCount:=(dwSize-dwTotal)
     else
        dwCount:=16;
     // Build the hex string to dump
     szLine:='''';
     for dwIndex:=0 to Pred(dwCount) do
     begin
        if (dwIndex = Pred(dwCount)) then
           szLine:=szLine+Format('%.2x', [Ord(lpszData[dwIndex])])
        else
           szLine:=szLine+Format('%.2x ', [Ord(lpszData[dwIndex])]);
     end;
     szLine:=szLine+'''';
     // Dump the line
     tsRes.Add(szLine);
     // Increment for the next block
     Inc(dwTotal, dwCount);
     Inc(lpszData, dwCount);
  end;

  // Finish the table data block
  tsRes.Add('}');
  tsRes.Add('');
  
end;

// WinMain
begin

  // Create string list
  tsRes:=TStringList.Create;

  // Resource protection
  try
     // Dump table name defines
     for dwCount:=0 to High(tblPersist) do
        // Define table
        tsRes.Add(Format('#define %s%s%s', [tblPersist[dwCount].N, #9, tblPersist[dwCount].N]));
     tsRes.Add('');
     // Dump table data
     for dwCount:=0 to High(tblPersist) do
        // Dump table
        DumpTable(dwCount);
     // Dump the final resource
     tsRes.SaveToFile('DisAsm32.RC');
  finally
     // Free string list
     tsRes.Free;
  end;

end.