//************************************************************************
//Win32 CodeHook 1.0.0
//http://www.kbasm.com/
//
//The contents of this file are subject to the Mozilla Public License
//Version 1.1 (the "License"); you may not use this file except in
//compliance with the License.
//You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
//Software distributed under the License is distributed on an "AS IS" basis,
//WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
//for the specific language governing rights and limitations under the
//License.
//
//The Original Code is CHook.dpr
//
//The Initial Developer of the Original Code is Wang Qi.
//************************************************************************


library CHook;

uses
  SysUtils,
  Classes,
  CodeHookIntf, CodeHook;

{$R *.res}

procedure GetCodeHook(Obj: PPointer); stdcall;
begin
  Obj^ := Pointer(CodeHook.GetCodeHookIntf);
end;

exports
  GetCodeHook;

begin
end.

