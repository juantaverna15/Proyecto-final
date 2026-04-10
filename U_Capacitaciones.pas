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
    - Todas las entradas de usuario son validadas antes
      de ser aceptadas.
*******************************************************}

interface

uses
  crt, U_Tipos, U_Archivos, U_Arboles, U_Utils;

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

{======================================================}
{         BLOQUE DE FUNCIONES DE VALIDACIÓN            }
{======================================================}

{------------------------------------------------------}
{ V-1. Verifica si un año es bisiesto                  }
{   Regla: divisible por 4, excepto centenarios que    }
{   no sean divisibles por 400.                        }
{------------------------------------------------------}
function EsBisiesto(anio: integer): boolean;
begin
  EsBisiesto := ((anio mod 4 = 0) and (anio mod 100 <> 0))
                or (anio mod 400 = 0);
end;

{------------------------------------------------------}
{ V-2. Devuelve la cantidad de días del mes dado       }
{   Tiene en cuenta febrero en años bisiestos.         }
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
    dias := 0;   { Mes fuera de rango -> 0 días fuerza inválido }
  end;
  DiasEnMes := dias;
end;

{------------------------------------------------------}
{ V-3. Valida si un registro TFecha es una fecha real  }
{------------------------------------------------------}
function FechaValida(f: TFecha): boolean;
begin
  FechaValida := (f.anio > 0)
             and (f.mes  >= 1) and (f.mes  <= 12)
             and (f.dia  >= 1) and (f.dia  <= DiasEnMes(f.mes, f.anio));
end;

{------------------------------------------------------}
{ V-4. Compara dos fechas: devuelve TRUE si f1 > f2   }
{------------------------------------------------------}
function FechaMayor(f1, f2: TFecha): boolean;
var
  resultado: boolean;
begin
  if f1.anio <> f2.anio then
    resultado := f1.anio > f2.anio
  else if f1.mes <> f2.mes then
    resultado := f1.mes > f2.mes
  else
    resultado := f1.dia > f2.dia;
  FechaMayor := resultado;
end;

{------------------------------------------------------}
{ V-5. Verifica que TODOS los caracteres de s sean     }
{   dígitos (0..9) y que s no esté vacío.              }
{   Usado para validar código y horas como texto.      }
{------------------------------------------------------}
function EsSoloDigitos(s: string): boolean;
var
  i   : integer;
  ok  : boolean;
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

{======================================================}
{         BLOQUE DE FUNCIONES DE INGRESO VALIDADO      }
{======================================================}

{------------------------------------------------------}
{ E-1. Ingresa el CÓDIGO de capacitación               }
{   - Solo acepta dígitos (rechaza letras y símbolos). }
{   - Pide de nuevo si el ingreso no es válido.        }
{   - Retorna 0 si el usuario quiere volver.           }
{------------------------------------------------------}
function LeerCodigoValido: integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    writeln;
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
      writeln('  [!] Entrada inválida: no se permiten letras ni símbolos.');
      writeln('      Ingrese únicamente dígitos numéricos.');
    end;
  until valido;
  LeerCodigoValido := valor;
end;

{------------------------------------------------------}
{ E-2. Ingresa la FECHA DE INICIO                      }
{   - Valida que sea una fecha calendario real.         }
{   - Contempla meses con 28/29/30/31 días.            }
{   - Incluye validación de año bisiesto (Feb 29).     }
{------------------------------------------------------}
procedure LeerFechaInicio(var f: TFecha);
var
  valido: boolean;
begin
  repeat
    writeln;
    writeln('  Fecha de inicio:');
    f.dia  := LeerEnteroRango('    Día  (1-31) : ', 1, 31);
    f.mes  := LeerEnteroRango('    Mes  (1-12) : ', 1, 12);
    f.anio := LeerEntero     ('    Año         : ');
    valido := FechaValida(f);
    if not valido then
    begin
      writeln;
      writeln('  [!] Fecha inválida. Verifique:');
      writeln('      - El mes debe estar entre 1 y 12.');
      writeln('      - El día debe ser válido para ese mes.');
      if (f.mes = 2) and (f.dia = 29) and not EsBisiesto(f.anio) then
        writeln('      - El año ', f.anio, ' no es bisiesto: febrero tiene solo 28 días.');
    end;
  until valido;
end;

{------------------------------------------------------}
{ E-3. Ingresa la FECHA DE FIN                         }
{   - Valida que sea una fecha real (igual que inicio)  }
{   - Valida que sea MAYOR que la fecha de inicio.     }
{------------------------------------------------------}
procedure LeerFechaFin(var fFin: TFecha; fInicio: TFecha);
var
  esReal  : boolean;
  esMayor : boolean;
  valido  : boolean;
