In order for Emballo to work, it need to be told about how to resolve the dependencies of your app.

For exemple, imagine this situation:

```
type
  TFoo = class
  public
    constructor Create(Bar: IBar);
  end;
```

IBar is a dependency of TFoo, and hence in order to give you an instance of TFoo, Emballo need to know how it should get the IBar dependency.

In Emballo, this is done using Modules

# Module #

A Module is a place where you can logicaly group configurations regarding dependency resolution. Exemple:

```
uses
  Emballo.DI;

type
  TMyModule = class(TModule)
  public
    procedure Configure;
  end;

implementation

procedure TMyModule.Configure;
begin
  Bind(IFoo).ToType(TFoo);
end;
```

What we just did here is to tell Emballo that whenever it needs an IFoo, it must create an instance of the class TFoo.

Note that if TFoo's constructor have any dependencies, Emballo will try to resolve them too.

You can have any number of modules in your project, and they will be used then creating the injector, as we'll see next.

# Different ways of resolving dependencies #

There are many different strategies Emballo can use when resolving some dependency. Most of them are configured inside the Configure method of the modules

## Type binding ##

It occurs when you bind a given class/interface to an concrete class, so that Emballo will use the concrete class whenever it needs an instance of the bound type. Exemple:

```
uses
  Emballo.DI;

type
  TMyModule = class(TModule)
  public
    procedure Configure;
  end;

implementation

procedure TMyModule.Configure;
begin
  Bind(IFoo).ToType(TFoo);
end;
```

## Instance binding ##

With instance binding, you bind a given type to an already existing instance of that type, so that Emballo will just use that instance whenever it needs the bound type. Exemple:

```
uses
  Emballo.DI;

type
  TMyModule = class(TModule)
  public
    procedure Configure;
  end;

implementation

procedure TMyModule.Configure;
var
  MyFoo: TFoo;
begin
  MyFoo := GetAnInstanceOfIFooNoMatterWhere();
  Bind(TFoo).ToInstance(MyFoo);
end;
```

Note that the instance will be automaticaly Free'd whem the module itself is Free'd, which happen whem the Injector is Free'd. If you don't want this behaviour, you can tell Emballo to NOT Free the instance:

```
uses
  Emballo.DI;

type
  TMyModule = class(TModule)
  public
    procedure Configure;
  end;

implementation

procedure TMyModule.Configure;
var
  MyFoo: TFoo;
begin
  MyFoo := GetAnInstanceOfIFooNoMatterWhere();
  Bind(TFoo).ToInstance(MyFoo).AndDontReleaseInstance;
end;
```

## Factory methods ##

You can annotate any function of a module with [FactoryMethod](FactoryMethod.md), and that method will be called everytime Emballo need the type that is returned by the function. Exemple:

```
uses
  Emballo.DI;

type
  TMyModule = class(TModule)
  public
    [FactoryMethod]
    function ProvideBar(Foo: IFoo): TBar;
  end;

implementation

function TMyModule.ProvideBar(Foo: IFoo): TBar;
begin
  Result := TBar.Create;
  Result.SetFoo(Foo);
end;
```

This is very useful when the object creation needs more than simply calling it's constructor.

In this case, whenever Emballo needs a TBar, it will call the method TMyModule.ProvideBar. If the method has arguments, Emballo will try to fill them.

The method name is irrelevant.