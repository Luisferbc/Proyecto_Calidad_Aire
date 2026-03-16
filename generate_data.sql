/* ======================================================
   DATOS SINTÉTICOS
====================================================== */

-- -------------------------------------------------------
-- municipio (código DANE real)
-- -------------------------------------------------------
INSERT INTO municipio (id, id_departamento, nombre, poblacion, latitud, longitud, altitud) VALUES
    ('05001', '05', 'Medellín',       2700000,   6.2518, -75.5636, 1495),
    ('05615', '05', 'Rionegro',        120000,   6.1544, -75.3741, 2125),
    ('08001', '08', 'Barranquilla',   1300000,  10.9685, -74.7813,   18),
    ('11001', '11', 'Bogotá D.C.',    8000000,   4.7110, -74.0721, 2600),
    ('13001', '13', 'Cartagena',       990000,  10.3910, -75.4794,    2),
    ('25754', '25', 'Soacha',          700000,   4.5797, -74.2170, 2565),
    ('68001', '68', 'Bucaramanga',     600000,   7.1193, -73.1227,  959),
    ('76001', '76', 'Cali',           2400000,   3.4516, -76.5320, 1000);

-- -------------------------------------------------------
-- tiempo (12 meses de 2024)
-- -------------------------------------------------------
INSERT INTO tiempo (fecha, anio, mes, trimestre) VALUES
    ('2024-01-01', 2024, 1,  1),
    ('2024-02-01', 2024, 2,  1),
    ('2024-03-01', 2024, 3,  1),
    ('2024-04-01', 2024, 4,  2),
    ('2024-05-01', 2024, 5,  2),
    ('2024-06-01', 2024, 6,  2),
    ('2024-07-01', 2024, 7,  3),
    ('2024-08-01', 2024, 8,  3),
    ('2024-09-01', 2024, 9,  3),
    ('2024-10-01', 2024, 10, 4),
    ('2024-11-01', 2024, 11, 4),
    ('2024-12-01', 2024, 12, 4);

-- -------------------------------------------------------
-- estacion_monitoreo
-- -------------------------------------------------------
INSERT INTO estacion_monitoreo (id_municipio, nombre, latitud, longitud, altitud, entidad_operadora) VALUES
    ('05001', 'Estación Medellín - El Poblado',     6.2100, -75.5680, 1495, 'SIATA'),
    ('05001', 'Estación Medellín - Bello',          6.3370, -75.5550, 1450, 'SIATA'),
    ('08001', 'Estación Barranquilla - Centro',    10.9685, -74.7813,   18, 'DAMAB'),
    ('11001', 'Estación Bogotá - Kennedy',          4.6280, -74.1460, 2571, 'SDMA'),
    ('76001', 'Estación Cali - Univalle',            3.3752, -76.5320, 1000, 'DAGMA'),
    ('68001', 'Estación Bucaramanga - Norte',        7.1400, -73.1200,  959, 'CDMB');

-- -------------------------------------------------------
-- medicion_calidad_aire (promedio mensual PM2.5 por estación)
-- Escenario: Medellín tiene picos en enero-marzo (verano)
-- Bogotá elevada todo el año; Barranquilla más baja
-- -------------------------------------------------------
INSERT INTO medicion_calidad_aire (id_estacion, id_tiempo, pm25, pm10, temperatura, humedad) VALUES
-- Medellín El Poblado (id_estacion=1)
    (1,  1, 28.4, 45.2, 22.1, 68),  -- ene: pico verano
    (1,  2, 31.7, 52.1, 23.0, 64),  -- feb: pico
    (1,  3, 26.3, 41.8, 22.8, 66),  -- mar
    (1,  4, 14.2, 23.5, 21.5, 78),  -- abr: lluvias bajan PM2.5
    (1,  5, 12.8, 21.0, 21.0, 82),
    (1,  6, 11.5, 19.4, 20.5, 85),
    (1,  7, 18.9, 30.2, 21.0, 75),  -- jul: segundo verano
    (1,  8, 20.1, 33.5, 21.5, 72),
    (1,  9, 13.4, 22.1, 21.0, 80),
    (1, 10, 15.6, 25.8, 21.2, 78),
    (1, 11, 12.1, 20.3, 20.8, 83),
    (1, 12, 22.3, 36.7, 22.5, 70),  -- dic: fin de año
