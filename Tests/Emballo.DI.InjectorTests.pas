unit Emballo.DI.InjectorTests;

interface

uses
  TestFramework, Emballo.DI;

type
  TTestModule = class(TModule)
  public
    procedure Configure; override;
  end;

  TInjectorTests = class(TTestCase)
  published
    procedure InstantiateWithDependencies;
  end;

  TSeccondClass = class
  public
    constructor Create;
  end;

  IFoo = interface
    ['{58DB334F-1C83-4062-99E4-2AB37EF8F280}']
  end;

  TFoo = class(TInterfacedObject, IFoo)

  end;

  TFirstClass = class
  public
    FSeccondClass: TSeccondClass;
    constructor Create(const SeccondClass: TSeccondClass; const Foo: IFoo);
  end;

implementation

{ TFirstClass }

constructor TFirstClass.Create(const SeccondClass: TSeccondClass; const Foo: IFoo);
begin
  FSeccondClass := SeccondClass;
end;

{ TInjectorTests }

procedure TInjectorTests.InstantiateWithDependencies;
var
  Injector: TInjector;
  FC: TFirstClass;
begin
  Injector := TInjector.Create([TTestModule.Create]);
  FC := Injector.GetInstance<TFirstClass>;
  try
    CheckNotNull(FC);
    CheckNotNull(FC.FSeccondClass);
  finally
    FC.Free;
  end;
end;

{ TSeccondClass }

constructor TSeccondClass.Create;
begin

end;

{ TTestModule }

procedure TTestModule.Configure;
begin
  inherited;
  Bind(IFoo).ToType(TFoo);
end;

initialization
RegisterTest('Emballo.DI', TInjectorTests.Suite);

end.
