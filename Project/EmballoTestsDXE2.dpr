{   Copyright 2010 - Magno Machado Paulo (magnomp@gmail.com)

    This file is part of Emballo.

    Emballo is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Emballo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Emballo.
    If not, see <http://www.gnu.org/licenses/>. }

program EmballoTestsDXE2;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

{ Ensures that there will be RTTI for interfaces in cases where such info
  would be otherwise eliminated by the smart linker. See Barry Kelly's answer
  on http://stackoverflow.com/questions/2997761/delphi-rtti-unable-to-find-interface }
{$STRONGLINKTYPES ON}

uses
  FastMM4,
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  Emballo.DynamicProxy.ImplTests in '..\Tests\Emballo.DynamicProxy.ImplTests.pas',
  Emballo.DllWrapper.ImplTests in '..\Tests\Emballo.DllWrapper.ImplTests.pas',
  Emballo.Hash.Md5AlgorithmTests in '..\Tests\Emballo.Hash.Md5AlgorithmTests.pas',
  Emballo.SynteticClassTests in '..\Tests\Emballo.SynteticClassTests.pas',
  Emballo.Mock.MockTests in '..\Tests\Emballo.Mock.MockTests.pas',
  Emballo.DynamicProxy.InterfaceProxyTests in '..\Tests\Emballo.DynamicProxy.InterfaceProxyTests.pas',
  Emballo.Mock.EqualsParameterMatcherTests in '..\Tests\Emballo.Mock.EqualsParameterMatcherTests.pas',
  Emballo.DynamicProxy.MethodImplTests_Cdecl in '..\Tests\Emballo.DynamicProxy.MethodImplTests_Cdecl.pas',
  Emballo.DynamicProxy.MethodImplTests_Pascal in '..\Tests\Emballo.DynamicProxy.MethodImplTests_Pascal.pas',
  Emballo.DynamicProxy.MethodImplTests_Stdcall in '..\Tests\Emballo.DynamicProxy.MethodImplTests_Stdcall.pas',
  Emballo.DynamicProxy.MethodImplTests_Register in '..\Tests\Emballo.DynamicProxy.MethodImplTests_Register.pas',
  Emballo.RuntimeCodeGeneration.MethodInvokationInfoTests in '..\Tests\Emballo.RuntimeCodeGeneration.MethodInvokationInfoTests.pas',
  Emballo.DITests in '..\Tests\Emballo.DITests.pas',
  Emballo.DI.InjectorTests in '..\Tests\Emballo.DI.InjectorTests.pas',
  Emballo.DI.InjectorConstantTests in '..\Tests\Emballo.DI.InjectorConstantTests.pas',
  Emballo.DI.InstanceBindingTests in '..\Tests\Emballo.DI.InstanceBindingTests.pas';

{$R *.RES}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

