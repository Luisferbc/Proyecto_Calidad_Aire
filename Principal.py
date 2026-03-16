import streamlit as st
import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')  # Backend no interactivo
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import warnings
warnings.filterwarnings('ignore')

# Configurar página
st.set_page_config(
    page_title="Observatorio Aire Salud Colombia",
    page_icon="🫁",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
    <style>
    .main-header {
        font-size: 3rem;
        font-weight: bold;
        color: #1E88E5;
        text-align: center;
        margin-bottom: 2rem;
    }
    .section-header {
        font-size: 2rem;
        font-weight: bold;
        color: #43A047;
        margin-top: 2rem;
        margin-bottom: 1rem;
    }
    .metric-card {
        background-color: #f0f8ff;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 5px solid #1E88E5;
        margin: 1rem 0;
    }
    .help-icon {
        cursor: pointer;
        color: #1E88E5;
    }
    </style>
""", unsafe_allow_html=True)

# Función para cargar datos
@st.cache_data
def load_data():
    # Simulación de datos basada en el SQL proporcionado
    data = {}
    
    # Municipios
    data['municipio'] = pd.DataFrame({
        'id': ['05001', '08001', '11001', '13001', '76001', '68001'],
        'nombre': ['Medellín', 'Barranquilla', 'Bogotá D.C.', 'Cartagena', 'Cali', 'Bucaramanga'],
        'id_departamento': ['05', '08', '11', '13', '76', '68'],
        'poblacion': [2700000, 1300000, 8000000, 990000, 2400000, 600000]
    })
    
    # Departamento
    data['departamento'] = pd.DataFrame({
        'id': ['05', '08', '11', '13', '76', '68'],
        'nombre': ['Antioquia', 'Atlántico', 'Bogotá D.C.', 'Bolívar', 'Valle del Cauca', 'Santander'],
        'region': ['Andina', 'Caribe', 'Andina', 'Caribe', 'Pacífica', 'Andina']
    })
    
    # Tiempo
    data['tiempo'] = pd.DataFrame({
        'id': range(1, 13),
        'fecha': pd.date_range('2024-01-01', periods=12, freq='M'),
        'anio': [2024]*12,
        'mes': range(1, 13),
        'trimestre': [1,1,1,2,2,2,3,3,3,4,4,4]
    })
    
    # Estaciones de monitoreo
    data['estacion_monitoreo'] = pd.DataFrame({
        'id': range(1, 7),
        'id_municipio': ['05001', '05001', '08001', '11001', '76001', '68001'],
        'nombre': ['Estación Medellín - El Poblado', 'Estación Medellín - Bello', 
                   'Estación Barranquilla - Centro', 'Estación Bogotá - Kennedy',
                   'Estación Cali - Univalle', 'Estación Bucaramanga - Norte'],
        'latitud': [6.2100, 6.3370, 10.9685, 4.6280, 3.3752, 7.1400],
        'longitud': [-75.5680, -75.5550, -74.7813, -74.1460, -76.5320, -73.1200]
    })
    
    # Mediciones de calidad del aire
    np.random.seed(42)
    mediciones = []
    for estacion in range(1, 7):
        for mes in range(1, 13):
            pm25 = np.random.uniform(10, 40) if estacion <= 2 else np.random.uniform(8, 25)
            mediciones.append({
                'id_estacion': estacion,
                'id_tiempo': mes,
                'pm25': pm25,
                'pm10': pm25 * 1.8,
                'temperatura': np.random.uniform(20, 30),
                'humedad': np.random.uniform(60, 85)
            })
    data['medicion_calidad_aire'] = pd.DataFrame(mediciones)
    
    # Defunciones
    data['defuncion'] = pd.DataFrame({
        'id': range(1, 31),
        'id_persona': range(1, 31),
        'id_tiempo': np.random.randint(1, 13, 30),
        'id_municipio_ocurrencia': np.random.choice(['05001', '08001', '11001', '76001', '68001'], 30),
        'area_defuncion': np.random.choice([1, 2, 3], 30),
        'probable_manera_muerte': np.random.choice([0, 2], 30)
    })
    
    # Causas de defunción
    data['causa_defuncion'] = pd.DataFrame({
        'id': range(1, 31),
        'id_defuncion': range(1, 31),
        'codigo_cie10': np.random.choice(['J44', 'J18', 'J45', 'J96', 'I21', 'J60'], 30)
    })
    
    # Personas
    data['persona'] = pd.DataFrame({
        'id': range(1, 31),
        'sexo': np.random.choice([1, 2], 30),
        'grupo_edad_2': np.random.choice([4, 5, 6], 30),
        'nivel_educativo': np.random.choice([2, 3, 9], 30)
    })
    
    return data

def help_icon(text):
    st.info(f"💡 {text}")

def landing_page():
    st.markdown('<p class="main-header">🫁 Observatorio Aire Salud Colombia</p>', unsafe_allow_html=True)
    
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        st.image("Calidad_aire.jpg", caption="Calidad del Aire y Salud Respiratoria", use_column_width=True)
    
    st.markdown("""
    ### Bienvenido al Observatorio de Calidad del Aire y Salud
        
    Este proyecto analiza la relación entre la **calidad del aire** y las **defunciones por causas respiratorias** 
    en las principales ciudades de Colombia durante el año 2024.
    """)
    
    st.markdown("### 📊 Características del Dataset")
    
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.metric("Municipios", "6")
    with col2:
        st.metric("Estaciones", "6")
    with col3:
        st.metric("Meses", "12")
    with col4:
        st.metric("Defunciones", "30")
    
    if st.button("🚀 Ingresar al Panel de Análisis", type="primary", use_container_width=True):
        st.session_state['page'] = 'dashboard'
        st.rerun()

def dashboard():
    data = load_data()
    
    st.sidebar.header("🎛️ Filtros")
    deptos = data['departamento']['nombre'].tolist()
    depto_seleccionado = st.sidebar.selectbox("Seleccionar Departamento", ["Todos"] + deptos)
    
    st.markdown('<p class="main-header">📈 Panel de Análisis - Calidad del Aire y Salud</p>', unsafe_allow_html=True)
    
    # KPIs
    pm25_promedio = data['medicion_calidad_aire']['pm25'].mean()
    pm25_max = data['medicion_calidad_aire']['pm25'].max()
    dias_criticos = len(data['medicion_calidad_aire'][data['medicion_calidad_aire']['pm25'] > 25])
    
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("PM2.5 Promedio", f"{pm25_promedio:.1f} µg/m³")
    with col2:
        st.metric("PM2.5 Máximo", f"{pm25_max:.1f} µg/m³")
    with col3:
        st.metric("Días Críticos", dias_criticos)
    
    # Gráficos principales
    mediciones_con_ciudad = data['medicion_calidad_aire'].merge(
        data['estacion_monitoreo'], on='id_estacion'
    ).merge(
        data['municipio'], on='id_municipio'
    ).merge(
        data['tiempo'], on='id_tiempo'
    )
    
    fig, ax = plt.subplots(figsize=(12, 6))
    sns.lineplot(data=mediciones_con_ciudad, x='mes', y='pm25', hue='nombre_y', marker='o', ax=ax)
    plt.title('Evolución Mensual de PM2.5 por Ciudad')
    plt.axhline(y=25, color='r', linestyle='--', alpha=0.7, label='Límite OMS')
    st.pyplot(fig)
    help_icon("El PM2.5 puede penetrar profundamente en los pulmones")

def documentacion():
    st.markdown("## 📚 Documentación")
    st.markdown("""
    ### Base de Datos
    - **medicion_calidad_aire**: PM2.5, PM10, temperatura, humedad
    - **defuncion**: Registro de fallecimientos
    - **causa_defuncion**: Códigos CIE-10
    
    ### Variables
    - PM2.5: Material particulado fino < 2.5µm
    - CIE-10 J: Enfermedades respiratorias
    """)

def main():
    if 'page' not in st.session_state:
        st.session_state['page'] = 'landing'
    
    if st.session_state['page'] == 'landing':
        landing_page()
    else:
        st.sidebar.title("🧭 Navegación")
        opcion = st.sidebar.radio("Ir a:", ["Dashboard", "Documentación", "🏠 Inicio"])
        
        if opcion == "Dashboard":
            dashboard()
        elif opcion == "Documentación":
            documentacion()
        else:
            st.session_state['page'] = 'landing'
            st.rerun()

if __name__ == "__main__":
    main()