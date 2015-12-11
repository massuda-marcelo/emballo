# Introdução #

Emballo trata simplesmente de obter implementações de interfaces sem que o código cliente (o código que requisita a implementação) tenha que conhecer que de fato implementa aquela interface.

## Configurando dependencias ##

Para cada interface que deve ser gerenciada pelo Emballo, você precisa dizer ao framework como obter implementações para ela. O framework usa implementações de IFactory para obter implementações de uma dada interface, mas normalmente você não necessita se importar com isso. Para configurar o framework, você usa a função RegisterFactory, que é declarada na unit EbRegistry. Existem três overloads desta função:

  * `function RegisterFactory(const Factory): IRegister;`
Recebe qualquer IFactory e registra-o

  * `function RegisterFactory(const GUID: TGUID; Implementor: TClass): IRegister;`
Isso dirá ao framework para instanciar dinamicamente a classe `Implementor` quando uma implementação da interface `GUID` for necessária.

  * `function RegisterFactory(const GUID: TGUID; const Instance: IInterface): IRegister;`
Isso irá configurar o framework para usar o objeto `Instance` quando a interface `GUID` for necessária.

Estas funções na verdade não registram nada no framework. Elas apenas configuram um `IRegister` baseado nos parametros passados para as funções, e o `IRegister` é o verdadeiro responsavel por fazer o registro.

## Usando IRegister ##

O propósito por trás do `IRegister` é o de permitir ao programador configurar algumas opções interessantes antes de registrar a factory no framework.

Se você chamar o método `Singleton`, você vai configurar o factory para realizar um cache da instancia obtida, de forma que ela não será novamente requisitada à factory.

Depois de terminar a configuração do `IRegister`, você precisa chamar o método `Done` para realizar o registro. Por exemplo:

```
RegisterFactory(IMyDependency, TMyDependency).Done;
```
or
```
RegisterFactory(IMyDependency, TMyDependency).Singleton.Done;
```

# Usando #

Agora que o framework sabe como obter implementações das suas interfaces, você pode começar a utiliza-lo. Isso é feito através de `Emballo.Get` (Unit `EbCore`). Ela recebe um argumento generico que é a interface para a qual você necessita uma instancia. Essa função retorna uma interface daquele tipo.
Por exemplo:
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

Seja la quando você necessitar de uma instancia de uma interface, o framework tentará obter as instancias através de todos os factories registrados, e a estratégia que cada factory utilizará para obter a instancia é especifico da implementação de cada factory, como vimos acima.