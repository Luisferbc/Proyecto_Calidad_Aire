# 🫁 Observatorio Aire Salud Colombia

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![Streamlit](https://img.shields.io/badge/Streamlit-1.31.0-FF4B4B.svg)](https://streamlit.io/)
[![Pandas](https://img.shields.io/badge/Pandas-2.1.4-150458.svg)](https://pandas.pydata.org/)
[![Seaborn](https://img.shields.io/badge/Seaborn-0.13.1-3776AB.svg)](https://seaborn.pydata.org/)
[![Plotly](https://img.shields.io/badge/Plotly-5.18.0-3F4F75.svg)](https://plotly.com/)
[![Statsmodels](https://img.shields.io/badge/Statsmodels-0.14+-2C6F99.svg)](https://www.statsmodels.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Matplotlib](https://img.shields.io/badge/Matplotlib-3.8.2-11557C.svg)](https://matplotlib.org/)

## 📋 Descripción

Análisis de correlación entre la calidad del aire y la tasa de mortalidad por enfermedades respiratorias en los departamentos de Colombia durante 2024, integrando datos del IDEAM y el DANE. El proyecto busca generar evidencia estadística para la formulación de políticas públicas en salud ambiental.

---

## 🔍 Identificación de la Problemática

Colombia reporta aproximadamente **14.825 muertes anuales** por enfermedades respiratorias (DANE), en un contexto donde el promedio nacional de PM2.5 en zonas urbanas alcanza los **14,1 μg/m³** según el IDEAM. Sin embargo, este promedio oculta disparidades regionales críticas en departamentos con alta presión industrial y vehicular.

**Pregunta de investigación:** ¿Existe una correlación estadísticamente significativa entre la calidad del aire y la tasa de mortalidad por enfermedades respiratorias en los departamentos de Colombia durante 2024?

---

## 🗄️ Base de Datos

Diseñada en **MySQL**, integra fuentes del DANE (defunciones reales 2024) e IDEAM (mediciones simuladas por departamento ante la ausencia de datos oficiales desagregados).

### Modelo Relacional

![Modelo relacional](sql/modelo%20relacional.png)

**Tablas principales:** `pais`, `departamento`, `municipio`, `estacion_monitoreo`, `tiempo`, `persona`, `defuncion`, `diagnostico_cie10`, `defuncion_diagnostico`, `medicion_calidad_aire`, `indice_calidad_aire`, `tasa_mortalidad`.

Los scripts se encuentran en la carpeta `sql/`:

- `create_database.sql` — Creación del esquema y tablas
- `generate_data.sql` — Inserción de datos
- `querys.sql` — Consultas analíticas con JOINs, subconsultas y funciones agregadas

---

## 📊 Análisis de Datos

El análisis completo se documenta en `documento_final.ipynb` e incluye:

- **ETL:** Extracción desde DANE y construcción de datos simulados con parámetros reales del ICA colombiano (Resolución 2254/2017)
- **SQL:** Consultas complejas con subconsultas, JOINs múltiples, funciones agregadas y filtros avanzados
- **Pandas:** Análisis exploratorio (EDA), limpieza, normalización y pruebas de correlación (Pearson, Spearman)
- **Statsmodels:** Modelado estadístico de la relación ICA–mortalidad respiratoria

---

## 📈 Visualización

Dashboard interactivo construido con **Streamlit** que incluye:

| Visualización                          | Tipo       | Variables                                    |
| -------------------------------------- | ---------- | -------------------------------------------- |
| Mapa coroplético TMCE por departamento | Mapa       | `tasa_mortalidad`, `departamento`            |
| Evolución mensual del ICA general      | Línea      | `indice_calidad_aire`, `tiempo`              |
| Scatter ICA vs TMCE por departamento   | Dispersión | `indice_calidad_aire`, `tasa_mortalidad`     |
| Top 10 causas de muerte respiratoria   | Barras     | `defuncion_diagnostico`, `diagnostico_cie10` |
| Distribución de nivel de riesgo ICA    | Dona       | `indice_calidad_aire`                        |

Una demo del dashboard está disponible en `video.mp4`.

---

## 💡 Soluciones Propuestas

Con base en los hallazgos del análisis:

1. Priorizar control de fuentes de PM2.5 en el **Eje Cafetero** (Quindío, Risaralda, Caldas) y la **región Pacífica**
2. Ampliar la red de estaciones de monitoreo del IDEAM en municipios con alta TMCE y sin cobertura actual
3. Revisar los umbrales permisibles de la **Resolución 2254/2017** frente a la evidencia epidemiológica de 2024
4. Focalizar programas de salud respiratoria en adultos mayores del régimen subsidiado en zonas de alto ICA

---

## 📁 Estructura del Proyecto

```
Proyecto_Calidad_Aire/
├── streamlit/
│   ├── app.py                  # Dashboard principal
│   ├── Principal.py            # Módulo de lógica
│   ├── consultas.ipynb         # Consultas integradas con Pandas
│   ├── Calidad_aire.jpg        # Recurso visual
│   ├── Integrantes.txt
│   └── requirements.txt
├── sql/
│   ├── create_database.sql
│   ├── generate_data.sql
│   ├── querys.sql
│   ├── modelo entidad relacion.png
│   └── modelo relacional.png
├── documento_final.ipynb       # Informe completo del proyecto
├── landing_calidad_aire_mortalidad.html
├── video.mp4
├── LICENSE
└── README.md
```

---

## 🚀 Instalación

**1. Clona el repositorio**

```bash
git clone https://github.com/Luisferbc/Proyecto_Calidad_Aire.git
cd Proyecto_Calidad_Aire
```

**2. Crea y activa un entorno virtual**

```bash
# bash
python3 -m venv venv
source venv/bin/activate

# fish shell
python3 -m venv venv
source venv/bin/activate.fish
```

**3. Instala las dependencias**

```bash
pip install -r streamlit/requirements.txt
pip install matplotlib seaborn statsmodels
```

**4. Corre el dashboard**

```bash
cd streamlit
streamlit run app.py
```

Abre tu navegador en `http://localhost:8501`.

---

## 👥 Equipo de Desarrollo

| Integrante                         | Rol                                           |
| ---------------------------------- | --------------------------------------------- |
| **David Galvan Sierra**            | Análisis estadístico y pruebas de correlación |
| **Carlos Eduardo Bustamante**      | Diseño y gestión de base de datos MySQL       |
| **Bryan Emanuel Cadena Hincapie**  | ETL, procesamiento de datos DANE e IDEAM      |
| **Luis Fernando Bermudez Cardona** | Dashboard Streamlit y visualizaciones         |

---

## 📄 Documentación

El informe completo del proyecto está disponible en `documento_final.ipynb` y cubre:

- Introducción y planteamiento del problema
- Metodología (ETL, diseño de BD, análisis estadístico)
- Resultados y visualizaciones
- Conclusiones y recomendaciones de política pública

## Ademas, todas loas notas y documentos del proyecto están disponibles en [Google Drive](https://drive.google.com/drive/folders/1OkOU16bduAeNxH3n1jS6EPcZXbAPGXvn?usp=drive_link).

**Curso:** Análisis de Datos Intermedio — **Docente:** Feibert Alirio Guzmán Pérez
