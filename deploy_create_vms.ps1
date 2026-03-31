# ============================================================================
# Script de Despliegue de VMs en GCP para Lamudi Scraper
# ============================================================================
# Crea 5 VMs para ejecutar en paralelo los 5 scripts de scraping
# Cada VM ejecuta una selección de estados diferente
# ============================================================================

$PROJECT_ID = "guru-491919"
$REGION = "us-central1"
$ZONE = "us-central1-a"
$SERVICE_ACCOUNT = "lamudi-scraper@guru-491919.iam.gserviceaccount.com"
$MACHINE_TYPE = "e2-medium"  # 2 vCPU, 4GB RAM
$IMAGE_FAMILY = "debian-12"
$IMAGE_PROJECT = "debian-cloud"
$BOOT_DISK_SIZE = "50GB"

# Definición de VMs (nombre, script, descripción)
$VMS = @(
    @{
        name = "lamudi-vm-1"
        script = "lamudi_scraper_seleccion1.py"
        description = "Lamudi Scraper VM 1 (Aguascalientes-Chiapas)"
    },
    @{
        name = "lamudi-vm-2"
        script = "lamudi_scraper_seleccion2.py"
        description = "Lamudi Scraper VM 2 (Chihuahua-Durango)"
    },
    @{
        name = "lamudi-vm-3"
        script = "lamudi_scraper_seleccion3.py"
        description = "Lamudi Scraper VM 3 (EDOMEX-Jalisco)"
    },
    @{
        name = "lamudi-vm-4"
        script = "lamudi_scraper_seleccion4.py"
        description = "Lamudi Scraper VM 4 (Michoacán-Oaxaca)"
    },
    @{
        name = "lamudi-vm-5"
        script = "lamudi_scraper_seleccion5.py"
        description = "Lamudi Scraper VM 5 (Puebla-Zacatecas)"
    }
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "GCP Lamudi Scraper - Deploy VMs" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "`nProyecto: $PROJECT_ID" -ForegroundColor Yellow
Write-Host "Región: $REGION" -ForegroundColor Yellow
Write-Host "Máquina: $MACHINE_TYPE" -ForegroundColor Yellow
Write-Host "`nVMs a crear: $($VMS.Count)" -ForegroundColor Yellow

# Startup script para instalar dependencias y ejecutar scraper
$STARTUP_SCRIPT = @"
#!/bin/bash
set -e

echo "=== Lamudi Scraper VM Startup ==="
cd /root

# Actualizar sistema
apt-get update
apt-get install -y python3-pip git wget

# Instalar Chrome para Selenium
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
apt-get update
apt-get install -y google-chrome-stable

# Instalar ChromeDriver
CHROME_VERSION=\$(google-chrome --version | awk '{print \$NF}' | cut -d '.' -f1)
wget -q https://googlechromelabs.github.io/chrome-for-testing/
wget -q https://edgedl.me.chromium.org/chromedriver/LATEST_RELEASE_\$CHROME_VERSION -O /tmp/driver_version
DRIVER_VERSION=\$(cat /tmp/driver_version)
wget -q https://edgedl.me.chromium.org/chromedriver/\$DRIVER_VERSION/chromedriver-linux64.zip -O /tmp/chromedriver.zip
unzip /tmp/chromedriver.zip -d /usr/local/bin/
chmod +x /usr/local/bin/chromedriver-linux64/chromedriver

# Clonar repositorio
git clone https://github.com/ai360Daniel/lamudi_scrape.git
cd lamudi_scrape

# Instalar Python dependencies
pip3 install -q -r requirements.txt

echo "=== Máquina lista para ejecutar scraper ==="
echo "Ejecuta: python3 @SCRIPT_NAME@ para comenzar"
"@

Write-Host "`n[Confirmación]" -ForegroundColor Cyan
Write-Host "¿Deseas crear $($VMS.Count) VMs en GCP?" -ForegroundColor Yellow
$confirm = Read-Host "Escribe 'si' para confirmar"

if ($confirm -ne "si") {
    Write-Host "❌ Operación cancelada" -ForegroundColor Red
    exit 1
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Creando VMs..." -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$errorCount = 0

foreach ($vm in $VMS) {
    $VM_NAME = $vm.name
    $SCRIPT_NAME = $vm.script
    $DESCRIPTION = $vm.description
    
    # Reemplazar nombre del script en el startup script
    $STARTUP_SCRIPT_FINAL = $STARTUP_SCRIPT -replace "@SCRIPT_NAME@", $SCRIPT_NAME
    $STARTUP_SCRIPT_FILE = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $STARTUP_SCRIPT_FILE -Value $STARTUP_SCRIPT_FINAL
    
    Write-Host "`n[→] Creando VM: $VM_NAME" -ForegroundColor Yellow
    Write-Host "    Descripción: $DESCRIPTION" -ForegroundColor Gray
    Write-Host "    Script: $SCRIPT_NAME" -ForegroundColor Gray
    
    try {
        gcloud compute instances create $VM_NAME `
            --project=$PROJECT_ID `
            --zone=$ZONE `
            --machine-type=$MACHINE_TYPE `
            --image-family=$IMAGE_FAMILY `
            --image-project=$IMAGE_PROJECT `
            --boot-disk-size=$BOOT_DISK_SIZE `
            --service-account=$SERVICE_ACCOUNT `
            --scopes=cloud-platform `
            --metadata-from-file startup-script=$STARTUP_SCRIPT_FILE `
            --description=$DESCRIPTION `
            --quiet
        
        Write-Host "    ✅ VM creada exitosamente" -ForegroundColor Green
    }
    catch {
        Write-Host "    ❌ Error al crear VM: $_" -ForegroundColor Red
        $errorCount++
    }
    finally {
        Remove-Item $STARTUP_SCRIPT_FILE -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Resumen del Deploy" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "VMs creadas: $($VMS.Count - $errorCount)/$($VMS.Count)" -ForegroundColor Yellow

if ($errorCount -eq 0) {
    Write-Host "`n✅ ¡Todas las VMs creadas exitosamente!" -ForegroundColor Green
    Write-Host "`nPróximos pasos:" -ForegroundColor Yellow
    Write-Host "1. Ir a Google Cloud Console: https://console.cloud.google.com" -ForegroundColor Gray
    Write-Host "2. Navegar a Compute Engine > Instancias" -ForegroundColor Gray
    Write-Host "3. Conectarse via SSH a cada VM y ejecutar:" -ForegroundColor Gray
    Write-Host "   python3 lamudi_scraper_seleccion[1-5].py" -ForegroundColor Gray
    Write-Host "`nListar VMs creadas:" -ForegroundColor Yellow
    gcloud compute instances list --project=$PROJECT_ID --filter="name:lamudi-vm*" --format="table(name,ZONE,MACHINE_TYPE,STATUS)"
} else {
    Write-Host "`n⚠️  Se encontraron errores en la creación de VMs" -ForegroundColor Yellow
}
