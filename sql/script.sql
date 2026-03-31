CREATE DATABASE mortalidad_calidad_aire;
USE mortalidad_calidad_aire;

-- ─────────────────────────────────────────
-- DIMENSIÓN: pais
-- ─────────────────────────────────────────
CREATE TABLE pais (
    id          VARCHAR(10)  NOT NULL,   -- Código M49 ONU
    nombre      VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);

-- ─────────────────────────────────────────
-- DIMENSIÓN: departamento
-- ─────────────────────────────────────────
CREATE TABLE departamento (
    id      CHAR(2)      NOT NULL,   -- Código DIVIPOLA 2 dígitos
    nombre  VARCHAR(100) NOT NULL,
    region  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id)
);

-- ─────────────────────────────────────────
-- DIMENSIÓN: municipio
-- ─────────────────────────────────────────
CREATE TABLE municipio (
    id               CHAR(5)       NOT NULL,   -- Código DIVIPOLA 5 dígitos
    id_departamento  CHAR(2)       NOT NULL,
    nombre           VARCHAR(100)  NOT NULL,
    poblacion        INT           NOT NULL,
    latitud          DECIMAL(9,6)  NOT NULL,
    longitud         DECIMAL(9,6)  NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_departamento) REFERENCES departamento(id)
);

-- ─────────────────────────────────────────
-- DIMENSIÓN: tiempo
-- ─────────────────────────────────────────
CREATE TABLE tiempo (
    id    INT NOT NULL AUTO_INCREMENT,
    anio  INT NOT NULL,
    mes   INT NOT NULL,
    PRIMARY KEY (id)
);

-- ─────────────────────────────────────────
-- DIMENSIÓN: diagnostico_cie10
-- ─────────────────────────────────────────
CREATE TABLE diagnostico_cie10 (
    id               VARCHAR(10)  NOT NULL,   -- Código CIE-10
    nombre           VARCHAR(200) NOT NULL,
    categoria        VARCHAR(100) NOT NULL,
    es_respiratorio  TINYINT(1)   NOT NULL,
    PRIMARY KEY (id)
);
-- Tablas de hechos (datos transaccionales):

-- ─────────────────────────────────────────
-- HECHO: persona
-- ─────────────────────────────────────────
CREATE TABLE persona (
    id                   BIGINT       NOT NULL,
    id_pais_nacimiento   VARCHAR(10),
    sexo                 TINYINT      NOT NULL,
    grupo_edad_1         TINYINT      NOT NULL,
    grupo_edad_2         TINYINT      NOT NULL,
    estado_civil         TINYINT      NOT NULL,
    nivel_educativo      TINYINT      NOT NULL,
    seguridad_social     TINYINT      NOT NULL,
    ocupacion            VARCHAR(200),
    PRIMARY KEY (id),
    FOREIGN KEY (id_pais_nacimiento) REFERENCES pais(id)
);

-- ─────────────────────────────────────────
-- HECHO: defuncion
-- ─────────────────────────────────────────
CREATE TABLE defuncion (
    id                        BIGINT      NOT NULL,
    id_persona                BIGINT      NOT NULL,
    id_tiempo                 INT         NOT NULL,
    id_municipio_ocurrencia   CHAR(5),
    id_municipio_residencia   CHAR(5),
    area_defuncion            TINYINT     NOT NULL,
    area_residencia           FLOAT,
    sitio_defuncion           TINYINT     NOT NULL,
    probable_manera_muerte    FLOAT,
    ocupacion_causa_muerte    FLOAT,
    tipo_accidente_laboral    TINYINT     NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_persona)              REFERENCES persona(id),
    FOREIGN KEY (id_tiempo)               REFERENCES tiempo(id),
    FOREIGN KEY (id_municipio_ocurrencia) REFERENCES municipio(id),
    FOREIGN KEY (id_municipio_residencia) REFERENCES municipio(id)
);

-- ─────────────────────────────────────────
-- HECHO: causa_defuncion
-- ─────────────────────────────────────────
CREATE TABLE causa_defuncion (
    id             BIGINT      NOT NULL,
    id_defuncion   BIGINT      NOT NULL,
    codigo_cie10   VARCHAR(10) NOT NULL,
    causa_ops_667  VARCHAR(10) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_defuncion) REFERENCES defuncion(id)
);

-- ─────────────────────────────────────────
-- HECHO: defuncion_diagnostico
-- ─────────────────────────────────────────
CREATE TABLE defuncion_diagnostico (
    id               BIGINT     NOT NULL AUTO_INCREMENT,
    id_defuncion     BIGINT     NOT NULL,
    id_diagnostico   VARCHAR(10) NOT NULL,
    es_causa_basica  TINYINT(1) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_defuncion)   REFERENCES defuncion(id),
    FOREIGN KEY (id_diagnostico) REFERENCES diagnostico_cie10(id)
);

-- ─────────────────────────────────────────
-- HECHO: estacion_monitoreo
-- ─────────────────────────────────────────
CREATE TABLE estacion_monitoreo (
    id                 INT          NOT NULL AUTO_INCREMENT,
    id_municipio       CHAR(5)      NOT NULL,
    nombre             VARCHAR(100) NOT NULL,
    latitud            DECIMAL(9,6) NOT NULL,
    longitud           DECIMAL(9,6) NOT NULL,
    altitud            FLOAT        NOT NULL,
    entidad_operadora  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_municipio) REFERENCES municipio(id)
);

-- ─────────────────────────────────────────
-- HECHO: medicion_calidad_aire
-- ─────────────────────────────────────────
CREATE TABLE medicion_calidad_aire (
    id           INT     NOT NULL AUTO_INCREMENT,
    id_estacion  INT     NOT NULL,
    id_tiempo    INT     NOT NULL,
    pm25         FLOAT   NOT NULL,
    pm10         FLOAT   NOT NULL,
    no2          FLOAT   NOT NULL,
    so2          FLOAT   NOT NULL,
    co           FLOAT   NOT NULL,
    o3           FLOAT   NOT NULL,
    temperatura  FLOAT   NOT NULL,
    humedad      FLOAT   NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_estacion) REFERENCES estacion_monitoreo(id),
    FOREIGN KEY (id_tiempo)   REFERENCES tiempo(id)
);

