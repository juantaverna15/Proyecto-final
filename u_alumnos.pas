unit U_Alumnos;
{$codepage utf8}


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



{FUNCIONES DE VALIDACIÓN}



{Verifica que el string no tenga dígitos      
 y no esté vacío. se usa para validar nombres. }

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


{Valida si el codigo de capacitacion son numeros}
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
      writeln('  [!] Solo se permiten NUMEROS. Sin letras ni símbolos.');
    end;
  until valido;
  LeerCodigoCap := valor;
end;



{VALIDAR DNI SIN PUNTOS NI DIGITOS NI SIMBOLOS}
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

{ESTO VALIDA EL NOMBRE QUE NO TENGA DIGITOS Y NO ESTE VACIO}
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

{LEE LA FECHA Y LLAMA LAS FUNCIONES DE VALIDACION HASTA QUE SE INGRESE BIEN}
procedure LeerFechaNacimiento(var f: TFecha);
var
  valido: boolean;
begin
  repeat
    writeln('  Fecha de nacimiento:');
    f.dia  := LeerEnteroRango('    Día  (1-31) : ', 1, 31);
    f.mes  := LeerEnteroRango('    Mes  (1-12) : ', 1, 12);
    f.anio := LeerEnteroRango('    Año  (1940-2010) : ', 1900, 2010);
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
{VALIDA LA ENTRADA DE DOCENTES, NO TERMINA HASTA QUE SE INGRESE CORRECTAMENTE}
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
  aluTemp       : TAlumno;
  capTemp       : TCapacitacion;
begin
  repeat
    clrscr;
    writeln('=============================================');
    writeln('             GESTIÓN DE ALUMNOS              ');
    writeln('=============================================');
    writeln('  Ingrese 0 para volver al menú anterior.');
    writeln;

    {Código de capacitación, solo dígitos }
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
        begin
          LeerAlumno(archAlu, posAlu, aluTemp);
          if aluTemp.estado = no_activo then
          begin
            writeln;
            writeln('  [!] El alumno figura como NO ACTIVO en esta capacitación.');
            opcion := LeerEnteroRango('  ¿Desea reactivarlo? (1=Sí / 2=No): ', 1, 2);
            if opcion = 1 then
            begin
              aluTemp.estado := activo;
              ActualizarAlumno(archAlu, posAlu, aluTemp);
              posCap := BuscarCapacitacionPorCodigo(archCap, codCap);
              if posCap <> -1 then
              begin
                LeerCapacitacion(archCap, posCap, capTemp);
                capTemp.cantAlumnos := capTemp.cantAlumnos + 1;
                ActualizarCapacitacion(archCap, posCap, capTemp);
              end;
              writeln;
              writeln('  [!] Alumno dado de alta .');
            end;
          end
          else
            ConsultarAlumno(archAlu, archCap, posAlu);
        end;
      end;
      writeln;
      writeln('  Presione ENTER para continuar...');
      readln;
    end;

  until codCap = 0;
end;


{ nuevo alumno }

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

  {  DNI validado }
  alu.dni := LeerDNIValido;

  { Nombre sin dígitos y no vacío }
  writeln;
  LeerNombreValido(alu.apenom);

  { Fecha de nacimiento real con año bisiesto }
  writeln;
  LeerFechaNacimiento(alu.fechaNac);

  { Docente UTN}
  writeln;
  alu.esDocenteUTN := LeerEsDocenteUTN;

  { Condición}
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
  writeln('  Alumno inscripto .');
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