unit U_Capacitaciones;

{******************************************************
  Unidad: U_Capacitaciones
  Sistema: Gestión de Capacitaciones FRCU
  Propósito:
    - Gestionar las operaciones ABMC del archivo de
      capacitaciones, interactuando con los árboles
      e interfaces de archivos.
  Restricciones:
    - Programación estructurada.
    - Sin break, exit ni goto.
*******************************************************}

interface

uses
  crt, U_Tipos, U_Archivos, U_Arboles;

{------------------------------------------------------}
{ Procedimientos públicos                              }
{------------------------------------------------------}

procedure MenuCapacitaciones(var arch: TArchivoCapacitaciones;
                             var arbolCod: PNodoCodigo;
                             var arbolNom: PNodoNombre);



{------------------------------------------------------}
{ Declaración de procedimientos internos               }
{------------------------------------------------------}

procedure AltaCapacitacion(var arch: TArchivoCapacitaciones;
                           var arbolCod: PNodoCodigo;
                           var arbolNom: PNodoNombre;
                           codigo: integer);

procedure ConsultarCapacitacion(var arch: TArchivoCapacitaciones;
                                var arbolCod: PNodoCodigo;
                                var arbolNom: PNodoNombre;
                                pos: longint);

procedure ModificarCapacitacion(var arch: TArchivoCapacitaciones; pos: longint);
procedure BajaCapacitacion(var arch: TArchivoCapacitaciones; pos: longint);
procedure MostrarCapacitacion(reg: TCapacitacion);

implementation
{------------------------------------------------------}
{ 1. Menú principal de capacitaciones                  }
{------------------------------------------------------}

procedure MenuCapacitaciones(var arch: TArchivoCapacitaciones;
                             var arbolCod: PNodoCodigo;
                             var arbolNom: PNodoNombre);
var
  codigo: integer;
  pos: longint;
  opcion: integer;
  reg: TCapacitacion;
begin
  repeat
    clrscr;
    writeln('=============================================');
    writeln('        GESTIÓN DE CAPACITACIONES - FRCU     ');
    writeln('=============================================');
    writeln;
    write('Ingrese el código de capacitación (0 para volver): ');
    readln(codigo);

    if codigo <> 0 then
    begin
      pos := BuscarPorCodigo(arbolCod, codigo);
      if pos = -1 then
      begin
        writeln('No existe una capacitación con ese código.');
        writeln('¿Desea darla de alta? (1=Sí / 2=No): ');
        readln(opcion);
        if opcion = 1 then
          AltaCapacitacion(arch, arbolCod, arbolNom, codigo);
      end
      else
      begin
        LeerCapacitacion(arch, pos, reg);
        ConsultarCapacitacion(arch, arbolCod, arbolNom, pos);
      end;
    end;
  until codigo = 0;
end;


{------------------------------------------------------}
{ 2. Alta de nueva capacitación                        }
{------------------------------------------------------}

procedure AltaCapacitacion(var arch: TArchivoCapacitaciones;
                           var arbolCod: PNodoCodigo;
                           var arbolNom: PNodoNombre;
                           codigo: integer);
var
  reg: TCapacitacion;
  pos: longint;
  tipoNum, areaNum: integer;
begin
  clrscr;
  writeln('=============================================');
  writeln('             ALTA DE CAPACITACIÓN            ');
  writeln('=============================================');
  reg.codigo := codigo;
  write('Nombre: '); readln(reg.nombre);

  { Fecha de inicio }
  write('Fecha de inicio (dd mm aaaa): ');
  readln(reg.fechaInicio.dia, reg.fechaInicio.mes, reg.fechaInicio.anio);

  { Fecha de fin }
  write('Fecha de fin (dd mm aaaa): ');
  readln(reg.fechaFin.dia, reg.fechaFin.mes, reg.fechaFin.anio);

  writeln('Tipo: 1) Curso  2) Taller  3) Seminario');
  readln(tipoNum);
  case tipoNum of
    1: reg.tipo := curso;
    2: reg.tipo := taller;
    3: reg.tipo := seminario;
  end;

  write('Cantidad de horas: '); readln(reg.horas);
  write('Docentes: '); readln(reg.docentes);
  reg.cantAlumnos := 0;

  writeln('Área: 1) ISI  2) LOI  3) Civil  4) Electro  5) General');
  readln(areaNum);
  case areaNum of
    1: reg.area := ISI;
    2: reg.area := LOI;
    3: reg.area := Civil;
    4: reg.area := Electro;
    5: reg.area := General;
  end;

  reg.estado := activo;

  GrabarCapacitacion(arch, reg);
  pos := filesize(arch) - 1;
  InsertarCodigo(arbolCod, reg.codigo, pos);
  InsertarNombre(arbolNom, reg.nombre, pos);

  writeln;
  writeln('Capacitación creada correctamente.');
  writeln('Presione ENTER para continuar...');
  readln;
