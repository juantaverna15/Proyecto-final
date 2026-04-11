program FRCU_Capacitaciones;
{$codepage utf8}

uses
  crt,
  U_Tipos,
  U_Arboles,
  U_Archivos,
  U_Capacitaciones,
  U_Alumnos,
  U_Listados,
  U_Estadisticas,
  U_Utilidades;          


{variables globales}

var
  archCap  : TArchivoCapacitaciones;
  archAlu  : TArchivoAlumnos;
  arbolCod : PNodoCodigo;
  arbolNom : PNodoNombre;
  opcion   : integer;


{ Procedimiento: Mostrar menú principal   }


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
end;


{ Programa principal                                   }


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
    opcion := LeerEnteroRango('Seleccione una opción: ', 1, 5);

    case opcion of
      1: MenuCapacitaciones(archCap, arbolCod, arbolNom);
      2: MenuAlumnos(archAlu, archCap);
      3: MenuListados(archCap, archAlu);
      4: MenuEstadisticas(archCap);
    end;

  until opcion = 5;



  LiberarArbolCodigo(arbolCod);
  LiberarArbolNombre(arbolNom);
  CerrarArchivoCapacitaciones(archCap);
  CerrarArchivoAlumnos(archAlu);

  clrscr;
  writeln('=============================================');
  writeln('     PROGRAMA FINALIZADO                     ');
  writeln('=============================================');
  writeln('Gracias por usar el sistema de gestión FRCU.');
  writeln;
end.