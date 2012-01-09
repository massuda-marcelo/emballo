unit Emballo.DI.InjectorConstantTests;

interface

uses
  TestFramework,
  Emballo.DI;

type
  TestAttr = class(TCustomAttribute)

  end;

  TestAttr2 = class(TCustomAttribute)

  end;

  TFoo = class
  public
    FBar: String;
    FFoo: String;
    constructor Create([TestAttr] Bar: String; [TestAttr2] Foo: String);
  end;

  TInjectorConstantTests = class(TTestCase)
  published
    procedure TestConstants;
  end;

  TConstantTestModule = class(TModule)
  public
    procedure Configure; override;
  end;

implementation

{ TConstantTestModule }

procedure TConstantTestModule.Configure;
begin
  inherited;
  BindConstant('Emballo Rocks').ToAttribute(TestAttr);
  BindConstant('Star Wars too =)').ToAttribute(TestAttr2);
end;

{ TFoo }

constructor TFoo.Create(Bar: String; Foo: String);
begin
  FBar := Bar;
  FFoo := Foo;
end;

{ TInjectorConstantTests }

procedure TInjectorConstantTests.TestConstants;
var
  Injector: TInjector;
  Foo: TFoo;
begin
  Injector := TInjector.Create([TConstantTestModule.Create]);
  Foo := Injector.GetInstance<TFoo>;
  try
    CheckEquals('Emballo Rocks', Foo.FBar);
    CheckEquals('Star Wars too =)', Foo.FFoo);
  finally
    Foo.Free;
  end;
end;

initialization
RegisterTest('Emballo.DI', TInjectorConstantTests.Suite);

end.
