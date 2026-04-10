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
    - Todas las entradas de usuario son validadas antes
      de ser aceptadas.
*******************************************************}

interface

uses
  crt, U_Tipos, U_Archivos, U_Utils;

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


{======================================================}
{         BLOQUE DE FUNCIONES DE VALIDACIÓN            }
{======================================================}

{------------------------------------------------------}
{ V-1. Verifica que un string contenga solo dígitos    }
{   y no esté vacío.                                   }
{------------------------------------------------------}
function EsSoloDigitos(s: string): boolean;
var
  i  : integer;
  ok : boolean;
begin
  ok := length(s) > 0;
  i  := 1;
  while ok and (i <= length(s)) do
  begin
    if not (s[i] in ['0'..'9']) then
      ok := false;
    i := i + 1;
  end;
  EsSoloDigitos := ok;
end;

{------------------------------------------------------}
{ V-2. Verifica que el string NO contenga dígitos      }
{   y no esté vacío. Usado para validar nombres.       }
{------------------------------------------------------}
function EsNombreValido(s: string): boolean;
var
  i          : integer;
  tieneLetras: boolean;
  tieneDigito: boolean;
begin
  tieneLetras := length(s) > 0;
  tieneDigito := false;
  i := 1;
  while i <= length(s) do
  begin
    if s[i] in ['0'..'9'] then
      tieneDigito := true;
    i := i + 1;
  end;
  { Válido: tiene contenido y ningún dígito }
  EsNombreValido := tieneLetras and not tieneDigito;
end;

{------------------------------------------------------}
{ V-3. Año bisiesto                                    }
{------------------------------------------------------}
function EsBisiesto(anio: integer): boolean;
begin
  EsBisiesto := ((anio mod 4 = 0) and (anio mod 100 <> 0))
                or (anio mod 400 = 0);
end;

{------------------------------------------------------}
{ V-4. Días reales en un mes dado                      }
{------------------------------------------------------}
function DiasEnMes(mes, anio: integer): integer;
var
  dias: integer;
begin
  case mes of
    1, 3, 5, 7, 8, 10, 12 : dias := 31;
    4, 6, 9, 11            : dias := 30;
    2: if EsBisiesto(anio) then
         dias := 29
       else
         dias := 28;
  else
    dias := 0;
  end;
  DiasEnMes := dias;
end;

{------------------------------------------------------}
{ V-5. Valida que un TFecha sea una fecha calendario   }
{   real (incluye año bisiesto para febrero).          }
{------------------------------------------------------}
function FechaValida(f: TFecha): boolean;
begin
  FechaValida := (f.anio > 0)
             and (f.mes  >= 1) and (f.mes  <= 12)
             and (f.dia  >= 1) and (f.dia  <= DiasEnMes(f.mes, f.anio));
end;


{======================================================}
{         BLOQUE DE FUNCIONES DE INGRESO VALIDADO      }
{======================================================}

{------------------------------------------------------}
{ E-1. Ingresa el CÓDIGO de capacitación               }
{   - Solo dígitos, rechaza letras y símbolos.         }
{   - Retorna 0 si el usuario quiere volver.           }
{------------------------------------------------------}
function LeerCodigoCap: integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    write('Código de capacitación (solo números, 0 para volver): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0);
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] Solo se permiten dígitos numéricos. Sin letras ni símbolos.');
    end;
  until valido;
  LeerCodigoCap := valor;
end;

{------------------------------------------------------}
{ E-2. Ingresa el DNI del alumno                       }
{   - Solo dígitos (sin puntos ni guiones).            }
{   - Valor mínimo: 1                                  }
{   - Valor máximo: 99.999.999                         }
{------------------------------------------------------}
function LeerDNIValido: longint;
var
  s     : string;
  valor : longint;
  code  : integer;
  valido: boolean;
begin
  repeat
    write('  DNI (solo números, máx. 99.999.999, sin puntos): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor >= 1) and (valor <= 99999999);
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] DNI inválido. Ingrese solo dígitos, entre 1 y 99999999.');
      writeln('      No use puntos, guiones ni letras.');
    end;
  until valido;
  LeerDNIValido := valor;
end;

{------------------------------------------------------}
{ E-3. Ingresa el APELLIDO Y NOMBRE del alumno         }
{   - No puede estar vacío.                            }
{   - No puede contener dígitos (0-9).                 }
{------------------------------------------------------}
procedure LeerNombreValido(var nombre: string);
var
  valido: boolean;
begin
  repeat
    write('  Apellido y nombre: ');
    readln(nombre);
    valido := EsNombreValido(nombre);
    if not valido then
    begin
      writeln;
      if length(nombre) = 0 then
        writeln('  [!] El nombre no puede estar vacío.')
      else
        writeln('  [!] El nombre no debe contener números ni símbolos.');
    end;
  until valido;
