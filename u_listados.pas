unit U_Listados;
{$codepage utf8}

interface

uses
  crt, U_Tipos, U_Archivos, U_Utilidades;



procedure MenuListados(var archCap: TArchivoCapacitaciones;
                       var archAlu: TArchivoAlumnos);

implementation

procedure ListadoPorArea(var archCap: TArchivoCapacitaciones); forward;
procedure ListadoCapacitacionesDeAlumno(var archCap: TArchivoCapacitaciones;
                                        var archAlu: TArchivoAlumnos); forward;
procedure ListadoAprobadosPorCapacitacion(var archCap: TArchivoCapacitaciones;
                                          var archAlu: TArchivoAlumnos); forward;
procedure GenerarCertificado(var archCap: TArchivoCapacitaciones;
                             var archAlu: TArchivoAlumnos); forward;
procedure MostrarCapacitacionCorta(reg: TCapacitacion); forward;
procedure MostrarAlumnoCorto(reg: TAlumno); forward;



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



procedure ListadoPorArea(var archCap: TArchivoCapacitaciones);
const
  AreaTexto: array[TAreaCapacitacion] of string[10] =
    ('ISI', 'LOI', 'Civil', 'Electro', 'General');
var
  reg        : TCapacitacion;
  regMin     : TCapacitacion;
  pos        : longint;
  posMin     : longint;
  encontrado : boolean;
  hayAlguna  : boolean;
  lastArea   : string;
  lastNombre : string;
  lastPos    : longint;
  areaReg    : string;
  areaMin    : string;
  esMayor    : boolean;
  esMenor    : boolean;
begin
  clrscr;
  writeln('=============================================');
  writeln('  LISTADO DE CAPACITACIONES POR ÁREA/NOMBRE  ');
  writeln('=============================================');

  hayAlguna  := false;
  lastArea   := '';
  lastNombre := '';
  lastPos    := -1;

  encontrado := true;
  while encontrado do
  begin
    encontrado := false;
    posMin     := -1;
    pos        := 0;
    seek(archCap, 0);

    while pos < filesize(archCap) do
    begin
      read(archCap, reg);

      if reg.estado = activo then
      begin
        areaReg := AreaTexto[reg.area];

        { ¿Es este registro mayor que el último impreso? }
        esMayor := false;
        if areaReg > lastArea then
          esMayor := true
        else if areaReg = lastArea then
        begin
          if reg.nombre > lastNombre then
            esMayor := true
          else if reg.nombre = lastNombre then
            esMayor := (pos > lastPos);
        end;

        if esMayor then
        begin
          if not encontrado then
          begin
            encontrado := true;
            regMin     := reg;
            posMin     := pos;
          end
          else
          begin
            { ¿Es menor que el mínimo actual? }
            areaMin := AreaTexto[regMin.area];
            esMenor := false;
            if areaReg < areaMin then
              esMenor := true
            else if areaReg = areaMin then
            begin
              if reg.nombre < regMin.nombre then
                esMenor := true
              else if reg.nombre = regMin.nombre then
                esMenor := (pos < posMin);
            end;

            if esMenor then
            begin
              regMin := reg;
              posMin := pos;
            end;
          end;
        end;
      end;

      pos := pos + 1;
    end;

    if encontrado then
    begin
      areaMin   := AreaTexto[regMin.area];
      hayAlguna := true;

      { Encabezado de área cuando cambia }
      if areaMin <> lastArea then
      begin
        writeln;
        writeln('  ÁREA: ', areaMin);
        writeln('  =============================================');
      end;

      MostrarCapacitacionCorta(regMin);

      lastArea   := areaMin;
      lastNombre := regMin.nombre;
      lastPos    := posMin;
    end;
  end;

  if not hayAlguna then
    writeln('  No hay capacitaciones activas.');

  writeln('---------------------------------------------');
  writeln('Fin del listado. Presione ENTER...');
  readln;
