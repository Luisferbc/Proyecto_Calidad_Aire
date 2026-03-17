import streamlit as st
import pandas as pd
import sqlite3
import matplotlib.pyplot as plt
import seaborn as sns

st.set_page_config(page_title="Observatorio Aire y Salud", layout="wide")

# ---------------------------------------------------
# CARGA DE DATOS SIMULADOS
# ---------------------------------------------------

def load_data():

    data = {}

    data['departamento'] = pd.DataFrame({
        'id':[1,2,3,4,5],
        'nombre':['Antioquia','Atlántico','Bogotá','Valle','Santander']
    })

    data['municipio'] = pd.DataFrame({
        'id':[1,2,3,4,5],
        'nombre':['Medellín','Barranquilla','Bogotá','Cali','Bucaramanga'],
        'id_departamento':[1,2,3,4,5]
    })

    data['tiempo'] = pd.DataFrame({
        'id':range(1,13),
        'anio':[2024]*12,
        'mes':range(1,13)
    })

    data['persona'] = pd.DataFrame({
        'id':range(1,101),
        'sexo':['M','F']*50,
        'grupo_edad_2':['Adulto']*100,
        'ocupacion':['Empleado']*100
    })

    data['defuncion'] = pd.DataFrame({
        'id':range(1,101),
        'id_persona':range(1,101),
        'id_tiempo':[1,2,3,4,5]*20,
        'id_municipio_ocurrencia':[1,2,3,4,5]*20,
        'id_municipio_residencia':[1,2,3,4,5]*20
    })

    data['causa_defuncion'] = pd.DataFrame({
        'id_defuncion':range(1,101),
        'codigo_cie10':['J45','J12','I10','J20','E11']*20
    })

    data['estacion_monitoreo'] = pd.DataFrame({
        'id':[1,2,3,4,5],
        'id_municipio':[1,2,3,4,5]
    })

    data['medicion_calidad_aire'] = pd.DataFrame({
        'id_estacion':[1,2,3,4,5]*20,
        'pm25':[12,18,25,20,16]*20
    })

    return data


# ---------------------------------------------------
# CREAR BASE SQLITE
# ---------------------------------------------------

def create_database(data):

    conn = sqlite3.connect(':memory:')

    for name, df in data.items():
        df.to_sql(name, conn, index=False, if_exists='replace')

    return conn


# ---------------------------------------------------
# CONSULTAS SQL
# ---------------------------------------------------

def run_queries(conn):

    queries = {}

    queries["Defunciones por enfermedades respiratorias por municipio y mes"] = """
    SELECT
        d.id AS id_defuncion,
        t.anio,
        t.mes,
        mu.nombre AS municipio,
        dep.nombre AS departamento,
        cd.codigo_cie10,
        p.sexo,
        p.grupo_edad_2
    FROM defuncion d
    JOIN causa_defuncion cd ON cd.id_defuncion = d.id
    JOIN persona p ON p.id = d.id_persona
    JOIN tiempo t ON t.id = d.id_tiempo
    JOIN municipio mu ON mu.id = d.id_municipio_ocurrencia
    JOIN departamento dep ON dep.id = mu.id_departamento
    WHERE cd.codigo_cie10 LIKE 'J%'
    """

    queries["Distribución mensual de mortalidad respiratoria por departamento"] = """
    SELECT
        t.mes,
        dep.nombre AS departamento,
        COUNT(*) AS total_defunciones,
        SUM(CASE WHEN cd.codigo_cie10 LIKE 'J%' THEN 1 ELSE 0 END)
        AS muertes_respiratorias
    FROM defuncion d
    JOIN causa_defuncion cd ON cd.id_defuncion = d.id
    JOIN tiempo t ON t.id = d.id_tiempo
    JOIN municipio mu ON mu.id = d.id_municipio_ocurrencia
    JOIN departamento dep ON dep.id = mu.id_departamento
    GROUP BY t.mes, dep.nombre
    """

    queries["Municipios con alta contaminación PM2.5 y mortalidad respiratoria"] = """
    SELECT
        mu.nombre AS municipio,
        dep.nombre AS departamento,
        AVG(mca.pm25) AS pm25_promedio
    FROM municipio mu
    JOIN departamento dep ON dep.id = mu.id_departamento
    JOIN estacion_monitoreo em ON em.id_municipio = mu.id
    JOIN medicion_calidad_aire mca ON mca.id_estacion = em.id
    GROUP BY mu.id
    HAVING AVG(mca.pm25) > 15
    

    results = {}

    for name,q in queries.items():
        results[name] = pd.read_sql_query(q, conn)

    return results


# ---------------------------------------------------
# LANDING PAGE
# ---------------------------------------------------

def landing():

    st.title("Observatorio Aire y Salud Colombia")

    st.image("Calidad_aire.jpg", use_container_width=True)

    st.write(
        "Análisis de la relación entre **calidad del aire** y "
        "**mortalidad por enfermedades respiratorias**."
    )

    if st.button("Ingresar al Dashboard"):
        st.session_state.page = "dashboard"


# ---------------------------------------------------
# DASHBOARD
# ---------------------------------------------------

def dashboard(results):

    st.title("Dashboard Aire y Salud")

    option = st.selectbox(
        "Seleccione consulta",
        list(results.keys())
    )

    df = results[option]

    st.dataframe(df)

    if option == "Consulta 2":

        fig, ax = plt.subplots()

        sns.barplot(
            data=df,
            x="mes",
            y="muertes_respiratorias",
            hue="departamento",
            ax=ax
        )

        st.pyplot(fig)


# ---------------------------------------------------
# MAIN
# ---------------------------------------------------

def main():

    data = load_data()

    conn = create_database(data)

    results = run_queries(conn)

    if "page" not in st.session_state:
        st.session_state.page = "landing"

    if st.session_state.page == "landing":
        landing()
    else:
        dashboard(results)


if __name__ == "__main__":
    main()