-- ─────────────────────────────────────────
-- HECHO: indice_calidad_aire
-- ─────────────────────────────────────────
CREATE TABLE indice_calidad_aire (
    id            INT        NOT NULL AUTO_INCREMENT,
    id_medicion   INT        NOT NULL,
    id_estacion   INT        NOT NULL,
    id_tiempo     INT        NOT NULL,
    ica_pm25      FLOAT      NOT NULL,
    ica_pm10      FLOAT      NOT NULL,
    ica_no2       FLOAT      NOT NULL,
    ica_so2       FLOAT      NOT NULL,
    ica_co        FLOAT      NOT NULL,
    ica_o3        FLOAT      NOT NULL,
    ica_general   FLOAT      NOT NULL,
    nivel_riesgo  VARCHAR(40) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_medicion)  REFERENCES medicion_calidad_aire(id),
    FOREIGN KEY (id_estacion)  REFERENCES estacion_monitoreo(id),
    FOREIGN KEY (id_tiempo)    REFERENCES tiempo(id)
);

-- ─────────────────────────────────────────
-- HECHO: tasa_mortalidad
-- ─────────────────────────────────────────
CREATE TABLE tasa_mortalidad (
    id                INT          NOT NULL AUTO_INCREMENT,
    id_tiempo         INT          NOT NULL,
    nivel_geografico  VARCHAR(20)  NOT NULL,   -- 'municipio' o 'departamento'
    id_geografia      VARCHAR(10)  NOT NULL,   -- Código DIVIPOLA
    tipo_tasa         VARCHAR(10)  NOT NULL,   -- TMG, TMCE, TMAE, AVPP
    causa             VARCHAR(20)  NOT NULL,   -- 'TODAS' o 'RESPIRATORIA'
    valor             DOUBLE       NOT NULL,
    poblacion_base    INT          NOT NULL,
    total_muertes     INT          NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (id_tiempo) REFERENCES tiempo(id)
);

-- Generacion de insertos (valores dummy)
-- ─────────────────────────────────────────
-- 1. DIMENSIÓN: pais 
-- ─────────────────────────────────────────
INSERT INTO pais (id, nombre) VALUES
('170', 'Colombia'),
('840', 'Estados Unidos'),
('724', 'España'),
('076', 'Brasil'),
('858', 'Uruguay'),
('860', 'Uzbekistán'),
('862', 'Venezuela (República Bolivariana de)'),
('704', 'Viet Nam'),
('887', 'Yemen'),
('894', 'Zambia'),
('716', 'Zimbabwe'),
('004', 'Afganistán'),
('008', 'Albania'),
('012', 'Argelia'),
('020', 'Andorra'),
('024', 'Angola'),
('660', 'Anguila'),
('010', 'Antártida'),
('028', 'Antigua y Barbuda'),
('032', 'Argentina'),
('031', 'Azerbaiyán'),
('044', 'Bahamas'),
('048', 'Bahréin'),
('050', 'Bangladesh'),
('052', 'Barbados'),
('056', 'Bélgica'),
('084', 'Belice'),
('204', 'Benin'),
('250', 'Francia'),
('276', 'Alemania'),
('156', 'China'),
('356', 'India'),
('360', 'Indonesia'),
('392', 'Japón'),
('410', 'República de Corea (Corea del Sur)'),
('484', 'México');

-- ─────────────────────────────────────────
-- 2. DIMENSIÓN: departamento
-- ─────────────────────────────────────────
INSERT INTO departamento (id, nombre, region) VALUES
('05', 'ANTIOQUIA', 'Región Eje Cafetero y Antioquia'), ('08', 'ATLÁNTICO', 'Región Caribe'),
('11', 'BOGOTÁ, D. C.', 'Región Central'), ('13', 'BOLÍVAR', 'Región Caribe'),
('15', 'BOYACÁ', 'Región Central'), ('17', 'CALDAS', 'Región Eje Cafetero y Antioquia'),
('18', 'CAQUETÁ', 'Región Amazonía'), ('19', 'CAUCA', 'Región Pacífica'),
('20', 'CESAR', 'Región Caribe'), ('23', 'CÓRDOBA', 'Región Caribe'),
('25', 'CUNDINAMARCA', 'Región Central'), ('27', 'CHOCÓ', 'Región Pacífica'),
('41', 'HUILA', 'Región Central'), ('44', 'LA GUAJIRA', 'Región Caribe'),
('47', 'MAGDALENA', 'Región Caribe'), ('50', 'META', 'Región Llanos / Orinoquía'),
('52', 'NARIÑO', 'Región Pacífica'), ('54', 'NORTE DE SANTANDER', 'Región Central'),
('63', 'QUINDÍO', 'Región Eje Cafetero y Antioquia'), ('66', 'RISARALDA', 'Región Eje Cafetero y Antioquia'),
('68', 'SANTANDER', 'Región Central'), ('70', 'SUCRE', 'Región Caribe'),
('73', 'TOLIMA', 'Región Central'), ('76', 'VALLE DEL CAUCA', 'Región Pacífica'),
('81', 'ARAUCA', 'Región Llanos / Orinoquía'), ('85', 'CASANARE', 'Región Llanos / Orinoquía'),
('86', 'PUTUMAYO', 'Región Amazonía'), ('88', 'ARCHIPIÉLAGO DE SAN ANDRÉS', 'Región Caribe'),
('91', 'AMAZONAS', 'Región Amazonía'), ('94', 'GUAINÍA', 'Región Amazonía');

