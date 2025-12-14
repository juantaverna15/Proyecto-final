unit U_Archivos;

{******************************************************
  Unidad: U_Archivos
  Sistema: Gestión de Capacitaciones FRCU
  Propósito:
    - Manejar archivos random de capacitaciones y alumnos.
    - Proveer operaciones básicas de acceso, lectura,
      escritura, búsqueda y actualización.
  Estructura:
    * Sin uso de break, exit ni goto.
    * Procedimientos modulares.
*******************************************************}

interface

uses
  crt, U_Tipos, U_Arboles;

{-------------------------------------------------------}
{ Procedimientos públicos                                }
{-------------------------------------------------------}

procedure AbrirArchivoCapacitaciones(var arch: TArchivoCapacitaciones);
procedure AbrirArchivoAlumnos(var arch: TArchivoAlumnos);

procedure CerrarArchivoCapacitaciones(var arch: TArchivoCapacitaciones);
procedure CerrarArchivoAlumnos(var arch: TArchivoAlumnos);

procedure LeerCapacitacion(var arch: TArchivoCapacitaciones; pos: longint; var reg: TCapacitacion);
procedure GrabarCapacitacion(var arch: TArchivoCapacitaciones; reg: TCapacitacion);
procedure ActualizarCapacitacion(var arch: TArchivoCapacitaciones; pos: longint; reg: TCapacitacion);

procedure LeerAlumno(var arch: TArchivoAlumnos; pos: longint; var reg: TAlumno);
procedure GrabarAlumno(var arch: TArchivoAlumnos; reg: TAlumno);
procedure ActualizarAlumno(var arch: TArchivoAlumnos; pos: longint; reg: TAlumno);

function BuscarCapacitacionPorCodigo(var arch: TArchivoCapacitaciones; codigo: integer): longint;
function BuscarAlumnoPorDNI(var arch: TArchivoAlumnos; codCap: integer; dni: longint): longint;

procedure CargarArbolesDesdeArchivo(var arch: TArchivoCapacitaciones;
                                    var arbolCod: PNodoCodigo;
                                    var arbolNom: PNodoNombre);

implementation

{-------------------------------------------------------}
{ 1. Apertura y cierre de archivos random               }
{-------------------------------------------------------}

procedure AbrirArchivoCapacitaciones(var arch: TArchivoCapacitaciones);
begin
  assign(arch, ARCH_CAPACITACIONES);
  {$I-}
  reset(arch);
  {$I+}
  if IOResult <> 0 then
  begin
    rewrite(arch);
    writeln('Archivo de capacitaciones creado (vacío).');
  end
  else
    writeln('Archivo de capacitaciones abierto correctamente.');
end;

procedure AbrirArchivoAlumnos(var arch: TArchivoAlumnos);
begin
  assign(arch, ARCH_ALUMNOS);
  {$I-}
  reset(arch);
  {$I+}
  if IOResult <> 0 then
  begin
    rewrite(arch);
    writeln('Archivo de alumnos creado (vacío).');
  end
  else
    writeln('Archivo de alumnos abierto correctamente.');
end;

procedure CerrarArchivoCapacitaciones(var arch: TArchivoCapacitaciones);
begin
  close(arch);
end;

procedure CerrarArchivoAlumnos(var arch: TArchivoAlumnos);
begin
  close(arch);
end;

{-------------------------------------------------------}
{ 2. Operaciones básicas de lectura/escritura           }
{-------------------------------------------------------}

procedure LeerCapacitacion(var arch: TArchivoCapacitaciones; pos: longint; var reg: TCapacitacion);
begin
  seek(arch, pos);
  read(arch, reg);
end;

procedure GrabarCapacitacion(var arch: TArchivoCapacitaciones; reg: TCapacitacion);
begin
  seek(arch, filesize(arch));  { agrega al final }
  write(arch, reg);
end;

procedure ActualizarCapacitacion(var arch: TArchivoCapacitaciones; pos: longint; reg: TCapacitacion);
begin
  seek(arch, pos);
  write(arch, reg);
end;

procedure LeerAlumno(var arch: TArchivoAlumnos; pos: longint; var reg: TAlumno);
begin
  seek(arch, pos);
  read(arch, reg);
end;

procedure GrabarAlumno(var arch: TArchivoAlumnos; reg: TAlumno);
begin
  seek(arch, filesize(arch));  { agrega al final }
  write(arch, reg);
end;

procedure ActualizarAlumno(var arch: TArchivoAlumnos; pos: longint; reg: TAlumno);
begin
  seek(arch, pos);
  write(arch, reg);
end;

{-------------------------------------------------------}
{ 3. Búsquedas secuenciales                             }
{-------------------------------------------------------}

function BuscarCapacitacionPorCodigo(var arch: TArchivoCapacitaciones; codigo: integer): longint;
var
  reg: TCapacitacion;
  pos, encontrado: longint;
begin
  encontrado := -1;
  pos := 0;
  seek(arch, 0);
  while (pos < filesize(arch)) and (encontrado = -1) do
  begin
    read(arch, reg);
    if reg.codigo = codigo then
      encontrado := pos;
    pos := pos + 1;
  end;
  BuscarCapacitacionPorCodigo := encontrado;
end;

function BuscarAlumnoPorDNI(var arch: TArchivoAlumnos; codCap: integer; dni: longint): longint;
var
  reg: TAlumno;
  pos, encontrado: longint;
begin
  encontrado := -1;
  pos := 0;
  seek(arch, 0);
  while (pos < filesize(arch)) and (encontrado = -1) do
  begin
    read(arch, reg);
    if (reg.codCapacitacion = codCap) and (reg.dni = dni) then
      encontrado := pos;
    pos := pos + 1;
  end;
  BuscarAlumnoPorDNI := encontrado;
end;

{-------------------------------------------------------}
{ 4. Cargar árboles desde archivo                       }
{-------------------------------------------------------}

procedure CargarArbolesDesdeArchivo(var arch: TArchivoCapacitaciones;
                                    var arbolCod: PNodoCodigo;
                                    var arbolNom: PNodoNombre);
var
  reg: TCapacitacion;
  pos: longint;
begin
  InicializarArbolCodigo(arbolCod);
  InicializarArbolNombre(arbolNom);

  if filesize(arch) > 0 then
  begin
    seek(arch, 0);
    pos := 0;
    while pos < filesize(arch) do
    begin
      read(arch, reg);
      if reg.estado = activo then
      begin
        InsertarCodigo(arbolCod, reg.codigo, pos);
        InsertarNombre(arbolNom, reg.nombre, pos);
      end;
      pos := pos + 1;
    end;
  end;
end;

end.
