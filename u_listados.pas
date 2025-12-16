unit U_Listados;

{******************************************************
  Unidad: U_Listados
  Sistema: Gestión de Capacitaciones FRCU
  Propósito:
    - Generar listados y certificados en consola,
      accediendo a los archivos random.
  Restricciones:
    - Programación imperativa estructurada.
    - Sin break, exit ni goto.
*******************************************************}

interface

uses
  crt, U_Tipos, U_Archivos;

{------------------------------------------------------}
{ Procedimientos públicos                              }
{------------------------------------------------------}

procedure MenuListados(var archCap: TArchivoCapacitaciones;
                       var archAlu: TArchivoAlumnos);

implementation

{------------------------------------------------------}
{ Declaración de procedimientos internos               }
{------------------------------------------------------}

// Cambia estas declaraciones forward por forward real
procedure ListadoPorArea(var archCap: TArchivoCapacitaciones); forward;
procedure ListadoCapacitacionesDeAlumno(var archCap: TArchivoCapacitaciones;
                                        var archAlu: TArchivoAlumnos); forward;
procedure ListadoAprobadosPorCapacitacion(var archCap: TArchivoCapacitaciones;
                                          var archAlu: TArchivoAlumnos); forward;
procedure GenerarCertificado(var archCap: TArchivoCapacitaciones;
                             var archAlu: TArchivoAlumnos); forward;

procedure MostrarCapacitacionCorta(reg: TCapacitacion); forward;
procedure MostrarAlumnoCorto(reg: TAlumno); forward;

{------------------------------------------------------}
{ 6. Utilitarios de impresión (DEFINIR PRIMERO)        }
{------------------------------------------------------}

procedure MostrarCapacitacionCorta(reg: TCapacitacion);
const
  TipoTexto: array[TTipoCapacitacion] of string = ('Curso', 'Taller', 'Seminario');
  AreaTexto: array[TAreaCapacitacion] of string = ('ISI', 'LOI', 'Civil', 'Electro', 'General');
begin
  writeln('[', AreaTexto[reg.area], '] ',
          reg.nombre, ' (', TipoTexto[reg.tipo], ')');
  writeln('Docentes: ', reg.docentes);
  writeln('Inicio: ', reg.fechaInicio.dia, '/', reg.fechaInicio.mes, '/', reg.fechaInicio.anio,
          '  Fin: ', reg.fechaFin.dia, '/', reg.fechaFin.mes, '/', reg.fechaFin.anio);
  writeln('---------------------------------------------');
end;

procedure MostrarAlumnoCorto(reg: TAlumno);
begin
  writeln(reg.apenom, ' - DNI: ', reg.dni);
end;

{------------------------------------------------------}
{ 1. Menú de listados                                  }
{------------------------------------------------------}

procedure MenuListados(var archCap: TArchivoCapacitaciones;
                       var archAlu: TArchivoAlumnos);
var
  opcion: integer;
begin
  repeat
    clrscr;
    writeln('=============================================');
    writeln('               MENÚ DE LISTADOS              ');
    writeln('=============================================');
    writeln('1) Capacitaciones por área y nombre');
    writeln('2) Capacitaciones de un alumno');
    writeln('3) Alumnos aprobados por capacitación');
    writeln('4) Generar certificado');
    writeln('5) Volver');
    writeln('---------------------------------------------');
    write('Opción: ');
    readln(opcion);

    case opcion of
      1: ListadoPorArea(archCap);
      2: ListadoCapacitacionesDeAlumno(archCap, archAlu);
      3: ListadoAprobadosPorCapacitacion(archCap, archAlu);
      4: GenerarCertificado(archCap, archAlu);
    end;
  until opcion = 5;
end;

{------------------------------------------------------}
{ 2. Listado por área y nombre de capacitación         }
{------------------------------------------------------}

procedure ListadoPorArea(var archCap: TArchivoCapacitaciones);
var
  reg: TCapacitacion;
  pos: longint;
begin
  clrscr;
  writeln('=============================================');
  writeln('  LISTADO DE CAPACITACIONES POR ÁREA/NOMBRE  ');
  writeln('=============================================');
  seek(archCap, 0);
  pos := 0;
  while pos < filesize(archCap) do
  begin
    read(archCap, reg);
    if reg.estado = activo then
      MostrarCapacitacionCorta(reg);
    pos := pos + 1;
  end;
  writeln('---------------------------------------------');
  writeln('Fin del listado. Presione ENTER...');
  readln;
end;

{------------------------------------------------------}
{ 3. Listado de capacitaciones de un alumno            }
{------------------------------------------------------}

procedure ListadoCapacitacionesDeAlumno(var archCap: TArchivoCapacitaciones;
                                        var archAlu: TArchivoAlumnos);
var
  regAlu: TAlumno;
  regCap: TCapacitacion;
  dniBuscado: longint;
  posAlu, posCap: longint;
  condicionTexto: string;