-- ─────────────────────────────────────────
-- 3. DIMENSIÓN: municipio
-- ─────────────────────────────────────────
INSERT INTO municipio (id, id_departamento, nombre, poblacion, latitud, longitud) VALUES
('05001', '05', 'Medellín', 2533424, 6.2442, -75.5812), ('08001', '08', 'Barranquilla', 1274250, 10.9685, -74.7813),
('11001', '11', 'Bogotá D.C.', 7743955, 4.7110, -74.0721), ('13001', '13', 'Cartagena', 1028736, 10.3910, -75.4794),
('15001', '15', 'Tunja', 180578, 5.5353, -73.3678), ('17001', '17', 'Manizales', 446160, 5.0703, -75.5138),
('18001', '18', 'Florencia', 173011, 1.6144, -75.6062), ('19001', '19', 'Popayán', 318059, 2.4382, -76.6132),
('20001', '20', 'Valledupar', 532956, 10.4631, -73.2532), ('23001', '23', 'Montería', 505334, 8.7480, -75.8814),
('25001', '25', 'Agua de Dios', 11211, 4.3750, -74.6710), ('27001', '27', 'Quibdó', 130825, 5.6947, -76.6611),
('41001', '41', 'Neiva', 364408, 2.9273, -75.2819), ('44001', '44', 'Riohacha', 300445, 11.5444, -72.9072),
('47001', '47', 'Santa Marta', 539000, 11.2408, -74.1990), ('50001', '50', 'Villavicencio', 545302, 4.1420, -73.6266),
('52001', '52', 'Pasto', 392930, 1.2136, -77.2811), ('54001', '54', 'Cúcuta', 777106, 7.8939, -72.5078),
('63001', '63', 'Armenia', 304314, 4.5339, -75.6811), ('66001', '66', 'Pereira', 477027, 4.8087, -75.6906),
('68001', '68', 'Bucaramanga', 608102, 7.1193, -73.1227), ('70001', '70', 'Sincelejo', 290940, 9.3047, -75.3978),
('73001', '73', 'Ibagué', 541101, 4.4389, -75.2322), ('76001', '76', 'Cali', 2252616, 3.4516, -76.5320),
('81001', '81', 'Arauca', 93855, 7.0847, -70.7591), ('85001', '85', 'Yopal', 177435, 5.3378, -72.3959),
('86001', '86', 'Mocoa', 59620, 1.1478, -76.6479), ('88001', '88', 'San Andrés', 58245, 12.5847, -81.7006),
('91001', '91', 'Leticia', 49764, -4.2153, -69.9406), ('94001', '94', 'Inírida', 33502, 3.8653, -67.9239);

-- ─────────────────────────────────────────
-- 4. DIMENSIÓN: tiempo
-- ─────────────────────────────────────────
INSERT INTO tiempo (id, anio, mes) VALUES
(1, 2024, 1), (2, 2024, 2), (3, 2024, 3), (4, 2024, 4), (5, 2024, 5), (6, 2024, 6),
(7, 2024, 7), (8, 2024, 8), (9, 2024, 9), (10, 2024, 10), (11, 2024, 11), (12, 2024, 12),
(13, 2024, 1), (14, 2024, 2), (15, 2024, 3), (16, 2024, 4), (17, 2024, 5), (18, 2024, 6),
(19, 2024, 7), (20, 2024, 8), (21, 2024, 9), (22, 2024, 10), (23, 2024, 11), (24, 2024, 12),
(25, 2024, 1), (26, 2024, 2), (27, 2024, 3), (28, 2024, 4), (29, 2024, 5), (30, 2024, 6);

-- ─────────────────────────────────────────
-- 5. DIMENSIÓN: diagnostico_cie10
-- ─────────────────────────────────────────
INSERT INTO diagnostico_cie10 (id, nombre, categoria, es_respiratorio) VALUES
('J00', 'Rinofaringitis aguda (resfriado común)', 'Infecciones agudas vías respiratorias superiores', 1),
('J01', 'Sinusitis aguda', 'Infecciones agudas vías respiratorias superiores', 1),
('J02', 'Faringitis aguda', 'Infecciones agudas vías respiratorias superiores', 1),
('J03', 'Amigdalitis aguda', 'Infecciones agudas vías respiratorias superiores', 1),
('J04', 'Laringitis y traqueítis agudas', 'Infecciones agudas vías respiratorias superiores', 1),
('J09', 'Influenza debida a virus de la gripe', 'Influenza y neumonía', 1),
('J10', 'Influenza debida a otro virus de la gripe id', 'Influenza y neumonía', 1),
('J12', 'Neumonía viral no clasificada en otra parte', 'Influenza y neumonía', 1),
('J18', 'Neumonía organismo no especificado', 'Influenza y neumonía', 1),
('J20', 'Bronquitis aguda', 'Infecciones agudas vías respiratorias inferiores', 1),
('J21', 'Bronquiolitis aguda', 'Infecciones agudas vías respiratorias inferiores', 1),
('J30', 'Rinitis alérgica y vasomotora', 'Otras enfermedades vías respiratorias superiores', 1),
('J32', 'Sinusitis crónica', 'Otras enfermedades vías respiratorias superiores', 1),
('J40', 'Bronquitis no especificada como aguda o crónica', 'Enfermedades crónicas vías respiratorias inferiores', 1),
('J43', 'Enfisema pulmonar', 'Enfermedades crónicas vías respiratorias inferiores', 1),
('J44', 'Enfermedad pulmonar obstructiva crónica (EPOC)', 'Enfermedades crónicas vías respiratorias inferiores', 1),
('J45', 'Asma', 'Enfermedades crónicas vías respiratorias inferiores', 1),
('J60', 'Neumoconiosis del minero del carbón', 'Enfermedades por agentes externos', 1),
('J68', 'Afecciones respiratorias debidas a inhalación', 'Enfermedades por agentes externos', 1),
('J81', 'Edema pulmonar', 'Otras enfermedades respiratorias', 1),
('J96', 'Insuficiencia respiratoria no clasificada', 'Otras enfermedades respiratorias', 1),
('I219', 'Infarto agudo de miocardio no especificado', 'Enfermedades cardiovasculares', 0),
('I25', 'Enfermedad isquémica crónica del corazón', 'Enfermedades cardiovasculares', 0),
('I64', 'Accidente vascular encefálico (ACV)', 'Enfermedades cardiovasculares', 0),
('C34', 'Tumor maligno de bronquios y pulmón', 'Cánceres asociados a contaminación del aire', 0),
('P22', 'Dificultad respiratoria del recién nacido', 'Afecciones perinatales respiratorias', 1),
('J440', 'EPOC con infección respiratoria aguda', 'Enfermedades crónicas vías respiratorias inferiores', 1),
('J449', 'EPOC no especificada', 'Enfermedades crónicas vías respiratorias inferiores', 1),
('J189', 'Neumonía no especificada', 'Influenza y neumonía', 1),
('I110', 'Enfermedad cardíaca hipertensiva con insufic', 'Enfermedades cardiovasculares', 0);

