# Introduction #

Mocking is a common thechinique used on unit tests, the idea is very simple: You create fake implementations of classes that are required by the class you're testing.

These fake implementations can be created manualy, but this is a tedious and time-consuming task, and this is the problem that mocking frameworks are designed to solve.

# Using #

## Creating the mock ##

The first thing you have to do is to obtain your mock object. The syntax will be improved soon, but for now this is all we have:
```
type
  { This is the class for which you want the fake implementation }
  TService = class
  public
    function DoSomething: Integer; virtual;
  end;

var
  MockedService: TMock<TService>;
begin
  MockedService = TMock<TService>.Create
```

That's all. You can access the mocked `TService` instance through `MockedService.GetObject` or you can simply cast the MockedService variable to TService.

Instead of TService (a class), you could use an interface. It would work the same way.

Note that you don't have to write code to support the mock, everything is done at runtime.

## Preparing the mock ##

Often you will need to verify the interactions between your mocks and your class under tests, so you'll have to prepare your mocks to return expected values or throw exceptions when it's methods are called.

### Raising exceptions ###

Imagine you want to test how your class under tests behave when `TService.DoSomething` raises an exception. All you have to do is to configure this behaviour in your mock, and this is very simple to do:
```
MockedService.WillRaise(EDatabaseError).When.DoSomething;
```

After that, if someone call `MockedService.GetObject.DoSomething`, it will magicaly raise an `EDatabaseError`!

### Returning values ###

If instead of raising exceptions, you want your mocked object to return some value uppon a method call. This is all you have to do:
```
MockedService.WillReturn(1).When.DoSomething;
```

## Verifying interactions ##

If the class under tests call any unexpected method on the mocked object, an exception will be raised. However, you still may need to make sure the class actually called some expected methods on the mocked object. To do this, you can use the VerifyUsage of the TMock record:
```
MockedService.VerifyUsage;
```

# Conclusion #

Unfortunately, there's still a lot of work to do. Everything exposed here is implemented and working, but isn't enough for production use.