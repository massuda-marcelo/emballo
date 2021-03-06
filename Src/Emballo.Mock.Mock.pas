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

unit Emballo.Mock.Mock;

interface

uses
  SysUtils,
  Emballo.General,
  Emballo.Mock.MockInternal,
  Emballo.Mock.When;

type
  TMock<T> = record
  private
    FInternal: IMockInternal<T>;
  public
    function GetObject: T;
    function Expects: T;
    procedure VerifyUsage;
    function WillRaise(ExceptionClass: TExceptionClass): IWhen<T>;
    function WillReturn(const Value: Integer): IWhen<T>; overload;
    function WillReturn(const Value: String): IWhen<T>; overload;
    function WillReturn(const Value: Boolean): IWhen<T>; overload;
    function WillReturn(const Value: TDateTime): IWhen<T>; overload;
    class function Create: TMock<T>; static;
    procedure Free;
    class operator Implicit(const Value: TMock<T>): T;
  end;

implementation

uses
  Emballo.Mock.MockInternalImpl;

{ TMock<T> }

class function TMock<T>.Create: TMock<T>;
begin
  Result.FInternal := TMockInternal<T>.Create;
end;

function TMock<T>.Expects: T;
begin
  Result := FInternal.Expects;
end;

procedure TMock<T>.Free;
begin
  FInternal := Nil;
end;

function TMock<T>.GetObject: T;
begin
  Result := FInternal.GetObject;
end;

class operator TMock<T>.Implicit(const Value: TMock<T>): T;
begin
  Result := Value.GetObject;
end;

procedure TMock<T>.VerifyUsage;
begin
  FInternal.VerifyUsage;
end;

function TMock<T>.WillRaise(ExceptionClass: TExceptionClass): IWhen<T>;
begin
  Result := FInternal.WillRaise(ExceptionClass);
end;

function TMock<T>.WillReturn(const Value: TDateTime): IWhen<T>;
begin
  Result := FInternal.WillReturn(Value);
end;

function TMock<T>.WillReturn(const Value: Boolean): IWhen<T>;
begin
  Result := FInternal.WillReturn(Value);
end;

function TMock<T>.WillReturn(const Value: String): IWhen<T>;
begin
  Result := FInternal.WillReturn(Value);
end;

function TMock<T>.WillReturn(const Value: Integer): IWhen<T>;
begin
  Result := FInternal.WillReturn(Value);
end;

end.