-- ─────────────────────────────────────────
-- 6. HECHO: persona
-- ─────────────────────────────────────────
-- Vaciamos para evitar errores de duplicado (ID 10001, etc)
SET FOREIGN_KEY_CHECKS = 0; 
TRUNCATE TABLE persona; 
SET FOREIGN_KEY_CHECKS = 1;

-- Insertamos los 30 registros limpios
INSERT INTO persona (id, id_pais_nacimiento, sexo, grupo_edad_1, grupo_edad_2, estado_civil, nivel_educativo, seguridad_social, ocupacion) VALUES 
(10001, '170', 1, 22, 6, 6, 3, 1, 'Agricultor'),
(10002, '170', 2, 26, 6, 2, 4, 2, 'Comerciante'),
(10003, '170', 1, 20, 5, 1, 5, 1, 'Docente'),
(10004, '170', 2, 22, 6, 9, 2, 3, 'Ama de casa'),
(10005, '170', 1, 15, 4, 1, 6, 1, 'Estudiante'),
(10006, '170', 1, 30, 8, 4, 6, 1, 'Ingeniero Industrial'),
(10007, '170', 2, 24, 6, 6, 3, 3, 'Enfermera Auxiliar'),
(10008, '170', 1, 29, 7, 4, 5, 1, 'Mecánico Automotriz'),
(10009, '170', 2, 25, 6, 2, 4, 2, 'Contadora Pública'),
(10010, '170', 1, 22, 6, 1, 3, 1, 'Conductor de Carga'),
(10011, '170', 2, 27, 7, 6, 6, 2, 'Médico General'),
(10012, '170', 1, 21, 5, 1, 2, 3, 'Panadero Artesanal'),
(10013, '170', 2, 30, 8, 2, 5, 1, 'Administradora de Empresas'),
(10014, '170', 1, 26, 6, 3, 4, 2, 'Plomero certificado'),
(10015, '170', 1, 28, 7, 6, 3, 2, 'Pintor de Interiores'),
(10016, '170', 2, 20, 5, 2, 4, 3, 'Asistente Administrativo'),
(10017, '170', 1, 23, 6, 1, 4, 1, 'Vigilante de Seguridad'),
(10018, '170', 2, 31, 8, 2, 5, 2, 'Secretaria Ejecutiva'),
(10019, '170', 1, 19, 4, 1, 2, 3, 'Obrero de Construcción'),
(10020, '170', 2, 28, 7, 6, 6, 1, 'Abogada Litigante'),
(10021, '170', 1, 24, 6, 4, 5, 2, 'Técnico Electricista'),
(10022, '170', 2, 22, 6, 2, 3, 1, 'Cajera de Supermercado'),
(10023, '170', 1, 27, 7, 1, 4, 1, 'Chef de Cocina'),
(10024, '170', 2, 25, 6, 6, 5, 2, 'Psicóloga Clínica'),
(10025, '170', 1, 21, 5, 3, 2, 3, 'Mensajero Motorizado'),
(10026, '170', 2, 29, 7, 2, 6, 1, 'Arquitecta Proyectista'),
(10027, '170', 1, 30, 8, 6, 4, 2, 'Operario de Planta'),
(10028, '032', 2, 23, 6, 1, 6, 1, 'Bióloga Investigadora'),
(10029, '152', 1, 28, 7, 6, 3, 2, 'Periodista Digital'),
(10030, '484', 2, 20, 5, 2, 4, 3, 'Diseñadora Gráfica');

-- ─────────────────────────────────────────
-- 7. HECHO: defuncion 
-- ─────────────────────────────────────────
INSERT INTO defuncion (id, id_persona, id_tiempo, id_municipio_ocurrencia, id_municipio_residencia, area_defuncion, area_residencia, sitio_defuncion, probable_manera_muerte, ocupacion_causa_muerte, tipo_accidente_laboral) VALUES 
(10001, 10001, 1, '05001', '05001', 1, 1.0, 1, 0, NULL, 2), 
(10002, 10002, 2, '08001', '08001', 1, 1.0, 2, 0, NULL, 2), 
(10003, 10003, 3, '11001', '11001', 1, 1.0, 1, 0, NULL, 2), 
(10004, 10004, 4, '13001', '13001', 2, 2.0, 3, 0, NULL, 2), 
(10005, 10005, 5, '15001', '15001', 1, 1.0, 1, 0, NULL, 2), 
(10006, 10006, 6, '17001', '17001', 1, 1.0, 1, 0, NULL, 2), 
(10007, 10007, 7, '18001', '18001', 3, 3.0, 4, 0, NULL, 2), 
(10008, 10008, 8, '19001', '19001', 1, 1.0, 1, 0, NULL, 2), 
(10009, 10009, 9, '20001', '20001', 1, 1.0, 2, 0, NULL, 2), 
(10010, 10010, 10, '23001', '23001', 2, 2.0, 1, 0, NULL, 2), 
(10011, 10011, 11, '25001', '25001', 1, 1.0, 1, 0, NULL, 2), 
(10012, 10012, 12, '27001', '27001', 1, 1.0, 3, 0, NULL, 2), 
(10013, 10013, 13, '41001', '41001', 1, 1.0, 1, 0, NULL, 2), 
(10014, 10014, 14, '44001', '44001', 3, 3.0, 4, 0, NULL, 2), 
(10015, 10015, 15, '47001', '47001', 1, 1.0, 1, 0, NULL, 2), 
(10016, 10016, 16, '50001', '50001', 1, 1.0, 2, 0, NULL, 2), 
(10017, 10017, 17, '52001', '52001', 2, 2.0, 1, 0, NULL, 2), 
(10018, 10018, 18, '54001', '54001', 1, 1.0, 1, 0, NULL, 2), 
(10019, 10019, 19, '63001', '63001', 1, 1.0, 3, 0, NULL, 2), 
(10020, 10020, 20, '66001', '66001', 1, 1.0, 1, 0, NULL, 2), 
(10021, 10021, 21, '68001', '68001', 3, 3.0, 4, 0, NULL, 2), 
(10022, 10022, 22, '70001', '70001', 1, 1.0, 1, 0, NULL, 2), 
(10023, 10023, 23, '73001', '73001', 1, 1.0, 2, 0, NULL, 2), 
(10024, 10024, 24, '76001', '76001', 2, 2.0, 1, 0, NULL, 2), 
(10025, 10025, 25, '81001', '81001', 1, 1.0, 1, 0, NULL, 2), 
(10026, 10026, 26, '85001', '85001', 1, 1.0, 3, 0, NULL, 2), 
(10027, 10027, 27, '86001', '86001', 3, 3.0, 4, 0, NULL, 2), 
(10028, 10028, 28, '88001', '88001', 1, 1.0, 1, 0, NULL, 2), 
(10029, 10029, 29, '91001', '91001', 1, 1.0, 2, 0, NULL, 2), 
(10030, 10030, 30, '94001', '94001', 2, 2.0, 1, 0, NULL, 2);

