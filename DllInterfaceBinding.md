Introduction

It is possible to use an interface to encapsulate the access to a Dll. This is an elegant way of accessing Dlls, and has the following advantages:

Saves you from having to do the Dll loading/unloading, and error handling
Saves you from having to write lots of calls to GetProcAddress
Automatically generates an exception if one exported function can't be found on the Dll, making it very easy to identify the problem and fix it.
Doesn't pollute the namespace with lots of declarations of functions of the Dll
Defining the interface
You just have to declare an interface which all methods correspond to exported functions on the Dll. You must match the method name, parameter types, return type and calling convention. For exemple: If you have a Dll that exports this function:

```
function Sum(A: Byte; B: Word): Integer; stdcall;
begin
  Result := A + B;
end;
```

Then your interface must be:

```
type
  {$M+}
  IMyDll = interface
    // guid
    function Sum(A: Byte; B: Word): Integer; stdcall;
  end;
  {$M-}
```
Notes:

Interfaces by default doesn't generated detailed RTTI information as we need to do the Dll binding, so you must surround it with {$M+} and ($M-}
The interface name doesn't matter, but it is recomended to use a name similar to the Dll name
The parameter names doesn't matter, but it is recomended to use the same names used on the Dll documentation
If you doesn't match the parameter types, return type or calling convention, Emballo won't generate any error. This just can't be done, because Dlls doesn't carry such metadata. However, if you do this mistake, you are likely get some weird erros when calling the functions.

Using the interface
In order to get the interface implementation, you just have to call `DllWrapperService.Get<Interface>(Dll name)` on Emballo.DllWrapper unit. Exemple:

```
var
  MyDll: IMyDll;
begin
  MyDll := DllWrapperService.Get<IMyDll>('MyDll.dll');
  ShowMessage(IntToStr(MyDll.Sum(1, 2)));
```

Then the framework will take care of all LoadLibrary, GetProcAddress and FreeLibrary for you. The dll name parameter is passed to the windows API LoadLibrary function, so if you want to know details about this parameter, look at the API documentation