end;




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
if (alu.codCapacitacion = codCap) and
   (alu.estado = activo)          and
   (alu.condicion = Aprobado)     then
  writeln(alu.apenom:30, '   Aprobado');
      posAlu := posAlu + 1;
    end;
  end
  else
    writeln('No existe capacitación con ese código.');

  writeln;
  writeln('Presione ENTER para continuar...');
  readln;
end;




procedure GenerarCertificado(var archCap: TArchivoCapacitaciones;
                             var archAlu: TArchivoAlumnos);
var
  codCap        : integer;
  dni           : longint;
  posCap, posAlu: longint;
  cap           : TCapacitacion;
  alu           : TAlumno;
  sTipo         : string;
  sArea         : string;
  sCondicion    : string;
  sDocUTN       : string;
  sHoras        : string;
begin
  clrscr;
  writeln('=============================================');
  writeln('           GENERAR CERTIFICADO               ');
  writeln('=============================================');
  codCap := LeerEntero       ('Codigo de capacitacion : ');
  dni    := LeerLongintRango ('DNI del alumno         : ', 10000000, 99999999);

  posCap := BuscarCapacitacionPorCodigo(archCap, codCap);
  posAlu := BuscarAlumnoPorDNI(archAlu, codCap, dni);

  if (posCap = -1) or (posAlu = -1) then
  begin
    writeln;
    writeln('  [!] No se encontro el alumno o la capacitacion.');
  end
  else
  begin
    LeerCapacitacion(archCap, posCap, cap);
    LeerAlumno(archAlu, posAlu, alu);

    if (cap.estado = no_activo) or (alu.estado = no_activo) then
    begin
      writeln;
      if cap.estado = no_activo then
        writeln('  [!] La capacitacion esta dada de baja. No se puede emitir certificado.');
      if alu.estado = no_activo then
        writeln('  [!] El alumno esta dado de baja. No se puede emitir certificado.');
    end
    else
    begin
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

      if alu.condicion = Aprobado then
        sCondicion := 'APROBADO'
      else
        sCondicion := 'ASISTENCIA';

      if alu.esDocenteUTN then
        sDocUTN := 'Si'
      else
        sDocUTN := 'No';

      str(cap.horas, sHoras);

      clrscr;
      writeln('*********************************************');
      writeln('*   UNIVERSIDAD TECNOLOGICA NACIONAL        *');
      writeln('*   Facultad Regional Concepcion del Urugay *');
      writeln('*   Secretaria de Extension Universitaria   *');
      writeln('*********************************************');
      writeln;
      writeln('              C E R T I F I C A D O         ');
      writeln('---------------------------------------------');
      writeln;
      writeln('La Secretaria certifica que:');
      writeln;
      writeln('  Alumno   : ', alu.apenom);
      writeln('  DNI      : ', alu.dni);
      writeln('  Doc. UTN : ', sDocUTN);
      writeln;
      writeln('Ha completado satisfactoriamente:');
      writeln;
      writeln('  Nombre   : ', cap.nombre);
      writeln('  Tipo     : ', sTipo, ' - Area: ', sArea);
      writeln('  Duracion : ', sHoras, ' horas');
      writeln('  Inicio   : ', cap.fechaInicio.dia, '/',
                               cap.fechaInicio.mes, '/',
                               cap.fechaInicio.anio);
      writeln('  Fin      : ', cap.fechaFin.dia, '/',
                               cap.fechaFin.mes, '/',
                               cap.fechaFin.anio);
      writeln('  Docentes : ', cap.docentes);
      writeln;
      writeln('---------------------------------------------');
      writeln('  Condicion: >>> ', sCondicion, ' <<<');
      writeln('---------------------------------------------');
      writeln;
      writeln('  Concepcion del Uruguay, ',
              cap.fechaFin.dia, '/',
              cap.fechaFin.mes, '/',
              cap.fechaFin.anio);
      writeln;
      writeln('  ______________________________________');
      writeln('  Secretaria de Extension Universitaria');
      writeln('  FRCU - UTN');
      writeln;
      writeln('*********************************************');
    end;  { cierra else estado activo }
  end;    { cierra else posCap/posAlu }

  writeln;
  writeln('Presione ENTER para continuar...');
  readln;
end;

end.