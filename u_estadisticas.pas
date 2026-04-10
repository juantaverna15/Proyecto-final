unit U_Estadisticas;

{******************************************************
  Unidad: U_Estadisticas
  Sistema: Gestión de Capacitaciones FRCU
  Propósito:
    - Calcular y mostrar estadísticas generales
      del sistema de capacitaciones.
  Restricciones:
    - Programación estructurada.
    - Sin break, exit ni goto.
*******************************************************}

interface

uses
  crt, U_Tipos, U_Archivos, U_Utils;

{------------------------------------------------------}
{ Procedimientos públicos                              }
{------------------------------------------------------}

procedure MenuEstadisticas(var archCap: TArchivoCapacitaciones);

implementation

{------------------------------------------------------}
{ Declaración de procedimientos internos (con forward) }
{------------------------------------------------------}

procedure DistribucionPorTipo(var archCap: TArchivoCapacitaciones); forward;
procedure PorcentajePorArea(var archCap: TArchivoCapacitaciones); forward;
procedure PromedioHorasPorTipo(var archCap: TArchivoCapacitaciones); forward;


{======================================================}
{   BLOQUE DE VALIDACIÓN DE FECHAS (uso interno)       }
{======================================================}

{------------------------------------------------------}
{ V-1. Año bisiesto                                    }
{------------------------------------------------------}
function EsBisiesto(anio: integer): boolean;
begin
  EsBisiesto := ((anio mod 4 = 0) and (anio mod 100 <> 0))
                or (anio mod 400 = 0);
end;

{------------------------------------------------------}
{ V-2. Días reales según mes y año                     }
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
{ V-3. Fecha calendario real                           }
{------------------------------------------------------}
function FechaValida(f: TFecha): boolean;
begin
  FechaValida := (f.anio > 0)
             and (f.mes  >= 1) and (f.mes  <= 12)
             and (f.dia  >= 1) and (f.dia  <= DiasEnMes(f.mes, f.anio));
end;


{======================================================}
{   COMPARACIÓN Y RANGO DE FECHAS                      }
{   (deben ir ANTES de LeerFechaHasta que las usa)     }
{======================================================}

function CompararFechas(f1, f2: TFecha): integer;
begin
  if f1.anio < f2.anio then
    CompararFechas := -1
  else if f1.anio > f2.anio then
    CompararFechas := 1
  else if f1.mes < f2.mes then
    CompararFechas := -1
  else if f1.mes > f2.mes then
    CompararFechas := 1
  else if f1.dia < f2.dia then
    CompararFechas := -1
  else if f1.dia > f2.dia then
    CompararFechas := 1
  else
    CompararFechas := 0;
end;

function FechaEnRango(f, desde, hasta: TFecha): boolean;
var
  desdeOk, hastaOk: boolean;
begin
  desdeOk      := (CompararFechas(f, desde) >= 0);
  hastaOk      := (CompararFechas(f, hasta) <= 0);
  FechaEnRango := desdeOk and hastaOk;
end;


{======================================================}
{   BLOQUE DE INGRESO VALIDADO DE FECHAS               }
{======================================================}

{------------------------------------------------------}
{ E-1. Ingresa la fecha DESDE                          }
{   - Debe ser una fecha calendario real.              }
{   - Contempla año bisiesto.                          }
{   - Pide de nuevo si la fecha es inválida.           }
{------------------------------------------------------}
procedure LeerFechaDesde(var f: TFecha);
var
  valido: boolean;
begin
  repeat
    writeln('  Fecha DESDE:');
    write  ('    Día  (1-31) : '); readln(f.dia);
    write  ('    Mes  (1-12) : '); readln(f.mes);
    write  ('    Año         : '); readln(f.anio);
    valido := FechaValida(f);
    if not valido then
    begin
      writeln;
      writeln('  [!] Fecha DESDE inválida. Verifique:');
      writeln('      - El mes debe estar entre 1 y 12.');
      writeln('      - El día debe ser válido para ese mes y año.');
      if (f.mes = 2) and (f.dia = 29) and not EsBisiesto(f.anio) then
        writeln('      - El año ', f.anio,
                ' no es bisiesto: febrero solo tiene 28 días.');
      writeln;
    end;
  until valido;
end;

