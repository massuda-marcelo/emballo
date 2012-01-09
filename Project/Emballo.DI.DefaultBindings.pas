unit Emballo.DI.DefaultBindings;

interface

uses
  Emballo.DI;

type
  AppPath = class(TCustomAttribute)
  end;

  IsDebugging = class(TCustomAttribute)
  end;

  TDefaultBindings = class(TModule)
  public
    procedure Configure; override;
  end;

implementation

{ TDefaultBindings }

procedure TDefaultBindings.Configure;
begin
  inherited;
  BindConstant(ParamStr(0)).ToAttribute(AppPath);
  BindConstant(DebugHook <> 0).ToAttribute(IsDebugging);
end;

end.
