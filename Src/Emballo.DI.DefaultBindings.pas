unit Emballo.DI.DefaultBindings;

interface

uses
  Emballo.DI;

type
  AppPath = class(TCustomAttribute)
  end;

  IsDebugging = class(TCustomAttribute)
  end;

  TDefaultModule = class(TModule)
  public
    procedure Configure; override;
  end;

implementation

{ TDefaultModule }

procedure TDefaultModule.Configure;
begin
  inherited;
  BindConstant(ParamStr(0)).ToAttribute(AppPath);
  BindConstant(DebugHook <> 0).ToAttribute(IsDebugging);
end;

end.
