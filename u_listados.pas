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
  crt, U_Tipos, U_Archivos, U_Utils;

{------------------------------------------------------}
{ Procedimientos públicos                              }
{------------------------------------------------------}

procedure MenuListados(var archCap: TArchivoCapacitaciones;
                       var archAlu: TArchivoAlumnos);

implementation

{------------------------------------------------------}
{ Declaración de procedimientos internos               }
{------------------------------------------------------}

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
{ 6. Utilitarios de impresión                          }
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
    opcion := LeerEnteroRango('Opción: ', 1, 5);

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
  regAlu        : TAlumno;
  regCap        : TCapacitacion;
  dniBuscado    : longint;
  posAlu, posCap: longint;
  condicionTexto: string;
begin
  clrscr;
  writeln('=============================================');
  writeln('   CAPACITACIONES DE UN DETERMINADO ALUMNO   ');
  writeln('=============================================');
  dniBuscado := LeerLongintRango('Ingrese DNI del alumno: ', 10000000, 99999999);

  seek(archAlu, 0);
  posAlu := 0;
  while posAlu < filesize(archAlu) do
  begin
    read(archAlu, regAlu);
    if (regAlu.dni = dniBuscado) and (regAlu.estado = activo) then
    begin
      writeln;
      writeln('Alumno: ', regAlu.apenom, '  DNI: ', regAlu.dni);
      writeln('Fecha de nacimiento: ', regAlu.fechaNac.dia, '/',
              regAlu.fechaNac.mes, '/', regAlu.fechaNac.anio);
      writeln('--------------------------------------------------');
      writeln('CAPACITACIONES INSCRIPTAS:');
      writeln;

      posCap := BuscarCapacitacionPorCodigo(archCap, regAlu.codCapacitacion);
      if posCap <> -1 then
      begin
        LeerCapacitacion(archCap, posCap, regCap);
        writeln('Capacitación: ', regCap.nombre);
        writeln('Inicio: ', regCap.fechaInicio.dia, '/', regCap.fechaInicio.mes, '/',
                regCap.fechaInicio.anio,
                '  Fin: ', regCap.fechaFin.dia, '/', regCap.fechaFin.mes, '/',
                regCap.fechaFin.anio);
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
  codCap        : integer;
  posCap, posAlu: longint;
  cap           : TCapacitacion;
  alu           : TAlumno;
begin
  clrscr;
  writeln('=============================================');
  writeln('     ALUMNOS APROBADOS POR CAPACITACIÓN      ');
  writeln('=============================================');
  codCap := LeerEntero('Ingrese código de capacitación: ');

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
      if (alu.codCapacitacion = codCap) and (alu.estado = activo) then
      begin
        if alu.condicion = Aprobado then
          writeln(alu.apenom:30, '   Aprobado')
        else
          writeln(alu.apenom:30, '   Asistencia');
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


{======================================================}
{         CERTIFICADO  (diseño rediseñado)             }
{======================================================}

{------------------------------------------------------}
{ 5. Generar certificado de cursado o aprobación       }
{                                                      }
{   Diseño: caja de doble línea (80 cols), caja       }
{   interna de línea simple para los datos de la      }
{   capacitación, formato DNI con puntos,             }
{   fecha de emisión escrita en letras.               }
{------------------------------------------------------}

procedure GenerarCertificado(var archCap: TArchivoCapacitaciones;
                             var archAlu: TArchivoAlumnos);