end;


{------------------------------------------------------}
{ 3. Consulta y submenú de una capacitación             }
{------------------------------------------------------}

procedure ConsultarCapacitacion(var arch: TArchivoCapacitaciones;
                                var arbolCod: PNodoCodigo;
                                var arbolNom: PNodoNombre;
                                pos: longint);
var
  reg: TCapacitacion;
  opcion: integer;
begin
  repeat
    clrscr;
    LeerCapacitacion(arch, pos, reg);
    writeln('=============================================');
    writeln('         CONSULTA DE CAPACITACIÓN            ');
    writeln('=============================================');
    MostrarCapacitacion(reg);
    writeln;
    writeln('1) Modificar');
    writeln('2) Dar de baja');
    writeln('3) Volver');
    write('Seleccione opción: ');
    readln(opcion);

    case opcion of
      1: ModificarCapacitacion(arch, pos);
      2: BajaCapacitacion(arch, pos);
    end;
  until opcion = 3;
end;


{------------------------------------------------------}
{ 4. Modificación de una capacitación                  }
{------------------------------------------------------}

procedure ModificarCapacitacion(var arch: TArchivoCapacitaciones; pos: longint);
var
  reg: TCapacitacion;
  opcion: integer;
begin
  LeerCapacitacion(arch, pos, reg);
  repeat
    clrscr;
    writeln('=============================================');
    writeln('         MODIFICAR CAPACITACIÓN              ');
    writeln('=============================================');
    MostrarCapacitacion(reg);
    writeln;
    writeln('1) Modificar nombre');
    writeln('2) Modificar docentes');
    writeln('3) Modificar fechas');
    writeln('4) Modificar tipo');
    writeln('5) Volver');
    write('Opción: ');
    readln(opcion);

    case opcion of
      1: begin
           write('Nuevo nombre: '); readln(reg.nombre);
         end;
      2: begin
           write('Nuevos docentes: '); readln(reg.docentes);
         end;
      3: begin
           write('Nueva fecha inicio (dd mm aaaa): ');
           readln(reg.fechaInicio.dia, reg.fechaInicio.mes, reg.fechaInicio.anio);
           write('Nueva fecha fin (dd mm aaaa): ');
           readln(reg.fechaFin.dia, reg.fechaFin.mes, reg.fechaFin.anio);
         end;
      4: begin
           writeln('1) Curso 2) Taller 3) Seminario');
           readln(opcion);
           case opcion of
             1: reg.tipo := curso;
             2: reg.tipo := taller;
             3: reg.tipo := seminario;
           end;
         end;
    end;
  until opcion = 5;

  ActualizarCapacitacion(arch, pos, reg);
end;


{------------------------------------------------------}
{ 5. Baja lógica de una capacitación                   }
{------------------------------------------------------}

procedure BajaCapacitacion(var arch: TArchivoCapacitaciones; pos: longint);
var
  reg: TCapacitacion;
begin
  LeerCapacitacion(arch, pos, reg);
  reg.estado := no_activo;
  ActualizarCapacitacion(arch, pos, reg);
  writeln;
  writeln('Capacitación marcada como "no activa".');
  writeln('Presione ENTER para continuar...');
  readln;
end;


{------------------------------------------------------}
{ 6. Mostrar datos en pantalla                         }
{------------------------------------------------------}

procedure MostrarCapacitacion(reg: TCapacitacion);
const
  TipoTexto: array[TTipoCapacitacion] of string = ('Curso', 'Taller', 'Seminario');
  AreaTexto: array[TAreaCapacitacion] of string = ('ISI', 'LOI', 'Civil', 'Electro', 'General');
  EstadoTexto: array[TEstadoRegistro] of string = ('Activo', 'No activo');
begin
  writeln('Código: ', reg.codigo);
  writeln('Nombre: ', reg.nombre);
  writeln('Fechas: ', reg.fechaInicio.dia, '/', reg.fechaInicio.mes, '/', reg.fechaInicio.anio,
          '  al  ', reg.fechaFin.dia, '/', reg.fechaFin.mes, '/', reg.fechaFin.anio);
  writeln('Tipo: ', TipoTexto[reg.tipo]);
  writeln('Horas: ', reg.horas);
  writeln('Docentes: ', reg.docentes);
  writeln('Área: ', AreaTexto[reg.area]);
  writeln('Cantidad de alumnos: ', reg.cantAlumnos);
  writeln('Estado: ', EstadoTexto[reg.estado]);
end;

end.