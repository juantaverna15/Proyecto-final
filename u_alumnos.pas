unit U_Alumnos;

{******************************************************
  Unidad: U_Alumnos
  Sistema: Gestión de Capacitaciones FRCU
  Propósito:
    - Gestionar operaciones ABMC de alumnos asociados
      a capacitaciones, manteniendo consistencia
      con el archivo maestro de capacitaciones.
  Restricciones:
    - Programación estructurada (sin break, exit, goto)
*******************************************************}

interface

uses
  crt, u_tipos, u_archivos;

{------------------------------------------------------}
{ Procedimiento principal del módulo                   }
{------------------------------------------------------}

procedure MenuAlumnos(var archAlu: TArchivoAlumnos;
                      var archCap: TArchivoCapacitaciones);

implementation

{------------------------------------------------------}
{ Declaración de procedimientos internos               }
{------------------------------------------------------}

procedure AltaAlumno(var archAlu: TArchivoAlumnos;
                     var archCap: TArchivoCapacitaciones;
                     codCap: integer); forward;

procedure ConsultarAlumno(var archAlu: TArchivoAlumnos;
                          var archCap: TArchivoCapacitaciones;
                          posAlu: longint); forward;

procedure ModificarAlumno(var archAlu: TArchivoAlumnos; pos: longint); forward;
procedure BajaAlumno(var archAlu: TArchivoAlumnos;
                     var archCap: TArchivoCapacitaciones;
                     pos: longint); forward;
procedure MostrarAlumno(reg: TAlumno); forward;

{------------------------------------------------------}
{ 1. Menú principal de alumnos                         }
{------------------------------------------------------}

procedure MenuAlumnos(var archAlu: TArchivoAlumnos;
                      var archCap: TArchivoCapacitaciones);
var
  codCap: integer;
  dni: longint;
  posCap, posAlu: longint;
  opcion: integer;
begin
  repeat
    clrscr;
    writeln('=============================================');
    writeln('             GESTIÓN DE ALUMNOS              ');
    writeln('=============================================');
    writeln;
    write('Ingrese código de capacitación (0 para volver): ');
    readln(codCap);

    if codCap <> 0 then
    begin
      posCap := BuscarCapacitacionPorCodigo(archCap, codCap);
      if posCap = -1 then
        writeln('No existe una capacitación con ese código.')
      else
      begin
        write('Ingrese DNI del alumno: ');
        readln(dni);
        posAlu := BuscarAlumnoPorDNI(archAlu, codCap, dni);

        if posAlu = -1 then
        begin
          writeln('El alumno no está inscripto en esta capacitación.');
          writeln('¿Desea darlo de alta? (1=Sí / 2=No): ');
          readln(opcion);
          if opcion = 1 then
            AltaAlumno(archAlu, archCap, codCap);
        end
        else
          ConsultarAlumno(archAlu, archCap, posAlu);
      end;
      writeln('Presione ENTER para continuar...');
      readln;
    end;
  until codCap = 0;
end;

{------------------------------------------------------}
{ 2. Alta de nuevo alumno                              }
{------------------------------------------------------}

procedure AltaAlumno(var archAlu: TArchivoAlumnos;
                     var archCap: TArchivoCapacitaciones;
                     codCap: integer);
var
  alu: TAlumno;
  cap: TCapacitacion;
  posCap: longint;
  cond, docFlag: integer;
begin
  clrscr;
  writeln('=============================================');
  writeln('               ALTA DE ALUMNO                ');
  writeln('=============================================');
  alu.codCapacitacion := codCap;

  write('DNI: '); readln(alu.dni);
  write('Apellido y nombre: '); readln(alu.apenom);
  write('Fecha de nacimiento (dd mm aaaa): ');
  readln(alu.fechaNac.dia, alu.fechaNac.mes, alu.fechaNac.anio);

  writeln('¿Es docente UTN? (1=Sí / 2=No): ');
  readln(docFlag);
  alu.esDocenteUTN := (docFlag = 1);

  writeln('Condición: 1) Aprobado  2) Asistencia');
  readln(cond);
  if cond = 1 then
    alu.condicion := Aprobado
  else
    alu.condicion := Asistencia;

  alu.estado := activo;

  { Guardar alumno }
  GrabarAlumno(archAlu, alu);

  { Actualizar cantidad de inscriptos }
  posCap := BuscarCapacitacionPorCodigo(archCap, codCap);
  if posCap <> -1 then
  begin
    LeerCapacitacion(archCap, posCap, cap);
    cap.cantAlumnos := cap.cantAlumnos + 1;
    ActualizarCapacitacion(archCap, posCap, cap);
  end;

  writeln;
  writeln('Alumno inscripto correctamente.');
  writeln('Presione ENTER para continuar...');
  readln;
