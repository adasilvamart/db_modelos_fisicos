/** BASE DE DATOS CURSOS ONLINE **/
DROP DATABASE IF EXISTS CURSOS_ONLINE;
CREATE DATABASE IF NOT EXISTS CURSOS_ONLINE;
USE CURSOS_ONLINE;


/** TABLA ENTIDAD AULA **/
DROP TABLE IF EXISTS AULAS;
CREATE TABLE IF NOT EXISTS AULAS
(
	ID_AULA INT UNSIGNED AUTO_INCREMENT NOT NULL,
    NOMBRE ENUM ('SÓCRATES','ARISTÓTELES', 'PITÁGORAS','SÓFOCLES', 'PLATÓN') NOT NULL,
	LOCALIDAD  VARCHAR(30) NOT NULL,
	DIRECCION VARCHAR (45) NOT NULL,
	
    /* CLAVE PRIMARIA */
    PRIMARY KEY (ID_AULA),
    
    /*RESTRICCIÓN DE UNICIDAD PARA LA SUMA DE NOMBRE + LOCALIDAD*/
    UNIQUE INDEX U_NOM_LOC (NOMBRE,LOCALIDAD)
       
) ENGINE INNODB;

		/* TABLA ATRIBUTO MULTIVALUADO TELEFONO (AULA) */
        DROP TABLE IF EXISTS TELEFONOS_AULAS;
        CREATE TABLE IF NOT EXISTS TELEFONOS_AULAS
        (
			/* UN ATRIBUTO MULTIVALUADO SIEMPRE TIENE SOLO 2 COLUMNAS*/
			TELEFONO VARCHAR (10) NOT NULL,
            AULA INT UNSIGNED NOT NULL,
            
            /* CLAVE PRIMARIA */
            PRIMARY KEY (TELEFONO, AULA), /* En atributos mv siempre clave primaria compuesta*/
            
            /* RESTRICIÓN DE INTEGRIDAD REFERENCIAL, DEFINIMOS LA COLUMNA AULA COMO UNA FOREIGN KEY,
			   ES EL ENGANCHE AL ALULA DE LA TABLA AULAS **/
            FOREIGN KEY (AULA) REFERENCES AULAS(ID_AULA)
				/* Siempre tiene dependencia en existencia*/
				ON DELETE CASCADE
                ON UPDATE CASCADE,
                 
            INDEX FK_TLF_AULA (TELEFONO)
            
        ) ENGINE INNODB;
        
        
/** TABLA ENTIDAD ALUMNO **/
DROP TABLE IF EXISTS ALUMNOS;
CREATE TABLE IF NOT EXISTS ALUMNOS
(
	DNI CHAR (9) NOT NULL,
    NOMBRE VARCHAR (50) NOT NULL,
    DIRECCION VARCHAR (60) NOT NULL,
    TELEFONO VARCHAR (10) NULL,
    FECHA_NAC DATE NOT NULL,
    EMAIL VARCHAR (45) NOT NULL,
    FOTO BLOB NULL,
	DNI_DIG BLOB NULL,
    
    /* RELACION CON AULA*/
    AULA INT UNSIGNED NOT NULL,
    
    FOREIGN KEY (AULA) REFERENCES AULAS(ID_AULA)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
	UNIQUE INDEX FK_AULA (AULA),
    
    /* CLAVE PRIMARIA */
    PRIMARY KEY (DNI),
    
    /* CLAVE ALTERNATIVA (EMAIL) */
    UNIQUE INDEX AK_EMAIL_ALUMNO (EMAIL)
    
) ENGINE INNODB;


/* TABLA ENTIDAD DEPARTAMENTO */
DROP TABLE IF EXISTS DEPARTAMENTOS;
CREATE TABLE IF NOT EXISTS DEPARTAMENTOS
(
	ID_DEPARTAMENTO INT UNSIGNED AUTO_INCREMENT NOT NULL,
    NOMBRE VARCHAR(20) NOT NULL,
    EMAIL VARCHAR(45) NOT NULL,
    
    /* CLAVE PRIMARIA */
	PRIMARY KEY (ID_DEPARTAMENTO),
    
    /* CLAVE ALTERNATIVA EMAIL_DEPARTAMENTO*/
    UNIQUE INDEX AK_EMAIL_DEPARTAMENTO (EMAIL)

) ENGINE INNODB;