begin
  repeat
    writeln;
    writeln('  Fecha de fin:');
    fFin.dia  := LeerEnteroRango('    Día  (1-31) : ', 1, 31);
    fFin.mes  := LeerEnteroRango('    Mes  (1-12) : ', 1, 12);
    fFin.anio := LeerEntero     ('    Año         : ');

    esReal  := FechaValida(fFin);
    esMayor := esReal and FechaMayor(fFin, fInicio);
    valido  := esReal and esMayor;

    if not esReal then
    begin
      writeln;
      writeln('  [!] Fecha inválida. Verifique día, mes y año.');
      if (fFin.mes = 2) and (fFin.dia = 29) and not EsBisiesto(fFin.anio) then
        writeln('      - El año ', fFin.anio, ' no es bisiesto: febrero tiene solo 28 días.');
    end
    else if not esMayor then
    begin
      writeln;
      writeln('  [!] La fecha de fin debe ser MAYOR que la fecha de inicio:');
      writeln('      Inicio: ', fInicio.dia, '/', fInicio.mes, '/', fInicio.anio);
      writeln('      Fin ingresado: ', fFin.dia, '/', fFin.mes, '/', fFin.anio);
    end;
  until valido;
end;

{------------------------------------------------------}
{ E-4. Ingresa el TIPO de capacitación (1-3)           }
{   - Acepta solo 1, 2 ó 3.                            }
{   - Solicita de nuevo mientras el valor sea inválido.}
{------------------------------------------------------}
function LeerTipoValido: integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    writeln;
    writeln('  Tipo de capacitación:');
    writeln('    1) Curso');
    writeln('    2) Taller');
    writeln('    3) Seminario');
    write  ('  Seleccione tipo (1-3): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor >= 1) and (valor <= 3);
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] Opción inválida. Ingrese 1, 2 ó 3.');
    end;
  until valido;
  LeerTipoValido := valor;
end;

{------------------------------------------------------}
{ E-5. Ingresa la CANTIDAD DE HORAS                    }
{   - Solo se aceptan caracteres numéricos.            }
{   - El valor debe ser MAYOR QUE 3 (mínimo 4 horas). }
{------------------------------------------------------}
function LeerHorasValidas: integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    write('  Cantidad de horas (número entero, mayor que 3): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor > 3);
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] Inválido. Solo se aceptan números enteros mayores que 3.');
      writeln('      Letras y símbolos no están permitidos.');
    end;
  until valido;
  LeerHorasValidas := valor;
end;

{------------------------------------------------------}
{ E-6. Ingresa la CANTIDAD DE DOCENTES                 }
{   - Valor mayor que 0 (no nulo) y menor que 10.      }
{   - Rango aceptado: 1 a 9.                           }
{------------------------------------------------------}
function LeerCantDocentesValida: integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    write('  Cantidad de docentes (entre 1 y 9): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor > 0) and (valor < 10);
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] Inválido. La cantidad de docentes debe ser un número entre 1 y 9.');
    end;
  until valido;
  LeerCantDocentesValida := valor;
end;

{------------------------------------------------------}
{ E-7. Ingresa el ÁREA de la capacitación (1-5)        }
{   - Acepta solo valores entre 1 y 5.                 }
{------------------------------------------------------}
function LeerAreaValida: integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    writeln;
    writeln('  Área responsable:');
    writeln('    1) ISI');
    writeln('    2) LOI');
    writeln('    3) Civil');
    writeln('    4) Electro');
    writeln('    5) General');
    write  ('  Seleccione área (1-5): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor >= 1) and (valor <= 5);
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] Opción inválida. Ingrese un número entre 1 y 5.');
    end;
  until valido;
  LeerAreaValida := valor;
end;


{======================================================}
{         PROCEDIMIENTOS PRINCIPALES DEL MENÚ          }
{======================================================}

{------------------------------------------------------}
{ 1. Menú principal de capacitaciones                  }
{------------------------------------------------------}

procedure MenuCapacitaciones(var arch: TArchivoCapacitaciones;
                             var arbolCod: PNodoCodigo;
                             var arbolNom: PNodoNombre);
var
  codigo : integer;
  pos    : longint;
  opcion : integer;
  reg    : TCapacitacion;
begin
  repeat
    clrscr;
    writeln('=============================================');
    writeln('      GESTIÓN DE CAPACITACIONES - FRCU       ');
    writeln('=============================================');
    writeln('  Ingrese 0 como código para volver al menú anterior.');

    { E-1: Lectura del código con validación de caracteres }
    codigo := LeerCodigoValido;

    if codigo <> 0 then
    begin
      pos := BuscarPorCodigo(arbolCod, codigo);

      if pos = -1 then
      begin
        writeln;
        writeln('  No existe una capacitación con el código ', codigo, '.');
        write  ('  ¿Desea darla de alta? (1=Sí / 2=No): ');
        opcion := LeerEnteroRango('', 1, 2);
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
{ 2. Alta de nueva capacitación (con validaciones)     }
{------------------------------------------------------}

procedure AltaCapacitacion(var arch: TArchivoCapacitaciones;
                           var arbolCod: PNodoCodigo;
                           var arbolNom: PNodoNombre;
                           codigo: integer);
var
  reg       : TCapacitacion;
  pos       : longint;
  tipoNum   : integer;
  areaNum   : integer;
  cantDoc   : integer;
