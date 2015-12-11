# Why do we need dependency injection at all? #

Classes that directly instantiate its dependencies are very dificult (or even impossible) to unit test, to reuse, to maintain, etc. The reason is that whenever you use the client class, the dependency class must go together.

As an exemple, imagine this hypothetical scenario: You have to develop a class that reads a temperature from a thermometer, and fires an alarm if the temperature is higher than a certain limit. You have three classes: TThermometer, TAlarm and TTemparatureVerifier

These are their declarations:
```
type
  TThermometer = class
  private
    function GetCurrentTemperature: Extended;
  public
    property CurrentTemperature: Extended read GetCurrentTemperature;
  end;

  TAlarm = class
  public
    procedure FireAlarm;
  end;

  ITemperatureVerifier = interface
    // guid
    procedure VerifyTemperature;
  end;

  TTemperatureVerifier = class
  private
    FThermometer: TThermometer;
    FAlarm: TAlarm;
  public
    constructor Create;
    procedure VerifyTemperature;
  end;
```

TThermometer and TAlarm methods have a low level implementation that communicates directly to their physical devices.
This is TTemperatureVerifier implementation:
```
constructor TTemperatureVerifier.Create;
begin
  FThermometer := TThermometer.Create;
  FAlarm := TAlarm.Create;
end;

procedure TTemperatureVerifier.VerifyTemperature;
begin
  if FThermometer.CurrentTemperature > MAX_TEMP then
    FAlarm.FireAlarm;
end;
```

But now, how to unit test our TTemperatureVerifier? As it is highly coupled to the physical alarm and thermometer, it's now impossible to unit test it.

The solution is to define interfaces for thermometer and alarm, and have implementations of such interfaces that communicates with the real devices:
```
type
  IThermometer = interface
    // guid
    function GetCurrentTemperature: Extended;
    property CurrentTemperature: Extended read GetCurrentTemperature;
  end;

  TThermometer = class(TInterfacedObject, IThermometer)
  private
    function GetCurrentTemperature: Extended;
  end;

  IAlarm = interface
    // guid
    procedure FireAlarm;
  end;

  TAlarm = class(TInterfacedObject, IAlarm)
  private
    procedure FireAlarm;
  end;

  ITemperatureVerifier = interface
    // guid
    procedure VerifyTemperature;
  end;

  TTemperatureVerifier = class
  private
    FThermometer: IThermometer;
    FAlarm: IAlarm;
  public
    constructor Create(const Thermometer: IThermometer; const Alarm: IAlarm);
    procedure VerifyTemperature;
  end;

constructor TTemperatureVerifier.Create(const Thermometer: IThermometer; const Alarm: IAlarm);
begin
  FThermometer := Thermometer;
  FAlarm := Alarm;
end;

procedure TTemperatureVerifier.VerifyTemperature;
begin
  if FThermometer.CurrentTemperature > MAX_TEMP then
    FAlarm.FireAlarm;
end;
```

Now you can easily unit test this class by just providing mock implementations of IThermometer and IAlarm.
In fact, this is already dependency injection even though you don't use any framework for this. TTemperatureVerifier have its dependencies injected through its constructor.

Now, how to use this class?
Simply:
```
var
  TemperatureVerifier: ITemperatureVerifier;
begin
  TemperatureVerifier := TTemperatureVerifier.Create(TThermometer.Create, TAlarm.Create);
```

But there's still a problem here: What if you're required to support various kinds of thermometer and alarm devices, each requiring it's own implementation of IThermometer and IAlarm?
For exemple, if you are required to support thermometers from vendors A, B and C, and alarms from vendors D, E and F, you have nine possible combinations of devices that you must care about when instantiating TTemperatureVerifier.

One could create a factory for IThermometer and another for IAlarm and the instantiation would be as simple as
```
var
  TemperatureVerifier: ITemperatureVerifier;
begin
  TemperatureVerifier := TTemperatureVerifier.Create(ThermometerFactory.Get, AlarmFactory.Get);
```

It solves the problem, but it's up to you to develop, test and maintain such factories.

DI frameworks (Emballo included) handles all of this for you.
You only have to tell the framework what are the classes that implements IThermometer and IAlarm. Besides that, it also takes care of providing all the dependencies that are required by IThermoneter and IAlarm. Now, if you want a ITempareatureVerifier, all you do is:
```
var
  Injector: TInjector;
  TemperatureVerifier: ITemperatureVerifier;
begin
  Injector := EmballoServices.CreateInjector(...);
  TemperatureVerifier := Injector.GetInstance<ITemperatureVerifier>;
```