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

unit Emballo.General;

interface

uses
  SysUtils;

type
  TExceptionClass = class of Exception;
  TCustomAttributeClass = class of TCustomAttribute;

{ Emballo does some low level hacking to make it possible to hook into
  non virtual methods. This is usefull e.g. on the Dynamic Proxy or Mocking
  frameworks. However, this can't be done on very small methods. If you really
  need to hook into these kind of methods, you can do a call to
  the MakeMeGoodForHook procedure at the beginning of the method you want to
  hook. It will ensure that the method has at least the
  needed size to make it hookable. However, it will also increase your executable
  file size by a few bytes for each use of this procedure. }
procedure MakeMeGoodForHook;

implementation

procedure MakeMeGoodForHook;
begin
end;


end.
