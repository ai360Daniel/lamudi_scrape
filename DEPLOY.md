# 🚀 Guía de Despliegue - VMs en GCP para Lamudi Scraper

## 📋 Resumen

Este conjunto de scripts PowerShell automatiza la creación y gestión de VMs en Google Cloud Platform para ejecutar en paralelo los 5 scripts de web scraping de Lamudi.

### ✨ Características
- ✅ Creación automática de 5 VMs (e2-medium)
- ✅ Configuración automática de service account y permisos
- ✅ Instalación automática de dependencias (Chrome, ChromeDriver, Python)
- ✅ Clonación automática del repositorio en cada VM
- ✅ Herramientas de monitoreo y gestión

---

## 🔧 Requisitos Previos

### 1. **Instalar Google Cloud SDK**
Descargar e instalar desde: https://cloud.google.com/sdk/docs/install

**En Windows:**
```powershell
# Descargar e instalar
(New-Object Net.WebClient).DownloadFile('https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe', "$env:Temp\GoogleCloudSDKInstaller.exe")
& "$env:Temp\GoogleCloudSDKInstaller.exe"
```

### 2. **Autenticarse en GCP**
```powershell
gcloud auth login
gcloud config set project guru-491919
```

### 3. **Verificar permisos**
Tu usuario de GCP debe tener estos permisos:
- `compute.instances.create`
- `iam.serviceAccounts.actAs`
- `iam.serviceAccounts.create`

---

## 🚀 Pasos de Despliegue

### Paso 1: Ejecutar Setup (una sola vez)
```powershell
cd "c:\Users\THUNDEROBOT\OneDrive - Ai360 SA de CV\ai360_local\3. Proyectos\Lamudi webscrape"
.\deploy_gcp_setup.ps1
```

**Qué hace:**
- ✅ Verifica que gcloud esté instalado
- ✅ Configura el proyecto GCP
- ✅ Crea el service account `lamudi-scraper`
- ✅ Asigna permisos necesarios al bucket
- ✅ Habilita las APIs requeridas

**Salida esperada:**
```
[1/5] Verificando gcloud CLI...
✅ gcloud CLI encontrado

[2/5] Configurando proyecto GCP: guru-491919...
✅ Proyecto configurado

[3/5] Creando service account: lamudi-scraper...
✅ Service account creada: lamudi-scraper@guru-491919.iam.gserviceaccount.com

[4/5] Asignando permisos al bucket: scraping_inmuebles...
✅ Permisos asignados al service account

[5/5] Habilitando APIs necesarias...
✅ APIs habilitadas

===========================
✅ Setup completado exitosamente!
===========================
```

### Paso 2: Crear las 5 VMs
```powershell
.\deploy_create_vms.ps1
```

**Qué hace:**
- Crea 5 VMs en paralelo (o secuencial, según carga)
- Cada VM: 2 vCPU, 4GB RAM, 50GB disco, Debian 12
- Asigna el service account `lamudi-scraper`
- Ejecuta startup script que instala:
  - Python 3 + pip
  - Google Chrome
  - ChromeDriver
  - Repositorio GitHub
  - Dependencias Python

**Salida esperada:**
```
================================
GCP Lamudi Scraper - Deploy VMs
================================

Proyecto: guru-491919
Región: us-central1
Máquina: e2-medium

VMs a crear: 5

[Confirmación]
¿Deseas crear 5 VMs en GCP? si

================================
Creando VMs...
================================

[→] Creando VM: lamudi-vm-1
    Descripción: Lamudi Scraper VM 1 (Aguascalientes-Chiapas)
    Script: lamudi_scraper_seleccion1.py
    ✅ VM creada exitosamente

[→] Creando VM: lamudi-vm-2
    ...

✅ ¡Todas las VMs creadas exitosamente!

Próximos pasos:
1. Ir a Google Cloud Console
2. Navegar a Compute Engine > Instancias
3. Conectarse via SSH a cada VM
```

**Tiempo estimado:** 3-5 minutos por VM

### Paso 3: Conéctate a las VMs y Ejecuta los Scripts
```powershell
# Ver estado de todas las VMs
.\deploy_vm_utils.ps1 -Action status

# Conectarse a VM 1
.\deploy_vm_utils.ps1 -Action connect -VMNumber 1

# En la VM (vía SSH):
cd lamudi_scrape
python3 lamudi_scraper_seleccion1.py
```

---

## 📊 Scripts Disponibles

### 1️⃣ **deploy_gcp_setup.ps1**
Configuración inicial de GCP (ejecutar UNA sola vez)

```powershell
.\deploy_gcp_setup.ps1
```

**Acciones:**
- Crear service account
- Asignar permisos IAM
- Habilitar APIs

---

### 2️⃣ **deploy_create_vms.ps1**
Crear las 5 VMs para web scraping

```powershell
.\deploy_create_vms.ps1
```

**VMs creadas:**
| VM | Script | Estados |
|----|--------|---------|
| lamudi-vm-1 | lamudi_scraper_seleccion1.py | Aguascalientes → Chiapas |
| lamudi-vm-2 | lamudi_scraper_seleccion2.py | Chihuahua → Durango |
| lamudi-vm-3 | lamudi_scraper_seleccion3.py | EDOMEX → Jalisco |
| lamudi-vm-4 | lamudi_scraper_seleccion4.py | Michoacán → Oaxaca |
| lamudi-vm-5 | lamudi_scraper_seleccion5.py | Puebla → Zacatecas |

