# Introduction #
Emballo can automatically handle a pool of objects for you. That means: Instead of instantiating a new instance everytime the service is needed, the framework will first look at the pool to check if there's already one available object.

Basically, for a given service interface, you specify the maximum number of objects that can be stored on the pool. Then, you get instances of these services normaly and, when you have no more references to it, it will go to the pool and will be used the next time you request the service. The syntax for configuring a pool is very simple:
`RegisterFactory(....).Pool(Maximum number of objects on the pool).Done;`
Exemple:
`RegisterFactory(IDBConnection, TOrableConnection).Pool(5).Done;`

Let's look an exemple to see how it works:
type
  { Defines the service interface }
  IDBConnection = interface
    // guid
  end;

(...)

{ Register the service and configure the pool with the maximum of two objects }
RegisterFactory(IDBConnection, TOrableConnection).Pool(2).Done;

{ Now, use it }
var
  Con1: IDBConnection;
  Con2: IDBConnection;
  Con3: IDBConnection;
begin
  { This will cause a new TOrableConnection to be instantiated because the pool is empty }
  Con1 := Emballo.Get<IDBConnection>;

  { This will cause a new TOrableConnection to be instantiated because the pool is empty }
  Con2 := Emballo.Get<IDBConnection>;

  { This will cause a new TOrableConnection to be instantiated because the pool is empty }
  Con3 := Emballo.Get<IDBConnection>;

  { As there will be no more references to the object that Con1 used to point, this object will be moved to the pool (By the usual Delphi rules, it would be Free'd now, but Emballo automatically detects this and keep the object alive }
  Con1 := Nil;

  { This will also go to the pool }
  Con2 := Nil;

  { Now, there are two objects on the pool, and the pool is configured to allow only two objects. So, when we release Con3, it will be Free'd }
  Con3 := Nil;

  { As we already have two objects on the pool, the above call will just get one of them instead of creating a new one }
  Con1 := Emballo.Get<IDBConnection>;
end;

Note that pool support requires absolutely NO changes on your classes or interfaces. And the code that uses the services don't need to be aware of the pool support. You implement and use the interfaces exactly the same way you used to do without pool support!

= Tips =

Since the objects can be reused, you should implement them as stateless. That is, they shouldn't carry state information.```