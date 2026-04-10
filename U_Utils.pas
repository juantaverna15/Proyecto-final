unit U_Utils;

{******************************************************
  Unidad: U_Utils
  Sistema: Gestión de Capacitaciones FRCU
  Propósito:
    - Proveer funciones de lectura segura de enteros
      que NUNCA crashean la consola, sin importar
      qué carácter ingrese el usuario.
    - Centralizar la validación de entrada numérica
      para ser reutilizada en todas las unidades.
  Restricciones:
    - Sin break, exit ni goto.
*******************************************************}

interface

uses crt;

{------------------------------------------------------}
{ Lee un entero SIN rango. Nunca crashea.              }
{ Repite hasta que el usuario ingrese solo dígitos.    }
{------------------------------------------------------}
function LeerEntero(prompt: string): integer;

{------------------------------------------------------}
{ Lee un entero dentro de un rango [minVal..maxVal].   }
{ Repite hasta que el valor sea válido.                }
{------------------------------------------------------}
function LeerEnteroRango(prompt: string; minVal, maxVal: integer): integer;

{------------------------------------------------------}
{ Lee un longint dentro de un rango [minVal..maxVal].  }
{ Útil para DNI.                                       }
{------------------------------------------------------}
function LeerLongintRango(prompt: string; minVal, maxVal: longint): longint;

implementation

{------------------------------------------------------}
{ Verifica que el string tenga solo dígitos y no       }
{ esté vacío. Función interna de la unidad.            }
{------------------------------------------------------}
function SoloDigitos(s: string): boolean;
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
  SoloDigitos := ok;
end;

{------------------------------------------------------}
{ LeerEntero                                           }
{------------------------------------------------------}
function LeerEntero(prompt: string): integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    write(prompt);
    readln(s);
    valido := SoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0);
    end;
    if not valido then
      writeln('  [!] Entrada inválida. Ingrese solo dígitos numéricos.');
  until valido;
  LeerEntero := valor;
end;

{------------------------------------------------------}
{ LeerEnteroRango                                      }
{------------------------------------------------------}
function LeerEnteroRango(prompt: string; minVal, maxVal: integer): integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    write(prompt);
    readln(s);
    valido := SoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor >= minVal) and (valor <= maxVal);
    end;
    if not valido then
      writeln('  [!] Inválido. Ingrese un número entre ', minVal, ' y ', maxVal, '.');
  until valido;
  LeerEnteroRango := valor;
end;

{------------------------------------------------------}
{ LeerLongintRango                                     }
{------------------------------------------------------}
function LeerLongintRango(prompt: string; minVal, maxVal: longint): longint;
var
  s     : string;
  valor : longint;
  code  : integer;
  valido: boolean;
begin
  repeat
    write(prompt);
    readln(s);
    valido := SoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor >= minVal) and (valor <= maxVal);
    end;
    if not valido then
      writeln('  [!] Inválido. Ingrese un número entre ', minVal, ' y ', maxVal, '.');
  until valido;
  LeerLongintRango := valor;
end;

end.