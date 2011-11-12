unit Emballo.DITests;

interface

uses
  TestFramework, Emballo.DI, SysUtils, Rtti;

type
  TDelegateModule = class(TModule)
  public
    FDelegate: TProc;
    procedure Configure; override;
  end;

  TTestModule = class(TModule)
  public
    procedure Configure; override;
  end;

  TModuleTests = class(TTestCase)
  private
    FModule: TTestModule;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestBindings;
    procedure TestScopes;
  end;

  TInjectorImplTests = class(TTestCase)
  private
    FCtx: TRttiContext;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ShouldConfigureAllModulesOnInjectorCreation;
    procedure GetInstance;
    procedure TestScope;
  end;

  TMyScope = class(TScope)
  protected
    function Get(const Info: TRttiType): TValue; override;
  end;

  TDelegateScope = class(TScope)
  type
    TGet = reference to function(const Info: TRttiType): TValue;
  class var
    FGet: TGet;
  protected
    function Get(const Info: TRttiType): TValue; override;
  end;

  TAbstractFoo = class

  end;

  TConcreteFoo = class(TAbstractFoo)

  end;

  IBar = interface
    ['{22081868-7E42-4429-A8BD-2CB485E35CE0}']
  end;

  TBar = class(TInterfacedObject, IBar)

  end;

implementation

uses
  Emballo.Rtti;

function Delegate(const Proc: TProc): TDelegateModule;
begin
  Result := TDelegateModule.Create;
  Result.FDelegate := Proc;
end;

{ TModuleTests }

procedure TModuleTests.SetUp;
begin
  inherited;
  FModule := TTestModule.Create;
end;

procedure TModuleTests.TearDown;
begin
  inherited;
  FModule.Free;
end;

procedure TModuleTests.TestBindings;
//var
//  Binding: IBinding;
begin
//  FModule.Configure;
//  Binding := FModule.Bindings[0];
//  CheckTrue(TAbstractFoo.ClassInfo = Binding.BoundType.Handle);
//  CheckTrue(TConcreteFoo.ClassInfo = Binding.BoundToType.Handle);
//
//  Binding := FModule.Bindings[1];
//  CheckTrue(GetTypeInfoFromGUID(IBar) = Binding.BoundType.Handle);
//  CheckTrue(TBar.ClassInfo = Binding.BoundToType.Handle);
end;

procedure TModuleTests.TestScopes;
//var
//  Binding: IBinding;
begin
//  FModule.Configure;
//
//  Binding := FModule.Bindings[0];
//  CheckEquals(TDefaultScope, Binding.Scope, 'When not specified, a binding will be scoped by TDefaultScope');
//
//  Binding := FModule.Bindings[1];
//  CheckEquals(TMyScope, Binding.Scope);
end;

{ TTestModule }

procedure TTestModule.Configure;
begin
  inherited;
  Bind(TAbstractFoo).ToType(TConcreteFoo);
  Bind(IBar).ToType(TBar).InScope(TMyScope);
end;

{ TInjectorImplTests }

procedure TInjectorImplTests.GetInstance;
var
  Injector: IInjector;
  Ctx: TRttiContext;
  Bar: IInterface;
  Obj: TObject;
begin
  Injector := TInjectorImpl.Create([TTestModule.Create]);

  Ctx := TRttiContext.Create;
  try
    Obj := Injector.GetInstance(Ctx.GetType(TAbstractFoo)).AsObject;
    try
      CheckTrue(Obj.InheritsFrom(TConcreteFoo));
    finally
      Obj.Free;
    end;

    Bar := Injector.GetInstance(Ctx.GetType(TypeInfo(IBar))).AsInterface;
    CheckTrue(TObject(Bar).InheritsFrom(TBar));
  finally
    Ctx.Free;
  end;
end;

procedure TInjectorImplTests.SetUp;
begin
  inherited;
  FCtx := TRttiContext.Create;
end;

procedure TInjectorImplTests.ShouldConfigureAllModulesOnInjectorCreation;
var
  Injector: TInjectorImpl;
  M1, M2: TModule;
  Called1, Called2: Boolean;
begin
  Called1 := False;
  Called2 := False;
  M1 := Delegate(procedure
  begin
    Called1 := True;
  end);

  M2 := Delegate(procedure
  begin
    Called2 := True;
  end);

  Injector := TInjectorImpl.Create([M1, M2]);
  try
    CheckTrue(Called1);
    CheckTrue(Called2);
  finally
    Injector.Free;
  end;
end;

procedure TInjectorImplTests.TearDown;
begin
  inherited;
  FCtx.Free;
end;

procedure TInjectorImplTests.TestScope;
var
  Module: TModule;
  Injector: IInjector;
  FooInstance: TObject;
  BarInstance: IBar;
  ReturnedInstanceObj: TObject;
  ReturnedInstanceIntf: IBar;
  V: TValue;
begin
  Module := Delegate(procedure
  begin
    Module.Bind(TAbstractFoo).ToType(TConcreteFoo).InScope(TDelegateScope);
    Module.Bind(IBar).ToType(TBar).InScope(TDelegateScope);
  end);

  Injector := TInjectorImpl.Create([Module]);

  BarInstance := TBar.Create;

  FooInstance := TConcreteFoo.Create;
  V := TValue.From(FooInstance);
  try
    TDelegateScope.FGet := function(const Info: TRttiType): TValue
    begin
      CheckEquals(TAbstractFoo, Info.AsInstance.MetaclassType);
      Result := V;
    end;

    ReturnedInstanceObj := Injector.GetInstance(FCtx.GetType(TAbstractFoo)).AsObject;
    CheckTrue(FooInstance = ReturnedInstanceObj, 'If the scope has already an instance of the requested type, that instance should be returned');

    V := TValue.From(BarInstance);
    TDelegateScope.FGet := function(const Info: TRttiType): TValue
    begin
      Result := V;
    end;

    ReturnedInstanceIntf := Injector.GetInstance(FCtx.GetType(TypeInfo(IBar))).AsInterface as IBar;
    CheckTrue(BarInstance = ReturnedInstanceIntf, 'If the scope has already an instance of the requested type, that instance should be returned');
  finally
    FooInstance.Free;
  end;
end;

{ TDelegateModule }

procedure TDelegateModule.Configure;
begin
  inherited;
  FDelegate();
end;

{ TDelegateScope }

function TDelegateScope.Get(const Info: TRttiType): TValue;
begin
  Result := FGet(Info);
end;

{ TMyScope }

function TMyScope.Get(const Info: TRttiType): TValue;
begin
  Result := TValue.Empty;
end;

initialization
RegisterTest('Emballo.DI', TModuleTests.Suite);
RegisterTest('Emballo.DI', TInjectorImplTests.Suite);

end.