-- ─────────────────────────────────────────
-- 8. ESTACION DE MONITOREO 
-- ─────────────────────────────────────────
INSERT INTO estacion_monitoreo (id, id_municipio, nombre, latitud, longitud, altitud, entidad_operadora) VALUES
(1, '08001', 'Estación Barranquilla Norte', 11.0041, -74.8070, 18.0, 'IDEAM'), (2, '08001', 'Estación Barranquilla Sur', 10.9878, -74.7893, 15.0, 'IDEAM'),
(3, '08001', 'Estación Barranquilla Puerto', 10.9605, -74.7965, 5.0, 'DAMA Atlántico'), (4, '13001', 'Estación Cartagena Centro', 10.4231, -75.5482, 3.0, 'EPA Cartagena'),
(5, '13001', 'Estación Cartagena Zona Industrial', 10.3752, -75.5011, 2.0, 'IDEAM'), (6, '47001', 'Estación Santa Marta Costera', 11.2408, -74.1990, 5.0, 'CORPAMAG'),
(7, '44001', 'Estación Riohacha Guajira', 11.5444, -72.9072, 2.0, 'CORPOGUAJIRA'), (8, '23001', 'Estación Montería Sinú', 8.7480, -75.8814, 18.0, 'CVS'),
(9, '70001', 'Estación Sincelejo Sabanas', 9.3047, -75.3978, 213.0, 'CARSUCRE'), (10, '20001', 'Estación Valledupar Central', 10.4631, -73.2532, 168.0, 'CORPOCESAR'),
(11, '88001', 'Estación San Andrés Isla', 12.5847, -81.7006, 2.0, 'CORALINA'), (12, '05001', 'Estación Medellín Área Metro', 6.2442, -75.5812, 1495.0, 'SIATA'),
(13, '05001', 'Estación Medellín Poblado', 6.2081, -75.5684, 1540.0, 'SIATA'), (14, '05001', 'Estación Medellín Bello', 6.3373, -75.5579, 1450.0, 'SIATA'),
(15, '05001', 'Estación Medellín Itagüí', 6.1759, -75.6012, 1550.0, 'SIATA'), (16, '17001', 'Estación Manizales Nevado Ruiz', 5.0703, -75.5138, 2160.0, 'CORPOCALDAS'),
(17, '63001', 'Estación Armenia Centro', 4.5339, -75.6811, 1551.0, 'CRQ'), (18, '66001', 'Estación Pereira Urbana', 4.8087, -75.6906, 1411.0, 'CARDER'),
(19, '76001', 'Estación Cali Sur', 3.3951, -76.5361, 995.0, 'DAGMA'), (20, '76001', 'Estación Cali Norte', 3.4516, -76.5320, 1010.0, 'DAGMA'),
(21, '27001', 'Estación Quibdó Río Atrato', 5.6947, -76.6611, 43.0, 'CODECHOCÓ'), (22, '52001', 'Estación Pasto Volcán Galeras', 1.2136, -77.2811, 2527.0, 'CORPONARIÑO'),
(23, '19001', 'Estación Popayán Central', 2.4382, -76.6132, 1760.0, 'CRC'), (24, '11001', 'Estación Bogotá Kennedy', 4.6300, -74.1500, 2600.0, 'RMCAB'),
(25, '11001', 'Estación Bogotá Usaquén', 4.7000, -74.0300, 2600.0, 'RMCAB'), (26, '68001', 'Estación Bucaramanga Norte', 7.1193, -73.1227, 959.0, 'CDMB'),
(27, '54001', 'Estación Cúcuta Central', 7.8939, -72.5078, 320.0, 'CORPONOR'), (28, '73001', 'Estación Ibagué Centro', 4.4389, -75.2322, 1285.0, 'CORTOLIMA'),
(29, '50001', 'Estación Villavicencio Llanos', 4.1420, -73.6266, 467.0, 'CORMACARENA'), (30, '91001', 'Estación Leticia Amazónica', -4.2153, -69.9406, 82.0, 'CORPOAMAZONIA');

