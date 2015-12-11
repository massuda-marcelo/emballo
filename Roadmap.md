This is what I plan to implement for the future. I won't give any date, though.

  1. Mock framework. Similar to Java's EasyMock. Given an interface, the framework automatically delivers you an mock implementation of the interface, where you configure how it should behave and then use it the unit tests of a class that deppends on that interface. This will be built on top of our interface proxy.
  1. Passive View framework. This let you remove much of the logic from your visual classes (`TForm`, `TFrame`, etc), thus improving testability and maintainability of your applications