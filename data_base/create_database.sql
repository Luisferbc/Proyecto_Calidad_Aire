/* ======================================================
   1. BASE DE DATOS
====================================================== */
CREATE DATABASE IF NOT EXISTS observatorio_aire_salud_colombia;
USE observatorio_aire_salud_colombia;

/* ======================================================
   2. pais
====================================================== */
CREATE TABLE pais (
    id         VARCHAR(10)  NOT NULL,
    nombre     VARCHAR(100) NOT NULL,
    CONSTRAINT pk_pais PRIMARY KEY (id)
);

INSERT INTO pais (id, nombre)
VALUES ('COL', 'Colombia');

/* ======================================================
   3. departamento
   id = código DANE del departamento (ej: '05' Antioquia)
====================================================== */
CREATE TABLE departamento (
    id       VARCHAR(10)  NOT NULL,
    id_pais  VARCHAR(10)  NOT NULL,
    nombre   VARCHAR(120) NOT NULL,
    region   VARCHAR(50),
    CONSTRAINT pk_departamento PRIMARY KEY (id),
    CONSTRAINT fk_departamento_pais FOREIGN KEY (id_pais) REFERENCES pais(id)
);

INSERT INTO departamento (id, id_pais, nombre, region) VALUES
    ('05', 'COL', 'Antioquia',        'Andina'),
    ('08', 'COL', 'Atlántico',        'Caribe'),
    ('11', 'COL', 'Bogotá D.C.',      'Andina'),
    ('13', 'COL', 'Bolívar',          'Caribe'),
    ('25', 'COL', 'Cundinamarca',     'Andina'),
    ('68', 'COL', 'Santander',        'Andina'),
    ('76', 'COL', 'Valle del Cauca',  'Pacífica');

/* ======================================================
   4. municipio
   id = código DANE completo del municipio (ej: '05001')
====================================================== */
CREATE TABLE municipio (
    id               VARCHAR(10)  NOT NULL,
    id_departamento  VARCHAR(10)  NOT NULL,
    nombre           VARCHAR(120) NOT NULL,
    poblacion        INT,
    latitud          FLOAT,
    longitud         FLOAT,
    altitud          FLOAT,
    CONSTRAINT pk_municipio PRIMARY KEY (id),
    CONSTRAINT fk_municipio_departamento FOREIGN KEY (id_departamento) REFERENCES departamento(id)
);

/* ======================================================
   5. tiempo
====================================================== */
CREATE TABLE tiempo (
    id         INT          NOT NULL AUTO_INCREMENT,
    fecha      DATE,
    anio       INT          NOT NULL,
    mes        TINYINT      NOT NULL  COMMENT '1=Enero ... 12=Diciembre',
    trimestre  TINYINT               COMMENT '1 a 4',
    semana     TINYINT,
    CONSTRAINT pk_tiempo PRIMARY KEY (id)
);

/* ======================================================
   6. estacion_monitoreo
====================================================== */
CREATE TABLE estacion_monitoreo (
    id                 INT          NOT NULL AUTO_INCREMENT,
    id_municipio       VARCHAR(10)  NOT NULL,
    nombre             VARCHAR(120) NOT NULL,
    latitud            FLOAT,
    longitud           FLOAT,
    altitud            FLOAT,
    entidad_operadora  VARCHAR(120),
    CONSTRAINT pk_estacion_monitoreo PRIMARY KEY (id),
    CONSTRAINT fk_estacion_municipio FOREIGN KEY (id_municipio) REFERENCES municipio(id)
);

/* ======================================================
   7. medicion_calidad_aire
====================================================== */
CREATE TABLE medicion_calidad_aire (
    id           INT    NOT NULL AUTO_INCREMENT,
    id_estacion  INT    NOT NULL,
    id_tiempo    INT    NOT NULL,
    pm25         FLOAT  COMMENT 'µg/m³',
    pm10         FLOAT  COMMENT 'µg/m³',
    no2          FLOAT,
    so2          FLOAT,
    co           FLOAT,
    o3           FLOAT,
    temperatura  FLOAT,
    humedad      FLOAT,
    CONSTRAINT pk_medicion PRIMARY KEY (id),
    CONSTRAINT fk_medicion_estacion FOREIGN KEY (id_estacion) REFERENCES estacion_monitoreo(id),
    CONSTRAINT fk_medicion_tiempo   FOREIGN KEY (id_tiempo)   REFERENCES tiempo(id)
);

