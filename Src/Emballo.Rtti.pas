{   Copyright 2010 - Magno Machado Paulo (magnomp@gmail.com)

    This file is part of Emballo.

    Emballo is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Emballo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Emballo.
    If not, see <http://www.gnu.org/licenses/>. }

unit Emballo.Rtti;

interface

uses
  TypInfo, SysUtils, Rtti;

type
  EUnknownGUID = class(Exception)
  public
    constructor Create(GUID: TGUID);
  end;

  TRttiUtils = class
  public
    class function GetAttribute<T:TCustomAttribute>(const RttiObject: TRttiObject): T;
  end;

{ Returns the typeinfo of an interface given it's GUID.
  The interface is searched using Rtti, and if no interface with the given GUID
  can be found, an EUnknownGUID is raised }
function GetTypeInfoFromGUID(GUID: TGUID): PTypeInfo;

{ Returns the GUID of an interface given it's type info }
function GetGUIDFromTypeInfo(ATypeInfo: PTypeInfo): TGUID;

{ Returns the TRttiInterfaceType of an interface, given it's GUID }
function GetRttiTypeFromGUID(Ctx: TRttiContext; GUID: TGUID): TRttiInterfaceType;

{ Returns the size of the type via it's typeinfo }
function GetTypeSize(const Info: PTypeInfo): Integer;

implementation

function GetRttiTypeFromGUID(Ctx: TRttiContext; GUID: TGUID): TRttiInterfaceType;
var
  Types: TArray<TRttiType>;
  LType: TRttiType;
begin
  Types := Ctx.GetTypes;
  for LType in Types do
  begin
    if LType is TRttiInterfaceType then
    begin
      Result := TRttiInterfaceType(LType);
      if IsEqualGUID(Result.GUID, GUID) then
        Exit;
    end;
  end;

  raise EUnknownGUID.Create(GUID);
end;

function GetTypeInfoFromGUID(GUID: TGUID): PTypeInfo;
var
  Ctx: TRttiContext;
begin
  Ctx := TRttiContext.Create;
  try
    Result := GetRttiTypeFromGUID(Ctx, GUID).Handle;
  finally
    Ctx.Free;
  end;
end;

function GetGUIDFromTypeInfo(ATypeInfo: PTypeInfo): TGUID;
var
  Ctx: TRttiContext;
begin
  Ctx := TRttiContext.Create;
  try
    Result := (Ctx.GetType(ATypeInfo) as TRttiInterfaceType).GUID;
  finally
    Ctx.Free;
  end;
end;

function GetTypeSize(const Info: PTypeInfo): Integer;
var
  Ctx: TRttiContext;
begin
  Ctx := TRttiContext.Create;
  try
    Result := Ctx.GetType(Info).TypeSize;
  finally
    Ctx.Free;
  end;
end;

{ EUnknownGUID }

constructor EUnknownGUID.Create(GUID: TGUID);
begin
  inherited Create('GUID not found: ' + GUIDToString(GUID));
end;

{ TRttiUtils }

class function TRttiUtils.GetAttribute<T>(const RttiObject: TRttiObject): T;
var
  Attr: TCustomAttribute;
begin
  for Attr in RttiObject.GetAttributes do
    if Attr.ClassType.InheritsFrom(T) then
      Exit(T(Attr));

  Result := Nil;
end;

end.