-- ─────────────────────────────────────────
-- 9. MEDICION CALIDAD AIRE
-- ─────────────────────────────────────────
INSERT INTO medicion_calidad_aire (id, id_estacion, id_tiempo, pm25, pm10, no2, so2, co, o3, temperatura, humedad) VALUES
(1, 1, 1, 60.76, 35.68, 63.48, 18.31, 4.51, 21.00, 21.4, 65.2), (2, 2, 2, 15.00, 101.12, 9.23, 21.94, 9.39, 10.09, 34.8, 80.1),
(3, 3, 3, 47.82, 10.99, 6.73, 16.22, 4.06, 15.13, 34.3, 75.0), (4, 4, 4, 11.34, 96.57, 33.68, 29.51, 4.72, 104.59, 27.0, 55.4),
(5, 5, 5, 5.93, 141.91, 47.25, 12.18, 0.26, 35.40, 16.0, 88.3), (6, 6, 6, 25.40, 55.20, 22.10, 5.40, 2.10, 45.60, 28.5, 70.1),
(7, 7, 7, 30.10, 60.50, 25.40, 6.20, 3.50, 50.20, 29.0, 68.4), (8, 8, 8, 45.60, 80.30, 40.10, 15.50, 5.20, 65.40, 32.1, 85.0),
(9, 9, 9, 12.50, 30.40, 15.60, 3.20, 1.50, 25.30, 25.4, 60.2), (10, 10, 10, 18.40, 40.20, 20.50, 4.80, 2.40, 35.80, 26.8, 62.5),
(11, 11, 11, 5.20, 15.60, 8.40, 1.50, 0.80, 15.20, 28.0, 75.6), (12, 12, 12, 55.40, 95.60, 60.20, 25.40, 8.50, 85.40, 22.5, 55.4),
(13, 13, 13, 48.20, 85.40, 55.30, 22.10, 7.40, 75.20, 23.1, 58.2), (14, 14, 14, 52.10, 90.20, 58.40, 24.50, 8.10, 80.50, 22.8, 56.5),
(15, 15, 15, 45.80, 82.50, 52.10, 20.80, 6.90, 72.40, 23.5, 59.8), (16, 16, 16, 22.50, 45.60, 18.50, 8.40, 2.50, 35.60, 18.5, 75.2),
(17, 17, 17, 35.40, 65.80, 30.20, 12.50, 4.50, 55.20, 20.5, 70.5), (18, 18, 18, 28.50, 55.40, 25.60, 10.20, 3.80, 45.80, 21.2, 68.4),
(19, 19, 19, 42.50, 75.60, 45.80, 18.50, 6.50, 68.50, 28.5, 65.2), (20, 20, 20, 38.40, 70.20, 42.50, 16.40, 5.80, 62.40, 29.1, 64.5),
(21, 21, 21, 15.60, 35.80, 12.50, 4.50, 1.80, 25.60, 26.5, 85.4), (22, 22, 22, 10.50, 25.40, 8.50, 2.50, 1.20, 18.50, 15.4, 88.5),
(23, 23, 23, 20.50, 45.80, 15.60, 6.50, 2.40, 35.80, 18.5, 78.5), (24, 24, 24, 65.80, 110.50, 75.40, 28.50, 9.50, 95.60, 16.5, 55.8),
(25, 25, 25, 60.20, 105.40, 70.50, 26.80, 8.80, 90.20, 17.2, 54.5), (26, 26, 26, 35.80, 68.50, 32.50, 14.50, 4.80, 58.40, 24.5, 62.5),
(27, 27, 27, 48.50, 85.60, 45.80, 18.50, 6.50, 75.60, 28.5, 58.4), (28, 28, 28, 25.60, 50.40, 22.50, 8.50, 3.20, 42.50, 22.5, 68.5),
(29, 29, 29, 18.50, 40.50, 15.80, 5.50, 2.10, 30.50, 28.5, 75.4), (30, 30, 30, 8.50, 22.40, 6.50, 2.10, 0.90, 15.80, 32.5, 85.6);

-- ─────────────────────────────────────────
-- 10. ÍNDICE CALIDAD AIRE [cite: 475]
-- ─────────────────────────────────────────
INSERT INTO indice_calidad_aire (id, id_medicion, id_estacion, id_tiempo, ica_pm25, ica_pm10, ica_no2, ica_so2, ica_co, ica_o3, ica_general, nivel_riesgo) VALUES
(1, 1, 1, 1, 153.92, 33.04, 61.10, 26.16, 51.50, 19.44, 153.92, 'Dañino'), (2, 2, 2, 2, 56.71, 73.83, 8.71, 31.34, 99.40, 9.34, 99.40, 'Aceptable'),
(3, 3, 3, 3, 130.35, 10.18, 6.35, 23.17, 46.10, 14.01, 130.35, 'Dañino para grupos sensibles'), (4, 4, 4, 4, 47.25, 71.58, 31.77, 42.16, 53.70, 148.80, 148.80, 'Dañino para grupos sensibles'),
(5, 5, 5, 5, 24.71, 94.02, 44.58, 17.40, 2.95, 32.78, 94.02, 'Aceptable'), (6, 6, 6, 6, 77.00, 51.10, 20.80, 7.70, 23.80, 42.20, 77.00, 'Aceptable'),
(7, 7, 7, 7, 86.50, 55.50, 24.00, 8.80, 39.70, 46.40, 86.50, 'Aceptable'), (8, 8, 8, 8, 122.50, 63.40, 37.80, 22.10, 58.50, 60.50, 122.50, 'Dañino para grupos sensibles'),
(9, 9, 9, 9, 52.00, 28.10, 14.70, 4.50, 17.00, 23.40, 52.00, 'Aceptable'), (10, 10, 10, 10, 63.50, 37.20, 19.30, 6.80, 27.20, 33.10, 63.50, 'Aceptable'),
(11, 11, 11, 11, 21.60, 14.40, 7.90, 2.10, 9.00, 14.00, 21.60, 'Bueno'), (12, 12, 12, 12, 151.00, 71.00, 56.80, 36.20, 91.00, 101.50, 151.00, 'Dañino'),
(13, 13, 13, 13, 128.50, 65.90, 52.10, 31.50, 80.50, 106.00, 128.50, 'Dañino para grupos sensibles'), (14, 14, 14, 14, 136.00, 68.30, 55.10, 35.00, 87.00, 122.50, 136.00, 'Dañino para grupos sensibles'),
(15, 15, 15, 15, 123.00, 64.50, 49.10, 29.70, 75.50, 102.00, 123.00, 'Dañino para grupos sensibles'), (16, 16, 16, 16, 71.40, 42.20, 17.40, 12.00, 28.40, 32.90, 71.40, 'Aceptable'),
(17, 17, 17, 17, 96.50, 56.00, 28.50, 17.80, 51.50, 51.10, 96.50, 'Aceptable'), (18, 18, 18, 18, 83.20, 51.30, 24.10, 14.50, 43.10, 42.40, 83.20, 'Aceptable'),
(19, 19, 19, 19, 115.00, 61.00, 43.20, 26.40, 71.00, 92.50, 115.00, 'Dañino para grupos sensibles'), (20, 20, 20, 20, 104.50, 58.40, 40.10, 23.40, 64.00, 73.00, 104.50, 'Dañino para grupos sensibles'),
(21, 21, 21, 21, 58.00, 33.10, 11.80, 6.40, 20.40, 23.70, 58.00, 'Aceptable'), (22, 22, 22, 22, 43.70, 23.50, 8.00, 3.50, 13.60, 17.10, 43.70, 'Bueno'),
(23, 23, 23, 23, 67.50, 42.40, 14.70, 9.20, 27.20, 33.10, 67.50, 'Aceptable'), (24, 24, 24, 24, 156.40, 78.40, 71.10, 40.70, 101.00, 126.00, 156.40, 'Dañino'),
(25, 25, 25, 25, 153.50, 75.80, 66.50, 38.20, 94.00, 110.00, 153.50, 'Dañino'), (26, 26, 26, 26, 97.40, 57.30, 30.60, 20.70, 54.50, 54.00, 97.40, 'Aceptable'),
(27, 27, 27, 27, 129.50, 66.00, 43.20, 26.40, 71.00, 115.00, 129.50, 'Dañino para grupos sensibles'), (28, 28, 28, 28, 77.40, 46.60, 21.20, 12.10, 36.30, 39.30, 77.40, 'Aceptable'),
(29, 29, 29, 29, 63.70, 37.50, 14.90, 7.80, 23.80, 28.20, 63.70, 'Aceptable'), (30, 30, 30, 30, 35.40, 20.70, 6.10, 3.00, 10.20, 14.60, 35.40, 'Bueno');