end;

{------------------------------------------------------}
{ E-4. Ingresa la FECHA DE NACIMIENTO                  }
{   - Valida que sea una fecha calendario real.        }
{   - Contempla meses con 28/29/30/31 días.            }
{   - Incluye validación de año bisiesto (Feb-29).     }
{------------------------------------------------------}
procedure LeerFechaNacimiento(var f: TFecha);
var
  valido: boolean;
begin
  repeat
    writeln('  Fecha de nacimiento:');
    f.dia  := LeerEnteroRango('    Día  (1-31) : ', 1, 31);
    f.mes  := LeerEnteroRango('    Mes  (1-12) : ', 1, 12);
    f.anio := LeerEntero     ('    Año         : ');
    valido := FechaValida(f);
    if not valido then
    begin
      writeln;
      writeln('  [!] Fecha inválida. Verifique:');
      writeln('      - El mes debe estar entre 1 y 12.');
      writeln('      - El día debe ser válido para ese mes y año.');
      if (f.mes = 2) and (f.dia = 29) and not EsBisiesto(f.anio) then
        writeln('      - El año ', f.anio,
                ' no es bisiesto: febrero solo tiene 28 días.');
    end;
  until valido;
end;

{------------------------------------------------------}
{ E-5. Pregunta si es DOCENTE UTN                      }
{   - Acepta solo 1 (Sí) o 2 (No).                    }
{   - Pide de nuevo hasta que el valor sea correcto.   }
{------------------------------------------------------}
function LeerEsDocenteUTN: boolean;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    writeln('  ¿Es docente UTN?');
    writeln('    1) Sí');
    writeln('    2) No');
    write  ('  Seleccione (1 o 2): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and ((valor = 1) or (valor = 2));
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] Opción inválida. Ingrese 1 (Sí) o 2 (No).');
    end;
  until valido;
  LeerEsDocenteUTN := (valor = 1);
end;

{------------------------------------------------------}
{ E-6. Ingresa la CONDICIÓN académica del alumno       }
{   - Acepta solo 1 (Aprobado) o 2 (Asistencia).      }
{   - Pide de nuevo hasta que el valor sea correcto.   }
{------------------------------------------------------}
function LeerCondicionValida: TCondicionAlumno;
var
  s      : string;
  valor  : integer;
  code   : integer;
  valido : boolean;
  result : TCondicionAlumno;
begin
  repeat
    writeln('  Condición académica:');
    writeln('    1) Aprobado');
    writeln('    2) Asistencia');
    write  ('  Seleccione (1 o 2): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and ((valor = 1) or (valor = 2));
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] Opción inválida. Ingrese 1 (Aprobado) o 2 (Asistencia).');
    end;
  until valido;
  if valor = 1 then
    result := Aprobado
  else
    result := Asistencia;
  LeerCondicionValida := result;
end;


{======================================================}
{         PROCEDIMIENTOS PRINCIPALES DEL MENÚ          }
{======================================================}

{------------------------------------------------------}
{ 1. Menú principal de alumnos                         }
{------------------------------------------------------}

procedure MenuAlumnos(var archAlu: TArchivoAlumnos;
                      var archCap: TArchivoCapacitaciones);
var
  codCap        : integer;
  dni           : longint;
  posCap, posAlu: longint;
  opcion        : integer;
begin
  repeat
    clrscr;
    writeln('=============================================');
    writeln('             GESTIÓN DE ALUMNOS              ');
    writeln('=============================================');
    writeln('  Ingrese 0 como código para volver al menú anterior.');
    writeln;

    { E-1: Código de capacitación, solo dígitos }
    codCap := LeerCodigoCap;

    if codCap <> 0 then
    begin
      posCap := BuscarCapacitacionPorCodigo(archCap, codCap);

      if posCap = -1 then
      begin
        writeln;
        writeln('  [!] No existe una capacitación con el código ', codCap, '.');
      end
      else
      begin
        writeln;
        { E-2: DNI, solo números, máx 99.999.999 }
        dni    := LeerDNIValido;
        posAlu := BuscarAlumnoPorDNI(archAlu, codCap, dni);

        if posAlu = -1 then
        begin
          writeln;
          writeln('  El alumno no está inscripto en esta capacitación.');
          opcion := LeerEnteroRango('  ¿Desea darlo de alta? (1=Sí / 2=No): ', 1, 2);
          if opcion = 1 then
            AltaAlumno(archAlu, archCap, codCap);
        end
        else
          ConsultarAlumno(archAlu, archCap, posAlu);
      end;
      writeln;
      writeln('Presione ENTER para continuar...');
      readln;
    end;

  until codCap = 0;
end;


