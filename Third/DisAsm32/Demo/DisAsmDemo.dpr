program DisAsmDemo;
{$APPTYPE CONSOLE}

// Includes
uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  SysUtils,
  DisAsm32;

// Disassembler object
var
  daCode:        TDisAsm;
  dwCount:       Integer;

begin

  // Create the disassembler object
  daCode:=TDisAsm.Create;

  // Disassemble the code from the DisAsm unit
  daCode.Disassemble(@DisassembleAddress);

  // Display information
  WriteLn(Format('Base Address        : %p', [daCode.BaseAddress]));
  WriteLn(Format('Disassembled Size   : %d', [daCode.Size]));
  WriteLn(Format('Instruction Count   : %d', [daCode.Count]));
  WriteLn(Format('Function            : %s', ['DisassembleAddress']));
  WriteLn;
  WriteLn('Press Enter to display the assembly listing...');
  Readln;

  // Display the code
  for dwCount:=0 to Pred(daCode.Count) do
  begin
     // Display the address / size / asm listing
     Write(Format('%p ', [daCode[dwCount].Address]));
     Write(Format('%.2d ', [daCode[dwCount].Code.Size]));
     WriteLn(daCode[dwCount].Code.szText);
  end;

  // Done
  WriteLn;
  WriteLn('Press Enter to end the demo...');
  Readln;

  // Free the disassembler object
  daCode.Free;

end.