-- Medellín Bello (id_estacion=2) — más contaminado (tráfico industrial)
    (2,  1, 38.2, 60.1, 22.0, 66),
    (2,  2, 42.5, 68.3, 23.1, 62),
    (2,  3, 35.8, 56.2, 22.5, 65),
    (2,  4, 19.3, 31.0, 21.3, 79),
    (2,  7, 25.4, 40.8, 21.2, 74),
    (2, 12, 30.1, 48.5, 22.3, 69),
-- Barranquilla (id_estacion=3) — ciudad costera, PM2.5 más bajo
    (3,  1, 12.1, 22.0, 29.5, 72),
    (3,  4,  9.8, 17.5, 30.1, 78),
    (3,  7, 10.5, 19.2, 31.0, 75),
    (3, 10, 11.3, 20.8, 29.8, 74),
-- Bogotá Kennedy (id_estacion=4) — altiplano, PM2.5 moderado-alto
    (4,  1, 22.7, 38.5, 13.5, 72),
    (4,  2, 24.1, 40.3, 13.8, 70),
    (4,  3, 19.8, 33.1, 14.0, 74),
    (4,  7, 21.3, 35.6, 14.2, 71),
    (4, 10, 18.5, 31.2, 13.9, 76),
    (4, 12, 25.9, 43.1, 13.2, 68),
-- Cali (id_estacion=5)
    (5,  1, 17.3, 29.8, 24.5, 73),
    (5,  4, 13.5, 23.1, 23.8, 80),
    (5,  7, 16.8, 28.4, 24.1, 75),
    (5, 10, 14.9, 25.5, 24.0, 77),
-- Bucaramanga (id_estacion=6)
    (6,  1, 20.5, 34.2, 25.0, 70),
    (6,  4, 15.1, 25.8, 24.5, 77),
    (6,  7, 19.2, 32.5, 25.1, 71),
    (6, 10, 16.8, 28.1, 24.8, 74);

