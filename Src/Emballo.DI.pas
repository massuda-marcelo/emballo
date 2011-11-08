unit Emballo.DI;

interface

uses
  Rtti, Generics.Collections;

type
  TScope = class abstract
  protected
    function GetInstanceAsObject(const Info: TRttiType): TObject; virtual; abstract;
    function GetInstanceAsInterface(const Info: TRttiType): IInterface; virtual; abstract;
  end;
  TScopeClass = class of TScope;

  TDefaultScope = class(TScope)
  protected
    function GetInstanceAsInterface(const Info: TRttiType): IInterface;
      override;
    function GetInstanceAsObject(const Info: TRttiType): TObject; override;
  end;

  IBinding = interface
    ['{A9A4F8A0-A317-4C35-B9AE-92BD6F242A6C}']
    function GetBoundType: TRttiType;
    function GetBoundToType: TRttiType;
    function GetScopeClass: TScopeClass;

    property BoundType: TRttiType read GetBoundType;
    property BoundToType: TRttiType read GetBoundToType;
    property Scope: TScopeClass read GetScopeClass;
  end;

  IInjector = interface
    ['{EA362B67-A4B9-43E4-B098-77DEF8982303}']
    function GetInstanceAsObject(const Info: TRttiType): TObject;
    function GetInstanceAsInterface(const Info: TRttiType): IInterface;
  end;

  TBinder = class(TObject, IBinding)
  private
    FBoundType: TRttiType;
    FBoundToType: TRttiType;
    FScopeClass: TScopeClass;
    FRttiContext: TRttiContext;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function GetBoundType: TRttiType;
    function GetBoundToType: TRttiType;
    function GetScopeClass: TScopeClass;
    function GetInstanceAsObject(const Injector: IInjector): TObject;
    function GetInstanceAsInterface(const Injector: IInjector): IInterface;
  public
    function ToType(const AClass: TClass): TBinder;
    function InScope(const ScopeClass: TScopeClass): TBinder;
    constructor Create(const BoundType: TClass); overload;
    constructor Create(const BoundType: TGUID); overload;
    destructor Destroy; override;
  end;

  TModule = class abstract
  private
    FBindings: TList<TBinder>;
    FRttiContext: TRttiContext;
    function GetBinding(Index: Integer): IBinding;
  public
    constructor Create;
    destructor Destroy; override;
    property Bindings[Index: Integer]: IBinding read GetBinding;
    function Bind(const AClass: TClass): TBinder; overload;
    function Bind(const AGUID: TGUID): TBinder; overload;
    procedure Configure; virtual; abstract;
  end;

  TInjector = record
  private
    FInjector: IInjector;
  public
    function GetInstance<T>: T;
    constructor Create(const Modules: array of TModule);
  end;

  TInjectorImpl = class(TInterfacedObject, IInjector)
  private
    FModules: array of TModule;
    FScopes: TDictionary<TScopeClass, TScope>;
    FImplicitBindings: TList<TBinder>;
    FCtx: TRttiContext;
    function Instantiate(const AClass: TClass): TObject;
    function GetScope(const ScopeClass: TScopeClass): TScope;
    function GetBinder(const Info: TRttiType): TBinder;
    function GetInstanceAsObject(const Info: TRttiType): TObject;
    function GetInstanceAsInterface(const Info: TRttiType): IInterface;
  public
    constructor Create(const Modules: array of TModule);
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  Emballo.Rtti,
  TypInfo,
  Emballo.SynteticClass;

var
  Ctx: TRttiContext;

{ TInjectorImpl }

constructor TInjectorImpl.Create(const Modules: array of TModule);
var
  Module: TModule;
  i: Integer;
begin
  FCtx := TRttiContext.Create;
  FImplicitBindings := TList<TBinder>.Create;
  FScopes := TDictionary<TScopeClass, TScope>.Create;

  SetLength(FModules, Length(Modules));
  for i := 0 to High(Modules) do
  begin
    FModules[i] := Modules[i];
    FModules[i].Configure;
  end;
