unit U_Capacitaciones;
{$codepage utf8}
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
  crt, U_Tipos, U_Archivos, U_Arboles, U_Utilidades;

procedure MenuCapacitaciones(var arch: TArchivoCapacitaciones;
                             var arbolCod: PNodoCodigo;
                             var arbolNom: PNodoNombre);

procedure AltaCapacitacion(var arch: TArchivoCapacitaciones;
                           var arbolCod: PNodoCodigo;
                           var arbolNom: PNodoNombre;
                           codigo: integer);

procedure ConsultarCapacitacion(var arch: TArchivoCapacitaciones;
                                var arbolCod: PNodoCodigo;
                                var arbolNom: PNodoNombre;
                                pos: longint);

procedure ModificarCapacitacion(var arch: TArchivoCapacitaciones;
                                var arbolCod: PNodoCodigo;
                                var arbolNom: PNodoNombre;
                                pos: longint);
procedure BajaCapacitacion(var arch: TArchivoCapacitaciones; pos: longint);
procedure MostrarCapacitacion(reg: TCapacitacion);

implementation

{======================================================}
{         BLOQUE DE FUNCIONES DE VALIDACIÓN            }
{======================================================}

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

function EsSoloDigitos(s: string): boolean;
var
  i              : integer;
  contienedigitos: boolean;
begin
  contienedigitos := length(s) > 0;
  i := 1;
  while contienedigitos and (i <= length(s)) do
  begin
    if not (s[i] in ['0'..'9']) then
      contienedigitos := false;
    i := i + 1;
  end;
  EsSoloDigitos := contienedigitos;
end;

{======================================================}
{         BLOQUE DE FUNCIONES DE INGRESO VALIDADO      }
{======================================================}

procedure LeerTextoNoVacio(msj: string; var texto: string; maxLen: integer);
var
  valido      : boolean;
  soloEspacios: boolean;
  caracterOk  : boolean;
  i           : integer;
  c           : char;
begin
  repeat
    write(msj);
    readln(texto);

    valido := length(texto) > 0;

    soloEspacios := true;
    i := 1;
    while i <= length(texto) do
    begin
      if texto[i] <> ' ' then
        soloEspacios := false;
      i := i + 1;
    end;
    valido := valido and not soloEspacios;

    caracterOk := true;
    i := 1;
    while caracterOk and (i <= length(texto)) do
    begin
      c := texto[i];
      if not ( (c in ['a'..'z']) or
               (c in ['A'..'Z']) or
               (c = ' ')         or
               (c = '-')         or
               (c = '.')         or
               (ord(c) >= 128)   ) then
        caracterOk := false;
      i := i + 1;
    end;
    valido := valido and caracterOk;

    valido := valido and (length(texto) <= maxLen);

    if not valido then
    begin
      writeln;
      if length(texto) = 0 then
        writeln('  [!] El campo no puede estar vacío.')
      else if length(texto) > maxLen then
        writeln('  [!] Máximo ', maxLen, ' caracteres (ingresó ', length(texto), ').')
      else if soloEspacios then
        writeln('  [!] El campo no puede contener solo espacios.')
      else
        writeln('  [!] Solo se permiten letras, espacios, guion y punto.');
    end;
  until valido;
end;

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

procedure LeerFechaInicio(var f: TFecha);
var
  valido: boolean;
begin
  repeat
    writeln;
    writeln('  Fecha de inicio:');
    f.dia  := LeerEnteroRango('    Día  (1-31)       : ', 1, 31);
    f.mes  := LeerEnteroRango('    Mes  (1-12)       : ', 1, 12);
    f.anio := LeerEnteroRango('    Año  (2000-2100)  : ', 2000, 2100);
    valido := FechaValida(f);
    if not valido then
    begin
      writeln;
      writeln('  [!] Fecha inválida. Verifique:');
      writeln('      - El día debe ser válido para ese mes.');
      if (f.mes = 2) and (f.dia = 29) and not EsBisiesto(f.anio) then
        writeln('      - El año ', f.anio, ' no es bisiesto: febrero tiene solo 28 días.');
    end;
  until valido;
end;

procedure LeerFechaFin(var fFin: TFecha; fInicio: TFecha);
var
  esReal  : boolean;
  esMayor : boolean;
  valido  : boolean;
