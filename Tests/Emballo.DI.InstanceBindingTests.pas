unit Emballo.DI.InstanceBindingTests;

interface

uses
  Emballo.DI, TestFramework, Rtti;

type
  TDependency = class

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
  ReleaseProc: TReleaseProcedure;
  Dependency: TDependency;
  Module: TModule;
  Binding: IBindingRegistry;
begin
  Dependency := TDependency.Create;
  Module := TTestModuleReleaseInstance.Create(Dependency);
  Module.Configure;
  Binding := Module.Bindings[0];

  CheckTrue(Binding.TryBuild(TTypeInformation.FromType(FContext.GetType(TDependency)), Nil, V, ReleaseProc));
  CheckEquals(TDependency, V.AsObject.ClassType);
  CheckTrue(Dependency = V.AsObject);

  Binding := Nil;
  Module.Free;
end;

procedure TInstanceBindingTests.TestTryBuild;
var
  V: TValue;
  ReleaseProc: TReleaseProcedure;
  Dependency: TDependency;
  Module: TModule;
  Binding: IBindingRegistry;
begin
  Dependency := TDependency.Create;
  Module := TTestModuleDontReleaseInstance.Create(Dependency);
  Module.Configure;
  Binding := Module.Bindings[0];

  CheckTrue(Binding.TryBuild(TTypeInformation.FromType(FContext.GetType(TDependency)), Nil, V, ReleaseProc));
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

initialization
RegisterTest('Emballo.DI', TInstanceBindingTests.Suite);

end.
