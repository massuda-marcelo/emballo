unit Emballo.DI.ProviderMethodBindingTests;

interface

uses
  TestFramework, Emballo.DI, Classes;

type
  TBar = class
  end;

  TFoo = class
    Bar: TBar;
  end;

  LogStream = class(TCustomAttribute)
  end;


  TPaymentProcessor = class
  private
    FLogStream: TStream;
  public
    property LogStream: TStream read FLogStream;
    constructor Create([LogStream] LogStream: TStream);
  end;

  TFooFactoryDelegate = reference to function(Bar: TBar): TFoo;

  TTestModule = class(TModule)
  private
    FLogStream: TStream;
  public
    FooFactoryDelegate: TFooFactoryDelegate;

    property LogStream: TStream read FLogStream write FLogStream;

    [FactoryMethod]
    function FooFactory(const Bar: TBar): TFoo;

    [LogStream]
    [FactoryMethod]
    function PaymentLogStream: TStream;

    procedure Configure; override;
  end;

  TProviderMethodBindingTests = class(TTestCase)
  published
    procedure TestProviderMethodBinding;
    procedure TestProviderMethodWithAttributes;
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

procedure TProviderMethodBindingTests.TestProviderMethodWithAttributes;
var
  Proc: TPaymentProcessor;
  Module: TTestModule;
  Injector: TInjector;
begin
  Module := TTestModule.Create;
  Module.LogStream := TMemoryStream.Create;
  Injector := TInjector.Create([Module]);
  Proc := Injector.GetInstance<TPaymentProcessor>;
  try
    CheckTrue(Proc.LogStream = Module.LogStream);
  finally
    Proc.Free;
  end;

  { We don't need to manualy free the memory stream, as the default behaviour for
    Emballo is to automaticaly free it whenever the object which received the
    dependency is freed }
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

function TTestModule.PaymentLogStream: TStream;
begin
  Result := FLogStream;
end;

{ TPaymentProcessor }

constructor TPaymentProcessor.Create(LogStream: TStream);
begin
  FLogStream := LogStream;
end;

initialization
RegisterTest('Emballo.DI', TProviderMethodBindingTests.Suite);

end.