begin
  clrscr;
  writeln('=============================================');
  writeln('           ALTA DE CAPACITACIÓN              ');
  writeln('=============================================');
  writeln('  Código asignado: ', codigo);
  writeln;

  reg.codigo := codigo;

  { --- Nombre --- }
  write('Nombre de la capacitación: ');
  readln(reg.nombre);

  { --- E-2: Fecha de inicio (validación de fecha real + año bisiesto) --- }
  LeerFechaInicio(reg.fechaInicio);

  { --- E-3: Fecha de fin (fecha real + mayor que inicio) --- }
  LeerFechaFin(reg.fechaFin, reg.fechaInicio);

  { --- E-4: Tipo (1=Curso, 2=Taller, 3=Seminario) --- }
  tipoNum := LeerTipoValido;
  case tipoNum of
    1: reg.tipo := curso;
    2: reg.tipo := taller;
    3: reg.tipo := seminario;
  end;

  { --- E-5: Cantidad de horas (solo números, mayor que 3) --- }
  writeln;
  reg.horas := LeerHorasValidas;

  { --- E-6: Cantidad de docentes (no nulo, menor que 10) --- }
  writeln;
  cantDoc := LeerCantDocentesValida;
  { Se registra la cantidad y luego se piden los nombres }
  writeln('  Ingrese el nombre de los ', cantDoc, ' docente(s):');
  write  ('  Nombres: ');
  readln(reg.docentes);

  reg.cantAlumnos := 0;

  { --- E-7: Área (1 a 5) --- }
  areaNum := LeerAreaValida;
  case areaNum of
    1: reg.area := ISI;
    2: reg.area := LOI;
    3: reg.area := Civil;
    4: reg.area := Electro;
    5: reg.area := General;
  end;

  reg.estado := activo;

  { --- Grabar en archivo y árboles --- }
  GrabarCapacitacion(arch, reg);
  pos := filesize(arch) - 1;
  InsertarCodigo(arbolCod, reg.codigo, pos);
  InsertarNombre(arbolNom, reg.nombre, pos);

  writeln;
  writeln('=============================================');
  writeln('  Capacitación creada correctamente.');
  writeln('=============================================');
  writeln('Presione ENTER para continuar...');
  readln;
end;


{------------------------------------------------------}
{ 3. Consulta y submenú de una capacitación            }
{------------------------------------------------------}

procedure ConsultarCapacitacion(var arch: TArchivoCapacitaciones;
                                var arbolCod: PNodoCodigo;
                                var arbolNom: PNodoNombre;
                                pos: longint);
var
  reg    : TCapacitacion;
  opcion : integer;
begin
  repeat
    clrscr;
    LeerCapacitacion(arch, pos, reg);
    writeln('=============================================');
    writeln('         CONSULTA DE CAPACITACIÓN            ');
    writeln('=============================================');
    MostrarCapacitacion(reg);
    writeln;
    writeln('  1) Modificar');
    writeln('  2) Dar de baja');
    writeln('  3) Volver');
    opcion := LeerEnteroRango('Seleccione opción: ', 1, 3);

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
  reg    : TCapacitacion;
  opcion : integer;
  tipoNum: integer;
begin
  LeerCapacitacion(arch, pos, reg);
  repeat
    clrscr;
    writeln('=============================================');
    writeln('         MODIFICAR CAPACITACIÓN              ');
    writeln('=============================================');
    MostrarCapacitacion(reg);
    writeln;
    writeln('  1) Modificar nombre');
    writeln('  2) Modificar docentes');
    writeln('  3) Modificar fechas');
    writeln('  4) Modificar tipo');
    writeln('  5) Volver');
    opcion := LeerEnteroRango('Opción: ', 1, 5);

    case opcion of
      1: begin
           write('Nuevo nombre: ');
           readln(reg.nombre);
         end;
      2: begin
           write('Nuevos docentes: ');
           readln(reg.docentes);
         end;
      3: begin
           { Reutiliza los validadores de fecha }
           LeerFechaInicio(reg.fechaInicio);
           LeerFechaFin(reg.fechaFin, reg.fechaInicio);
         end;
      4: begin
           tipoNum := LeerTipoValido;
           case tipoNum of
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
  TipoTexto  : array[TTipoCapacitacion] of string  = ('Curso', 'Taller', 'Seminario');
  AreaTexto  : array[TAreaCapacitacion] of string   = ('ISI', 'LOI', 'Civil', 'Electro', 'General');
  EstadoTexto: array[TEstadoRegistro]   of string   = ('Activo', 'No activo');
begin
  writeln('  Código   : ', reg.codigo);
  writeln('  Nombre   : ', reg.nombre);
  writeln('  Inicio   : ', reg.fechaInicio.dia, '/', reg.fechaInicio.mes, '/', reg.fechaInicio.anio);
  writeln('  Fin      : ', reg.fechaFin.dia, '/', reg.fechaFin.mes, '/', reg.fechaFin.anio);
  writeln('  Tipo     : ', TipoTexto[reg.tipo]);
  writeln('  Horas    : ', reg.horas);
  writeln('  Docentes : ', reg.docentes);
  writeln('  Área     : ', AreaTexto[reg.area]);
  writeln('  Alumnos  : ', reg.cantAlumnos);
  writeln('  Estado   : ', EstadoTexto[reg.estado]);
end;

end.