{------------------------------------------------------}
{ E-2. Ingresa la fecha HASTA                          }
{   - Debe ser una fecha calendario real.              }
{   - Debe ser mayor o igual a la fecha DESDE.         }
{   - Pide de nuevo si la fecha es inválida o          }
{     anterior a DESDE.                                }
{------------------------------------------------------}
procedure LeerFechaHasta(var f: TFecha; desde: TFecha);
var
  esReal    : boolean;
  esMayorIg : boolean;
  valido    : boolean;
begin
  repeat
    writeln('  Fecha HASTA:');
    write  ('    Día  (1-31) : '); readln(f.dia);
    write  ('    Mes  (1-12) : '); readln(f.mes);
    write  ('    Año         : '); readln(f.anio);

    esReal := FechaValida(f);

    { Compara usando la misma función ya existente en el archivo }
    esMayorIg := esReal and (CompararFechas(f, desde) >= 0);

    valido := esReal and esMayorIg;

    if not esReal then
    begin
      writeln;
      writeln('  [!] Fecha HASTA inválida. Verifique:');
      writeln('      - El mes debe estar entre 1 y 12.');
      writeln('      - El día debe ser válido para ese mes y año.');
      if (f.mes = 2) and (f.dia = 29) and not EsBisiesto(f.anio) then
        writeln('      - El año ', f.anio,
                ' no es bisiesto: febrero solo tiene 28 días.');
      writeln;
    end
    else if not esMayorIg then
    begin
      writeln;
      writeln('  [!] La fecha HASTA debe ser igual o posterior a la fecha DESDE.');
      writeln('      DESDE ingresado : ',
              desde.dia, '/', desde.mes, '/', desde.anio);
      writeln('      HASTA ingresado : ',
              f.dia, '/', f.mes, '/', f.anio);
      writeln;
    end;
  until valido;
end;


{======================================================}
{         PROCEDIMIENTOS PRINCIPALES                   }
{======================================================}

{------------------------------------------------------}
{ 1. Menú de estadísticas                              }
{------------------------------------------------------}

procedure MenuEstadisticas(var archCap: TArchivoCapacitaciones);
var
  opcion: integer;
begin
  repeat
    clrscr;
    writeln('=============================================');
    writeln('             MENÚ DE ESTADÍSTICAS            ');
    writeln('=============================================');
    writeln('1) Distribución de capacitaciones por tipo (entre dos fechas)');
    writeln('2) Porcentaje por área / departamento');
    writeln('3) Promedio de horas por tipo de capacitación');
    writeln('4) Volver');
    writeln('---------------------------------------------');
    opcion := LeerEnteroRango('Opción: ', 1, 4);

    case opcion of
      1: DistribucionPorTipo(archCap);
      2: PorcentajePorArea(archCap);
      3: PromedioHorasPorTipo(archCap);
    end;
  until opcion = 4;
end;


{------------------------------------------------------}
{ 3. Distribución por tipo entre dos fechas            }
{   VALIDACIONES:                                      }
{   - Fecha DESDE: debe ser una fecha real (bisiesto)  }
{   - Fecha HASTA: fecha real + >= que fecha DESDE     }
{------------------------------------------------------}

procedure DistribucionPorTipo(var archCap: TArchivoCapacitaciones);
var
  reg                        : TCapacitacion;
  desde, hasta               : TFecha;
  pos                        : longint;
  cantCurso, cantTaller, cantSem: integer;
begin
  clrscr;
  writeln('=============================================');
  writeln(' DISTRIBUCIÓN POR TIPO ENTRE DOS FECHAS      ');
  writeln('=============================================');
  writeln;

  { E-1: Fecha DESDE — fecha real con año bisiesto }
  LeerFechaDesde(desde);

  writeln;

  { E-2: Fecha HASTA — fecha real + mayor o igual a DESDE }
  LeerFechaHasta(hasta, desde);

  writeln;
  writeln('  Buscando entre: ',
          desde.dia, '/', desde.mes, '/', desde.anio,
          '  y  ',
          hasta.dia, '/', hasta.mes, '/', hasta.anio, ' ...');
  writeln;

  cantCurso  := 0;
  cantTaller := 0;
  cantSem    := 0;

  seek(archCap, 0);
  pos := 0;
  while pos < filesize(archCap) do
  begin
    read(archCap, reg);
    if (reg.estado = activo) and FechaEnRango(reg.fechaInicio, desde, hasta) then
    begin
      case reg.tipo of
        curso    : cantCurso  := cantCurso  + 1;
        taller   : cantTaller := cantTaller + 1;
        seminario: cantSem    := cantSem    + 1;
      end;
    end;
    pos := pos + 1;
  end;

  writeln('Cursos:     ', cantCurso);
  writeln('Talleres:   ', cantTaller);
  writeln('Seminarios: ', cantSem);
  writeln('---------------------------------------------');
  writeln('Total: ', cantCurso + cantTaller + cantSem);
  writeln;
  writeln('Presione ENTER para continuar...');
  readln;
