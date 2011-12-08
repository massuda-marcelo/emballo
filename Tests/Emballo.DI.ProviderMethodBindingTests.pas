unit Emballo.DI.ProviderMethodBindingTests;

interface

uses
  TestFramework, Emballo.DI;

type
  TBar = class
  end;

  TFoo = class
    Bar: TBar;
  end;

  TFooFactoryDelegate = reference to function(Bar: TBar): TFoo;

  TTestModule = class(TModule)
  public
    FooFactoryDelegate: TFooFactoryDelegate;

    [FactoryMethod]
    function FooFactory(const Bar: TBar): TFoo;
    procedure Configure; override;
  end;

  TProviderMethodBindingTests = class(TTestCase)
  published
    procedure TestProviderMethodBinding;
  end;

implementation

{ TProviderMethodBindingTests }

procedure TProviderMethodBindingTests.TestProviderMethodBinding;
var
  Injector: TInjector;
  Foo: TFoo;
  Module: TTestModule;
  ReturnedInstance: TFoo;
begin
  Module := TTestModule.Create;
  Module.FooFactoryDelegate := function(Bar: TBar): TFoo
  begin
    Result := TFoo.Create;
    Result.Bar := Bar;
    ReturnedInstance := Result;
  end;

  Injector := TInjector.Create([Module]);
  Foo := Injector.GetInstance<TFoo>;
  CheckTrue(Foo = ReturnedInstance);
  CheckNotNull(Foo.Bar);
  Foo.Free;
end;

{ TTestModule }

procedure TTestModule.Configure;
begin
  inherited;
end;

function TTestModule.FooFactory(const Bar: TBar): TFoo;
begin
  Result := FooFactoryDelegate(Bar);
end;

initialization
RegisterTest('Emballo.DI', TProviderMethodBindingTests.Suite);

end.
