program FRCU_Capacitaciones;

{******************************************************
  Programa: FRCU_Capacitaciones
  Sistema:  Gestión de Capacitaciones - FRCU
  Propósito:
    - Integrar todos los módulos del sistema de gestión
      en consola, aplicando programación estructurada.
  Autor: [Tu Nombre]
  Fecha: [Fecha de creación]
*******************************************************}

uses
  crt,
  U_Tipos,
  U_Arboles,
  U_Archivos,
  U_Capacitaciones,
  U_Alumnos,
  U_Listados,
  U_Estadisticas;

{------------------------------------------------------}
{ Declaración de variables globales principales        }
{------------------------------------------------------}

var
  archCap: TArchivoCapacitaciones;
  archAlu: TArchivoAlumnos;
  arbolCod: PNodoCodigo;
  arbolNom: PNodoNombre;
  opcion: integer;

{------------------------------------------------------}
{ Procedimiento: Mostrar menú principal                }
{------------------------------------------------------}

procedure MostrarMenuPrincipal;
begin
  clrscr;
  writeln('=============================================');
  writeln('   SISTEMA DE GESTIÓN DE CAPACITACIONES - FRCU');
  writeln('=============================================');
  writeln('1) Capacitaciones');
  writeln('2) Alumnos');
  writeln('3) Listados');
  writeln('4) Estadísticas');
  writeln('5) Salir');
  writeln('---------------------------------------------');
  write('Seleccione una opción: ');
end;

{------------------------------------------------------}
{ Programa principal                                   }
{------------------------------------------------------}

begin
  clrscr;
  writeln('=============================================');
  writeln(' INICIALIZANDO SISTEMA DE CAPACITACIONES FRCU ');
  writeln('=============================================');
  writeln;

  { Abrir o crear archivos }
  AbrirArchivoCapacitaciones(archCap);
  AbrirArchivoAlumnos(archAlu);

  { Cargar árboles desde archivo de capacitaciones }
  CargarArbolesDesdeArchivo(archCap, arbolCod, arbolNom);

  writeln;
  writeln('Datos cargados correctamente.');
  writeln('Presione ENTER para continuar...');
  readln;

  { Menú principal del sistema }
  repeat
    MostrarMenuPrincipal;
    readln(opcion);

    case opcion of
      1: MenuCapacitaciones(archCap, arbolCod, arbolNom);
      2: MenuAlumnos(archAlu, archCap);
      3: MenuListados(archCap, archAlu);
      4: MenuEstadisticas(archCap);
    end;

  until opcion = 5;

  { Al salir, liberar recursos }
  LiberarArbolCodigo(arbolCod);
  LiberarArbolNombre(arbolNom);
  CerrarArchivoCapacitaciones(archCap);
  CerrarArchivoAlumnos(archAlu);

  clrscr;
  writeln('=============================================');
  writeln('     PROGRAMA FINALIZADO CORRECTAMENTE');
  writeln('=============================================');
  writeln('Gracias por usar el sistema de gestión FRCU.');
  writeln;
end.
