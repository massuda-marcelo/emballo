unit Emballo.DI.InstanceBindingTests;

interface

uses
  Emballo.DI, TestFramework, Rtti;

type
  TDependency = class

  end;

  TTestModule = class(TModule)
  private
    FDependency: TDependency;
  public
    procedure Configure; override;
    constructor Create(const Dependency: TDependency);
  end;

  TInstanceBindingTests = class(TTestCase)
  private
    FContext: TRttiContext;
    FDependency: TDependency;
    FModule: TModule;
    FBinding: IBindingRegistry;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestTryBuild;
  end;

implementation

{ TTestModule }

procedure TTestModule.Configure;
begin
  inherited;
  Bind(TDependency).ToInstance(FDependency);
end;

constructor TTestModule.Create(const Dependency: TDependency);
begin
  inherited Create;
  FDependency := Dependency;
end;

{ TInstanceBindingTests }

procedure TInstanceBindingTests.SetUp;
begin
  inherited;
  FContext := TRttiContext.Create;
  FDependency := TDependency.Create;
  FModule := TTestModule.Create(FDependency);
  FModule.Configure;
  FBinding := FModule.Bindings[0];
end;

procedure TInstanceBindingTests.TearDown;
begin
  inherited;
  FBinding := Nil;
  FModule.Free;
  FDependency.Free;
  FContext.Free;
end;

procedure TInstanceBindingTests.TestTryBuild;
var
  V: TValue;
begin
  CheckTrue(FBinding.TryBuild(TTypeInformation.Create(FContext.GetType(TDependency)), Nil, V));
  CheckEquals(TDependency, V.AsObject.ClassType);
  CheckTrue(FDependency = V.AsObject);
end;

initialization
RegisterTest('Emballo.DI', TInstanceBindingTests.Suite);

end.
