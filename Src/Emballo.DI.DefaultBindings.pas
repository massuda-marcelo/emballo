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

  TVclModule = class(TModule)
  public
    procedure Configure; override;
  end;

implementation

uses
  Forms, Rtti, Classes;

type
  TFormOwnerBinding = class(TInterfacedObject, IBindingRegistry)
  public
    function TryBuild(Info: ITypeInformation;
      InstanceResolver: IInstanceResolver; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
  end;

{ TDefaultModule }

procedure TDefaultModule.Configure;
begin
  inherited;
  BindConstant(ParamStr(0)).ToAttribute(AppPath);
  BindConstant(DebugHook <> 0).ToAttribute(IsDebugging);
end;

{ TVclModule }

procedure TVclModule.Configure;
begin
  inherited;
  RegisterBinding(TFormOwnerBinding.Create);
end;

{ TFormOwnerBinding }

function TFormOwnerBinding.TryBuild(Info: ITypeInformation;
  InstanceResolver: IInstanceResolver; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
var
  Method: TRttiMethod;
begin
  Result := False;
  if not Info.RttiType.IsInstance then
    Exit;

  if Info.RttiType.AsInstance.MetaclassType <> TComponent then
    Exit;

  if not (Info.Parent is TRttiMethod) then
    Exit;

  Method := TRttiMethod(Info.Parent);

  if (Method.Parent is TRttiInstanceType) and (Info.Name = 'AOwner') then
  begin
    if TRttiInstanceType(Method.Parent).MetaclassType.InheritsFrom(TCustomForm) then
    begin
      Value := TValue.From(Application);
      ReleaseProc := TReleaseProcedures.DO_NOTHING();
      Result := True;
    end;
  end;


end;

end.
