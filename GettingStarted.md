# Introduction #

Emballo is all about getting implementations of interfaces without the client code (the code that requests the implementation) having to know who actually implements that interface.

# Configuring dependencies #

For each interface that should be handled by Emballo, you must tell the framework how to get implementations for it.

The framework rely on implementations of IFactory for getting implementations of a given interface type, but usually you don't need to care about this.

In order to configure the framework, you use the RegisterFactory function, which is declared on the `EbRegistry` unit.

There are three overloads of this function:
  * `function RegisterFactory(const Factory: IFactory): IRegister;`
This takes any IFactory and registers it.

  * `function RegisterFactory(const GUID: TGUID; Implementor: TClass): IRegister;`
This will tell the framework to dynamically instantiate the class Implementor when an implementation of the GUID interface is needed.

  * `function RegisterFactory(const GUID: TGUID; const Instance: IInterface): IRegister;`
This will configure the framework to use the Instance object when the GUID interface is needed.

Those functions doesn't actually register anything within the framework. They just set up an IRegister based on the parameters passed to the functions, and the IRegister is the actual responsible for doing the registration.

## Using IRegister ##

The purpose behind the IRegister is to let the programmer set up some nice options before registering a factory on the framework.

If you call the Singleton method, you will configure the factory to cache the obtained instance, so that it won't be re-requested to the factory.

After you finished configuring the IRegister, you must call the Done method to do the actual registration. For exemple:

```
RegisterFactory(IMyDependency, TMyDependency).Done;
```
or
```
RegisterFactory(IMyDependency, TMyDependency).Singleton.Done;
```

# Using #

Now that the framework knows how to get implementations of your interfaces, you can start using it. This is done through Emballo.Get (EbCore unit). It takes a generic argument that is the interface for which you need an instance. The function returns an interface of that type.
For exemple:
```
type
  TClientObject = class
  public
    procedure DoSomething;
  end;

procedure TClientObject.DoSomething;
var
  Dependency: IDependency;
begin
  Dependency := Emballo.Get<IDependency>;
  Dependency.Foo;
end;
```

Whenever you need an instance of an interface, the framework will try to get the instances via all of the registered factories, and the strategy that each factory will use to obtain the instance is specific for the implementation of each factory, as we saw above.