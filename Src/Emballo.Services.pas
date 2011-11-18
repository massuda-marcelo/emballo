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

unit Emballo.Services;

interface

uses
  Emballo.DI, Emballo.Mock.Mock, Emballo.DynamicProxy.InvokationHandler;

type
  EmballoServices = class
  public
    class function CreateInjector(const Modules: array of TModule): TInjector;
    class function Mock<T>: TMock<T>;
    class function Proxy<T:class>(const InvokationHandler: TInvokationHandlerAnonMethod): T; overload;
    class function Proxy<T:class>(const InvokationHandler: TInvokationHandlerMethod): T; overload;
  end;

implementation

uses
  Emballo.DynamicProxy.Impl;

{ EmballoServices }

class function EmballoServices.CreateInjector(const Modules: array of TModule): TInjector;
begin
  Result := TInjector.Create(Modules);
end;

class function EmballoServices.Mock<T>: TMock<T>;
begin
  Result := TMock<T>.Create;
end;

class function EmballoServices.Proxy<T>(const InvokationHandler: TInvokationHandlerAnonMethod): T;
var
  Proxy: TDynamicProxy;
begin
  Proxy := TDynamicProxy.Create(TClass(T), Nil, InvokationHandler, Nil);
  Result := T(Proxy.ProxyObject);
end;

class function EmballoServices.Proxy<T>(const InvokationHandler: TInvokationHandlerMethod): T;
var
  Proxy: TDynamicProxy;
begin
  Proxy := TDynamicProxy.Create(TClass(T), Nil, InvokationHandler, Nil);
  Result := T(Proxy.ProxyObject);
end;

end.
