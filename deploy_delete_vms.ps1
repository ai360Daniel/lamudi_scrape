# ============================================================================
# Script para Eliminar VMs de Lamudi Scraper
# ============================================================================
# Limpia las VMs creadas (útil si necesitas rehacer el deploy)
# ============================================================================

$PROJECT_ID = "guru-491919"
$ZONE = "us-central1-a"

$VM_NAMES = @(
    "lamudi-vm-1",
    "lamudi-vm-2",
    "lamudi-vm-3",
    "lamudi-vm-4",
    "lamudi-vm-5"
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "GCP Lamudi Scraper - Eliminar VMs" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Write-Host "`nVMs a eliminar:" -ForegroundColor Yellow
foreach ($vm in $VM_NAMES) {
    Write-Host "  - $vm" -ForegroundColor Gray
}

Write-Host "`n⚠️  ADVERTENCIA: Esta acción no se puede deshacer" -ForegroundColor Red
$confirm = Read-Host "¿Deseas continuar? (escribe 'si' para confirmar)"

if ($confirm -ne "si") {
    Write-Host "❌ Operación cancelada" -ForegroundColor Red
    exit 1
}

Write-Host "`nEliminando VMs..." -ForegroundColor Yellow

$successCount = 0
$errorCount = 0

foreach ($vm in $VM_NAMES) {
    Write-Host "`n[→] Eliminando: $vm" -ForegroundColor Yellow
    
    try {
        gcloud compute instances delete $vm `
            --zone=$ZONE `
            --project=$PROJECT_ID `
            --quiet 2>$null
        
        Write-Host "    ✅ VM eliminada" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "    ⚠️  No existe o ya fue eliminada" -ForegroundColor Yellow
    }
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "VMs eliminadas: $successCount/$($VM_NAMES.Count)" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Cyan