---

### 3️⃣ **deploy_vm_utils.ps1**
Herramientas de monitoreo y control

```powershell
# Ver estado de todas las VMs
.\deploy_vm_utils.ps1

# Conectarse vía SSH
.\deploy_vm_utils.ps1 -Action connect -VMNumber 1

# Ver logs de la VM 2
.\deploy_vm_utils.ps1 -Action logs -VMNumber 2

# Detener VM 3
.\deploy_vm_utils.ps1 -Action stop -VMNumber 3

# Iniciar VM 4
.\deploy_vm_utils.ps1 -Action start -VMNumber 4
```

**Acciones disponibles:**
- `status`: Ver estado de todas las VMs
- `connect`: Conectarse por SSH a una VM
- `logs`: Ver logs de la máquina
- `stop`: Detener una VM
- `start`: Iniciar una VM

---

### 4️⃣ **deploy_delete_vms.ps1**
Eliminar todas las VMs (cuando termine el scraping)

```powershell
.\deploy_delete_vms.ps1
```

⚠️ **ADVERTENCIA:** Esta acción es irreversible. Todos los datos no guardados se perderán.

---

## 💡 Casos de Uso

### Ejecutar scraping completo en paralelo
```powershell
# Terminal 1
.\deploy_vm_utils.ps1 -Action connect -VMNumber 1
# En la VM: python3 lamudi_scraper_seleccion1.py

# Terminal 2
.\deploy_vm_utils.ps1 -Action connect -VMNumber 2
# En la VM: python3 lamudi_scraper_seleccion2.py

# ... y así con las demás
```

### Monitorear progreso
```powershell
# Ver estado de las VMs cada 10 segundos
while($true) {
    Clear-Host
    .\deploy_vm_utils.ps1 -Action status
    Start-Sleep -Seconds 10
}
```

### Detener todos los scrapings
```powershell
for ($i = 1; $i -le 5; $i++) {
    .\deploy_vm_utils.ps1 -Action stop -VMNumber $i
    Write-Host "VM $i detenida"
}
```

### Ver archivo de datos generados
```powershell
# Via SSH en la VM
gsutil ls gs://scraping_inmuebles/Lamudi/2026_03/
gsutil cat gs://scraping_inmuebles/Lamudi/2026_03/aguascalientes_casa.csv | head -100
```

---

## 🐛 Solución de Problemas

### "gcloud no está instalado"
**Solución:** Descargar e instalar desde https://cloud.google.com/sdk/docs/install

### "Proyecto no configurado"
```powershell
gcloud config set project guru-491919
```

### "Permisos insuficientes"
Asignar rol `Editor` al usuario en Google Cloud Console:
1. IAM & Admin > IAM
2. Buscar tu usuario
3. Click en editar
4. Añadir rol `Editor`

### "VMs no se crean"
```powershell
# Verificar quotas de recurso
gcloud compute project-info describe --project=guru-491919

# Ver errores detallados
gcloud compute instances create test-vm --zone=us-central1-a 2>&1
```

### "ChromeDriver no se instala en VM"
La VM descargará automáticamente la versión correcta. Si falla:
```bash
# Dentro de la VM vía SSH
sudo apt-get update
sudo apt-get install -y chromium-browser
which chromium-browser
```

---

## 📈 Monitoreo y Costos

### Costos aproximados (por mes)
- 5 × e2-medium: ~$75 USD
- Storage GCS: ~$5 USD (200GB datos aprox)
- **Total: ~$80 USD/mes**

### Reducir costos
```powershell
# Cambiar a e2-small (1 vCPU, 2GB RAM)
# En deploy_create_vms.ps1:
$MACHINE_TYPE = "e2-small"

# O tirar las VMs cuando no se usen
.\deploy_delete_vms.ps1
```

---

## 📋 Checklist Completo

- [ ] Instalar Google Cloud SDK
- [ ] Ejecutar `gcloud auth login`
- [ ] Ejecutar `.\deploy_gcp_setup.ps1`
- [ ] Verificar service account creada
- [ ] Ejecutar `.\deploy_create_vms.ps1`
- [ ] Esperar 3-5 minutos por VM
- [ ] Verificar VMs con `.\deploy_vm_utils.ps1`
- [ ] Conectarse a cada VM y ejecutar scripts
- [ ] Monitorear progreso
- [ ] Verificar datos en GCS
- [ ] Eliminar VMs cuando termine

---

## 🔗 Enlaces Útiles

- [Google Cloud SDK Docs](https://cloud.google.com/sdk/docs)
- [Compute Engine Pricing](https://cloud.google.com/compute/pricing)
- [Cloud Storage Pricing](https://cloud.google.com/storage/pricing)
- [Service Accounts](https://cloud.google.com/docs/authentication/service-accounts)

---

## ❓ Soporte

Para problemas o dudas:
1. Revisar logs: `.\deploy_vm_utils.ps1 -Action logs -VMNumber X`
2. Conectarse por SSH: `.\deploy_vm_utils.ps1 -Action connect -VMNumber X`
3. Ver documentación oficial de GCP

---

**Última actualización:** Marzo 31, 2026
**Versión:** 1.0
