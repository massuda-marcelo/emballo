After you configured the container by telling it how to get implementations of all your interfaces, you can start using it. This is done through `DIService.Get` (`Emballo.DI.Core` unit). It takes a generic argument that is the interface for which you need an instance. The function returns an interface of that type.
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
  Dependency := DIService.Get<IDependency>;
  Dependency.Foo;
end;
```

Whenever you need an instance of an interface, the framework will try to get the instances via all of the registered factories, and the strategy that each factory will use to obtain the instance is specific for the implementation of each factory, as we saw [here](ConfiguringDependencies.md).