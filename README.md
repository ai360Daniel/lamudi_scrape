# Lamudi Web Scraper 🏠

Sistema de web scraping para descargar datos de propiedades inmobiliarias desde **Lamudi.com.mx** con integración a **Google Cloud Storage (GCS)**.

## 📋 Descripción

Este proyecto descarga información de propiedades (casas, departamentos, etc.) de todos los estados de México desde Lamudi y los almacena en Google Cloud Storage con estructura automática de carpetas por año_mes.

### Características Principales
- ✅ Descarga propiedades por estado y tipo de inmueble
- ✅ Limpieza y enriquecimiento de datos (coordenadas, geolocalización, fechas)
- ✅ Integración con Google Cloud Storage (GCS)
- ✅ Manejo automático de links fallidos con reintentos
- ✅ **Paralelización por estado** para acelerar descarga

## 📁 Estructura de Carpetas en GCS

```
scraping_inmuebles/
└── Lamudi/
    └── 2026_03/  (Año_Mes actual)
        ├── aguascalientes_casa.csv
        ├── aguascalientes_departamento.csv
        ├── baja_california_casa.csv
        ├── baja_california_departamento.csv
        └── ... (resto de estados y tipos)
```

## 🚀 Ejecución

### Instalación de Dependencias

```bash
pip install -r requirements.txt
```

### Ejecución Simple

Para descargar todos los estados de forma secuencial:

```bash
python lamudi_scraper.py
```

### Ejecución Paralelizada ⚡

Este proyecto incluye **5 scripts de selección** para paralelizar la descarga por grupos de estados:

#### Scripts de Selección de Estados:

| Script | Estados | Ejecutar en |
|--------|---------|-----------|
| `lamudi_scraper_seleccion1.py` | Aguascalientes, Baja California, Baja California Sur, Campeche, Chiapas | VM 1 |
| `lamudi_scraper_seleccion2.py` | Chihuahua, Ciudad de México, Coahuila, Colima, Durango | VM 2 |
| `lamudi_scraper_seleccion3.py` | Estado de México, Guanajuato, Guerrero, Hidalgo, Jalisco | VM 3 |
| `lamudi_scraper_seleccion4.py` | Michoacán, Morelos, Nayarit, Nuevo León, Oaxaca | VM 4 |
| `lamudi_scraper_seleccion5.py` | Puebla, Querétaro, Quintana Roo, San Luis Potosí, Sinaloa, Sonora, Tabasco, Tamaulipas, Tlaxcala, Veracruz, Yucatán, Zacatecas | VM 5 |

#### Ejemplo de Ejecución Paralelizada en GCP:

1. **Crear 5 VMs en Compute Engine** (cada una con su service account):

```bash
for i in {1..5}; do
  gcloud compute instances create lamudi-vm-$i \
    --zone=us-central1-a \
    --service-account=lamudi-scraper@guru-491919.iam.gserviceaccount.com \
    --scopes=cloud-platform
done
```

2. **Ejecutar en paralelo** (una selección diferente en cada VM):

```bash
# En VM 1
python lamudi_scraper_seleccion1.py

# En VM 2
python lamudi_scraper_seleccion2.py

# ... etc
```

3. **Todos los datos se guardan** automáticamente en el mismo bucket GCS en la carpeta del mes actual.

#### Ventajas de Paralelización:
- ⚡ **Velocidad**: 5x más rápido que ejecución secuencial
- 💰 **Eficiente**: Distribuye carga entre VMs
- 🔄 **Escalable**: Cada VM trabaja independientemente
- 📊 **Consolidated**: Todos los datos en el mismo GCS bucket

## 📦 Estructura del Proyecto