/* ======================================================
   8. persona
   Perfil del fallecido — quién era
   DANE: SEXO, GRU_ED1, GRU_ED2, EST_CIVIL,
         NIVEL_EDU, SEG_SOCIAL, CODPAISNACFAL, OCUPACION
====================================================== */
CREATE TABLE persona (
    id                  INT          NOT NULL AUTO_INCREMENT,
    id_pais_nacimiento  VARCHAR(10),
    sexo                TINYINT      COMMENT '1=Masculino, 2=Femenino, 3=Indeterminado',
    grupo_edad_1        TINYINT      COMMENT '00=<1hora, 01=<1día, 02=1-6días, 03=7-27días, 04=28-29días, 05=1-5meses, 06=6-11meses, 07=1año, 08=2-4años, 09=5-9años, 10=10-14, 11=15-19, 12=20-24, 13=25-29, 14=30-34, 15=35-39, 16=40-44, 17=45-49, 18=50-54, 19=55-59, 20=60-64, 21=65-69, 22=70-74, 23=75-79, 24=80-84, 25=85-89, 26=90-94, 27=95-99, 28=100+, 29=Desconocida',
    grupo_edad_2        TINYINT      COMMENT '1=<1año, 2=1-4años, 3=5-14años, 4=15-44años, 5=45-64años, 6=65+años, 7=Desconocida',
    estado_civil        TINYINT      COMMENT '1=Unión libre +2años, 2=Unión libre -2años, 3=Separado/divorciado, 4=Viudo, 5=Soltero, 6=Casado, 9=Sin información',
    nivel_educativo     TINYINT      COMMENT '1=Preescolar, 2=B.Primaria, 3=B.Secundaria, 4=Media académica, 5=Media técnica, 6=Normalista, 7=Técnica profesional, 8=Tecnológica, 9=Profesional, 10=Especialización, 11=Maestría, 12=Doctorado, 13=Ninguno, 99=Sin información',
    seguridad_social    TINYINT      COMMENT '1=Contributivo, 2=Subsidiado, 3=Excepción, 4=Especial, 5=No asegurado, 9=Sin información',
    ocupacion           VARCHAR(120) COMMENT 'Última ocupación habitual — texto libre DANE',
    CONSTRAINT pk_persona PRIMARY KEY (id),
    CONSTRAINT fk_persona_pais FOREIGN KEY (id_pais_nacimiento) REFERENCES pais(id)
);

/* ======================================================
   9. defuncion
   El evento de muerte — dónde, cuándo, cómo
   Eliminado: tipo_defuncion (todos son no fetales)
====================================================== */
CREATE TABLE defuncion (
    id                       INT         NOT NULL AUTO_INCREMENT,
    id_persona               INT         NOT NULL,
    id_tiempo                INT         NOT NULL,
    id_municipio_ocurrencia  VARCHAR(10) NOT NULL,
    id_municipio_residencia  VARCHAR(10),
    area_defuncion           TINYINT     COMMENT '1=Cabecera municipal, 2=Centro poblado, 3=Rural disperso, 9=Sin información',
    area_residencia          TINYINT     COMMENT '1=Cabecera municipal, 2=Centro poblado, 3=Rural disperso, 9=Sin información',
    sitio_defuncion          TINYINT     COMMENT '1=Hospital/clínica, 2=Centro/puesto de salud, 3=Casa/domicilio, 4=Lugar de trabajo, 5=Vía pública, 6=Otro, 9=Sin información',
    probable_manera_muerte   TINYINT     COMMENT '0=Natural (Enfermedad), 1=Homicidio, 2=Accidente, 3=Pendiente investigación, 4=Suicidio, 5=No se pudo determinar, 6=Desconocido, 8=Intervención legal, 9=Guerra',
    ocupacion_causa_muerte   TINYINT     COMMENT '1=Sí, 2=No, 9=Sin información',
    tipo_accidente_laboral   TINYINT     COMMENT '1=Accidente de trabajo, 2=Enfermedad profesional, 9=Sin información',
    CONSTRAINT pk_defuncion PRIMARY KEY (id),
    CONSTRAINT fk_defuncion_persona    FOREIGN KEY (id_persona)              REFERENCES persona(id),
    CONSTRAINT fk_defuncion_tiempo     FOREIGN KEY (id_tiempo)               REFERENCES tiempo(id),
    CONSTRAINT fk_defuncion_mun_ocurr  FOREIGN KEY (id_municipio_ocurrencia) REFERENCES municipio(id),
    CONSTRAINT fk_defuncion_mun_res    FOREIGN KEY (id_municipio_residencia) REFERENCES municipio(id)
);

/* ======================================================
   10. causa_defuncion
   Diagnóstico — por qué murió
====================================================== */
CREATE TABLE causa_defuncion (
    id                INT         NOT NULL AUTO_INCREMENT,
    id_defuncion      INT         NOT NULL,
    codigo_cie10      VARCHAR(10)          COMMENT 'C_BAS1 — código CIE-10 (ej: J44 EPOC, J45 Asma)',
    causa_ops_667     VARCHAR(10)          COMMENT 'CAUSA_667 — agrupación OPS Lista 6/67',
    causa_homologada  VARCHAR(10)          COMMENT 'CAU_HOMOL — Lista 105 Colombia',
    CONSTRAINT pk_causa_defuncion PRIMARY KEY (id),
    CONSTRAINT fk_causa_defuncion FOREIGN KEY (id_defuncion) REFERENCES defuncion(id)
);

