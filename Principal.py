import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings

warnings.filterwarnings("ignore")

# -------------------------------------------------------
# CONFIGURACIÓN DE LA APP
# -------------------------------------------------------

st.set_page_config(
    page_title="Observatorio Aire Salud Colombia",
    page_icon="🫁",
    layout="wide"
)

# -------------------------------------------------------
# ESTILOS
# -------------------------------------------------------

st.markdown("""
<style>
.main-header {
    font-size: 3rem;
    font-weight: bold;
    color: #1E88E5;
    text-align: center;
}
.section-header {
    font-size: 2rem;
    font-weight: bold;
    color: #43A047;
}
</style>
""", unsafe_allow_html=True)


# -------------------------------------------------------
# CARGA DE DATOS
# -------------------------------------------------------

@st.cache_data
def load_data():

    data = {}

    # Municipios
    data['municipio'] = pd.DataFrame({
        'id_municipio': ['05001','08001','11001','13001','76001','68001'],
        'nombre_municipio': ['Medellín','Barranquilla','Bogotá','Cartagena','Cali','Bucaramanga'],
        'id_departamento': ['05','08','11','13','76','68'],
        'poblacion': [2700000,1300000,8000000,990000,2400000,600000]
    })

    # Departamentos
    data['departamento'] = pd.DataFrame({
        'id_departamento': ['05','08','11','13','76','68'],
        'nombre_departamento': ['Antioquia','Atlántico','Bogotá','Bolívar','Valle del Cauca','Santander'],
        'region': ['Andina','Caribe','Andina','Caribe','Pacífica','Andina']
    })

    # Tiempo
    data['tiempo'] = pd.DataFrame({
        'id_tiempo': range(1,13),
        'fecha': pd.date_range('2024-01-01', periods=12, freq='M'),
        'mes': range(1,13),
        'anio': [2024]*12
    })

    # Estaciones
    data['estacion_monitoreo'] = pd.DataFrame({
        'id_estacion': range(1,7),
        'id_municipio': ['05001','05001','08001','11001','76001','68001'],
        'nombre_estacion': [
            'Medellín Poblado',
            'Medellín Bello',
            'Barranquilla Centro',
            'Bogotá Kennedy',
            'Cali Univalle',
            'Bucaramanga Norte'
        ],
        'latitud': [6.21,6.33,10.96,4.62,3.37,7.14],
        'longitud': [-75.56,-75.55,-74.78,-74.14,-76.53,-73.12]
    })

    # Mediciones
    np.random.seed(42)

    registros = []

    for estacion in range(1,7):
        for mes in range(1,13):

            pm25 = np.random.uniform(10,40)

            registros.append({
                "id_estacion": estacion,
                "id_tiempo": mes,
                "pm25": pm25,
                "pm10": pm25*1.8,
                "temperatura": np.random.uniform(20,30),
                "humedad": np.random.uniform(60,85)
            })

    data['medicion_calidad_aire'] = pd.DataFrame(registros)

    return data


# -------------------------------------------------------
# LANDING PAGE
# -------------------------------------------------------

def landing_page():

    st.markdown(
        '<p class="main-header">🫁 Observatorio Aire y Salud Colombia</p>',
        unsafe_allow_html=True
    )

    st.write("""
    Plataforma de análisis de la relación entre **calidad del aire** y **salud pública**
    en las principales ciudades de Colombia.
    """)

    if st.button("🚀 Ingresar al Dashboard"):
        st.session_state["page"] = "dashboard"
        st.rerun()


# -------------------------------------------------------
# DASHBOARD
# -------------------------------------------------------

def dashboard():

    data = load_data()

    st.markdown(
        '<p class="main-header">📊 Dashboard Calidad del Aire</p>',
        unsafe_allow_html=True
    )

    # ---------------------------------------------------
    # KPIs
    # ---------------------------------------------------

    pm25_prom = data["medicion_calidad_aire"]["pm25"].mean()
    pm25_max = data["medicion_calidad_aire"]["pm25"].max()
    dias_criticos = len(
        data["medicion_calidad_aire"]
        [data["medicion_calidad_aire"]["pm25"] > 25]
    )

    c1,c2,c3 = st.columns(3)

    c1.metric("PM2.5 Promedio", f"{pm25_prom:.1f}")
    c2.metric("PM2.5 Máximo", f"{pm25_max:.1f}")
    c3.metric("Días Críticos", dias_criticos)

    # ---------------------------------------------------
    # MERGE DE DATOS
    # ---------------------------------------------------

    df = (
        data["medicion_calidad_aire"]
        .merge(data["estacion_monitoreo"], on="id_estacion")
        .merge(data["municipio"], on="id_municipio")
        .merge(data["tiempo"], on="id_tiempo")
    )

    # ---------------------------------------------------
    # GRÁFICO
    # ---------------------------------------------------

    st.subheader("Evolución mensual PM2.5 por ciudad")

    fig, ax = plt.subplots(figsize=(10,5))

    sns.lineplot(
        data=df,
        x="mes",
        y="pm25",
        hue="nombre_municipio",
        marker="o",
        ax=ax
    )

    ax.axhline(25, color="red", linestyle="--", label="Límite OMS")

    ax.set_ylabel("PM2.5")
    ax.set_xlabel("Mes")
    ax.set_title("Concentración de PM2.5")

    st.pyplot(fig)

    st.info("El PM2.5 es el contaminante más asociado a enfermedades respiratorias.")


# -------------------------------------------------------
# DOCUMENTACIÓN
# -------------------------------------------------------

def documentacion():

    st.header("Documentación")

    st.write("""
    **Variables principales**

    PM2.5 : Material particulado fino  
    PM10 : Material particulado grueso  

    **Tablas**

    - municipio
    - departamento
    - estacion_monitoreo
    - medicion_calidad_aire
    - tiempo
    """)


# -------------------------------------------------------
# MAIN
# -------------------------------------------------------

def main():

    if "page" not in st.session_state:
        st.session_state["page"] = "landing"

    if st.session_state["page"] == "landing":

        landing_page()

    else:

        st.sidebar.title("Navegación")

        opcion = st.sidebar.radio(
            "Ir a",
            ["Dashboard","Documentación","Inicio"]
        )

        if opcion == "Dashboard":
            dashboard()

        elif opcion == "Documentación":
            documentacion()

        else:
            st.session_state["page"] = "landing"
            st.rerun()


# -------------------------------------------------------

if __name__ == "__main__":
    main()
```