```
lamudi_webscrape/
├── requirements.txt                   # Dependencias Python
├── README.md                          # Este archivo
├── lamudi_scraper.py                  # Script principal (secuencial)
├── scraper_functions.py               # Módulo con todas las funciones
├── lamudi_scraper_seleccion1.py       # Scripts de selección por estado (paralelización)
├── lamudi_scraper_seleccion2.py
├── lamudi_scraper_seleccion3.py
├── lamudi_scraper_seleccion4.py
├── lamudi_scraper_seleccion5.py
├── Prueba1.ipynb                      # Notebook de pruebas (opcional)
```

## 🔧 Configuración de Google Cloud Storage

### Requisitos

- Proyecto GCP creado y activo
- Bucket `scraping_inmuebles` en GCS
- Service account con permisos

### Permisos Necesarios para Service Account

```bash
gcloud projects add-iam-policy-binding guru-491919 \
  --member="serviceAccount:lamudi-scraper@guru-491919.iam.gserviceaccount.com" \
  --role="roles/storage.objectAdmin"
```

### En la VM de GCP

Las credenciales se obtienen **automáticamente** mediante **Application Default Credentials (ADC)**. No necesitas:
- ❌ Variables de entorno `GOOGLE_APPLICATION_CREDENTIALS`
- ❌ Archivos JSON de credenciales
- ✅ Solo asignar el service account a la VM

## 📊 Funciones Principales

### `scraper_functions.py`

#### Configuración
- `obtener_carpeta_anio_mes()` - Genera ruta YYYY_MM automática
- `obtener_cliente_gcs()` - Conecta con GCS

#### Scraping
- `scrape_lamudi(usar_gcs=True)` - Descarga propiedades
- `scrape_y_guardar_fallidos(usar_gcs=True)` - Maneja reintentos

#### Procesamiento
- `limpiar_df(usar_gcs=True)` - Enriquece datos con coordenadas y geolocalización
- `filtrar_por_categoria()` - Filtra por tipo de propiedad
- `contar_propiedades_por_estado_y_tipo()` - Estadísticas

#### Gestión de Archivos GCS
- `guardar_archivo_gcs()` - Sube archivos a GCS
- `leer_archivo_gcs()` - Lee de GCS
- `archivo_existe_gcs()` - Verifica existencia

## 💡 Ejemplos de Uso

### Uso Secuencial (Todos los estados)
```python
from scraper_functions import scrape_lamudi, limpiar_df

# Descargar todos los estados
scrape_lamudi(usar_gcs=True)

# Limpiar datos
limpiar_df(usar_gcs=True)
```

### Uso en Script de Selección (Estados específicos)
```python
from scraper_functions import scrape_lamudi, limpiar_df

ESTADOS = ["Aguascalientes", "Baja California", "Baja California Sur"]

for estado in ESTADOS:
    print(f"Descargando {estado}...")
    scrape_lamudi(estados=[estado], usar_gcs=True)
    limpiar_df(estados=[estado], usar_gcs=True)
```

## 📝 Variables de Control

En `lamudi_scraper.py`:

```python
USAR_GCS = True  # True = Guardar en Google Cloud Storage
                 # False = Guardar localmente
```

## 🐛 Troubleshooting

### Error: "google.auth.exceptions.DefaultCredentialsError"
**Solución**: Asegúrate de que la VM de GCP tiene un service account asignado.

### Error: "403 Forbidden" en GCS
**Solución**: Verifica que el service account tenga permisos `roles/storage.objectAdmin` en el bucket.

### Scripts se ejecutan lentamente
**Solución**: Aumenta el número de VMs paralelas o ajusta wait times en `scraper_functions.py`.

## 🔔 Notas Importantes

- Los datos se almacenan en formato CSV (raw y cleaned)
- Los links fallidos se guardan en JSON para reintentos
- Carpetas se crean automáticamente por año_mes
- Si la carpeta ya existe, se usan los datos existentes como base
- Compatible con Python 3.8+

## 📞 Soporte

Para errores o preguntas, revisa:
1. Los logs en la VM
2. El estado del bucket en [Google Cloud Console](https://console.cloud.google.com)
3. Permisos del service account

---

**Última actualización**: Marzo 2026