-- -------------------------------------------------------
-- persona (30 fallecidos)
-- sexo: 1=Masculino, 2=Femenino
-- grupo_edad_2: 1=<1año, 2=1-4, 3=5-14, 4=15-44, 5=45-64, 6=65+, 7=desc
-- estado_civil: 5=Soltero, 6=Casado, 4=Viudo, 3=Separado, 9=Sin inf
-- nivel_educativo: 2=B.Primaria, 3=B.Secundaria, 9=Profesional, 13=Ninguno
-- seguridad_social: 1=Contributivo, 2=Subsidiado, 5=No asegurado
-- -------------------------------------------------------
INSERT INTO persona (id_pais_nacimiento, sexo, grupo_edad_1, grupo_edad_2, estado_civil, nivel_educativo, seguridad_social, ocupacion) VALUES
    ('COL', 1, 24, 6, 6, 2,  2, 'Agricultor'),          -- p1:  hombre 80-84
    ('COL', 2, 25, 6, 4, 2,  2, 'Ama de casa'),          -- p2:  mujer  85-89
    ('COL', 1, 23, 6, 6, 3,  1, 'Conductor'),            -- p3:  hombre 75-79
    ('COL', 2, 22, 6, 4, 2,  2, 'Ama de casa'),          -- p4:  mujer  70-74
    ('COL', 1, 20, 5, 6, 9,  1, 'Comerciante'),          -- p5:  hombre 60-64
    ('COL', 1, 19, 5, 6, 3,  1, 'Minero'),               -- p6:  hombre 55-59
    ('COL', 2, 21, 6, 4, 2,  2, 'Pensionada'),           -- p7:  mujer  65-69
    ('COL', 1, 26, 6, 4, 13, 2, 'Sin ocupación'),        -- p8:  hombre 90-94
    ('COL', 2, 24, 6, 6, 4,  2, 'Ama de casa'),          -- p9:  mujer  80-84
    ('COL', 1, 18, 5, 5, 9,  1, 'Docente'),              -- p10: hombre 50-54
    ('COL', 1, 17, 5, 6, 3,  1, 'Albañil'),              -- p11: hombre 45-49
    ('COL', 2, 23, 6, 3, 4,  1, 'Enfermera'),            -- p12: mujer  75-79
    ('COL', 1, 25, 6, 4, 2,  2, 'Campesino'),            -- p13: hombre 85-89
    ('COL', 2, 20, 5, 5, 4,  1, 'Empleada doméstica'),   -- p14: mujer  60-64
    ('COL', 1, 22, 6, 6, 2,  2, 'Mecánico'),             -- p15: hombre 70-74
    ('COL', 2, 26, 6, 4, 13, 2, 'Sin ocupación'),        -- p16: mujer  90-94
    ('COL', 1, 21, 6, 5, 9,  1, 'Abogado'),              -- p17: hombre 65-69
    ('COL', 1, 19, 5, 6, 3,  1, 'Taxista'),              -- p18: hombre 55-59
    ('COL', 2, 18, 5, 6, 4,  1, 'Costurera'),            -- p19: mujer  50-54
    ('COL', 1, 16, 4, 5, 3,  1, 'Soldador'),             -- p20: hombre 40-44
    ('COL', 2, 24, 6, 4, 2,  2, 'Ama de casa'),          -- p21: mujer  80-84
    ('COL', 1, 23, 6, 6, 2,  2, 'Ganadero'),             -- p22: hombre 75-79
    ('COL', 2, 22, 6, 5, 9,  1, 'Profesora'),            -- p23: mujer  70-74
    ('COL', 1, 27, 6, 4, 13, 2, 'Sin ocupación'),        -- p24: hombre 95-99
    ('COL', 2, 25, 6, 4, 2,  2, 'Ama de casa'),          -- p25: mujer  85-89
    ('COL', 1, 20, 5, 6, 3,  1, 'Carpintero'),           -- p26: hombre 60-64
    ('COL', 2, 17, 5, 6, 4,  2, 'Operaria textil'),      -- p27: mujer  45-49
    ('COL', 1, 15, 4, 5, 3,  1, 'Obrero construcción'),  -- p28: hombre 35-39
    ('COL', 2, 21, 6, 3, 4,  1, 'Pensionada'),           -- p29: mujer  65-69
    ('COL', 1, 24, 6, 6, 2,  2, 'Agricultor');           -- p30: hombre 80-84

-- -------------------------------------------------------
-- defuncion (30 registros distribuidos en 2024)
-- Municipio ocurrencia mapeado con ciudades con estación
-- probable_manera_muerte: 0=Natural (mayoría), otros casos
-- -------------------------------------------------------
INSERT INTO defuncion (id_persona, id_tiempo, id_municipio_ocurrencia, id_municipio_residencia, area_defuncion, area_residencia, sitio_defuncion, probable_manera_muerte, ocupacion_causa_muerte, tipo_accidente_laboral) VALUES
    (1,  1, '05001', '05001', 1, 1, 1, 0, 2, 9),  -- ene, Medellín
    (2,  1, '05001', '05001', 1, 1, 1, 0, 2, 9),
    (3,  2, '05001', '05615', 1, 1, 3, 0, 2, 9),  -- feb
    (4,  2, '08001', '08001', 1, 1, 1, 0, 2, 9),  -- Barranquilla
    (5,  3, '11001', '11001', 1, 1, 1, 0, 2, 9),  -- Bogotá
    (6,  3, '05001', '05001', 1, 1, 1, 0, 1, 2),  -- minero: ocupación causa muerte
    (7,  4, '76001', '76001', 1, 1, 1, 0, 2, 9),  -- Cali
    (8,  4, '05001', '05001', 1, 1, 3, 0, 2, 9),
    (9,  5, '11001', '25754', 1, 1, 1, 0, 2, 9),  -- Bogotá, vive Soacha
    (10, 5, '68001', '68001', 1, 1, 1, 0, 2, 9),  -- Bucaramanga
    (11, 6, '05001', '05001', 1, 1, 1, 0, 2, 9),
    (12, 6, '76001', '76001', 1, 1, 1, 0, 2, 9),
    (13, 7, '05001', '05615', 1, 3, 1, 0, 2, 9),  -- vive rural
    (14, 7, '11001', '11001', 1, 1, 1, 0, 2, 9),
    (15, 7, '08001', '08001', 1, 1, 3, 0, 2, 9),
    (16, 8, '05001', '05001', 1, 1, 1, 0, 2, 9),
    (17, 8, '68001', '68001', 1, 1, 1, 0, 2, 9),
    (18, 8, '05001', '05001', 1, 1, 3, 0, 2, 9),  -- taxista
    (19, 9, '76001', '76001', 1, 1, 1, 0, 2, 9),
    (20, 9, '05001', '05001', 1, 1, 1, 2, 1, 1),  -- accidente laboral
    (21, 10,'11001', '11001', 1, 1, 1, 0, 2, 9),
    (22, 10,'05001', '05001', 1, 1, 1, 0, 2, 9),
    (23, 10,'76001', '76001', 1, 1, 1, 0, 2, 9),
    (24, 11,'05001', '05001', 1, 1, 3, 0, 2, 9),
    (25, 11,'08001', '08001', 1, 1, 1, 0, 2, 9),
    (26, 11,'11001', '11001', 1, 1, 1, 0, 2, 9),
    (27, 12,'05001', '05001', 1, 1, 1, 0, 1, 2),  -- textil: ocupación causa muerte
    (28, 12,'05001', '05001', 1, 1, 4, 2, 1, 1),  -- obrero: accidente laboral
    (29, 12,'76001', '76001', 1, 1, 1, 0, 2, 9),
    (30, 12,'68001', '68001', 1, 1, 1, 0, 2, 9);

