unit Emballo.Services;

interface

uses
  Emballo.DI;

type
  EmballoServices = class
  public
    class function CreateInjector(const Modules: array of TModule): TInjector;
  end;

implementation

{ EmballoServices }

class function EmballoServices.CreateInjector(const Modules: array of TModule): TInjector;
begin
  Result := TInjector.Create(Modules);
end;

end.