{------------------------------------------------------}
{ 2. Alta de nuevo alumno (con validaciones completas) }
{------------------------------------------------------}

procedure AltaAlumno(var archAlu: TArchivoAlumnos;
                     var archCap: TArchivoCapacitaciones;
                     codCap: integer);
var
  alu   : TAlumno;
  cap   : TCapacitacion;
  posCap: longint;
begin
  clrscr;
  writeln('=============================================');
  writeln('               ALTA DE ALUMNO                ');
  writeln('=============================================');
  writeln('  Capacitación Nº: ', codCap);
  writeln;

  alu.codCapacitacion := codCap;

  { E-2: DNI validado (solo números, max 99.999.999) }
  alu.dni := LeerDNIValido;

  { E-3: Nombre sin dígitos y no vacío }
  writeln;
  LeerNombreValido(alu.apenom);

  { E-4: Fecha de nacimiento real con año bisiesto }
  writeln;
  LeerFechaNacimiento(alu.fechaNac);

  { E-5: Docente UTN, solo 1 o 2 }
  writeln;
  alu.esDocenteUTN := LeerEsDocenteUTN;

  { E-6: Condición, solo 1 o 2 }
  writeln;
  alu.condicion := LeerCondicionValida;

  alu.estado := activo;

  { Grabar alumno en archivo }
  GrabarAlumno(archAlu, alu);

  { Actualizar contador de inscriptos en la capacitación }
  posCap := BuscarCapacitacionPorCodigo(archCap, codCap);
  if posCap <> -1 then
  begin
    LeerCapacitacion(archCap, posCap, cap);
    cap.cantAlumnos := cap.cantAlumnos + 1;
    ActualizarCapacitacion(archCap, posCap, cap);
  end;

  writeln;
  writeln('=============================================');
  writeln('  Alumno inscripto correctamente.');
  writeln('=============================================');
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
  alu   : TAlumno;
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
    writeln('  1) Modificar');
    writeln('  2) Dar de baja');
    writeln('  3) Volver');
    opcion := LeerEnteroRango('Seleccione opción: ', 1, 3);

    case opcion of
      1: ModificarAlumno(archAlu, posAlu);
      2: BajaAlumno(archAlu, archCap, posAlu);
    end;
  until opcion = 3;
end;


{------------------------------------------------------}
{ 4. Modificación de alumno (con validaciones)         }
{------------------------------------------------------}

procedure ModificarAlumno(var archAlu: TArchivoAlumnos; pos: longint);
var
  alu   : TAlumno;
  opcion: integer;
begin
  LeerAlumno(archAlu, pos, alu);
  repeat
    clrscr;
    writeln('=============================================');
    writeln('          MODIFICAR ALUMNO                   ');
    writeln('=============================================');
    MostrarAlumno(alu);
    writeln;
    writeln('  1) Cambiar nombre');
    writeln('  2) Cambiar condición');
    writeln('  3) Cambiar si es docente UTN');
    writeln('  4) Volver');
    opcion := LeerEnteroRango('Opción: ', 1, 4);

    case opcion of
      1: begin
           writeln;
           { Reutiliza el validador de nombre }
           LeerNombreValido(alu.apenom);
         end;
      2: begin
           writeln;
           { Reutiliza el validador de condición }
           alu.condicion := LeerCondicionValida;
         end;
      3: begin
           writeln;
           { Reutiliza el validador de docente UTN }
           alu.esDocenteUTN := LeerEsDocenteUTN;
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
  alu   : TAlumno;
  cap   : TCapacitacion;
  posCap: longint;
begin
  LeerAlumno(archAlu, pos, alu);
  alu.estado := no_activo;
  ActualizarAlumno(archAlu, pos, alu);

  { Descontar cantidad de inscriptos activos en la capacitación }
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
{ 6. Mostrar datos del alumno en pantalla              }
{------------------------------------------------------}

procedure MostrarAlumno(reg: TAlumno);
const
  CondTexto  : array[TCondicionAlumno] of string = ('Aprobado', 'Asistencia');
  EstadoTexto: array[TEstadoRegistro]  of string = ('Activo',   'No activo');
begin
  writeln('  Cód. capacitación: ', reg.codCapacitacion);
  writeln('  DNI              : ', reg.dni);
  writeln('  Apellido y nombre: ', reg.apenom);
  writeln('  Fecha de nac.    : ', reg.fechaNac.dia, '/',
                                   reg.fechaNac.mes, '/',
                                   reg.fechaNac.anio);
  if reg.esDocenteUTN then
    writeln('  Docente UTN      : Sí')
  else
    writeln('  Docente UTN      : No');
  writeln('  Condición        : ', CondTexto[reg.condicion]);
  writeln('  Estado           : ', EstadoTexto[reg.estado]);
end;

end.