end;


{------------------------------------------------------}
{ 4. Porcentaje de capacitaciones por área             }
{------------------------------------------------------}

procedure PorcentajePorArea(var archCap: TArchivoCapacitaciones);
var
  reg     : TCapacitacion;
  pos     : longint;
  contArea: array[TAreaCapacitacion] of integer;
  total   : integer;
  area    : TAreaCapacitacion;
  nombres : array[TAreaCapacitacion] of string = ('ISI', 'LOI', 'Civil', 'Electro', 'General');
begin
  clrscr;
  writeln('=============================================');
  writeln(' PORCENTAJE DE CAPACITACIONES POR ÁREA');
  writeln('=============================================');

  for area := ISI to General do
    contArea[area] := 0;

  total := 0;
  seek(archCap, 0);
  pos := 0;
  while pos < filesize(archCap) do
  begin
    read(archCap, reg);
    if reg.estado = activo then
    begin
      contArea[reg.area] := contArea[reg.area] + 1;
      total := total + 1;
    end;
    pos := pos + 1;
  end;

  writeln;
  writeln('Área           Cantidad     Porcentaje');
  writeln('---------------------------------------------');
  if total > 0 then
  begin
    for area := ISI to General do
      writeln(nombres[area]:12, contArea[area]:10,
              (contArea[area] * 100.0 / total):12:2, ' %');
  end
  else
    writeln('No hay capacitaciones activas.');

  writeln;
  writeln('Presione ENTER para continuar...');
  readln;
end;


{------------------------------------------------------}
{ 5. Promedio de horas por tipo de capacitación        }
{------------------------------------------------------}

procedure PromedioHorasPorTipo(var archCap: TArchivoCapacitaciones);
var
  reg                              : TCapacitacion;
  pos                              : longint;
  sumCurso, sumTaller, sumSem      : longint;
  cantCurso, cantTaller, cantSem   : integer;
  promCurso, promTaller, promSem   : real;
begin
  clrscr;
  writeln('=============================================');
  writeln(' PROMEDIO DE HORAS POR TIPO DE CAPACITACIÓN');
  writeln('=============================================');

  sumCurso  := 0; sumTaller  := 0; sumSem  := 0;
  cantCurso := 0; cantTaller := 0; cantSem := 0;

  seek(archCap, 0);
  pos := 0;
  while pos < filesize(archCap) do
  begin
    read(archCap, reg);
    if reg.estado = activo then
    begin
      case reg.tipo of
        curso    : begin sumCurso  := sumCurso  + reg.horas; cantCurso  := cantCurso  + 1; end;
        taller   : begin sumTaller := sumTaller + reg.horas; cantTaller := cantTaller + 1; end;
        seminario: begin sumSem    := sumSem    + reg.horas; cantSem    := cantSem    + 1; end;
      end;
    end;
    pos := pos + 1;
  end;

  if cantCurso  > 0 then promCurso  := sumCurso  / cantCurso  else promCurso  := 0;
  if cantTaller > 0 then promTaller := sumTaller / cantTaller else promTaller := 0;
  if cantSem    > 0 then promSem    := sumSem    / cantSem    else promSem    := 0;

  writeln;
  writeln('Tipo         Promedio de horas');
  writeln('---------------------------------------------');
  writeln('Curso       ', promCurso:10:2);
  writeln('Taller      ', promTaller:10:2);
  writeln('Seminario   ', promSem:10:2);
  writeln;
  writeln('Presione ENTER para continuar...');
  readln;
end;

end.