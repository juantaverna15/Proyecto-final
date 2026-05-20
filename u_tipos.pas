unit U_Tipos;
{$codepage utf8}


interface


{ 1. Tipos de Enumeraciones   }


type
  { Tipos de capacitaciones ofrecidas }
  TTipoCapacitacion = (curso, taller, seminario);

  { Áreas o departamentos de la universidad }
  TAreaCapacitacion = (ISI, LOI, Civil, Electro, General);

  { Estado de registros (baja lógica) }
  TEstadoRegistro = (activo, no_activo);

  { Condición académica del alumno }
  TCondicionAlumno = (Aprobado, Asistencia);



{ 2. Tipo Fecha Estructurada   }


type
  TFecha = record
    dia, mes, anio: integer;
  end;



{ 3. Registro de Capacitaciones}


type
  TCapacitacion = record
    codigo: integer;             { Identificador único }
    nombre: string[50];          { Nombre de la capacitación }
    fechaInicio: TFecha;         { Fecha de inicio }
    fechaFin: TFecha;            { Fecha de finalización }
    tipo: TTipoCapacitacion;     { Curso / Taller / Seminario }
    horas: integer;              { Duración total }
    docentes: string[80];        { Nombres de docentes }
    cantAlumnos: integer;        { Número de alumnos inscriptos activos }
    area: TAreaCapacitacion;     { Área responsable }
    estado: TEstadoRegistro;     { Activo / No activo }
  end;



{ 4. Registro de Alumnos       }


type
  TAlumno = record
    codCapacitacion: integer;    { Código de la capacitación en la que se inscribe }
    dni: longint;                { Documento nacional de identidad }
    apenom: string[50];          { Apellido y nombre del alumno }
    fechaNac: TFecha;            { Fecha de nacimiento }
    esDocenteUTN: boolean;       { Indica si es docente de la UTN }
    condicion: TCondicionAlumno; { Aprobado / Asistencia }
    estado: TEstadoRegistro;     { Activo / No activo }
  end;



{ 5. Archivos Random           }


type
  TArchivoCapacitaciones = file of TCapacitacion;
  TArchivoAlumnos = file of TAlumno;



{ 6. Árboles Binarios de Búsqueda (ABB) }

type
  PNodoCodigo = ^TNodoCodigo;
  PNodoNombre = ^TNodoNombre;

  { Árbol por código de capacitación }
  TNodoCodigo = record
    codigo: integer;             { Clave de búsqueda }
    pos: longint;                { Posición relativa en archivo de capacitaciones }
    izq, der: PNodoCodigo;
  end;

  { Árbol por nombre de capacitación }
  TNodoNombre = record
    nombre: string[50];          { Clave de búsqueda }
    pos: longint;                { Posición relativa en archivo de capacitaciones }
    izq, der: PNodoNombre;
  end;



const
  ARCH_CAPACITACIONES = 'capacitaciones.dat';
  ARCH_ALUMNOS = 'alumnos.dat';

implementation

end.