end;

{------------------------------------------------------}
{ 3. Consulta y submenú de alumno                      }
{------------------------------------------------------}

procedure ConsultarAlumno(var archAlu: TArchivoAlumnos;
                          var archCap: TArchivoCapacitaciones;
                          posAlu: longint);
var
  alu: TAlumno;
  opcion: integer;
begin
  repeat
    clrscr;
    LeerAlumno(archAlu, posAlu, alu);
    writeln('=============================================');
    writeln('           CONSULTA DE ALUMNO                ');
    writeln('=============================================');
    MostrarAlumno(alu);
    writeln;
    writeln('1) Modificar');
    writeln('2) Dar de baja');
    writeln('3) Volver');
    write('Seleccione opción: ');
    readln(opcion);

    case opcion of
      1: ModificarAlumno(archAlu, posAlu);
      2: BajaAlumno(archAlu, archCap, posAlu);
    end;
  until opcion = 3;
end;

{------------------------------------------------------}
{ 4. Modificación de alumno                            }
{------------------------------------------------------}

procedure ModificarAlumno(var archAlu: TArchivoAlumnos; pos: longint);
var
  alu: TAlumno;
  opcion: integer;
  cond, docFlag: integer;
begin
  LeerAlumno(archAlu, pos, alu);
  repeat
    clrscr;
    writeln('=============================================');
    writeln('          MODIFICAR ALUMNO                   ');
    writeln('=============================================');
    MostrarAlumno(alu);
    writeln;
    writeln('1) Cambiar nombre');
    writeln('2) Cambiar condición');
    writeln('3) Cambiar si es docente UTN');
    writeln('4) Volver');
    write('Opción: ');
    readln(opcion);

    case opcion of
      1: begin
           write('Nuevo apellido y nombre: ');
           readln(alu.apenom);
         end;
      2: begin
           writeln('Condición: 1) Aprobado  2) Asistencia');
           readln(cond);
           if cond = 1 then
             alu.condicion := Aprobado
           else
             alu.condicion := Asistencia;
         end;
      3: begin
           writeln('¿Es docente UTN? (1=Sí / 2=No): ');
           readln(docFlag);
           alu.esDocenteUTN := (docFlag = 1);
         end;
    end;
  until opcion = 4;

  ActualizarAlumno(archAlu, pos, alu);
end;

{------------------------------------------------------}
{ 5. Baja lógica de alumno                             }
{------------------------------------------------------}

procedure BajaAlumno(var archAlu: TArchivoAlumnos;
                     var archCap: TArchivoCapacitaciones;
                     pos: longint);
var
  alu: TAlumno;
  cap: TCapacitacion;
  posCap: longint;
begin
  LeerAlumno(archAlu, pos, alu);
  alu.estado := no_activo;
  ActualizarAlumno(archAlu, pos, alu);

  { Descontar cantidad de inscriptos activos }
  posCap := BuscarCapacitacionPorCodigo(archCap, alu.codCapacitacion);
  if posCap <> -1 then
  begin
    LeerCapacitacion(archCap, posCap, cap);
    if cap.cantAlumnos > 0 then
    begin
      cap.cantAlumnos := cap.cantAlumnos - 1;
      ActualizarCapacitacion(archCap, posCap, cap);
    end;
  end;

  writeln;
  writeln('Alumno dado de baja lógicamente.');
  writeln('Presione ENTER para continuar...');
  readln;
end;

{------------------------------------------------------}
{ 6. Mostrar datos de alumno                           }
{------------------------------------------------------}

procedure MostrarAlumno(reg: TAlumno);
const
  CondTexto: array[TCondicionAlumno] of string = ('Aprobado', 'Asistencia');
  EstadoTexto: array[TEstadoRegistro] of string = ('Activo', 'No activo');
begin
  writeln('Código capacitación: ', reg.codCapacitacion);
  writeln('DNI: ', reg.dni);
  writeln('Apellido y nombre: ', reg.apenom);
  writeln('Fecha de nacimiento: ', reg.fechaNac.dia, '/', reg.fechaNac.mes, '/', reg.fechaNac.anio);
  
  if reg.esDocenteUTN then
    writeln('Docente UTN: Sí')
  else
    writeln('Docente UTN: No');
  
  // Agregar para usar las constantes y quitar los warnings
  writeln('Condición: ', CondTexto[reg.condicion]);
  writeln('Estado: ', EstadoTexto[reg.estado]);
end;

end.  // ← Solo UN end. para cerrar la implementación