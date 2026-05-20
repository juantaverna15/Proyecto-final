unit U_Utilidades;
{$codepage utf8}

{Unidad dedicada a verificacion de ingreso de datos (para evitar que salgan errores en la consola}
interface

uses crt, U_tipos;


{ Lee un entero SIN rango.  evita el crasheo de la consola }
{ Repite hasta que el usuario ingrese solo dígitos.    }
function LeerEntero(mensaje: string): integer;


{ Lee un entero dentro de un rango [minVal..maxVal].   }
{ Repite hasta que el valor sea válido.                }

function LeerEnteroRango(mensaje: string; minVal, maxVal: integer): integer;

{ Lee un longint dentro de un rango [minVal..maxVal]. para dni  }
function EsSoloDigitos(s: string): boolean;

function LeerLongintRango(mensaje: string; minVal, maxVal: longint): longint;

function EsBisiesto(anio: integer): boolean;
function DiasEnMes(mes, anio: integer): integer;
function FechaValida(f: TFecha): boolean;

implementation

function EsBisiesto(anio: integer): boolean;
begin
  EsBisiesto := ((anio mod 4 = 0) and (anio mod 100 <> 0))
                or (anio mod 400 = 0);
end;

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

function FechaValida(f: TFecha): boolean;
begin
  FechaValida := (f.anio > 0)
             and (f.mes  >= 1) and (f.mes  <= 12)
             and (f.dia  >= 1) and (f.dia  <= DiasEnMes(f.mes, f.anio));
end;

{ Verifica que el string tenga solo dígitos y no       }
{ esté vacío. Función interna de la unidad.            }

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


{ LeerEntero  / verifica que sean numeros enteros }

function LeerEntero(mensaje: string): integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    write(mensaje);
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0);
    end;
    if not valido then
      writeln('  [!] Entrada inválida. Ingrese solo valores numéricos.');
  until valido;
  LeerEntero := valor;
end;


{ LeerEnteroRango     }
function LeerEnteroRango(mensaje: string; minVal, maxVal: integer): integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    write(mensaje);
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor >= minVal) and (valor <= maxVal);
    end;
    if not valido then
      writeln('  [!] Entrada Inválida. Ingrese un número entre ', minVal, ' y ', maxVal, '.');
  until valido;
  LeerEnteroRango := valor;
end;


{ LeerLongintRango  }

function LeerLongintRango(mensaje: string; minVal, maxVal: longint): longint;
var
  s     : string;
  valor : longint;
  code  : integer;
  valido: boolean;
begin
  repeat
    write(mensaje);
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor >= minVal) and (valor <= maxVal);
    end;
    if not valido then
      writeln('  [!] Entrada Inválida. Ingrese un número entre ', minVal, ' y ', maxVal, '.');
  until valido;
  LeerLongintRango := valor;
end;

end.