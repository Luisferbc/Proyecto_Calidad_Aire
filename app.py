"""
Dashboard: Calidad del Aire y Mortalidad Respiratoria en Colombia 2024
Autores: Bryan Cadena, Carlos Bustamante, David Galvan, Luis Bermudez
Curso: Análisis de Datos Intermedio
"""

import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from scipy import stats
import os

# ─────────────────────────────────────────
# CONFIGURACIÓN DE LA PÁGINA
# ─────────────────────────────────────────
st.set_page_config(
    page_title="Calidad del Aire & Mortalidad - Colombia 2024",
    page_icon="🌿",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ─────────────────────────────────────────
# ESTILOS
# ─────────────────────────────────────────
st.markdown("""
<style>
    .metric-card {
        background: linear-gradient(135deg, #1e3a5f, #2563eb);
        padding: 1rem 1.5rem;
        border-radius: 12px;
        color: white;
        text-align: center;
        margin-bottom: 0.5rem;
    }
    .metric-card h3 { margin: 0; font-size: 2rem; }
    .metric-card p  { margin: 0; font-size: 0.85rem; opacity: 0.85; }
    .section-title  { color: #1e3a5f; border-left: 4px solid #2563eb; padding-left: 10px; }
</style>
""", unsafe_allow_html=True)

# ─────────────────────────────────────────
# DICCIONARIOS DE APOYO
# ─────────────────────────────────────────
DEPARTAMENTOS = {
    5: "Antioquia", 8: "Atlántico", 11: "Bogotá D.C.", 13: "Bolívar",
    15: "Boyacá", 17: "Caldas", 18: "Caquetá", 19: "Cauca",
    20: "Cesar", 23: "Córdoba", 25: "Cundinamarca", 27: "Chocó",
    41: "Huila", 44: "La Guajira", 47: "Magdalena", 50: "Meta",
    52: "Nariño", 54: "Norte de Santander", 63: "Quindío", 66: "Risaralda",
    68: "Santander", 70: "Sucre", 73: "Tolima", 76: "Valle del Cauca",
    81: "Arauca", 85: "Casanare", 86: "Putumayo", 88: "San Andrés",
    91: "Amazonas", 94: "Guainía", 95: "Guaviare", 97: "Vaupés", 99: "Vichada"
}

# Códigos CIE-10 respiratorios (capítulo J)
CODIGOS_RESPIRATORIOS = [
    'J00', 'J01', 'J02', 'J03', 'J04', 'J05', 'J06',
    'J10', 'J11', 'J12', 'J13', 'J14', 'J15', 'J16', 'J17', 'J18',
    'J20', 'J21', 'J22',
    'J30', 'J31', 'J32', 'J33', 'J34', 'J35', 'J36', 'J37', 'J38', 'J39',
    'J40', 'J41', 'J42', 'J43', 'J44', 'J45', 'J46', 'J47',
    'J60', 'J61', 'J62', 'J63', 'J64', 'J65', 'J66', 'J67', 'J68', 'J69',
    'J70', 'J80', 'J81', 'J82', 'J84', 'J85', 'J86',
    'J90', 'J91', 'J92', 'J93', 'J94', 'J95', 'J96', 'J98', 'J99'
]

NIVEL_RIESGO_ICA = {
    "Buena":           (0, 50,  "#00e400"),
    "Moderada":        (51, 100, "#ffff00"),
    "Dañina grupos":   (101, 150, "#ff7e00"),
    "Dañina":          (151, 200, "#ff0000"),
    "Muy dañina":      (201, 300, "#8f3f97"),
    "Peligrosa":       (301, 500, "#7e0023"),
}

MESES = {1:"Ene",2:"Feb",3:"Mar",4:"Abr",5:"May",6:"Jun",
          7:"Jul",8:"Ago",9:"Sep",10:"Oct",11:"Nov",12:"Dic"}

# ─────────────────────────────────────────
# CARGA Y PROCESAMIENTO DE DATOS
# ─────────────────────────────────────────
@st.cache_data(show_spinner="Cargando datos DANE...")
def cargar_mortalidad(ruta: str) -> pd.DataFrame:
    df = pd.read_csv(ruta, encoding='latin1', sep=',', low_memory=False)
    df['NOMBRE_DPTO'] = df['COD_DPTO'].map(DEPARTAMENTOS)
    df['ES_RESPIRATORIA'] = df['C_BAS1'].astype(str).str[:3].isin(CODIGOS_RESPIRATORIOS)
    return df


@st.cache_data(show_spinner="Cargando datos IDEAM...")
def cargar_calidad_aire(ruta: str) -> pd.DataFrame:
    df = pd.read_csv(ruta, encoding='latin1', low_memory=False)
    return df


def calcular_ica_pm25(pm25: float) -> float:
    """Calcula el ICA a partir de PM2.5 según EPA / IDEAM."""
    breakpoints = [
        (0.0,   12.0,   0,   50),
        (12.1,  35.4,  51,  100),
        (35.5,  55.4, 101,  150),
        (55.5, 150.4, 151,  200),
        (150.5, 250.4, 201, 300),
        (250.5, 500.4, 301, 500),
    ]
    for lo_c, hi_c, lo_i, hi_i in breakpoints:
        if lo_c <= pm25 <= hi_c:
            return round(((hi_i - lo_i) / (hi_c - lo_c)) * (pm25 - lo_c) + lo_i, 1)
    return 500.0


def nivel_riesgo(ica: float) -> str:
    for nombre, (lo, hi, _) in NIVEL_RIESGO_ICA.items():
        if lo <= ica <= hi:
            return nombre
    return "Peligrosa"


# ─────────────────────────────────────────
# DATOS SINTÉTICOS DE DEMOSTRACIÓN
# (Se reemplazan cuando el usuario sube sus archivos)
# ─────────────────────────────────────────
@st.cache_data
def datos_demo():
    np.random.seed(42)
    dptos = list(DEPARTAMENTOS.values())
    n = len(dptos)

    # Simular PM2.5 y PM10 por departamento
    pm25 = np.random.uniform(5, 60, n)
    pm10 = pm25 * np.random.uniform(1.5, 2.5, n)
    ica  = np.array([calcular_ica_pm25(v) for v in pm25])

    # Tasa de mortalidad correlacionada con ICA + ruido
    tasa = 0.08 * ica + np.random.normal(0, 3, n)
    tasa = np.clip(tasa, 2, 40)

    df_aire = pd.DataFrame({
        'departamento': dptos,
        'cod_dpto': list(DEPARTAMENTOS.keys()),
        'pm25': pm25.round(2),
        'pm10': pm10.round(2),
        'no2': np.random.uniform(5, 45, n).round(2),
        'so2': np.random.uniform(1, 20, n).round(2),
        'co': np.random.uniform(0.2, 3.5, n).round(2),
        'o3': np.random.uniform(10, 80, n).round(2),
        'ica_pm25': ica,
        'nivel_riesgo': [nivel_riesgo(v) for v in ica],
    })

    df_mort = pd.DataFrame({
        'departamento': dptos,
        'cod_dpto': list(DEPARTAMENTOS.keys()),
        'total_muertes': np.random.randint(50, 3000, n),
        'muertes_respiratorias': (tasa * np.random.uniform(10, 30, n)).astype(int),
        'poblacion': np.random.randint(80_000, 8_000_000, n),
        'tasa_mortalidad': tasa.round(2),
    })

    # Serie mensual (ICA promedio nacional)
    meses = list(range(1, 13))
    df_mensual = pd.DataFrame({
        'mes': meses,
        'mes_nombre': [MESES[m] for m in meses],
        'ica_promedio': np.random.uniform(40, 130, 12).round(1),
        'muertes_resp': np.random.randint(600, 1800, 12),
    })

    return df_aire, df_mort, df_mensual


# ─────────────────────────────────────────
# SIDEBAR – CARGA DE ARCHIVOS
# ─────────────────────────────────────────
with st.sidebar:
    st.image("https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Flag_of_Colombia.svg/320px-Flag_of_Colombia.svg.png", width=80)
    st.title("⚙️ Configuración")
    st.markdown("---")

    st.subheader("📂 Datos de Mortalidad (DANE)")
    archivo_mortalidad = st.file_uploader(
        "CSV defunciones DANE 2024",
        type=["csv"],
        key="mortalidad"
    )

    st.subheader("📂 Datos de Calidad del Aire (IDEAM)")
    archivo_aire = st.file_uploader(
        "CSV mediciones IDEAM",
        type=["csv"],
        key="aire"
    )

    st.markdown("---")
    st.subheader("🔎 Filtros")
    usar_demo = archivo_mortalidad is None or archivo_aire is None

    if usar_demo:
        st.info("📊 Mostrando **datos de demostración**. Sube tus archivos para ver análisis reales.")

    # Filtro de departamentos (se llena después de cargar datos)
    st.markdown("---")
    st.caption("Proyecto Final · Análisis de Datos Intermedio")


# ─────────────────────────────────────────
# CARGAR DATOS
# ─────────────────────────────────────────
if usar_demo:
    df_aire, df_mort, df_mensual = datos_demo()
else:
    try:
        df_raw_mort = cargar_mortalidad.__wrapped__(pd.read_csv(
            archivo_mortalidad, encoding='latin1', low_memory=False))
    except Exception:
        df_raw_mort = pd.read_csv(archivo_mortalidad, encoding='latin1', low_memory=False)
        df_raw_mort['NOMBRE_DPTO'] = df_raw_mort['COD_DPTO'].map(DEPARTAMENTOS)
        df_raw_mort['ES_RESPIRATORIA'] = df_raw_mort['C_BAS1'].astype(str).str[:3].isin(CODIGOS_RESPIRATORIOS)

    # Mortalidad agregada por departamento
    agr = df_raw_mort.groupby('COD_DPTO').agg(
        departamento=('NOMBRE_DPTO', 'first'),
        total_muertes=('COD_DPTO', 'count'),
        muertes_respiratorias=('ES_RESPIRATORIA', 'sum'),
    ).reset_index().rename(columns={'COD_DPTO': 'cod_dpto'})
    agr['tasa_mortalidad'] = (agr['muertes_respiratorias'] / agr['total_muertes'] * 100).round(2)
    df_mort = agr

    # Aire del CSV IDEAM
    df_aire_raw = pd.read_csv(archivo_aire, encoding='latin1', low_memory=False)
    # Intentar detectar columnas automáticamente
    col_pm25 = next((c for c in df_aire_raw.columns if 'pm25' in c.lower() or 'pm2_5' in c.lower()), None)
    col_pm10 = next((c for c in df_aire_raw.columns if 'pm10' in c.lower()), None)
    col_dpto = next((c for c in df_aire_raw.columns if 'dpto' in c.lower() or 'departamento' in c.lower()), None)

    if col_dpto and col_pm25:
        df_aire = df_aire_raw.groupby(col_dpto)[[col_pm25]].mean().reset_index()
        df_aire.columns = ['departamento', 'pm25']
        if col_pm10:
            df_aire['pm10'] = df_aire_raw.groupby(col_dpto)[col_pm10].mean().values
        df_aire['ica_pm25'] = df_aire['pm25'].apply(calcular_ica_pm25)
        df_aire['nivel_riesgo'] = df_aire['ica_pm25'].apply(nivel_riesgo)
    else:
        st.warning("⚠️ No se pudieron detectar columnas en el archivo IDEAM. Usando datos de demostración para calidad del aire.")
        df_aire, _, df_mensual = datos_demo()

    # Serie mensual
    if 'MES' in df_raw_mort.columns:
        df_mensual = df_raw_mort[df_raw_mort['ES_RESPIRATORIA']].groupby('MES').agg(
            muertes_resp=('ES_RESPIRATORIA', 'sum')
        ).reset_index()
        df_mensual['mes_nombre'] = df_mensual['MES'].map(MESES)
        df_mensual['ica_promedio'] = df_aire['ica_pm25'].mean()  # aproximación
        df_mensual.rename(columns={'MES': 'mes'}, inplace=True)
    else:
        _, _, df_mensual = datos_demo()


# ─────────────────────────────────────────
# JOIN PARA ANÁLISIS DE CORRELACIÓN
# ─────────────────────────────────────────
df_merged = pd.merge(
    df_aire[['departamento','pm25','pm10','ica_pm25','nivel_riesgo']],
    df_mort[['departamento','total_muertes','muertes_respiratorias','tasa_mortalidad']],
    on='departamento',
    how='inner'
)

# ─────────────────────────────────────────
# ENCABEZADO PRINCIPAL
# ─────────────────────────────────────────
st.markdown("## 🌿 Calidad del Aire y Mortalidad Respiratoria en Colombia 2024")
st.markdown("**Correlación entre contaminantes atmosféricos y tasa de mortalidad por enfermedades respiratorias por departamento**")
st.divider()

# ─────────────────────────────────────────
# KPIs
# ─────────────────────────────────────────
k1, k2, k3, k4 = st.columns(4)

with k1:
    st.markdown(f"""<div class="metric-card">
        <h3>{df_mort['muertes_respiratorias'].sum():,}</h3>
        <p>Muertes respiratorias</p>
    </div>""", unsafe_allow_html=True)

with k2:
    ica_prom = df_aire['ica_pm25'].mean()
    st.markdown(f"""<div class="metric-card">
        <h3>{ica_prom:.0f}</h3>
        <p>ICA PM2.5 promedio nacional</p>
    </div>""", unsafe_allow_html=True)

with k3:
    pm25_prom = df_aire['pm25'].mean()
    st.markdown(f"""<div class="metric-card">
        <h3>{pm25_prom:.1f} μg/m³</h3>
        <p>PM2.5 promedio nacional</p>
    </div>""", unsafe_allow_html=True)

with k4:
    if len(df_merged) >= 3:
        r, p = stats.pearsonr(df_merged['ica_pm25'], df_merged['tasa_mortalidad'])
        sig = "✅ Sig." if p < 0.05 else "⚠️ No sig."
        st.markdown(f"""<div class="metric-card">
            <h3>r = {r:.2f}</h3>
            <p>Pearson ICA–Mortalidad {sig}</p>
        </div>""", unsafe_allow_html=True)

st.divider()

# ─────────────────────────────────────────
# TABS PRINCIPALES
# ─────────────────────────────────────────
tab1, tab2, tab3, tab4 = st.tabs([
    "📊 Correlación",
    "🗺️ Mapa por Departamento",
    "📈 Serie Temporal",
    "🔬 EDA Calidad del Aire"
])

# ══════════════════════════════════════════
# TAB 1 – CORRELACIÓN
# ══════════════════════════════════════════
with tab1:
    st.markdown('<h3 class="section-title">Scatter: ICA vs Tasa de Mortalidad Respiratoria</h3>', unsafe_allow_html=True)

    col_scatter, col_stats = st.columns([2, 1])

    with col_scatter:
        fig_scatter = px.scatter(
            df_merged,
            x='ica_pm25',
            y='tasa_mortalidad',
            color='nivel_riesgo',
            size='muertes_respiratorias',
            hover_name='departamento',
            hover_data={'pm25': ':.2f', 'pm10': ':.2f'},
            trendline='ols',
            labels={
                'ica_pm25': 'ICA PM2.5',
                'tasa_mortalidad': 'Tasa Mortalidad Respiratoria (%)',
                'nivel_riesgo': 'Nivel de Riesgo'
            },
            color_discrete_map={
                "Buena": "#00e400",
                "Moderada": "#c8c800",
                "Dañina grupos": "#ff7e00",
                "Dañina": "#ff0000",
                "Muy dañina": "#8f3f97",
                "Peligrosa": "#7e0023",
            },
            template='plotly_white',
            title='Dispersión ICA PM2.5 vs Tasa de Mortalidad Respiratoria'
        )
        fig_scatter.update_layout(height=420)
        st.plotly_chart(fig_scatter, use_container_width=True)

    with col_stats:
        st.markdown("#### 📐 Estadísticas de Correlación")
        if len(df_merged) >= 3:
            r_p, p_p = stats.pearsonr(df_merged['ica_pm25'], df_merged['tasa_mortalidad'])
            r_s, p_s = stats.spearmanr(df_merged['ica_pm25'], df_merged['tasa_mortalidad'])

            st.metric("Pearson r", f"{r_p:.3f}", f"p = {p_p:.4f}")
            st.metric("Spearman ρ", f"{r_s:.3f}", f"p = {p_s:.4f}")

            interpretacion = (
                "🔴 Correlación fuerte positiva" if r_p > 0.6 else
                "🟡 Correlación moderada positiva" if r_p > 0.3 else
                "🟢 Correlación débil / no significativa"
            )
            st.info(interpretacion)

            st.markdown("#### 📋 Top 5 departamentos (ICA)")
            top5 = df_merged.nlargest(5, 'ica_pm25')[['departamento','ica_pm25','tasa_mortalidad']]
            top5.columns = ['Departamento','ICA','Tasa (%)']
            st.dataframe(top5.set_index('Departamento'), use_container_width=True)

    # Barras contaminantes por departamento
    st.markdown('<h3 class="section-title">Contaminantes promedio por departamento</h3>', unsafe_allow_html=True)
    dpto_sel = st.selectbox("Selecciona departamentos a comparar", df_aire['departamento'].sort_values().tolist(), index=0)

    cols_contam = [c for c in ['pm25','pm10','no2','so2','co','o3'] if c in df_aire.columns]
    if cols_contam:
        df_bar = df_aire[df_aire['departamento'].isin([dpto_sel])][['departamento'] + cols_contam].melt(
            id_vars='departamento', var_name='Contaminante', value_name='Concentración'
        )
        fig_bar = px.bar(df_bar, x='Contaminante', y='Concentración', color='Contaminante',
                         template='plotly_white', title=f"Concentración de contaminantes – {dpto_sel}")
        st.plotly_chart(fig_bar, use_container_width=True)


# ══════════════════════════════════════════
# TAB 2 – MAPA
# ══════════════════════════════════════════
with tab2:
    st.markdown('<h3 class="section-title">Mapa coroplético de tasa de mortalidad respiratoria</h3>', unsafe_allow_html=True)

    metrica = st.radio("Métrica a visualizar", ["tasa_mortalidad", "muertes_respiratorias", "ica_pm25"], horizontal=True)

    # Mapa usando datos lat/lon aproximados por departamento (centroide)
    CENTROIDES = {
        "Antioquia":(6.7,-75.5),"Atlántico":(10.7,-74.9),"Bogotá D.C.":(4.7,-74.1),
        "Bolívar":(8.6,-74.0),"Boyacá":(5.5,-73.4),"Caldas":(5.3,-75.3),
        "Caquetá":(0.9,-74.0),"Cauca":(2.3,-76.6),"Cesar":(9.9,-73.6),
        "Córdoba":(8.3,-75.6),"Cundinamarca":(5.0,-74.0),"Chocó":(5.7,-76.7),
        "Huila":(2.5,-75.7),"La Guajira":(11.5,-72.5),"Magdalena":(10.4,-74.4),
        "Meta":(3.5,-73.0),"Nariño":(1.5,-77.3),"Norte de Santander":(7.9,-72.5),
        "Quindío":(4.5,-75.7),"Risaralda":(5.3,-75.9),"Santander":(6.7,-73.1),
        "Sucre":(9.0,-75.0),"Tolima":(3.8,-75.2),"Valle del Cauca":(3.8,-76.5),
        "Arauca":(6.5,-71.0),"Casanare":(5.3,-72.0),"Putumayo":(0.4,-76.6),
        "San Andrés":( 12.5,-81.7),"Amazonas":(-1.5,-71.5),"Guainía":(2.6,-68.5),
        "Guaviare":(2.1,-72.3),"Vaupés":(0.5,-70.5),"Vichada":(4.4,-69.3),
    }

    df_map = df_merged.copy()
    df_map['lat'] = df_map['departamento'].map(lambda d: CENTROIDES.get(d, (4.5, -74.0))[0])
    df_map['lon'] = df_map['departamento'].map(lambda d: CENTROIDES.get(d, (4.5, -74.0))[1])

    fig_map = px.scatter_mapbox(
        df_map,
        lat='lat', lon='lon',
        size=metrica,
        color=metrica,
        hover_name='departamento',
        hover_data={
            'ica_pm25':':.1f',
            'pm25':':.2f',
            'tasa_mortalidad':':.2f',
            'muertes_respiratorias':True,
            'lat':False,'lon':False
        },
        color_continuous_scale='YlOrRd',
        mapbox_style='carto-positron',
        zoom=4.5,
        center={"lat": 4.5, "lon": -74.0},
        title=f"Distribución geográfica – {metrica.replace('_',' ').title()}",
        labels={metrica: metrica.replace('_',' ').title()}
    )
    fig_map.update_layout(height=550)
    st.plotly_chart(fig_map, use_container_width=True)

    st.markdown('<h3 class="section-title">Tabla resumen por departamento</h3>', unsafe_allow_html=True)
    st.dataframe(
        df_merged.sort_values('tasa_mortalidad', ascending=False)
                 .rename(columns={
                     'departamento':'Departamento',
                     'pm25':'PM2.5','pm10':'PM10',
                     'ica_pm25':'ICA PM2.5','nivel_riesgo':'Nivel Riesgo',
                     'total_muertes':'Total Muertes',
                     'muertes_respiratorias':'Muertes Resp.',
                     'tasa_mortalidad':'Tasa (%)'
                 })
                 .set_index('Departamento'),
        use_container_width=True,
        height=350
    )


# ══════════════════════════════════════════
# TAB 3 – SERIE TEMPORAL
# ══════════════════════════════════════════
with tab3:
    st.markdown('<h3 class="section-title">Evolución mensual 2024</h3>', unsafe_allow_html=True)

    col_l, col_r = st.columns(2)

    with col_l:
        fig_ica_mes = px.line(
            df_mensual, x='mes_nombre', y='ica_promedio',
            markers=True,
            labels={'mes_nombre':'Mes','ica_promedio':'ICA Promedio'},
            title='ICA promedio mensual nacional',
            template='plotly_white',
            color_discrete_sequence=['#2563eb']
        )
        # Banda de referencia (umbral "Moderada" = 51)
        fig_ica_mes.add_hline(y=51, line_dash='dot', line_color='orange',
                               annotation_text='Umbral Moderada (51)')
        fig_ica_mes.add_hline(y=101, line_dash='dot', line_color='red',
                               annotation_text='Umbral Dañina (101)')
        fig_ica_mes.update_layout(height=350)
        st.plotly_chart(fig_ica_mes, use_container_width=True)

    with col_r:
        fig_mort_mes = px.bar(
            df_mensual, x='mes_nombre', y='muertes_resp',
            labels={'mes_nombre':'Mes','muertes_resp':'Muertes Respiratorias'},
            title='Muertes respiratorias por mes',
            template='plotly_white',
            color='muertes_resp',
            color_continuous_scale='Reds'
        )
        fig_mort_mes.update_layout(height=350, coloraxis_showscale=False)
        st.plotly_chart(fig_mort_mes, use_container_width=True)

    # Correlación mensual si hay variación
    if df_mensual['ica_promedio'].nunique() > 1:
        r_m, p_m = stats.pearsonr(df_mensual['ica_promedio'], df_mensual['muertes_resp'])
        st.info(f"📐 Correlación ICA–Muertes Respiratorias mensual: **r = {r_m:.3f}** (p = {p_m:.4f})")


# ══════════════════════════════════════════
# TAB 4 – EDA CALIDAD DEL AIRE
# ══════════════════════════════════════════
with tab4:
    st.markdown('<h3 class="section-title">Distribución del ICA y contaminantes</h3>', unsafe_allow_html=True)

    c1, c2 = st.columns(2)

    with c1:
        # Histograma PM2.5
        fig_hist = px.histogram(
            df_aire, x='pm25', nbins=15,
            title='Distribución de PM2.5 por departamento',
            labels={'pm25':'PM2.5 (μg/m³)'},
            template='plotly_white',
            color_discrete_sequence=['#2563eb']
        )
        fig_hist.add_vline(x=12, line_dash='dash', line_color='green',
                           annotation_text='OMS: 12 μg/m³')
        fig_hist.add_vline(x=25, line_dash='dash', line_color='red',
                           annotation_text='Res. 2254/2017: 25 μg/m³')
        st.plotly_chart(fig_hist, use_container_width=True)

    with c2:
        # Distribución del nivel de riesgo ICA
        conteo_nivel = df_aire['nivel_riesgo'].value_counts().reset_index()
        conteo_nivel.columns = ['Nivel de Riesgo','Departamentos']
        fig_pie = px.pie(
            conteo_nivel, names='Nivel de Riesgo', values='Departamentos',
            title='Distribución de niveles de riesgo ICA (PM2.5)',
            color='Nivel de Riesgo',
            color_discrete_map={
                "Buena":"#00e400","Moderada":"#c8c800",
                "Dañina grupos":"#ff7e00","Dañina":"#ff0000",
                "Muy dañina":"#8f3f97","Peligrosa":"#7e0023"
            },
            template='plotly_white'
        )
        st.plotly_chart(fig_pie, use_container_width=True)

    # Box plot por nivel de riesgo
    st.markdown('<h3 class="section-title">PM2.5 y PM10 por nivel de riesgo</h3>', unsafe_allow_html=True)
    cols_box = [c for c in ['pm25','pm10'] if c in df_aire.columns]
    if cols_box:
        df_box = df_aire[['nivel_riesgo'] + cols_box].melt(
            id_vars='nivel_riesgo', var_name='Contaminante', value_name='Concentración'
        )
        fig_box = px.box(
            df_box, x='nivel_riesgo', y='Concentración', color='Contaminante',
            template='plotly_white',
            title='Concentración de PM por nivel de riesgo ICA'
        )
        st.plotly_chart(fig_box, use_container_width=True)

    # Ranking departamentos por ICA
    st.markdown('<h3 class="section-title">Ranking departamentos por ICA PM2.5</h3>', unsafe_allow_html=True)
    df_rank = df_aire.sort_values('ica_pm25', ascending=True)
    fig_rank = px.bar(
        df_rank, x='ica_pm25', y='departamento',
        orientation='h',
        color='ica_pm25',
        color_continuous_scale='YlOrRd',
        labels={'ica_pm25':'ICA PM2.5','departamento':'Departamento'},
        template='plotly_white',
        title='ICA PM2.5 por departamento (ordenado)'
    )
    fig_rank.add_vline(x=51,  line_dash='dot', line_color='orange')
    fig_rank.add_vline(x=101, line_dash='dot', line_color='red')
    fig_rank.update_layout(height=600, coloraxis_showscale=False)
    st.plotly_chart(fig_rank, use_container_width=True)


# ─────────────────────────────────────────
# FOOTER
# ─────────────────────────────────────────
st.divider()
st.caption(
    "📊 **Proyecto Final – Análisis de Datos Intermedio** | "
    "Bryan Cadena · Carlos Bustamante · David Galvan · Luis Bermudez | "
    "Docente: Feibert Alirio Guzmán Pérez | Colombia 2024"
)