/* TABLA ENTIDAD PROFESORES */
DROP TABLE IF EXISTS PROFESORES;
CREATE TABLE IF NOT EXISTS PROFESORES
(
	DNI CHAR(9) NOT NULL,
    NOMBRE VARCHAR(10) NOT NULL,
    EMAIL VARCHAR(50) NOT NULL,
    SALARIO FLOAT NOT NULL DEFAULT 1500.0,

    /* CLAVE PRIMARIA */
	PRIMARY KEY (DNI),
    
    /* CLAVE ALTERNATIVA EMAIL*/
    UNIQUE INDEX AK_E_MAIL_PROF (EMAIL),
    
    /* RELACION REFLEXIVA SUPERVISAR */
    SUPERVISOR CHAR(9) NOT NULL,
    /* falta fecha supervision*/
    FOREIGN KEY (SUPERVISOR) REFERENCES PROFESORES(DNI)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
	UNIQUE INDEX FK_SUPERVISOR (SUPERVISOR),
    
    /* RELACION ADMINISTRAR AULA */
    /* faltan atributos (numero_horas, dia_semana, precio_hora)*/
    AULA_ADMINISTRADA INT UNSIGNED NOT NULL,
    FOREIGN KEY (AULA_ADMINISTRADA) REFERENCES AULAS(ID_AULA)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
	UNIQUE INDEX FK_AULA_ADMINISTRADA (AULA_ADMINISTRADA),
    
    /* RELACION ESTAR ASIGNADO A DEPARTAMENTO */
    ID_DEPARTAMENTO INT UNSIGNED NOT NULL,
    FOREIGN KEY (ID_DEPARTAMENTO) REFERENCES DEPARTAMENTOS(ID_DEPARTAMENTO)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
	UNIQUE INDEX FK_DEPARTAMENTO_ASIGNADO (ID_DEPARTAMENTO),
    
    /* RELACION DIRIGIR DEPARTAMENTO */
    DEPARTAMENTO_DIRIGIDO INT UNSIGNED NOT NULL,
    /* falta fecha y prima*/
    FOREIGN KEY (DEPARTAMENTO_DIRIGIDO) REFERENCES DEPARTAMENTOS(ID_DEPARTAMENTO)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
	UNIQUE INDEX FK_DEPARTAMENTO_DIRIGIDO (ID_DEPARTAMENTO)

) ENGINE INNODB;


/** TABLA ENTIDAD CURSOS **/
DROP TABLE IF EXISTS CURSOS;
CREATE TABLE IF NOT EXISTS CURSOS
(
	ID_CURSO INT UNSIGNED AUTO_INCREMENT,
    NOMBRE VARCHAR (40) NOT NULL,
    DURACION INT NOT NULL DEFAULT 300, /* DEFAULT, pone un valorpor defecto*/
    LIBRO VARCHAR (60) NULL,
    URL_CURSO VARCHAR (60) NOT NULL,
    
    /* RELACION CURSO EVALUADO POR PROFESOR (DNI_PROFESOR)*/
    EVALUADOR CHAR(9) NOT NULL, 
    
    FOREIGN KEY (EVALUADOR) REFERENCES PROFESORES(DNI)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
	UNIQUE INDEX FK_PROFESOR_EVALUADOR (EVALUADOR),
    
    /* RELACION SER DELEGADO (DNI_ALUMNO) */
    DELEGADO CHAR (9) NOT NULL,
    
    FOREIGN KEY (DELEGADO) REFERENCES ALUMNOS(DNI)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
	UNIQUE INDEX FK_DNI_DELEGADO (DELEGADO),
    
    /* CLAVE PRIMARIA*/
    PRIMARY KEY (ID_CURSO),
    
    /* CLAVE ALTERNATIVA URL_CURSO (RESTRICCION UNICIDAD) */
    UNIQUE INDEX AK_URL_CURSO (URL_CURSO),
    
    /* CLAVE ALTERNATIVA NOMBRE_CURSO (RESTRICCION UNICIDAD) */
    UNIQUE INDEX AK_NOMBRE_URSO (NOMBRE)
    
) ENGINE INNODB;


/** TABLA RELACION ESTAR MATRICULADO **/
DROP TABLE IF EXISTS MATRICULAS_ALUMNOS_CURSOS;
CREATE TABLE IF NOT EXISTS MATRICULAS_ALUMNOS_CURSOS
(
	DNI_ALUMNO CHAR(9) NOT NULL,
    ID_CURSO INT UNSIGNED NOT NULL,
    FECHA DATE NOT NULL,
    NOTA FLOAT NOT NULL DEFAULT 0.0,
    
    /* CLAVE PRIMARIA COMPUESTA */
    PRIMARY KEY (DNI_ALUMNO, ID_CURSO),
    
    FOREIGN KEY (DNI_ALUMNO) REFERENCES ALUMNOS(DNI)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
    UNIQUE INDEX FK_DNI_ALUMNO (DNI_ALUMNO),
    
    FOREIGN KEY (ID_CURSO) REFERENCES CURSOS(ID_CURSO)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
	UNIQUE INDEX FK_ID_CURSO (ID_CURSO)
) ENGINE INNODB;


/** TABLA RELACION PROFESORES IMPARTIR CURSOS **/
DROP TABLE IF EXISTS PROFESORES_IMPARTEN_CURSOS;
CREATE TABLE IF NOT EXISTS PROFESORES_IMPARTEN_CURSOS
(
    DNI_PROFESOR CHAR(9) NOT NULL,
    ID_CURSO INT UNSIGNED NOT NULL,
    HORAS FLOAT NOT NULL DEFAULT 0.0,
    PRECIO_HORA FLOAT UNSIGNED NOT NULL DEFAULT 12.5,
    
    /* CLAVE PRIMARIA COMPUESTA */
    PRIMARY KEY (DNI_PROFESOR, ID_CURSO),
    
    /* CLAVE FORANEA DNI PROFESOR*/
    FOREIGN KEY (DNI_PROFESOR) REFERENCES PROFESORES(DNI)
		ON DELETE RESTRICT
        ON UPDATE CASCADE,
	UNIQUE INDEX FK_PROFESOR (DNI_PROFESOR),
    
    /* CLAVE FORANEA ID CURSO*/
    FOREIGN KEY (ID_CURSO) REFERENCES CURSOS(ID_CURSO)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	INDEX FK_ID_CURSO (ID_CURSO)
    
) ENGINE INNODB;