unit Emballo.DI.InstanceBinding;

interface

uses
  Emballo.DI, TestFramework;

type
  TDependency = class

  end;

  TTestModule = class(TModule)
  public
    procedure Configure; override;
  end;

  TInstanceBindingTests = class

  end;

implementation

{ TTestModule }

procedure TTestModule.Configure;
begin
  inherited;
  Bind(
end;

end.
