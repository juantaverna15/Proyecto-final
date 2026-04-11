unit U_Utilidades;
{$codepage utf8}

{Unidad dedicada a verificacion de ingreso de datos (para evitar que salgan errores en la consola}
interface

uses crt;


{ Lee un entero SIN rango.  evita el crasheo de la consola }
{ Repite hasta que el usuario ingrese solo dígitos.    }
function LeerEntero(mensaje: string): integer;


{ Lee un entero dentro de un rango [minVal..maxVal].   }
{ Repite hasta que el valor sea válido.                }

function LeerEnteroRango(mensaje: string; minVal, maxVal: integer): integer;

{ Lee un longint dentro de un rango [minVal..maxVal].  }
{ Útil para DNI.                                       }

function LeerLongintRango(mensaje: string; minVal, maxVal: longint): longint;

implementation


{ Verifica que el string tenga solo dígitos y no       }
{ esté vacío. Función interna de la unidad.            }

function SoloDigitos(s: string): boolean;
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
  SoloDigitos := contienedigitos;
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
    valido := SoloDigitos(s);
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


{ LeerEnteroRango                                      }
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
    valido := SoloDigitos(s);
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


{ LeerLongintRango                                     }

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
    valido := SoloDigitos(s);
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