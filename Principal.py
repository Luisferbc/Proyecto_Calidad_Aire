import streamlit as st
import pandas as pd
import sqlite3
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
from sklearn.linear_model import LinearRegression
import numpy as np
from PIL import Image
import os

# -------------------------------
# CONFIGURACIÓN DE LA APP
# -------------------------------
st.set_page_config(
    page_title="Observatorio Aire y Salud Colombia",
    page_icon="🌎",
    layout="wide"
)

# ---------------------------------------------------
# DATOS SIMULADOS
# ---------------------------------------------------

def load_data():
    data = {}

    data["departamento"] = pd.DataFrame({
        "id":[1,2,3,4,5],
        "nombre":["Antioquia","Atlántico","Bogotá","Valle","Santander"]
    })

    data["municipio"] = pd.DataFrame({
        "id":[1,2,3,4,5],
        "nombre":["Medellín","Barranquilla","Bogotá","Cali","Bucaramanga"],
        "id_departamento":[1,2,3,4,5],
        "lat":[6.24,10.98,4.71,3.45,7.13],
        "lon":[-75.57,-74.78,-74.07,-76.53,-73.12]
    })

    data["tiempo"] = pd.DataFrame({
        "id":range(1,13),
        "anio":[2024]*12,
        "mes":range(1,13)
    })

    data["persona"] = pd.DataFrame({
        "id":range(1,101),
        "sexo":["M","F"]*50,
        "grupo_edad_2":["Adulto"]*100,
        "ocupacion":["Empleado"]*100
    })

    data["defuncion"] = pd.DataFrame({
        "id":range(1,101),
        "id_persona":range(1,101),
        "id_tiempo":[1,2,3,4,5]*20,
        "id_municipio_ocurrencia":[1,2,3,4,5]*20,
        "id_municipio_residencia":[1,2,3,4,5]*20
    })

    data["causa_defuncion"] = pd.DataFrame({
        "id_defuncion":range(1,101),
        "codigo_cie10":["J45","J12","I10","J20","E11"]*20
    })

    data["estacion_monitoreo"] = pd.DataFrame({
        "id":[1,2,3,4,5],
        "id_municipio":[1,2,3,4,5]
    })

    data["medicion_calidad_aire"] = pd.DataFrame({
        "id_estacion":[1,2,3,4,5]*20,
        "pm25":[12,18,25,20,16]*20
    })

    return data

# ---------------------------------------------------
# BASE SQLITE
# ---------------------------------------------------

def create_database(data):
    conn = sqlite3.connect(":memory:")
    for name, df in data.items():
        df.to_sql(name, conn, index=False, if_exists="replace")
    return conn

# ---------------------------------------------------
# CONSULTAS SQL
# ---------------------------------------------------

def run_queries(conn):

    queries = {}

    queries["Muertes respiratorias por municipio"] = '''
    SELECT mu.nombre AS municipio, COUNT(*) AS muertes
    FROM defuncion d
    JOIN causa_defuncion cd ON cd.id_defuncion = d.id
    JOIN municipio mu ON mu.id = d.id_municipio_ocurrencia
    WHERE cd.codigo_cie10 LIKE 'J%'
    GROUP BY mu.nombre
    '''

    queries["Muertes respiratorias por mes"] = '''
    SELECT t.mes, COUNT(*) AS muertes
    FROM defuncion d
    JOIN causa_defuncion cd ON cd.id_defuncion = d.id
    JOIN tiempo t ON t.id = d.id_tiempo
    WHERE cd.codigo_cie10 LIKE 'J%'
    GROUP BY t.mes
    '''

    results = {}
    for name, query in queries.items():
        results[name] = pd.read_sql_query(query, conn)

    return results

# ---------------------------------------------------
# INDICADORES
# ---------------------------------------------------

def indicadores(data):
    pm25 = data["medicion_calidad_aire"]["pm25"].mean()

    col1, col2 = st.columns(2)

    col1.metric("PM2.5 Promedio", round(pm25,2))

    limite = 15
    if pm25 > limite:
        col2.error("Supera límite OMS")
    else:
        col2.success("Dentro límite OMS")

# ---------------------------------------------------
# MAPA INTERACTIVO
# ---------------------------------------------------

def mapa(data):
    df = data["municipio"].copy()
    pm25 = data["medicion_calidad_aire"].groupby("id_estacion").mean()
    df["pm25"] = pm25["pm25"].values

    fig = px.scatter_mapbox(
        df,
        lat="lat",
        lon="lon",
        size="pm25",
        color="pm25",
        hover_name="nombre",
        zoom=4,
        height=500
    )

    fig.update_layout(mapbox_style="open-street-map")
    st.plotly_chart(fig, use_container_width=True)

# ---------------------------------------------------
# CORRELACION
# ---------------------------------------------------

def correlacion(data):
    pm25 = data["medicion_calidad_aire"].groupby("id_estacion").mean()
    muertes = data["defuncion"].groupby("id_municipio_ocurrencia").count()

    df = pd.DataFrame({
        "pm25":pm25["pm25"].values,
        "muertes":muertes["id"].values[:5]
    })

    fig, ax = plt.subplots()
    sns.regplot(data=df, x="pm25", y="muertes", ax=ax)
    st.pyplot(fig)

    st.write("Correlación aproximada:", round(df.corr().iloc[0,1],2))

# ---------------------------------------------------
# PREDICCION
# ---------------------------------------------------

def prediccion(data):
    pm25 = data["medicion_calidad_aire"].groupby("id_estacion").mean()
    muertes = data["defuncion"].groupby("id_municipio_ocurrencia").count()

    X = pm25["pm25"].values.reshape(-1,1)
    y = muertes["id"].values[:5]

    modelo = LinearRegression()
    modelo.fit(X,y)

    pred = modelo.predict([[20]])
    st.write("Predicción de muertes con PM2.5=20:", int(pred[0]))

# ---------------------------------------------------
# DASHBOARD
# ---------------------------------------------------

def dashboard(data, results):

    st.title("📊 Observatorio Aire y Salud")

    st.subheader("Indicadores")
    indicadores(data)

    st.subheader("Mapa de contaminación")
    mapa(data)

    st.subheader("Correlación contaminación vs mortalidad")
    correlacion(data)

    st.subheader("Modelo predictivo")
    prediccion(data)

    st.subheader("Consultas SQL")

    consulta = st.selectbox("Seleccione consulta", list(results.keys()))
    st.dataframe(results[consulta])

# ---------------------------------------------------
# LANDING
# ---------------------------------------------------

def landing():

    st.title("🌫️ Calidad del Aire y Salud Pública en Colombia")

    st.markdown("""
    ### 📌 Propósito del proyecto

    Este proyecto analiza la relación entre la calidad del aire 
    y las comorbilidades en Colombia (2020–2025).
    """)

    ruta_imagen = "Calidad_aire.jpg"

    if os.path.exists(ruta_imagen):
        imagen = Image.open(ruta_imagen)
        st.image(imagen, use_container_width=True)
    else:
        st.warning("Imagen no encontrada")

    st.info("Usa el menú lateral para navegar")

# ---------------------------------------------------
# MAIN
# ---------------------------------------------------

def main():

    data = load_data()
    conn = create_database(data)
    results = run_queries(conn)

    menu = st.sidebar.radio(
        "🧭 Navegación",
        ["🏠 Inicio", "📊 Dashboard"]
    )

    if menu == "🏠 Inicio":
        landing()

    elif menu == "📊 Dashboard":
        dashboard(data, results)

# ---------------------------------------------------
# EJECUCIÓN
# ---------------------------------------------------

if __name__ == "__main__":
    main()
