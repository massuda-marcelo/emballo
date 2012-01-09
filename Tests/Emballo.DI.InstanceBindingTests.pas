unit Emballo.DI.InstanceBindingTests;

interface

uses
  Emballo.DI, TestFramework, Rtti;

type
  TDependency = class
    Str: String;
  end;

  TFoo = class
  public
    Dep: TDependency;
    constructor Create(Dep: TDependency);
  end;

  TTestModuleReleaseInstance = class(TModule)
  private
    FDependency: TDependency;
  public
    procedure Configure; override;
    constructor Create(const Dependency: TDependency);
  end;

  TTestModuleDontReleaseInstance = class(TModule)
  private
    FDependency: TDependency;
  public
    procedure Configure; override;
    constructor Create(const Dependency: TDependency);
  end;

  TInstanceBindingTests = class(TTestCase)
  private
    FContext: TRttiContext;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestTryBuild;
    procedure TestReuseInstance;
    procedure TestReleaseInstance;
  end;

implementation

{ TTestModuleReleaseInstance }

procedure TTestModuleReleaseInstance.Configure;
begin
  inherited;
  Bind(TDependency).ToInstance(FDependency);
end;

constructor TTestModuleReleaseInstance.Create(const Dependency: TDependency);
begin
  inherited Create;
  FDependency := Dependency;
end;

{ TInstanceBindingTests }

procedure TInstanceBindingTests.SetUp;
begin
  inherited;
  FContext := TRttiContext.Create;
end;

procedure TInstanceBindingTests.TearDown;
begin
  inherited;
  FContext.Free;
end;

procedure TInstanceBindingTests.TestReleaseInstance;
var
  V: TValue;
  DependenciesReleaseProc, InstanceReleaseProc: TReleaseProcedure;
  Dependency: TDependency;
  Module: TModule;
  Binding: IBindingRegistry;
begin
  Dependency := TDependency.Create;
  Module := TTestModuleReleaseInstance.Create(Dependency);
  Module.Configure;
  Binding := Module.Bindings[0];

  CheckTrue(Binding.TryBuild(TTypeInformation.FromType(FContext.GetType(TDependency)), Nil, V, DependenciesReleaseProc, InstanceReleaseProc));
  CheckEquals(TDependency, V.AsObject.ClassType);
  CheckTrue(Dependency = V.AsObject);

  Binding := Nil;
  Module.Free;
end;

procedure TInstanceBindingTests.TestReuseInstance;
var
  V: TValue;
  ReleaseProc: TReleaseProcedure;
  Dependency: TDependency;
  Module: TModule;
  Binding: IBindingRegistry;
  Injector: TInjector;
  Foo: TFoo;
begin
  Dependency := TDependency.Create;
  Module := TTestModuleReleaseInstance.Create(Dependency);
  Injector := TInjector.Create([Module]);

  Dependency.Str := 'ET phone home';

  { First, simply instantiate TFoo and free it. This is to see if the framework
    won't free the TDependency instance as it would normaly do with other
    dependencies }
  Foo := Injector.GetInstance<TFoo>;
  try
    CheckTrue(Foo.Dep = Dependency);
  finally
    Foo.Free;
  end;

  { If the TDependency object was freed, the check above will fail }
  Foo := Injector.GetInstance<TFoo>;
  try
    CheckEquals('ET phone home', Foo.Dep.Str);
  finally
    Foo.Free;
  end;

end;

procedure TInstanceBindingTests.TestTryBuild;
var
  V: TValue;
  DependenciesReleaseProc, InstanceReleaseProc: TReleaseProcedure;
  Dependency: TDependency;
  Module: TModule;
  Binding: IBindingRegistry;
begin
  Dependency := TDependency.Create;
  Module := TTestModuleDontReleaseInstance.Create(Dependency);
  Module.Configure;
  Binding := Module.Bindings[0];

  CheckTrue(Binding.TryBuild(TTypeInformation.FromType(FContext.GetType(TDependency)), Nil, V, DependenciesReleaseProc, InstanceReleaseProc));
  CheckEquals(TDependency, V.AsObject.ClassType);
  CheckTrue(Dependency = V.AsObject);

  Binding := Nil;
  Module.Free;
  Dependency.Free;
end;

{ TTestModuleDontReleaseInstance }

procedure TTestModuleDontReleaseInstance.Configure;
begin
  inherited;
  Bind(TDependency).ToInstance(FDependency).AndDontReleaseInstance;
end;

constructor TTestModuleDontReleaseInstance.Create(
  const Dependency: TDependency);
begin
  inherited Create;
  FDependency := Dependency;
end;

{ TFoo }

constructor TFoo.Create(Dep: TDependency);
begin
  Self.Dep := Dep;
end;

initialization
RegisterTest('Emballo.DI', TInstanceBindingTests.Suite);

end.