-- ─────────────────────────────────────────
-- 11. HECHO: causa_defuncion 
-- ─────────────────────────────────────────
INSERT INTO causa_defuncion (id, id_defuncion, codigo_cie10, causa_ops_667) VALUES
(1, 10001, 'I219', '303'), (2, 10002, 'J449', '213'),
(3, 10003, 'J189', '307'), (4, 10004, 'C34', '604'),
(5, 10005, 'J440', '604'), (6, 10006, 'I64', '305'),
(7, 10007, 'J20', '302'), (8, 10008, 'J12', '304'),
(9, 10009, 'J45', '215'), (10, 10010, 'I25', '303'),
(11, 10011, 'J60', '310'), (12, 10012, 'J81', '315'),
(13, 10013, 'P22', '405'), (14, 10014, 'I110', '301'),
(15, 10015, 'J09', '305'), (16, 10016, 'J30', '312'),
(17, 10017, 'J32', '312'), (18, 10018, 'J40', '313'),
(19, 10019, 'J43', '313'), (20, 10020, 'J68', '310'),
(21, 10021, 'J96', '315'), (22, 10022, 'J00', '300'),
(23, 10023, 'J01', '300'), (24, 10024, 'J02', '300'),
(25, 10025, 'J03', '300'), (26, 10026, 'J04', '300'),
(27, 10027, 'J10', '305'), (28, 10028, 'J18', '307'),
(29, 10029, 'J21', '302'), (30, 10030, 'C34', '200');

-- ─────────────────────────────────────────
-- 12. TABLA PUENTE: defuncion_diagnostico 
-- ─────────────────────────────────────────
INSERT INTO defuncion_diagnostico (id, id_defuncion, id_diagnostico, es_causa_basica) VALUES
(1, 10001, 'I219', 1), (2, 10002, 'J449', 1),
(3, 10003, 'J189', 1), (4, 10004, 'C34', 1),
(5, 10005, 'J440', 1), (6, 10006, 'I64', 1),
(7, 10007, 'J20', 1), (8, 10008, 'J12', 1),
(9, 10009, 'J45', 1), (10, 10010, 'I25', 1),
(11, 10011, 'J60', 1), (12, 10012, 'J81', 1),
(13, 10013, 'P22', 1), (14, 10014, 'I110', 1),
(15, 10015, 'J09', 1), (16, 10016, 'J30', 1),
(17, 10017, 'J32', 1), (18, 10018, 'J40', 1),
(19, 10019, 'J43', 1), (20, 10020, 'J68', 1),
(21, 10021, 'J96', 1), (22, 10022, 'J00', 1),
(23, 10023, 'J01', 1), (24, 10024, 'J02', 1),
(25, 10025, 'J03', 1), (26, 10026, 'J04', 1),
(27, 10027, 'J10', 1), (28, 10028, 'J18', 1),
(29, 10029, 'J21', 1), (30, 10030, 'C34', 1);

-- ─────────────────────────────────────────
-- 13. HECHO: tasa_mortalidad 
-- ─────────────────────────────────────────
INSERT INTO tasa_mortalidad (id, id_tiempo, nivel_geografico, id_geografia, tipo_tasa, causa, valor, poblacion_base, total_muertes) VALUES
(1, 1, 'municipio', '05001', 'TMG', 'TODAS', 65.4, 2533424, 1650), (2, 2, 'departamento', '08', 'TMCE', 'RESPIRATORIA', 15.2, 2800100, 425),
(3, 3, 'municipio', '11001', 'TMAE', 'TODAS', 58.9, 7743955, 4560), (4, 4, 'departamento', '13', 'TMG', 'TODAS', 60.1, 2200500, 1320),
(5, 5, 'municipio', '15001', 'TMCE', 'RESPIRATORIA', 18.5, 180578, 33), (6, 6, 'departamento', '17', 'TMG', 'TODAS', 646.9, 1050126, 6794),
(7, 7, 'municipio', '18001', 'TMAE', 'TODAS', 55.4, 173011, 95), (8, 8, 'departamento', '19', 'TMCE', 'RESPIRATORIA', 12.4, 1500200, 186),
(9, 9, 'municipio', '20001', 'TMG', 'TODAS', 50.2, 532956, 267), (10, 10, 'departamento', '23', 'TMAE', 'TODAS', 48.5, 1800400, 873),
(11, 11, 'municipio', '25001', 'TMCE', 'RESPIRATORIA', 10.1, 11211, 1), (12, 12, 'departamento', '27', 'TMG', 'TODAS', 45.6, 550000, 250),
(13, 13, 'municipio', '41001', 'TMAE', 'TODAS', 58.2, 364408, 212), (14, 14, 'departamento', '44', 'TMCE', 'RESPIRATORIA', 14.8, 1000500, 148),
(15, 15, 'municipio', '47001', 'TMG', 'TODAS', 62.1, 539000, 334), (16, 16, 'departamento', '50', 'TMAE', 'TODAS', 52.4, 1100200, 576),
(17, 17, 'municipio', '52001', 'TMCE', 'RESPIRATORIA', 16.5, 392930, 64), (18, 18, 'departamento', '54', 'TMG', 'TODAS', 58.3, 1600300, 932),
(19, 19, 'municipio', '63001', 'TMG', 'TODAS', 826.4, 304314, 2514), (20, 20, 'departamento', '66', 'TMG', 'TODAS', 800.4, 997930, 7987),
(21, 21, 'municipio', '68001', 'TMCE', 'RESPIRATORIA', 20.1, 608102, 122), (22, 22, 'departamento', '70', 'TMAE', 'TODAS', 49.5, 950000, 470),
(23, 23, 'municipio', '73001', 'TMG', 'TODAS', 656.5, 541101, 3552), (24, 24, 'departamento', '76', 'TMG', 'TODAS', 685.2, 4693432, 32159),
(25, 25, 'municipio', '81001', 'TMCE', 'RESPIRATORIA', 11.2, 93855, 10), (26, 26, 'departamento', '85', 'TMAE', 'TODAS', 50.1, 450000, 225),
(27, 27, 'municipio', '86001', 'TMG', 'TODAS', 45.2, 59620, 26), (28, 28, 'departamento', '88', 'TMCE', 'RESPIRATORIA', 13.5, 65000, 8),
(29, 29, 'municipio', '91001', 'TMAE', 'TODAS', 40.5, 49764, 20), (30, 30, 'departamento', '94', 'TMG', 'TODAS', 38.2, 55000, 21);

