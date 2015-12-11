The DI container can use the [Dll/Interface binding](DllInterfaceBinding.md) feature of Emballo to build a dependency interface. To use it, you must define an interface for a Dll as described in the Dll/Interface binding documentation, and call `RegisterFactoryDll(GUID, Dll name)`, defined on `Emballo.DI.Registry` unit. Exemple:
```
type
  {$M+}
  IMyDllWrapper = interface
    // guid
    function Sum(A, B: Integer): Integer; stdcall;
  end;
  {$M-}

(...)

RegisterFactoryDll(IMyDllWrapper, 'MyDll.dll')
```