-- -------------------------------------------------------
-- causa_defuncion
-- J = respiratorias (núcleo del análisis)
-- Otras para contraste en las consultas
-- -------------------------------------------------------
INSERT INTO causa_defuncion (id_defuncion, codigo_cie10, causa_ops_667, causa_homologada) VALUES
    (1,  'J44',  '03', '042'),  -- EPOC
    (2,  'J18',  '03', '038'),  -- Neumonía
    (3,  'J44',  '03', '042'),  -- EPOC
    (4,  'I21',  '09', '065'),  -- Infarto — NO respiratoria
    (5,  'J45',  '03', '043'),  -- Asma
    (6,  'J60',  '03', '048'),  -- Neumoconiosis (enfermedad laboral)
    (7,  'I10',  '09', '063'),  -- Hipertensión — NO respiratoria
    (8,  'J96',  '03', '046'),  -- Insuf. respiratoria
    (9,  'J18',  '03', '038'),  -- Neumonía
    (10, 'J44',  '03', '042'),  -- EPOC
    (11, 'J45',  '03', '043'),  -- Asma
    (12, 'C34',  '02', '025'),  -- Cáncer de pulmón — NO respiratoria (CIE-10 C)
    (13, 'J22',  '03', '039'),  -- Infección respiratoria aguda
    (14, 'E11',  '06', '078'),  -- Diabetes — NO respiratoria
    (15, 'J18',  '03', '038'),  -- Neumonía
    (16, 'J44',  '03', '042'),  -- EPOC
    (17, 'J96',  '03', '046'),  -- Insuf. respiratoria
    (18, 'J44',  '03', '042'),  -- EPOC
    (19, 'J45',  '03', '043'),  -- Asma
    (20, 'S72',  '11', '098'),  -- Fractura fémur (accidente) — NO respiratoria
    (21, 'J18',  '03', '038'),  -- Neumonía
    (22, 'J44',  '03', '042'),  -- EPOC
    (23, 'J44',  '03', '042'),  -- EPOC
    (24, 'J96',  '03', '046'),  -- Insuf. respiratoria
    (25, 'J18',  '03', '038'),  -- Neumonía
    (26, 'I21',  '09', '065'),  -- Infarto — NO respiratoria
    (27, 'J60',  '03', '048'),  -- Neumoconiosis (laboral textil)
    (28, 'J44',  '03', '042'),  -- EPOC
    (29, 'J45',  '03', '043'),  -- Asma
    (30, 'J22',  '03', '039');  -- Infección respiratoria aguda


