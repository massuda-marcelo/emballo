unit Emballo.DI.InjectorConstantTests;

interface

uses
  TestFramework,
  Emballo.DI;

type
  TestAttr = class(TCustomAttribute)

  end;

  TFoo = class
  public
    FBar: String;
    constructor Create([TestAttr] Bar: String);
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
end;

{ TFoo }

constructor TFoo.Create(Bar: String);
begin
  FBar := Bar;
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
  finally
    Foo.Free;
  end;
end;

initialization
RegisterTest('Emballo.DI', TInjectorConstantTests.Suite);

end.
