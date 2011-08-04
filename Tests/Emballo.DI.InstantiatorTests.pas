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

unit Emballo.DI.InstantiatorTests;

interface

uses
  TestFramework, Emballo.DI.Instantiator;

type
  TInstantiatorHack = class(TInstantiator)
  end;

  TInstantiatorTests = class(TTestCase)
  private
    FInstantiator: TInstantiatorHack;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestEnumConstructors;
    procedure TestInstantiate;
    procedure TestInstantiateClassWithConstructorDependencies;
  end;

implementation

uses
  Rtti,
  Emballo.DI.Registry;

type
  TTestClassA = class
  public
    constructor OneConstructorFromA;
    constructor AnotherConstructorFromA;
  end;

  TTestClassB = class(TTestClassA)
  end;

  TTestClassWithNoSuitableConstructor = class
  public
    FA: Integer;
    constructor Create(A: Integer);
  end;

  IDependency = interface
    ['{EF09895F-433F-4A0F-84B3-A974889EC2E1}']
  end;

  TDependencyImpl = class(TInterfacedObject, IDependency)

  end;

  TTestClassWithConstructorDependencies = class
  public
    constructor Create(const Dependency: IDependency);
  end;

{ TInstantiatorTests }

procedure TInstantiatorTests.SetUp;
begin
  inherited;
  RegisterFactory(IDependency, TDependencyImpl).Done;
  FInstantiator := TInstantiatorHack.Create;
end;

procedure TInstantiatorTests.TearDown;
begin
  inherited;
  FInstantiator.Free;
  ClearRegistry;
end;

procedure TInstantiatorTests.TestEnumConstructors;
  function ConstructorExists(const Name: String;
    Constructors: TArray<TRttiMethod>): Boolean;
  var
    Ctor: TRttiMethod;
  begin
    Result := False;
    for Ctor in Constructors do
    begin
      Result := Ctor.Name = Name;
      if Result then
        Exit;
    end;
  end;
var
  Constructors: TArray<TRttiMethod>;
begin
  Constructors := FInstantiator.EnumConstructors(TTestClassB);
  CheckEquals(2, Length(Constructors));
  CheckTrue(ConstructorExists('OneConstructorFromA', Constructors));
  CheckTrue(ConstructorExists('AnotherConstructorFromA', Constructors));
end;

procedure TInstantiatorTests.TestInstantiate;
begin
  try
    FInstantiator.Instantiate(TTestClassWithNoSuitableConstructor);
    Fail('Instantiating a class with no suitable constructor should raise an ENoSuitableConstructor');
  except
    on ENoSuitableConstructor do CheckTrue(True);
  end;
end;

procedure TInstantiatorTests.TestInstantiateClassWithConstructorDependencies;
var
  Obj: TObject;
begin
  Obj := FInstantiator.Instantiate(TTestClassWithConstructorDependencies);
  try
    CheckEquals(TTestClassWithConstructorDependencies, Obj.ClassType, 'The returned instance should be of the requested class');
  finally
    Obj.Free;
  end;
end;

{ TTestClassA }

constructor TTestClassA.AnotherConstructorFromA;
begin

end;

constructor TTestClassA.OneConstructorFromA;
begin

end;

{ TTestClassWithNoSuitableConstructor }

constructor TTestClassWithNoSuitableConstructor.Create(A: Integer);
begin
  FA := A;
end;

{ TTestClassWithConstructorDependencies }

constructor TTestClassWithConstructorDependencies.Create(
  const Dependency: IDependency);
begin

end;

initialization
RegisterTest('Emballo.DI', TInstantiatorTests.Suite);

end.
