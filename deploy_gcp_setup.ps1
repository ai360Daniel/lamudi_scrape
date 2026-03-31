# ============================================================================
# Script de Configuración GCP para Lamudi Scraper
# ============================================================================
# Este script configura las credenciales, service account y permisos necesarios
# Ejecutar ANTES de deploy_create_vms.ps1
# ============================================================================

$PROJECT_ID = "guru-491919"
$REGION = "us-central1"
$ZONE = "us-central1-a"
$SERVICE_ACCOUNT_NAME = "lamudi-scraper"
$BUCKET_NAME = "scraping_inmuebles"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "GCP Lamudi Scraper - Setup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# 1. Verificar que gcloud está instalado
Write-Host "`n[1/5] Verificando gcloud CLI..." -ForegroundColor Yellow
$gcloud = Get-Command gcloud -ErrorAction SilentlyContinue
if (-not $gcloud) {
    Write-Host "❌ gcloud CLI no está instalado. Por favor instálalo desde:" -ForegroundColor Red
    Write-Host "https://cloud.google.com/sdk/docs/install"
    exit 1
}
Write-Host "✅ gcloud CLI encontrado" -ForegroundColor Green

# 2. Configurar proyecto GCP
Write-Host "`n[2/5] Configurando proyecto GCP: $PROJECT_ID..." -ForegroundColor Yellow
gcloud config set project $PROJECT_ID
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al configurar proyecto" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Proyecto configurado" -ForegroundColor Green

# 3. Crear service account
Write-Host "`n[3/5] Creando service account: $SERVICE_ACCOUNT_NAME..." -ForegroundColor Yellow
$SA_EMAIL = "$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# Verificar si ya existe
$sa_exists = gcloud iam service-accounts list --filter="email:$SA_EMAIL" --format="value(email)" 2>$null
if ($sa_exists) {
    Write-Host "⚠️  Service account ya existe: $SA_EMAIL" -ForegroundColor Yellow
} else {
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME `
        --display-name="Lamudi Web Scraper Service Account" `
        --description="Service account para ejecutar scraper en VMs" `
        2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Service account creada: $SA_EMAIL" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Service account no pudo ser creada (puede que ya exista)" -ForegroundColor Yellow
    }
}

# 4. Asignar permisos al bucket
Write-Host "`n[4/5] Asignando permisos al bucket: $BUCKET_NAME..." -ForegroundColor Yellow
$roles = @(
    "roles/storage.objectCreator",
    "roles/storage.objectViewer",
    "roles/storage.bucketReader"
)

foreach ($role in $roles) {
    gcloud projects add-iam-policy-binding $PROJECT_ID `
        --member="serviceAccount:$SA_EMAIL" `
        --role="$role" `
        --quiet 2>$null
}
Write-Host "✅ Permisos asignados al service account" -ForegroundColor Green

# 5. Habilitar APIs necesarias
Write-Host "`n[5/5] Habilitando APIs necesarias..." -ForegroundColor Yellow
$apis = @(
    "compute.googleapis.com",
    "storage-api.googleapis.com",
    "iam.googleapis.com"
)

foreach ($api in $apis) {
    gcloud services enable $api --quiet 2>$null
}
Write-Host "✅ APIs habilitadas" -ForegroundColor Green

# 6. Crear regla de firewall para Cloud IAP
Write-Host "`n[6/6] Creando regla de firewall para Cloud Identity-Aware Proxy (IAP)..." -ForegroundColor Yellow
gcloud compute firewall-rules create allow-iap-ssh `
    --allow=tcp:22 `
    --source-ranges=35.235.240.0/20 `
    --description="Allow Cloud IAP to connect via SSH" `
    --quiet 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Regla de firewall creada para IAP" -ForegroundColor Green
} else {
    Write-Host "⚠️  Regla de firewall IAP no pudo ser creada (puede que ya exista)" -ForegroundColor Yellow
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "✅ Setup completado exitosamente!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host "`nSiguiente paso: ejecutar deploy_create_vms.ps1" -ForegroundColor Yellow
