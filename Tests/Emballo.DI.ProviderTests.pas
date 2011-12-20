unit Emballo.DI.ProviderTests;

interface

uses
  TestFramework, Emballo.DI;

type
  TFoo = class
  public
    constructor Create;
    class var Instantiated: Boolean;
  end;

  TBar = class
  public
    class var FFoo: TProvider<TFoo>;
    constructor Create(Foo: TProvider<TFoo>);
  end;

  TProviderTests = class(TTestCase)
  published
    procedure TestProviderImplicit;
  end;

implementation

{ TProviderTests }

procedure TProviderTests.TestProviderImplicit;
var
  Injector: TInjector;
  Bar: TBar;
  Foo: TFoo;
begin
  TFoo.Instantiated := False;
  Injector := TInjector.Create([]);
  Bar := Injector.GetInstance<TBar>;
  try
    CheckFalse(TFoo.Instantiated);
    Foo := Bar.FFoo().AsType<TFoo>; // Calling the provider should force the dependency to be created
    CheckTrue(TFoo.Instantiated);
  finally
    Foo.Free;
    Bar.Free;
  end;
end;

{ TFoo }

constructor TFoo.Create;
begin
  Instantiated := True;
end;

{ TBar }

constructor TBar.Create(Foo: TProvider<TFoo>);
begin
  FFoo := Foo;
end;

initialization
RegisterTest('Emballo.DI', TProviderTests.Suite);

end.
