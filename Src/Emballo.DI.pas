unit Emballo.DI;

interface

uses
  Rtti, Generics.Collections, Emballo.General, TypInfo;

type
  TReleaseProcedure = reference to procedure(const Obj: TObject);

  TReleaseProcedures = class
  public
    class function FREE: TReleaseProcedure;
    class function DO_NOTHING: TReleaseProcedure;
  end;

  TScope = class abstract
  protected
    function Get(const Info: TRttiType): TValue; virtual; abstract;
  end;
  TScopeClass = class of TScope;

  IInstanceResolver = interface
    function ResolveType(const RequestedType: TRttiType; const ClassType: TRttiInstanceType; const ScopeClass: TScopeClass): TValue;
  end;

  ITypeInformation = interface
    ['{ADA7CF05-4489-42A9-9F79-16632CECF778}']
    function GetRttiType: TRttiType;
    function GetName: String;
    function GetParent: TRttiObject;

    property RttiType: TRttiType read GetRttiType;
    property Parent: TRttiObject read GetParent;
    property Name: String read GetName;
  end;

  TTypeInformation = class(TInterfacedObject, ITypeInformation)
  private
    FRttiType: TRttiType;
    FName: String;
    FParent: TRttiObject;

    function GetRttiType: TRttiType;
    function GetName: String;
    function GetParent: TRttiObject;
    constructor Create(const AType: TRttiType; const AName: String; const AParent: TRttiObject);
  public
    class function FromType(const AType: TRttiType): ITypeInformation;
    class function Fromparameter(const AParameter: TRttiParameter): ITypeInformation;
  end;

  TDefaultScope = class(TScope)
  protected
    function Get(const Info: TRttiType): TValue; override;
  end;

  IConstantBinding = interface
    ['{8F1031D7-5956-45BA-A146-A72E14EF3808}']
    function GetValue: TValue;
    function GetAttribute: TCustomAttributeClass;

    property Value: TValue read GetValue;
    property Attribute: TCustomAttributeClass read GetAttribute;
  end;

  IClassBinding = interface
    ['{999A7A59-0B73-4899-879A-5A4E7A2AF7B1}']
    function GetBoundType: TRttiType;
    function GetBoundToType: TRttiType;
    function GetScopeClass: TScopeClass;

    property BoundType: TRttiType read GetBoundType;
    property BoundToType: TRttiType read GetBoundToType;
    property Scope: TScopeClass read GetScopeClass;
  end;

  ITypeFactory = interface
    ['{D3FB304F-085A-4041-A5D8-B8EA09554D48}']
    function TryBuild(Info: ITypeInformation; InstanceResolver: IInstanceResolver; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
  end;

  IConstantBinder = interface
    ['{DBB405E6-5A0E-438D-8E12-BB61DD291D4F}']
    procedure ToAttribute(const AttributeClass: TCustomAttributeClass);
  end;

  IScopper = interface
    ['{1681158F-CE7A-4A98-B854-4972244A75B2}']

    procedure InScope(const ScopeClass: TScopeClass);
  end;

  IClassBinder = interface
    ['{420C04EF-5E8A-431B-8518-707EBF8E95A9}']
    function ToType(const AClass: TClass): IScopper;
  end;

  IBindingRegistry = interface(ITypeFactory)
    ['{21FD7407-15D1-45B4-9C93-129A03D149ED}']
  end;

  IInjector = interface
    ['{EA362B67-A4B9-43E4-B098-77DEF8982303}']
    function GetInstance(const Info: TRttiType): TValue;
  end;

  IProtoBinder = interface
    ['{6381FDA9-F512-4C16-9284-A3D4907CEBE0}']
    procedure ToInstance(const Instance: TObject); overload;
    procedure ToInstance(const Instance: IInterface); overload;
    function ToType(const AType: TClass): IScopper;
  end;

  TAbstractConcreteTypeBinding = class(TInterfacedObject, IBindingRegistry, IScopper)
  private
    FType: TRttiType;
    FConcreteType: TRttiType;
    FScope: TScopeClass;
    FContext: TRttiContext;
  protected
    function Accept(const Info: ITypeInformation): Boolean; virtual; abstract;
  public
    constructor Create(const AType: TRttiType; const AConcreteType: TClass);
    function TryBuild(Info: ITypeInformation;
      InstanceResolver: IInstanceResolver; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
    procedure InScope(const ScopeClass: TScopeClass);
    destructor Destroy; override;
  end;

  TClassBinding = class(TAbstractConcreteTypeBinding)
  protected
    function Accept(const Info: ITypeInformation): Boolean; override;
  end;

  TInterfaceBinding = class(TAbstractConcreteTypeBinding)
  protected
    function Accept(const Info: ITypeInformation): Boolean; override;
  end;

  TProtoBinder = class(TInterfacedObject, IProtoBinder)
  private
    FBindings: TList<IBindingRegistry>;
    FType: ITypeInformation;
    procedure ToInstance(const Instance: TObject); overload;
    procedure ToInstance(const Instance: IInterface); overload;
    function ToType(const AType: TClass): IScopper;
  public
    constructor Create(const AType: ITypeInformation; const Bindings: TList<IBindingRegistry>);
  end;

  TInstanceBinding = class(TInterfacedObject, IBindingRegistry)
  private
    FType: ITypeInformation;
    FInstance: TValue;
  public
    function TryBuild(Info: ITypeInformation;
      InstanceResolver: IInstanceResolver; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
    constructor Create(const AType: ITypeInformation; const Instance: TValue);
  end;

  TBindingRegistry = class(TInterfacedObject, IBindingRegistry, IClassBinder, IConstantBinder, IScopper)
  private
    type
      TBindingKind = (bkClassBinding, bkInterfaceBinding, bkConstantBinding);
  private
    FKind: TBindingKind;
    FBoundType: TRttiType;
    FBoundToType: TRttiType;
    FScopeClass: TScopeClass;
    FRttiContext: TRttiContext;
    FValue: TValue;
    function GetBoundType: TRttiType;
    function GetBoundToType: TRttiType;
    function GetScopeClass: TScopeClass;
    function GetInstanceAsObject(const Injector: IInjector): TObject;
    function GetInstanceAsInterface(const Injector: IInjector): IInterface;
    function TryBuild(Info: ITypeInformation; InstanceResolver: IInstanceResolver; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
    procedure ToAttribute(const AttributeClass: TCustomAttributeClass);
  public
    function ToType(const AClass: TClass): IScopper;
    procedure InScope(const ScopeClass: TScopeClass);
    constructor Create(const BoundType: TClass); overload;
    constructor Create(const BoundType: TGUID); overload;
    constructor _CreateConstantBinding(const TypeInfo: PTypeInfo; const Value);
    class function CreateConstantBinding<T>(const Value: T): TBindingRegistry;
    destructor Destroy; override;
  end;

  TModule = class abstract
  private
    FBindings: TList<IBindingRegistry>;
    FRttiContext: TRttiContext;
    function GetBinding(Index: Integer): IBindingRegistry;
    function _BindConstant<T>(const Value: T): IConstantBinder;
  public
    constructor Create;
    destructor Destroy; override;
    property Bindings[Index: Integer]: IBindingRegistry read GetBinding;
    function Bind(const AClass: TClass): IProtoBinder; overload;
    function Bind(const AGUID: TGUID): IProtoBinder; overload;
    procedure RegisterBinding(const BindingRegistry: IBindingRegistry);
    function BindConstant(const Value: String): IConstantBinder; overload;
    function BindConstant(const Value: Boolean): IConstantBinder; overload;
    procedure Configure; virtual; abstract;
  end;

  TInjector = record
  private
    FInjector: IInjector;
  public
    function GetInstance<T>: T;
    constructor Create(const Modules: array of TModule);
  end;

  TInjectorImpl = class(TInterfacedObject, IInjector, IInstanceResolver)
  private
    type
      TDependencyRec = record
        Dep: TObject;
        ReleaseProc: TReleaseProcedure;
        constructor Create(const Dep: TObject; const ReleaseProc: TReleaseProcedure);
      end;
  private
    FModules: array of TModule;
    FScopes: TDictionary<TScopeClass, TScope>;
    FImplicitBindings: TList<IBindingRegistry>;
    FCtx: TRttiContext;
    function Instantiate(const AClass: TClass): TObject;
    function GetScope(const ScopeClass: TScopeClass): TScope;
    function Resolve(Info: ITypeInformation; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
    function ResolveType(const RequestedType: TRttiType; const ClassType: TRttiInstanceType; const ScopeClass: TScopeClass): TValue;
    function GetInstance(const Info: TRttiType): TValue;
  public
    constructor Create(const Modules: array of TModule);
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  Emballo.Rtti,
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
  FImplicitBindings := TList<IBindingRegistry>.Create;
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
  FImplicitBindings.Free;

  FCtx.Free;
  inherited;
end;

function TInjectorImpl.GetInstance(const Info: TRttiType): TValue;
var
  ReleaseProc: TReleaseProcedure;
begin
  Resolve(TTypeInformation.FromType(Info), Result, ReleaseProc);
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

  procedure FixInterfaceValue(AType: TRttiInterfaceType; var Value: TValue);
  var
    Intf: IInterface;
    FixedInterface: Pointer;
  begin
    Intf := Value.AsInterface;
    Supports(Intf, AType.GUID, FixedInterface);
    Intf._Release;
    TValue.Make(@FixedInterface, AType.Handle, Value);
  end;

var
  M: TRttiMethod;
  ArgsValues: TArray<TValue>;
  Args: TArray<TRttiParameter>;
  i: Integer;
  SC: TSynteticClass;
  ObjectsToFree: TList<TDependencyRec>;
  ParamIntf: IInterface;
  Aux: Pointer;
  ReleaseProc: TReleaseProcedure;
  Curr: TClass;
begin
  SC := TSynteticClass.Create(AClass.ClassName + '_EnhancedByEmballo', AClass, SizeOf(Pointer), Nil, True);
  SC.Finalizer := procedure(const Instance: TObject)
  var
    Data: Pointer;
    List: TList<TDependencyRec>;
    O: TDependencyRec;
    i: Integer;
  begin
    Data := GetAditionalData(Instance);
    List := TList<TDependencyRec>(Data^);
    for i := 0 to List.Count - 1 do
    begin
      O := List[i];
      if Assigned(O.ReleaseProc) then
        O.ReleaseProc(O.Dep);
    end;

    List.Free;
  end;

  Curr := AClass;
  while True do
  begin
    for M in FCtx.GetType(Curr).AsInstance.GetDeclaredMethods do
    begin
      if M.IsConstructor then
      begin
        ObjectsToFree := TList<TDependencyRec>.Create;
        Args := M.GetParameters;
        SetLength(ArgsValues, Length(Args));
        for i := 0 to Length(Args) - 1 do
        begin
          Resolve(TTypeInformation.FromParameter(Args[i]), ArgsValues[i], ReleaseProc);
          if Args[i].ParamType is TRttiInterfaceType then
            FixInterfaceValue(TRttiInterfaceType(Args[i].ParamType), ArgsValues[i])
          else if Args[i].ParamType.IsInstance then
            ObjectsToFree.Add(TDependencyRec.Create(ArgsValues[i].AsObject, ReleaseProc));
        end;

        Result := M.Invoke(SC.Metaclass, ArgsValues).AsObject;
        SetAditionalData(Result, ObjectsToFree);
        Exit;
      end;
    end;
    Curr := Curr.ClassParent;
  end;
end;

function TInjectorImpl.Resolve(Info: ITypeInformation;
  out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;

  procedure TryWith(const Factory: ITypeFactory);
  begin
    Result := Factory.TryBuild(Info, Self, Value, ReleaseProc);
  end;
var
  Module: TModule;
  Binding: IBindingRegistry;
begin
  for Module in FModules do
  begin
    for Binding in Module.FBindings do
    begin
      TryWith(Binding);
      if Result then
        Exit;
    end;
  end;

  for Binding in FImplicitBindings do
  begin
    TryWith(Binding);
    if Result then
      Exit;
  end;

  if Info.RttiType.IsInstance then
  begin
    Value := ResolveType(Info.RttiType, Info.RttiType.AsInstance, TDefaultScope);
    ReleaseProc := TReleaseProcedures.FREE();

    Result := True;
    Exit;
  end;

  Result := False;
end;

function TInjectorImpl.ResolveType(const RequestedType: TRttiType; const ClassType: TRttiInstanceType; const ScopeClass: TScopeClass): TValue;
var
  Scope: TScope;
  Value: TValue;
  Intf: IInterface;
begin
  Scope := GetScope(ScopeClass);
  Result := Scope.Get(RequestedType);
  if Result.IsEmpty then
  begin
    Value := TValue.From(Instantiate(ClassType.MetaclassType));
    if RequestedType is TRttiInterfaceType then
    begin
      Supports(Value.AsObject, IInterface, Intf);
      Result := TValue.From(Intf);
    end
    else
      Result := Value;
  end;
end;

{ TModule }

function TModule.Bind(const AClass: TClass): IProtoBinder;
begin
  Result := TProtoBinder.Create(TTypeInformation.FromType(FRttiContext.GetType(AClass)), FBindings);
end;

function TModule.Bind(const AGUID: TGUID): IProtoBinder;
begin
  Result := TProtoBinder.Create(TTypeInformation.FromType(GetRttiTypeFromGUID(FRttiContext, AGUID)), FBindings);
end;

function TModule.BindConstant(const Value: Boolean): IConstantBinder;
begin
  Result := _BindConstant<Boolean>(Value);
end;

function TModule.BindConstant(const Value: String): IConstantBinder;
begin
  Result := _BindConstant<String>(Value);
end;

constructor TModule.Create;
begin
  FBindings := TList<IBindingRegistry>.Create;
  FRttiContext := TRttiContext.Create;
end;

destructor TModule.Destroy;
begin
  FBindings.Free;
  FRttiContext.Free;
  inherited;
end;

function TModule.GetBinding(Index: Integer): IBindingRegistry;
begin
  Result := FBindings[Index];
end;

procedure TModule.RegisterBinding(const BindingRegistry: IBindingRegistry);
begin
  FBindings.Add(BindingRegistry);
end;

function TModule._BindConstant<T>(const Value: T): IConstantBinder;
begin
  Result := TBindingRegistry.CreateConstantBinding<T>(Value);
  FBindings.Add(Result as IBindingRegistry);
end;

{ TBindingRegistry }

constructor TBindingRegistry.Create(const BoundType: TClass);
begin
  FRttiContext := TRttiContext.Create;
  FScopeClass := TDefaultScope;
  FBoundType := FRttiContext.GetType(BoundType);
  FKind := bkClassBinding;
end;

constructor TBindingRegistry.Create(const BoundType: TGUID);
begin
  FRttiContext := TRttiContext.Create;
  FScopeClass := TDefaultScope;
  FBoundType := GetRttiTypeFromGUID(Ctx, BoundType);
  FKind := bkInterfaceBinding;
end;

class function TBindingRegistry.CreateConstantBinding<T>(
  const Value: T): TBindingRegistry;
begin
  Result := TBindingRegistry._CreateConstantBinding(TypeInfo(T), Value);
end;

constructor TBindingRegistry._CreateConstantBinding(const TypeInfo: PTypeInfo; const Value);
begin
  FKind := bkConstantBinding;
  TValue.Make(@Value, TypeInfo, FValue);
end;

destructor TBindingRegistry.Destroy;
begin
  FRttiContext.Free;
  inherited;
end;

function TBindingRegistry.GetBoundToType: TRttiType;
begin
  Result := FBoundToType;
end;


function TBindingRegistry.GetBoundType: TRttiType;
begin
  Result := FBoundType;
end;

function TBindingRegistry.GetInstanceAsInterface(const Injector: IInjector): IInterface;
var
  Obj: TObject;
begin
  Obj := GetInstanceAsObject(Injector);
  Supports(Obj, IInterface, Result);
  Result._Release;
end;

function TBindingRegistry.GetInstanceAsObject(const Injector: IInjector): TObject;
begin
  Result := FBoundToType.AsInstance.MetaclassType.NewInstance;
end;

function TBindingRegistry.GetScopeClass: TScopeClass;
begin
  Result := FScopeClass;
end;

procedure TBindingRegistry.InScope(const ScopeClass: TScopeClass);
begin
  FScopeClass := ScopeClass;
end;

procedure TBindingRegistry.ToAttribute(
  const AttributeClass: TCustomAttributeClass);
begin

end;

function TBindingRegistry.ToType(const AClass: TClass): IScopper;
begin
  FBoundToType := FRttiContext.GetType(AClass);
  Result := Self;
end;

function TBindingRegistry.TryBuild(Info: ITypeInformation;
  InstanceResolver: IInstanceResolver; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
begin
  if (FKind = bkConstantBinding) and (Info.RttiType.Handle = FValue.TypeInfo) then
  begin
    Value := FValue;
    ReleaseProc := Nil;
    Result := True;
    Exit;
  end;

  Result := False;
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
  V: TValue;
begin
  Ctx := TRttiContext.Create;
  try
    Info := Ctx.GetType(TypeInfo(T));
    V := FInjector.GetInstance(Info);
    if Info.IsInstance then
      Result := T(V.AsObject)
    else if Info is TRttiInterfaceType then
      Supports(V.AsInterface, TRttiInterfaceType(Info).GUID, Result);

  finally
    Ctx.Free;
  end;
end;

{ TDefaultScope }

function TDefaultScope.Get(const Info: TRttiType): TValue;
begin
  { The default scope behaviour is that nothing is scopped }
  Result := Nil;
end;

{ TTypeInformation }

constructor TTypeInformation.Create(const AType: TRttiType; const AName: String;
  const AParent: TRttiObject);
begin
  FRttiType := AType;
  FName := AName;
  FParent := AParent;
end;

class function TTypeInformation.Fromparameter(
  const AParameter: TRttiParameter): ITypeInformation;
begin
  Result := TTypeInformation.Create(AParameter.ParamType, AParameter.Name, AParameter.Parent);
end;

class function TTypeInformation.FromType(
  const AType: TRttiType): ITypeInformation;
begin
  Result := TTypeInformation.Create(AType, '', Nil);
end;

function TTypeInformation.GetName: String;
begin
  Result := FName;
end;

function TTypeInformation.GetParent: TRttiObject;
begin
  Result := FParent;
end;

function TTypeInformation.GetRttiType: TRttiType;
begin
  Result := FRttiType;
end;

{ TProtoBinder }

constructor TProtoBinder.Create(const AType: ITypeInformation;
  const Bindings: TList<IBindingRegistry>);
begin
  FType := AType;
  FBindings := Bindings;
end;

procedure TProtoBinder.ToInstance(const Instance: TObject);
begin
  FBindings.Add(TInstanceBinding.Create(FType, TValue.From(Instance)));
end;

procedure TProtoBinder.ToInstance(const Instance: IInterface);
begin
  FBindings.Add(TInstanceBinding.Create(FType, TValue.From(Instance)));
end;

function TProtoBinder.ToType(const AType: TClass): IScopper;
var
  B: IBindingRegistry;
begin
  if FType.RttiType.IsInstance then
    B := TClassBinding.Create(FType.RttiType, AType)
  else
    B := TInterfaceBinding.Create(FType.RttiType, AType);

  Result := B as IScopper;
  FBindings.Add(B);
end;

{ TInstanceBinding }

constructor TInstanceBinding.Create(const AType: ITypeInformation;
  const Instance: TValue);
begin
  FType := AType;
  FInstance := Instance;
end;

function TInstanceBinding.TryBuild(Info: ITypeInformation;
  InstanceResolver: IInstanceResolver; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
begin
  if Info.RttiType.Equals(FType.RttiType) then
  begin
    Value := FInstance;
    ReleaseProc := TReleaseProcedures.DO_NOTHING();
    Result := True;
  end
  else
    Result := False;
end;

{ TAbstractConcreteTypeBinding }

constructor TAbstractConcreteTypeBinding.Create(const AType: TRttiType; const AConcreteType: TClass);
begin
  FContext := TRttiContext.Create;
  FType := AType;
  FConcreteType := FContext.GetType(AConcreteType);
  FScope := TDefaultScope;
end;

destructor TAbstractConcreteTypeBinding.Destroy;
begin
  FContext.Free;
  inherited;
end;

procedure TAbstractConcreteTypeBinding.InScope(const ScopeClass: TScopeClass);
begin
  FScope := ScopeClass;
end;

function TAbstractConcreteTypeBinding.TryBuild(Info: ITypeInformation;
  InstanceResolver: IInstanceResolver; out Value: TValue; out ReleaseProc: TReleaseProcedure): Boolean;
begin
  if Accept(Info) then
  begin
    Value := InstanceResolver.ResolveType(Info.RttiType, FConcreteType.AsInstance, FScope);
    ReleaseProc := TReleaseProcedures.FREE();
    Result := True;
  end
  else
    Result := False;
end;

{ TClassBinding }

function TClassBinding.Accept(const Info: ITypeInformation): Boolean;
begin
  Result := Info.RttiType.IsInstance and FType.Equals(Info.RttiType);
end;

{ TInterfaceBinding }

function TInterfaceBinding.Accept(const Info: ITypeInformation): Boolean;
  function CompareGuids: Boolean;
  begin
    Result := IsEqualGUID(TRttiInterfaceType(Info.RttiType).GUID, TRttiInterfaceType(FType).GUID);
  end;

begin
  Result := (Info.RttiType is TRttiInterfaceType) and CompareGuids;
end;

{ TReleaseProcedures }

class function TReleaseProcedures.DO_NOTHING: TReleaseProcedure;
begin
  Result := procedure(const Obj: TObject)
  begin
  end;
end;

class function TReleaseProcedures.FREE: TReleaseProcedure;
begin
  Result := procedure(const Obj: TObject)
  begin
    Obj.Free;
  end;
end;

{ TInjectorImpl.TDependencyRec }

constructor TInjectorImpl.TDependencyRec.Create(const Dep: TObject;
  const ReleaseProc: TReleaseProcedure);
begin
  Self.Dep := Dep;
  Self.ReleaseProc := ReleaseProc;
end;

initialization
Ctx := TRttiContext.Create;
Ctx.GetType(TObject);

finalization
Ctx.Free;

end.