end;

destructor TInjectorImpl.Destroy;
var
  O: TObject;
begin
  for O in FModules do
    O.Free;

  for O in FScopes.Values do
    O.Free;

  FScopes.Free;

  for O in FImplicitBindings do
    O.Free;
  FImplicitBindings.Free;

  FCtx.Free;
  inherited;
end;

function TInjectorImpl.GetBinder(const Info: TRttiType): TBinder;
var
  Module: TModule;
begin
  for Module in FModules do
  begin
    for Result in Module.FBindings do
    begin
      if Result.GetBoundType.Equals(Info) then
        Exit;
    end;
  end;

  for Result in FImplicitBindings do
  begin
    if Result.GetBoundType.Equals(Info) then
      Exit;
  end;

  if Info.IsInstance then
  begin
    Result := TBinder.Create(Info.AsInstance.MetaclassType);
    Result.ToType(Info.AsInstance.MetaclassType);
    FImplicitBindings.Add(Result);
  end
  else
    Result := Nil;
end;

function TInjectorImpl.GetInstanceAsInterface(
  const Info: TRttiType): IInterface;
var
  Module: TModule;
  Binder: TBinder;
  Scope: TScope;
begin
  Binder := GetBinder(Info);
  Scope := GetScope(Binder.GetScopeClass);
  Result := Scope.GetInstanceAsInterface(Info);
  if Result = Nil then
  begin
    Supports(Instantiate(Binder.GetBoundToType.AsInstance.MetaclassType), IInterface, Result);
//    Result._Release;
  end;
end;

function TInjectorImpl.GetInstanceAsObject(const Info: TRttiType): TObject;
var
  Module: TModule;
  Binder: TBinder;
  Scope: TScope;
begin
  Binder := GetBinder(Info);
  Scope := GetScope(Binder.GetScopeClass);
  Result := Scope.GetInstanceAsObject(Info);
  if Result = Nil then
    Result := Instantiate(Binder.GetBoundToType.AsInstance.MetaclassType);
end;

function TInjectorImpl.GetScope(const ScopeClass: TScopeClass): TScope;
begin
  if not FScopes.TryGetValue(ScopeClass, Result) then
  begin
    Result := ScopeClass.NewInstance as TScope;
    FScopes.Add(ScopeClass, Result);
  end;
end;

function TInjectorImpl.Instantiate(const AClass: TClass): TObject;
var
  M: TRttiMethod;
  ArgsValues: TArray<TValue>;
  Args: TArray<TRttiParameter>;
  i: Integer;
  SC: TSynteticClass;
  ObjectsToFree: TList<TObject>;
  ParamIntf: IInterface;
  Aux: Pointer;
  Curr: TClass;
begin
  SC := TSynteticClass.Create(AClass.ClassName + '_EnhancedByEmballo', AClass, SizeOf(Pointer), Nil, True);
  SC.Finalizer := procedure(const Instance: TObject)
  var
    Data: Pointer;
    List: TList<TObject>;
    O: TObject;
  begin
    Data := GetAditionalData(Instance);
    List := TList<TObject>(Data^);
    for O in List do
      O.Free;

    List.Free;
  end;

  Curr := AClass;
  while True do
  begin
    for M in FCtx.GetType(Curr).AsInstance.GetDeclaredMethods do
    begin
      if M.IsConstructor then
      begin
        ObjectsToFree := TList<TObject>.Create;
        Args := M.GetParameters;
        SetLength(ArgsValues, Length(Args));
        for i := 0 to Length(Args) - 1 do
        begin
          if Args[i].ParamType.IsInstance then
          begin
            ArgsValues[i] := TValue.From(Self.GetInstanceAsObject(Args[i].ParamType));
            ObjectsToFree.Add(ArgsValues[i].AsObject);
          end
          else
          begin
            ParamIntf := Self.GetInstanceAsInterface(Args[i].ParamType);
            Supports(ParamIntf, (Args[i].ParamType as TRttiInterfaceType).GUID, Aux);
            TValue.Make(@Aux, Args[i].ParamType.Handle, ArgsValues[i]);
            ParamIntf._Release;
          end;
        end;

        Result := M.Invoke(SC.Metaclass, ArgsValues).AsObject;
        SetAditionalData(Result, ObjectsToFree);
        Exit;
      end;
    end;
    Curr := Curr.ClassParent;
  end;
