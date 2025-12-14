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
  crt, U_Tipos, U_Archivos;

{------------------------------------------------------}
{ Procedimientos públicos                              }
{------------------------------------------------------}

procedure MenuEstadisticas(var archCap: TArchivoCapacitaciones);

implementation

{------------------------------------------------------}
{ Procedimientos internos                              }
{------------------------------------------------------}

procedure DistribucionPorTipo(var archCap: TArchivoCapacitaciones);
procedure PorcentajePorArea(var archCap: TArchivoCapacitaciones);
procedure PromedioHorasPorTipo(var archCap: TArchivoCapacitaciones);
function FechaEnRango(f, desde, hasta: TFecha): boolean;
function CompararFechas(f1, f2: TFecha): integer;

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
    write('Opción: ');
    readln(opcion);

    case opcion of
      1: DistribucionPorTipo(archCap);
      2: PorcentajePorArea(archCap);
      3: PromedioHorasPorTipo(archCap);
    end;
  until opcion = 4;
end;

{------------------------------------------------------}
{ 2. Función auxiliar: comparación de fechas            }
{------------------------------------------------------}

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
  desdeOk := (CompararFechas(f, desde) >= 0);
  hastaOk := (CompararFechas(f, hasta) <= 0);
  FechaEnRango := desdeOk and hastaOk;
end;

{------------------------------------------------------}
{ 3. Distribución por tipo entre dos fechas             }
{------------------------------------------------------}

procedure DistribucionPorTipo(var archCap: TArchivoCapacitaciones);
var
  reg: TCapacitacion;
  desde, hasta: TFecha;
  pos: longint;
  cantCurso, cantTaller, cantSem: integer;
begin
  clrscr;
  writeln('=============================================');
  writeln(' DISTRIBUCIÓN POR TIPO ENTRE DOS FECHAS');
  writeln('=============================================');
  write('Ingrese fecha DESDE (dd mm aaaa): ');
  readln(desde.dia, desde.mes, desde.anio);
  write('Ingrese fecha HASTA (dd mm aaaa): ');
  readln(hasta.dia, hasta.mes, hasta.anio);

  cantCurso := 0;
  cantTaller := 0;
  cantSem := 0;

  seek(archCap, 0);
  pos := 0;
  while pos < filesize(archCap) do
  begin
    read(archCap, reg);
    if (reg.estado = activo) and FechaEnRango(reg.fechaInicio, desde, hasta) then
    begin
      case reg.tipo of
        curso: cantCurso := cantCurso + 1;
        taller: cantTaller := cantTaller + 1;
        seminario: cantSem := cantSem + 1;
      end;
    end;
    pos := pos + 1;
  end;

  writeln;
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
{ 4. Porcentaje de capacitaciones por área              }
{------------------------------------------------------}

procedure PorcentajePorArea(var archCap: TArchivoCapacitaciones);
var
  reg: TCapacitacion;
  pos: longint;
  contArea: array[TAreaCapacitacion] of integer;
  total, i: integer;
  area: TAreaCapacitacion;
  nombres: array[TAreaCapacitacion] of string = ('ISI', 'LOI', 'Civil', 'Electro', 'General');
begin
  clrscr;
  writeln('=============================================');
  writeln(' PORCENTAJE DE CAPACITACIONES POR ÁREA');
  writeln('=============================================');

  { Inicializar contadores }
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
      writeln(nombres[area]:12, contArea[area]:10, (contArea[area] * 100.0 / total):12:2, ' %');
  end
  else
    writeln('No hay capacitaciones activas.');
  writeln;
  writeln('Presione ENTER para continuar...');
  readln;
end;

{------------------------------------------------------}
{ 5. Estadística adicional: Promedio de horas por tipo  }
{------------------------------------------------------}

procedure PromedioHorasPorTipo(var archCap: TArchivoCapacitaciones);
var
  reg: TCapacitacion;
  pos: longint;
  sumCurso, sumTaller, sumSem: longint;
  cantCurso, cantTaller, cantSem: integer;
  promCurso, promTaller, promSem: real;
begin
  clrscr;
  writeln('=============================================');
  writeln(' PROMEDIO DE HORAS POR TIPO DE CAPACITACIÓN');
  writeln('=============================================');

  sumCurso := 0; sumTaller := 0; sumSem := 0;
  cantCurso := 0; cantTaller := 0; cantSem := 0;

  seek(archCap, 0);
  pos := 0;
  while pos < filesize(archCap) do
  begin
    read(archCap, reg);
    if reg.estado = activo then
    begin
      case reg.tipo of
        curso: begin sumCurso := sumCurso + reg.horas; cantCurso := cantCurso + 1; end;
        taller: begin sumTaller := sumTaller + reg.horas; cantTaller := cantTaller + 1; end;
        seminario: begin sumSem := sumSem + reg.horas; cantSem := cantSem + 1; end;
      end;
    end;
    pos := pos + 1;
  end;

  if cantCurso > 0 then promCurso := sumCurso / cantCurso else promCurso := 0;
  if cantTaller > 0 then promTaller := sumTaller / cantTaller else promTaller := 0;
  if cantSem > 0 then promSem := sumSem / cantSem else promSem := 0;

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
