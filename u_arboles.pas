unit U_Arboles;

{******************************************************
  Unidad: U_Arboles
  Sistema: Gestión de Capacitaciones FRCU
  Propósito:
    - Implementar Árboles Binarios de Búsqueda (ABB)
      para indexar capacitaciones:
        * Por código de capacitación.
        * Por nombre de capacitación.
    - Permitir búsqueda, inserción y recorrido.
*******************************************************}

interface

uses
  U_Tipos;

{--------------------------------------------------}
{ Procedimientos públicos de manejo de ABB }
{--------------------------------------------------}

procedure InicializarArbolCodigo(var raiz: PNodoCodigo);
procedure InicializarArbolNombre(var raiz: PNodoNombre);

procedure InsertarCodigo(var raiz: PNodoCodigo; codigo: integer; pos: longint);
procedure InsertarNombre(var raiz: PNodoNombre; nombre: string; pos: longint);

function BuscarPorCodigo(raiz: PNodoCodigo; codigo: integer): longint;
function BuscarPorNombre(raiz: PNodoNombre; nombre: string): longint;

procedure InOrdenCodigo(raiz: PNodoCodigo);
procedure InOrdenNombre(raiz: PNodoNombre);

procedure LiberarArbolCodigo(var raiz: PNodoCodigo);
procedure LiberarArbolNombre(var raiz: PNodoNombre);

implementation

{--------------------------------------------------}
{ 1. Inicialización de árboles vacíos              }
{--------------------------------------------------}

procedure InicializarArbolCodigo(var raiz: PNodoCodigo);
begin
  raiz := nil;
end;

procedure InicializarArbolNombre(var raiz: PNodoNombre);
begin
  raiz := nil;
end;

{--------------------------------------------------}
{ 2. Inserción ordenada (ABB clásico)              }
{--------------------------------------------------}

procedure InsertarCodigo(var raiz: PNodoCodigo; codigo: integer; pos: longint);
begin
  if raiz = nil then
  begin
    new(raiz);
    raiz^.codigo := codigo;
    raiz^.pos := pos;
    raiz^.izq := nil;
    raiz^.der := nil;
  end
  else
  begin
    if codigo < raiz^.codigo then
      InsertarCodigo(raiz^.izq, codigo, pos)
    else if codigo > raiz^.codigo then
      InsertarCodigo(raiz^.der, codigo, pos);
    { si es igual, no inserta duplicado }
  end;
end;

procedure InsertarNombre(var raiz: PNodoNombre; nombre: string; pos: longint);
begin
  if raiz = nil then
  begin
    new(raiz);
    raiz^.nombre := nombre;
    raiz^.pos := pos;
    raiz^.izq := nil;
    raiz^.der := nil;
  end
  else
  begin
    if nombre < raiz^.nombre then
      InsertarNombre(raiz^.izq, nombre, pos)
    else if nombre > raiz^.nombre then
      InsertarNombre(raiz^.der, nombre, pos);
    { si es igual, no inserta duplicado }
  end;
end;

{--------------------------------------------------}
{ 3. Búsqueda en ABB                               }
{ Devuelve: posición relativa del archivo          }
{ o -1 si no se encuentra                          }
{--------------------------------------------------}

function BuscarPorCodigo(raiz: PNodoCodigo; codigo: integer): longint;
var
  pos: longint;
begin
  pos := -1;
  if raiz <> nil then
  begin
    if codigo = raiz^.codigo then
      pos := raiz^.pos
    else
      if codigo < raiz^.codigo then
        pos := BuscarPorCodigo(raiz^.izq, codigo)
      else
        pos := BuscarPorCodigo(raiz^.der, codigo);
  end;
  BuscarPorCodigo := pos;
end;

function BuscarPorNombre(raiz: PNodoNombre; nombre: string): longint;
var
  pos: longint;
begin
  pos := -1;
  if raiz <> nil then
  begin
    if nombre = raiz^.nombre then
      pos := raiz^.pos
    else
      if nombre < raiz^.nombre then
        pos := BuscarPorNombre(raiz^.izq, nombre)
      else
        pos := BuscarPorNombre(raiz^.der, nombre);
  end;
  BuscarPorNombre := pos;
end;

{--------------------------------------------------}
{ 4. Recorridos (InOrden para listados ordenados)  }
{--------------------------------------------------}

procedure InOrdenCodigo(raiz: PNodoCodigo);
begin
  if raiz <> nil then
  begin
    InOrdenCodigo(raiz^.izq);
    writeln('Código: ', raiz^.codigo, ' -> Pos: ', raiz^.pos);
    InOrdenCodigo(raiz^.der);
  end;
end;

procedure InOrdenNombre(raiz: PNodoNombre);
begin
  if raiz <> nil then
  begin
    InOrdenNombre(raiz^.izq);
    writeln('Nombre: ', raiz^.nombre, ' -> Pos: ', raiz^.pos);
    InOrdenNombre(raiz^.der);
  end;
end;

{--------------------------------------------------}
{ 5. Liberar memoria de árboles                    }
{--------------------------------------------------}

procedure LiberarArbolCodigo(var raiz: PNodoCodigo);
begin
  if raiz <> nil then
  begin
    LiberarArbolCodigo(raiz^.izq);
    LiberarArbolCodigo(raiz^.der);
    dispose(raiz);
    raiz := nil;
  end;
end;

procedure LiberarArbolNombre(var raiz: PNodoNombre);
begin
  if raiz <> nil then
  begin
    LiberarArbolNombre(raiz^.izq);
    LiberarArbolNombre(raiz^.der);
    dispose(raiz);
    raiz := nil;
  end;
end;

end.