begin
  repeat
    writeln;
    writeln('  Fecha de fin:');
    fFin.dia  := LeerEnteroRango('    Día  (1-31)       : ', 1, 31);
    fFin.mes  := LeerEnteroRango('    Mes  (1-12)       : ', 1, 12);
    fFin.anio := LeerEnteroRango('    Año  (2000-2100)  : ', 2000, 2100);

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
      writeln('  [!] Opción inválida. Ingrese 1, 2 ó 3.');
  until valido;
  LeerTipoValido := valor;
end;

function LeerHorasValidas: integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    write('  Cantidad de horas: ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor >= 1);
    end;
    if not valido then
    begin
      writeln;
      writeln('  [!] Entrada inválida. Solo se aceptan números enteros positivos.');
    end;
  until valido;
  LeerHorasValidas := valor;
end;

function LeerCantDocentesValida: integer;
var
  s     : string;
  valor : integer;
  code  : integer;
  valido: boolean;
begin
  repeat
    write('  Cantidad de docentes (Máximo 10): ');
    readln(s);
    valido := EsSoloDigitos(s);
    if valido then
    begin
      val(s, valor, code);
      valido := (code = 0) and (valor > 0) and (valor <= 10);
    end;
    if not valido then
      writeln('  [!] Inválido. Ingrese un número entre 1 y 10.');
  until valido;
  LeerCantDocentesValida := valor;
end;

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
      writeln('  [!] Opción inválida. Ingrese un número entre 1 y 5.');
  until valido;
  LeerAreaValida := valor;
end;

{======================================================}
{         PROCEDIMIENTOS PRINCIPALES DEL MENÚ          }
{======================================================}

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
    writeln('  Ingrese 0 para volver al menú anterior.');

    codigo := LeerCodigoValido;

    if codigo <> 0 then
    begin
      pos := BuscarPorCodigo(arbolCod, codigo);

      if pos = -1 then
      begin
        { No está en el árbol — buscar en archivo (puede estar dada de baja) }
        pos := BuscarCapacitacionPorCodigo(arch, codigo);

        if pos <> -1 then
        begin
          { Existe pero está dada de baja }
          LeerCapacitacion(arch, pos, reg);
          writeln;
          writeln('  [!] La capacitación con código ', codigo, ' está dada de baja.');
          writeln('      Nombre: ', reg.nombre);
          writeln;
          opcion := LeerEnteroRango('  ¿Desea reactivarla? (1=Sí / 2=No): ', 1, 2);
          if opcion = 1 then
          begin
            reg.estado := activo;
            ActualizarCapacitacion(arch, pos, reg);
            InsertarCodigo(arbolCod, reg.codigo, pos);
            InsertarNombre(arbolNom, reg.nombre, pos);
            writeln;
            writeln('  [OK] Capacitación reactivada correctamente.');
          end;
          writeln;
          writeln('  Presione ENTER para continuar...');
          readln;
        end
        else
        begin
          { No existe en absoluto — ofrecer alta }
          writeln;
          writeln('  No existe una capacitación con el código ', codigo, '.');
          opcion := LeerEnteroRango('  ¿Desea darla de alta? (1=Sí / 2=No): ', 1, 2);
          if opcion = 1 then
            AltaCapacitacion(arch, arbolCod, arbolNom, codigo);
        end;
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
{ 2. Alta de nueva capacitación                        }
{------------------------------------------------------}

procedure AltaCapacitacion(var arch: TArchivoCapacitaciones;
                           var arbolCod: PNodoCodigo;
                           var arbolNom: PNodoNombre;
                           codigo: integer);
var
  reg     : TCapacitacion;
  pos     : longint;
  tipoNum : integer;
  areaNum : integer;
  cantDoc : integer;
begin
  clrscr;
  writeln('=============================================');
  writeln('           ALTA DE CAPACITACIÓN              ');
  writeln('=============================================');
  writeln('  Código asignado: ', codigo);
  writeln;

  reg.codigo := codigo;

  LeerTextoNoVacio('  Nombre de la capacitación : ', reg.nombre, 50);

  LeerFechaInicio(reg.fechaInicio);
  LeerFechaFin(reg.fechaFin, reg.fechaInicio);

  tipoNum := LeerTipoValido;
  case tipoNum of
    1: reg.tipo := curso;
    2: reg.tipo := taller;
    3: reg.tipo := seminario;
  end;

  writeln;
  reg.horas := LeerHorasValidas;

  writeln;
  cantDoc := LeerCantDocentesValida;
  writeln('  Ingrese los nombres de el/los ', cantDoc, ' docente(s):');
  LeerTextoNoVacio('  Nombres: ', reg.docentes, 80);

  reg.cantAlumnos := 0;

  areaNum := LeerAreaValida;
  case areaNum of
    1: reg.area := ISI;
    2: reg.area := LOI;
    3: reg.area := Civil;
    4: reg.area := Electro;
    5: reg.area := General;
  end;

  reg.estado := activo;

  GrabarCapacitacion(arch, reg);
  pos := filesize(arch) - 1;
  InsertarCodigo(arbolCod, reg.codigo, pos);
  InsertarNombre(arbolNom, reg.nombre, pos);

  writeln;
  writeln('=============================================');
  writeln('  Capacitación creada correctamente.');
  writeln('=============================================');
  writeln('  Presione ENTER para continuar...');
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
      1: ModificarCapacitacion(arch, arbolCod, arbolNom, pos);
      2: BajaCapacitacion(arch, pos);
    end;
  until opcion = 3;
end;

{------------------------------------------------------}
{ 4. Modificación de una capacitación                  }
{------------------------------------------------------}

procedure ModificarCapacitacion(var arch: TArchivoCapacitaciones;
                                var arbolCod: PNodoCodigo;
                                var arbolNom: PNodoNombre;
                                pos: longint);
var
  reg         : TCapacitacion;
  opcion      : integer;
  tipoNum     : integer;
  estadoAntes : TEstadoRegistro;
  estadoNuevo : TEstadoRegistro;
  s           : string;
  valor       : integer;
  code        : integer;
  valido      : boolean;
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
    writeln('  5) Cambiar estado (Activo / No activo)');
    writeln('  6) Volver');
    opcion := LeerEnteroRango('Opción: ', 1, 6);

    case opcion of
      1: LeerTextoNoVacio('  Nuevo nombre   : ', reg.nombre, 50);
      2: LeerTextoNoVacio('  Nuevos docentes: ', reg.docentes, 80);
      3: begin
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
      5: begin
           writeln;
           estadoAntes := reg.estado;
           repeat
             writeln('  Estado de la capacitación:');
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
               writeln('  [!] Opción inválida. Ingrese 1 (Activo) o 2 (No activo).');
           until valido;

           if valor = 1 then
             estadoNuevo := activo
           else
             estadoNuevo := no_activo;

           if estadoAntes = estadoNuevo then
           begin
             writeln;
             if estadoNuevo = no_activo then
               writeln('  [Aviso] La capacitación ya estaba dada de baja.')
             else
               writeln('  [Aviso] La capacitación ya estaba activa.');
           end
           else
           begin
             reg.estado := estadoNuevo;
             { Si se reactiva, volver a insertar en los árboles }
             if estadoNuevo = activo then
             begin
               InsertarCodigo(arbolCod, reg.codigo, pos);
               InsertarNombre(arbolNom, reg.nombre, pos);
               writeln('  [OK] Capacitación reactivada correctamente.');
             end
             else
               writeln('  [OK] Capacitación marcada como no activa.');
           end;
         end;
    end;
  until opcion = 6;

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
  if reg.estado = no_activo then
  begin
    writeln;
    writeln('  [Aviso] La capacitación ya estaba dada de baja. No se realizó ningún cambio.');
  end
  else
  begin
    reg.estado := no_activo;
    ActualizarCapacitacion(arch, pos, reg);
    writeln;
    writeln('  Capacitación marcada como "no activa".');
  end;
  writeln('  Presione ENTER para continuar...');
  readln;
end;

{------------------------------------------------------}
{ 6. Mostrar datos en pantalla                         }
{------------------------------------------------------}

procedure MostrarCapacitacion(reg: TCapacitacion);
const
  TipoTexto  : array[TTipoCapacitacion] of string = ('Curso', 'Taller', 'Seminario');
  AreaTexto  : array[TAreaCapacitacion] of string  = ('ISI', 'LOI', 'Civil', 'Electro', 'General');
  EstadoTexto: array[TEstadoRegistro]   of string  = ('Activo', 'No activo');
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