end;

{ TModule }

function TModule.Bind(const AClass: TClass): TBinder;
begin
  Result := TBinder.Create(AClass);
  FBindings.Add(Result);
end;

function TModule.Bind(const AGUID: TGUID): TBinder;
begin
  Result := TBinder.Create(AGUID);
  FBindings.Add(Result);
end;

constructor TModule.Create;
begin
  FBindings := TList<TBinder>.Create;
  FRttiContext := TRttiContext.Create;
end;

destructor TModule.Destroy;
var
  Binder: TBinder;
begin
  for Binder in FBindings do
      Binder.Free;

  FBindings.Free;
  FRttiContext.Free;
  inherited;
end;

function TModule.GetBinding(Index: Integer): IBinding;
begin
  Result := FBindings[Index];
end;

{ TBinder }

constructor TBinder.Create(const BoundType: TClass);
begin
  FRttiContext := TRttiContext.Create;
  FScopeClass := TDefaultScope;
  FBoundType := FRttiContext.GetType(BoundType);
end;

constructor TBinder.Create(const BoundType: TGUID);
begin
  FRttiContext := TRttiContext.Create;
  FScopeClass := TDefaultScope;
  FBoundType := GetRttiTypeFromGUID(Ctx, BoundType);
end;

destructor TBinder.Destroy;
begin
  FRttiContext.Free;
  inherited;
end;

function TBinder.GetBoundToType: TRttiType;
begin
  Result := FBoundToType;
end;


function TBinder.GetBoundType: TRttiType;
begin
  Result := FBoundType;
end;

function TBinder.GetInstanceAsInterface(const Injector: IInjector): IInterface;
var
  Obj: TObject;
begin
  Obj := GetInstanceAsObject(Injector);
  Supports(Obj, IInterface, Result);
  Result._Release;
end;

function TBinder.GetInstanceAsObject(const Injector: IInjector): TObject;
begin
  Result := FBoundToType.AsInstance.MetaclassType.NewInstance;
end;

function TBinder.GetScopeClass: TScopeClass;
begin
  Result := FScopeClass;
end;

function TBinder.InScope(const ScopeClass: TScopeClass): TBinder;
begin
  FScopeClass := ScopeClass;
  REsult := Self;
end;

function TBinder.ToType(const AClass: TClass): TBinder;
begin
  FBoundToType := FRttiContext.GetType(AClass);
  Result := Self;
end;

function TBinder.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TBinder._AddRef: Integer;
begin
  Result := -1;
end;

function TBinder._Release: Integer;
begin
  Result := -1;
end;

{ TInjector }

constructor TInjector.Create(const Modules: array of TModule);
begin
  FInjector := TInjectorImpl.Create(Modules);
end;

function TInjector.GetInstance<T>: T;
var
  Info: TRttiType;
  Ctx: TRttiContext;
begin
  Ctx := TRttiContext.Create;
  try
    Info := Ctx.GetType(TypeInfo(T));
    if Info.IsInstance then
      Result := T(FInjector.GetInstanceAsObject(Info));
  finally
    Ctx.Free;
  end;
end;

{ TDefaultScope }

function TDefaultScope.GetInstanceAsInterface(
  const Info: TRttiType): IInterface;
begin
  { The default scope behaviour is that nothing is scopped }
  Result := Nil;
end;

function TDefaultScope.GetInstanceAsObject(const Info: TRttiType): TObject;
begin
  { The default scope behaviour is that nothing is scopped }
  Result := Nil;
end;

initialization
Ctx := TRttiContext.Create;
Ctx.GetType(TObject);

finalization
Ctx.Free;

end.
