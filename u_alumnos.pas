unit U_Alumnos;
{$codepage utf8}
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
  crt, U_Tipos, U_Archivos, U_Utilidades;

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

procedure ModificarAlumno(var archAlu: TArchivoAlumnos;
                          var archCap: TArchivoCapacitaciones;
                          pos: longint); forward;

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
  contienedigitos : boolean;
begin
  contienedigitos := length(s) > 0;
  i  := 1;
  while contienedigitos and (i <= length(s)) do
  begin
    if not (s[i] in ['0'..'9']) then
      contienedigitos := false;
    i := i + 1;
  end;
  EsSoloDigitos := contienedigitos;
end;

{------------------------------------------------------}
{ V-2. Verifica que el string NO contenga dígitos      }
{   y no esté vacío. Usado para validar nombres.       }
{------------------------------------------------------}
function EsNombreValido(s: string): boolean;
var
  i      : integer;
  valido : boolean;
  c      : char;
begin
  valido := length(s) > 0;
  i := 1;
  while valido and (i <= length(s)) do
  begin
    c := s[i];
    { Permite: letras a-z / A-Z, espacio, guion medio,     }
    { punto (Dr. / Jr.) y bytes >= #128 que cubren los      }
    { caracteres UTF-8 de dos bytes: á é í ó ú ü ñ Ñ etc.  }
    if not ( (c in ['a'..'z']) or
             (c in ['A'..'Z']) or
             (c = ' ')         or
             (c = '-')         or
             (c = '.')         or
             (ord(c) >= 128)   ) then
      valido := false;
    i := i + 1;
  end;
  EsNombreValido := valido;
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
{   - Valor mínimo: 10.000.000                         }
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
    write('  DNI (solo números, sin puntos): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor >= 10000000) and (valor <= 99999999);
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] DNI inválido. .');
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


procedure LeerFechaNacimiento(var f: TFecha);
var
  valido: boolean;
begin
  repeat
    writeln('  Fecha de nacimiento:');
    f.dia  := LeerEnteroRango('    Día  (1-31) : ', 1, 31);
    f.mes  := LeerEnteroRango('    Mes  (1-12) : ', 1, 12);
    f.anio := LeerEnteroRango('    Año  (1900-2010) : ', 1900, 2010);
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


function LeerEstadoValido: TEstadoRegistro;
var
  s      : string;
  valor  : integer;
  code   : integer;
  valido : boolean;
begin
  repeat
    writeln('  Estado del alumno:');
    writeln('    1) Activo');
    writeln('    2) No activo');
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
      writeln('  [!] Opción inválida. Ingrese 1 (Activo) o 2 (No activo).');
    end;
  until valido;
  if valor = 1 then
    LeerEstadoValido := activo
  else
    LeerEstadoValido := no_activo;
end;

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
      1: ModificarAlumno(archAlu, archCap, posAlu);
      2: BajaAlumno(archAlu, archCap, posAlu);
    end;
  until opcion = 3;
end;




procedure ModificarAlumno(var archAlu: TArchivoAlumnos;
                          var archCap: TArchivoCapacitaciones;
                          pos: longint);
var
  alu         : TAlumno;
  cap         : TCapacitacion;
  posCap      : longint;
  opcion      : integer;
  estadoAntes : TEstadoRegistro;
  estadoNuevo : TEstadoRegistro;
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
    writeln('  3) Cambiar si es docente/alumno UTN');
    writeln('  4) Cambiar estado (Activo / No activo)');
    writeln('  5) Volver');
    opcion := LeerEnteroRango('Opción: ', 1, 5);

    case opcion of
      1: begin
           writeln;
           LeerNombreValido(alu.apenom);
         end;
      2: begin
           writeln;
           alu.condicion := LeerCondicionValida;
         end;
      3: begin
           writeln;
           alu.esDocenteUTN := LeerEsDocenteUTN;
         end;
      4: begin
           writeln;
           estadoAntes := alu.estado;
           estadoNuevo := LeerEstadoValido;
           alu.estado  := estadoNuevo;

           { Actualizar cantAlumnos en la capacitación según el cambio }
           if estadoAntes <> estadoNuevo then
           begin
             posCap := BuscarCapacitacionPorCodigo(archCap, alu.codCapacitacion);
             if posCap <> -1 then
             begin
               LeerCapacitacion(archCap, posCap, cap);
               if (estadoAntes = no_activo) and (estadoNuevo = activo) then
                 cap.cantAlumnos := cap.cantAlumnos + 1
               else if (estadoAntes = activo) and (estadoNuevo = no_activo) then
               begin
                 if cap.cantAlumnos > 0 then
                   cap.cantAlumnos := cap.cantAlumnos - 1;
               end;
               ActualizarCapacitacion(archCap, posCap, cap);
             end;
           end;
         end;
    end;
  until opcion = 5;

  ActualizarAlumno(archAlu, pos, alu);
end;




procedure BajaAlumno(var archAlu: TArchivoAlumnos;
                     var archCap: TArchivoCapacitaciones;
                     pos: longint);
var
  alu   : TAlumno;
  cap   : TCapacitacion;
  posCap: longint;
begin
  LeerAlumno(archAlu, pos, alu);

  if alu.estado = no_activo then
  begin
    writeln;
    writeln('  [Aviso] El alumno ya estaba dado de baja. No se realizó ningún cambio.');
  end
  else
  begin
    alu.estado := no_activo;
    ActualizarAlumno(archAlu, pos, alu);

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
    writeln('  Alumno dado de baja .');
  end;

  writeln('  Presione ENTER para continuar...');
  readln;
end;




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