-- Consultas
-- =============================================================================
-- CONSULTAS ANALÍTICAS: CORRELACIÓN CALIDAD DEL AIRE Y MORTALIDAD
-- =============================================================================

-- 1. RANKING DE RIESGO AMBIENTAL Y MORTALIDAD POR MUNICIPIO
-- Objetivo: Identificar qué ciudades tienen el peor aire (PM2.5) y su tasa de mortalidad.
-- Incluye un semáforo de riesgo basado en el promedio de material particulado.

SELECT 
    m.nombre AS municipio,
    ROUND(AVG(med.pm25), 2) AS promedio_pm25,
    MAX(t.valor) AS tasa_mortalidad_g_max,
    CASE 
        WHEN AVG(med.pm25) > 50 THEN 'Zona de Alto Riesgo (Crítico)'
        WHEN AVG(med.pm25) BETWEEN 25 AND 50 THEN 'Zona de Riesgo Moderado'
        ELSE 'Zona Segura / Aceptable'
    END AS categoria_ambiental
FROM municipio m 
-- CAMBIO AQUÍ: Se usa m.id en lugar de m.codigo
JOIN estacion_monitoreo e ON m.id = e.id_municipio 
JOIN medicion_calidad_aire med ON e.id = med.id_estacion 
-- CAMBIO AQUÍ: Se usa m.id en lugar de m.codigo
JOIN tasa_mortalidad t ON m.id = t.id_geografia 
WHERE t.tipo_tasa = 'TMG' 
GROUP BY m.nombre 
ORDER BY promedio_pm25 DESC 
LIMIT 0, 1000;


-- 2. IMPACTO DEL RIESGO DEL AIRE EN DEFUNCIONES RESPIRATORIAS (J00-J99)
-- Objetivo: Cruzar el nivel de riesgo del ICA con la cantidad de muertes 
-- por enfermedades del sistema respiratorio.

SELECT 
    ica.nivel_riesgo,
    COUNT(cd.id) AS total_defunciones,
    COUNT(DISTINCT d.id_persona) AS pacientes_afectados,
    GROUP_CONCAT(DISTINCT cd.codigo_cie10 SEPARATOR ', ') AS diagnosticos_en_este_nivel
FROM indice_calidad_aire ica
JOIN defuncion d ON ica.id_tiempo = d.id_tiempo 
JOIN causa_defuncion cd ON d.id = cd.id_defuncion
WHERE cd.codigo_cie10 REGEXP '^J' -- Filtra códigos CIE-10 que inician con J (Respiratorios)
GROUP BY ica.nivel_riesgo
ORDER BY total_defunciones DESC;


-- 3. ANÁLISIS DE VULNERABILIDAD POR PAÍS DE ORIGEN
-- Objetivo: Determinar si la población nacional o extranjera fallece más 
-- en días donde el PM10 supera el promedio nacional.

SELECT 
    p.nombre AS pais_nacimiento,
    COUNT(d.id) AS total_muertes_registradas,
    ROUND(AVG(med.pm10), 2) AS exposicion_media_pm10
FROM persona per
JOIN pais p ON per.id_pais_nacimiento = p.id
JOIN defuncion d ON per.id = d.id_persona
JOIN medicion_calidad_aire med ON d.id_tiempo = med.id_tiempo
WHERE med.pm10 > (SELECT AVG(pm10) FROM medicion_calidad_aire)
GROUP BY p.nombre
ORDER BY total_muertes_registradas DESC;


-- 4. ANÁLISIS DE VULNERABILIDAD POR OCUPACIÓN Y CALIDAD DEL AIRE
-- Objetivo: Identificar qué ocupaciones presentan mayor frecuencia de decesos 
-- en condiciones de aire 'Dañino' o 'Muy Dañino'.

SELECT 
    p.ocupacion,
    ica.nivel_riesgo,
    COUNT(d.id) AS total_defunciones,
    ROUND(AVG(med.pm25), 2) AS promedio_exposicion_pm25,
    ROUND(AVG(med.humedad), 2) AS humedad_promedio
FROM persona p
JOIN defuncion d ON p.id = d.id_persona
JOIN medicion_calidad_aire med ON d.id_tiempo = med.id_tiempo
JOIN indice_calidad_aire ica ON med.id = ica.id_medicion
WHERE ica.nivel_riesgo IN ('Dañino', 'Dañino para grupos sensibles', 'Muy Dañino')
GROUP BY p.ocupacion, ica.nivel_riesgo
HAVING total_defunciones > 0
ORDER BY total_defunciones DESC, promedio_exposicion_pm25 DESC;

-- 5. RESUMEN DE CORRELACIÓN POR GRUPOS DE EDAD
-- Objetivo: Ver qué grupos de edad son más sensibles a la contaminación por Ozono (O3).

SELECT 
    p.grupo_edad_1 AS edad_especifica,
    COUNT(d.id) AS muertes,
    ROUND(AVG(med.o3), 2) AS nivel_o3_promedio
FROM persona p
JOIN defuncion d ON p.id = d.id_persona
JOIN medicion_calidad_aire med ON d.id_tiempo = med.id_tiempo
GROUP BY p.grupo_edad_1
ORDER BY muertes DESC;