begin
  clrscr;
  writeln('=============================================');
  writeln('   CAPACITACIONES DE UN DETERMINADO ALUMNO   ');
  writeln('=============================================');
  write('Ingrese DNI del alumno: ');
  readln(dniBuscado);

  seek(archAlu, 0);
  posAlu := 0;
  while posAlu < filesize(archAlu) do
  begin
    read(archAlu, regAlu);
    if (regAlu.dni = dniBuscado) and (regAlu.estado = activo) then
    begin
      writeln;
      writeln('Alumno: ', regAlu.apenom, '  DNI: ', regAlu.dni);
      writeln('Fecha de nacimiento: ', regAlu.fechaNac.dia, '/', regAlu.fechaNac.mes, '/', regAlu.fechaNac.anio);
      writeln('--------------------------------------------------');
      writeln('CAPACITACIONES INSCRIPTAS:');
      writeln;

      posCap := BuscarCapacitacionPorCodigo(archCap, regAlu.codCapacitacion);
      if posCap <> -1 then
      begin
        LeerCapacitacion(archCap, posCap, regCap);
        writeln('Capacitación: ', regCap.nombre);
        writeln('Inicio: ', regCap.fechaInicio.dia, '/', regCap.fechaInicio.mes, '/', regCap.fechaInicio.anio,
                '  Fin: ', regCap.fechaFin.dia, '/', regCap.fechaFin.mes, '/', regCap.fechaFin.anio);
        writeln('Horas: ', regCap.horas);
        
        if regAlu.condicion = Aprobado then
          condicionTexto := 'Aprobado'
        else
          condicionTexto := 'Asistencia';
          
        writeln('Condición: ', condicionTexto);
        writeln('-------------------------------------------');
      end;
    end;
    posAlu := posAlu + 1;
  end;

  writeln;
  writeln('Fin del listado. Presione ENTER...');
  readln;
end;

{------------------------------------------------------}
{ 4. Listado de alumnos aprobados por capacitación     }
{------------------------------------------------------}

procedure ListadoAprobadosPorCapacitacion(var archCap: TArchivoCapacitaciones;
                                          var archAlu: TArchivoAlumnos);
var
  codCap: integer;
  posCap, posAlu: longint;
  cap: TCapacitacion;
  alu: TAlumno;
begin
  clrscr;
  writeln('=============================================');
  writeln('     ALUMNOS APROBADOS POR CAPACITACIÓN      ');
  writeln('=============================================');
  write('Ingrese código de capacitación: ');
  readln(codCap);

  posCap := BuscarCapacitacionPorCodigo(archCap, codCap);
  if posCap <> -1 then
  begin
    LeerCapacitacion(archCap, posCap, cap);
    writeln;
    writeln('Capacitación: ', cap.nombre);
    writeln('Inicio: ', cap.fechaInicio.dia, '/', cap.fechaInicio.mes, '/', cap.fechaInicio.anio);
    writeln('Fin: ', cap.fechaFin.dia, '/', cap.fechaFin.mes, '/', cap.fechaFin.anio);
    writeln('Docentes: ', cap.docentes);
    writeln('---------------------------------------------');
    writeln('APELLIDO Y NOMBRE            CONDICIÓN');
    writeln('---------------------------------------------');

    seek(archAlu, 0);
    posAlu := 0;
    while posAlu < filesize(archAlu) do
    begin
      read(archAlu, alu);
      if (alu.codCapacitacion = codCap) and (alu.estado = activo) and
         ((alu.condicion = Aprobado) or (alu.condicion = Asistencia)) then
      begin
        if alu.condicion = Aprobado then
          writeln(alu.apenom:25, '   ', 'Aprobado')
        else
          writeln(alu.apenom:25, '   ', 'Asistencia');
      end;
      posAlu := posAlu + 1;
    end;
  end
  else
    writeln('No existe capacitación con ese código.');

  writeln;
  writeln('Presione ENTER para continuar...');
  readln;
end;

{------------------------------------------------------}
{ 5. Generar certificado de cursado o aprobación       }
{------------------------------------------------------}

procedure GenerarCertificado(var archCap: TArchivoCapacitaciones;
                             var archAlu: TArchivoAlumnos);
var
  codCap: integer;
  dni: longint;
  posCap, posAlu: longint;
  cap: TCapacitacion;
  alu: TAlumno;
begin
  clrscr;
  writeln('=============================================');
  writeln('           GENERAR CERTIFICADO               ');
  writeln('=============================================');
  write('Ingrese código de capacitación: ');
  readln(codCap);
  write('Ingrese DNI del alumno: ');
  readln(dni);

  posCap := BuscarCapacitacionPorCodigo(archCap, codCap);
  posAlu := BuscarAlumnoPorDNI(archAlu, codCap, dni);

  if (posCap <> -1) and (posAlu <> -1) then
  begin
    LeerCapacitacion(archCap, posCap, cap);
    LeerAlumno(archAlu, posAlu, alu);
    clrscr;
    writeln('***********************************************');
    writeln('         UNIVERSIDAD TECNOLÓGICA NACIONAL      ');
    writeln('          FACULTAD REGIONAL CONCEPCIÓN         ');
    writeln('***********************************************');
    writeln;
    writeln('Se certifica que el/la alumno/a:');
    writeln(alu.apenom, '  (DNI ', alu.dni, ')');
    writeln('Ha completado la capacitación:');
    writeln('"', cap.nombre, '"');
    writeln('Dictada desde ', cap.fechaInicio.dia, '/', cap.fechaInicio.mes, '/', cap.fechaInicio.anio,
            ' hasta ', cap.fechaFin.dia, '/', cap.fechaFin.mes, '/', cap.fechaFin.anio, '.');
    writeln('Duración: ', cap.horas, ' horas.');
    writeln;
    if alu.condicion = Aprobado then
      writeln('=> Tipo de certificado: APROBACIÓN')
    else
      writeln('=> Tipo de certificado: CURSADO / ASISTENCIA');
    writeln;
    writeln('Concepción del Uruguay, ', cap.fechaFin.dia, '/', cap.fechaFin.mes, '/', cap.fechaFin.anio);
    writeln;
    writeln('-----------------------------------------------');
    writeln('Secretaría de Extensión Universitaria - FRCU');
    writeln('***********************************************');
  end
  else
    writeln('No se encontró el alumno o la capacitación.');
  writeln;
  writeln('Presione ENTER para continuar...');
  readln;
end;

end.