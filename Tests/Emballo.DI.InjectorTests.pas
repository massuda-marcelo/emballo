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
    procedure InjectInjectorItSelf;
    procedure GetInstanceInterface;
  end;

  TSeccondClass = class
  public
    constructor Create;
  end;

  IFoo = interface
    ['{58DB334F-1C83-4062-99E4-2AB37EF8F280}']
    procedure DoSomething;
  end;

  TFoo = class(TInterfacedObject, IFoo)
    procedure DoSomething;
  end;

  TFirstClass = class
  public
    FSeccondClass: TSeccondClass;
    constructor Create(const SeccondClass: TSeccondClass; const Foo: IFoo);
  end;

  TClassThatDependsOnTheInjector = class
  public
    FInjector: TInjector;
    constructor Create(const Injector: TInjector);
  end;

implementation

{ TFirstClass }

constructor TFirstClass.Create(const SeccondClass: TSeccondClass; const Foo: IFoo);
begin
  FSeccondClass := SeccondClass;
end;

{ TInjectorTests }

procedure TInjectorTests.GetInstanceInterface;
var
  Injector: TInjector;
  Foo: IFoo;
begin
  Injector := TInjector.Create([TTestModule.Create]);
  Foo := Injector.GetInstance<IFoo>;
  Foo.DoSomething;
end;

procedure TInjectorTests.InjectInjectorItSelf;
var
  Injector: TInjector;
  Instance: TClassThatDependsOnTheInjector;
begin
  Injector := TInjector.Create([]);
  Instance := Injector.GetInstance<TClassThatDependsOnTheInjector>;
  try
    CheckNotNull(Instance);
    CheckTrue(Instance.FInjector.IsInitialized);
  finally
    Instance.Free;
  end;
end;

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

{ TClassThatDependsOnTheInjector }

constructor TClassThatDependsOnTheInjector.Create(const Injector: TInjector);
begin
  FInjector := Injector;
end;

{ TFoo }

procedure TFoo.DoSomething;
begin

end;

initialization
RegisterTest('Emballo.DI', TInjectorTests.Suite);

end.