var
  codCap        : integer;
  dni           : longint;
  posCap, posAlu: longint;
  cap           : TCapacitacion;
  alu           : TAlumno;
  sTipo, sArea  : string;
  sHoras        : string;
  sAnio         : string;
  sDocUTN       : string;
  sCondicion    : string;
  sCentroTipo   : string;
  sLinea        : string;
  iLen          : integer;

  { ══════════════════════════════════════════════ }
  {   Funciones auxiliares locales al certificado  }
  { ══════════════════════════════════════════════ }

  { Repite el carácter c exactamente n veces }
  function RepStr(c: char; n: integer): string;
  var s: string; k: integer;
  begin
    s := '';
    for k := 1 to n do s := s + c;
    RepStr := s;
  end;

  { Centra texto s dentro de un ancho de 78 caracteres }
  function Centro(s: string): string;
  var pad: integer;
  begin
    pad := (78 - length(s)) div 2;
    if pad < 0 then pad := 0;
    Centro := RepStr(' ', pad) + s;
  end;

  { Entero a string de 2 dígitos con cero a la izquierda }
  function I2(n: integer): string;
  var s: string;
  begin
    str(n, s);
    if length(s) = 1 then s := '0' + s;
    I2 := s;
  end;

  { Entero a string de 3 dígitos con ceros a la izquierda }
  function I3(n: integer): string;
  var s: string;
  begin
    str(n, s);
    while length(s) < 3 do s := '0' + s;
    I3 := s;
  end;

  { Formatea DNI como XX.XXX.XXX }
  function FormatDNI(d: longint): string;
  var mill, miles, resto: longint; s: string;
  begin
    mill  := d div 1000000;
    miles := (d mod 1000000) div 1000;
    resto :=  d mod 1000;
    str(mill, s);
    FormatDNI := s + '.' + I3(miles) + '.' + I3(resto);
  end;

  { Nombre del mes en español }
  function NombreMes(m: integer): string;
  var nom: string;
  begin
    case m of
      1 : nom := 'enero';
      2 : nom := 'febrero';
      3 : nom := 'marzo';
      4 : nom := 'abril';
      5 : nom := 'mayo';
      6 : nom := 'junio';
      7 : nom := 'julio';
      8 : nom := 'agosto';
      9 : nom := 'septiembre';
      10: nom := 'octubre';
      11: nom := 'noviembre';
      12: nom := 'diciembre';
    else
      nom := '?';
    end;
    NombreMes := nom;
  end;

  { Fecha como DD/MM/AAAA }
  function FechaCorta(f: TFecha): string;
  var sA: string;
  begin
    str(f.anio, sA);
    FechaCorta := I2(f.dia) + '/' + I2(f.mes) + '/' + sA;
  end;

  { Fecha como "30 de junio de 2024" }
  function FechaLarga(f: TFecha): string;
  var sA, sD: string;
  begin
    str(f.anio, sA);
    str(f.dia,  sD);
    FechaLarga := sD + ' de ' + NombreMes(f.mes) + ' de ' + sA;
  end;

  { ══════════════════════════════════════════════ }
  {   Procedimientos de dibujo de la caja          }
  { ══════════════════════════════════════════════ }

  { Línea superior de la caja doble: ╔══...══╗ }
  procedure BT;
  begin
    writeln(#201, RepStr(#205, 78), #187);
  end;

  { Línea inferior de la caja doble: ╚══...══╝ }
  procedure BB;
  begin
    writeln(#200, RepStr(#205, 78), #188);
  end;

  { Línea divisora horizontal: ╠══...══╣ }
  procedure BH;
  begin
    writeln(#204, RepStr(#205, 78), #185);
  end;

  { Línea vacía dentro de la caja: ║            ║ }
  procedure BE;
  begin
    writeln(#186, RepStr(' ', 78), #186);
  end;

  { Línea de contenido dentro de la caja de 80 cols.   }
  {   s debe tener exactamente 78 chars (se rellena).  }
  procedure BL(s: string);
  begin
    if length(s) > 78 then s := copy(s, 1, 78);
    while length(s) < 78 do s := s + ' ';
    writeln(#186, s, #186);
  end;

  { ── Caja interna de línea simple (capacitación) ── }

  { Tapa superior: ║  ┌──72──┐  ║ }
  procedure IT;
  begin
    writeln(#186, '  ', #218, RepStr(#196, 72), #191, '  ', #186);
  end;

  { Tapa inferior: ║  └──72──┘  ║ }
  procedure IB;
  begin
    writeln(#186, '  ', #192, RepStr(#196, 72), #217, '  ', #186);
  end;

  { Línea de contenido: ║  │ s(70) │  ║ }
  procedure IL(s: string);
  begin
    if length(s) > 70 then s := copy(s, 1, 70);
    while length(s) < 70 do s := s + ' ';
    writeln(#186, '  ', #179, ' ', s, ' ', #179, '  ', #186);
  end;

{ ══════════════════════════════════════════════════ }
{              CUERPO PRINCIPAL                       }
{ ══════════════════════════════════════════════════ }

begin
  clrscr;
  writeln('=============================================');
  writeln('           GENERAR CERTIFICADO               ');
  writeln('=============================================');
  codCap := LeerEntero          ('Ingrese código de capacitación: ');
  dni    := LeerLongintRango    ('Ingrese DNI del alumno        : ', 10000000, 99999999);

  posCap := BuscarCapacitacionPorCodigo(archCap, codCap);
  posAlu := BuscarAlumnoPorDNI(archAlu, codCap, dni);

  if (posCap <> -1) and (posAlu <> -1) then
  begin
    LeerCapacitacion(archCap, posCap, cap);
    LeerAlumno(archAlu, posAlu, alu);
    clrscr;

    { ── Textos auxiliares ── }
    case cap.tipo of
      curso    : sTipo := 'Curso';
      taller   : sTipo := 'Taller';
      seminario: sTipo := 'Seminario';
    end;

    case cap.area of
      ISI    : sArea := 'ISI';
      LOI    : sArea := 'LOI';
      Civil  : sArea := 'Civil';
      Electro: sArea := 'Electro';
      General: sArea := 'General';
    end;

    str(cap.horas, sHoras);

    if alu.esDocenteUTN then
      sDocUTN := 'S' + #237   { í - evita problemas de codificación }
    else
      sDocUTN := 'No';

    if alu.condicion = Aprobado then
    begin
      sCondicion   := 'APROBADO';
      sCentroTipo  := Centro(#16 + #16 + #16 + '  CONDICIÓN: APROBADO  ' + #17 + #17 + #17);
    end
    else
    begin
      sCondicion   := 'ASISTENCIA';
      sCentroTipo  := Centro(#16 + #16 + #16 + '  CONDICIÓN: ASISTENCIA  ' + #17 + #17 + #17);
    end;

    { ─────────────────────────────────────────── }
    {              ENCABEZADO                     }
    { ─────────────────────────────────────────── }
    BT;
    BE;
    BL(Centro(#15 + '  UNIVERSIDAD TECNOLÓGICA NACIONAL  ' + #15));
    BL(Centro('FACULTAD REGIONAL CONCEPCIÓN DEL URUGUAY'));
    BL(Centro('Secretaría de Extensión Universitaria'));
    BE;
    BH;
    BE;
    BL(Centro(#4 + '  C  E  R  T  I  F  I  C  A  D  O  ' + #4));
    BE;
    BH;

    { ─────────────────────────────────────────── }
    {              DATOS DEL ALUMNO               }
    { ─────────────────────────────────────────── }
    BE;
    BL('  La Secretaría de Extensión Universitaria de la FRCU - UTN,');
    BL('  certifica que el/la siguiente alumno/a:');
    BE;

    sLinea := '   ' + #16 + ' Apellido y Nombre :  ' + alu.apenom;
    BL(sLinea);

    sLinea := '   ' + #16 + ' DNI               :  ' + FormatDNI(alu.dni);
    BL(sLinea);

    sLinea := '   ' + #16 + ' Docente UTN       :  ' + sDocUTN;
    BL(sLinea);

    BE;
    BL('  Ha completado la siguiente actividad de extensión universitaria:');
    BE;

    { ─────────────────────────────────────────── }
    {          CAJA INTERNA - CAPACITACIÓN        }
    { ─────────────────────────────────────────── }
    IT;

    IL('  Nombre   : ' + cap.nombre);

    { Tipo + Área en la misma línea }
    sLinea := '  Tipo     : ' + sTipo;
    while length(sLinea) < 35 do sLinea := sLinea + ' ';
    sLinea := sLinea + 'Área : ' + sArea;
    IL(sLinea);

    IL('  Duración : ' + sHoras + ' horas');
    IL('  Período  : ' + FechaCorta(cap.fechaInicio) + '   al   ' + FechaCorta(cap.fechaFin));

    { Docentes truncados a 57 chars para que quepan en IL }
    sLinea := cap.docentes;
    if length(sLinea) > 57 then sLinea := copy(sLinea, 1, 57);
    IL('  Docentes : ' + sLinea);

    IB;

    { ─────────────────────────────────────────── }
    {              CONDICIÓN / FIRMA              }
    { ─────────────────────────────────────────── }
    BE;
    BL(sCentroTipo);
    BE;

    sLinea := '  Concepción del Uruguay, ' + FechaLarga(cap.fechaFin) + '.';
    BL(sLinea);

    BE;
    BH;
    BE;

    BL(Centro('_________________________________________________'));
    BE;
    BL(Centro('Secretaría de Extensión Universitaria'));
    BL(Centro('Facultad Regional Concepción del Uruguay'));
    BL(Centro('Universidad Tecnológica Nacional'));
    BE;
    BB;

  end
  else
  begin
    writeln;
    writeln('  [!] No se encontró el alumno o la capacitación con esos datos.');
  end;

  writeln;
  writeln('Presione ENTER para continuar...');
  readln;
end;

end.