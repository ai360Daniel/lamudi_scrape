# ============================================================================
# Script de Utilidades para Lamudi Scraper VMs
# ============================================================================
# Monitorea, conecta y gestiona las VMs en ejecución
# ============================================================================

param(
    [ValidateSet("status", "connect", "logs", "stop", "start")]
    [string]$Action = "status",
    [int]$VMNumber = 1
)

$PROJECT_ID = "guru-491919"
$ZONE = "us-central1-a"
$VM_BASE_NAME = "lamudi-vm"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "GCP Lamudi Scraper - Utilidades" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

function Show-Status {
    Write-Host "`n📊 Estado de las VMs:" -ForegroundColor Yellow
    gcloud compute instances list `
        --project=$PROJECT_ID `
        --filter="name:lamudi-vm*" `
        --format="table(name,zone.basename(),machineType.machine_type().basename(),status,INTERNAL_IP,EXTERNAL_IP)"
}

function Connect-VM {
    $VM_NAME = "$VM_BASE_NAME-$VMNumber"
    Write-Host "`n🔌 Conectando a $VM_NAME..." -ForegroundColor Yellow
    
    # Verificar si la VM existe
    $vm_exists = gcloud compute instances list `
        --project=$PROJECT_ID `
        --filter="name:$VM_NAME" `
        --format="value(name)" 2>$null
    
    if (-not $vm_exists) {
        Write-Host "❌ VM no encontrada: $VM_NAME" -ForegroundColor Red
        return
    }
    
    Write-Host "✅ Conectando via SSH..." -ForegroundColor Green
    gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID
}

function Show-Logs {
    $VM_NAME = "$VM_BASE_NAME-$VMNumber"
    Write-Host "`n📋 Mostrando logs de $VM_NAME..." -ForegroundColor Yellow
    
    gcloud compute instances get-serial-port-output $VM_NAME `
        --zone=$ZONE `
        --project=$PROJECT_ID | tail -100
}

function Stop-VM {
    $VM_NAME = "$VM_BASE_NAME-$VMNumber"
    Write-Host "`n⏹️  Deteniendo $VM_NAME..." -ForegroundColor Yellow
    
    gcloud compute instances stop $VM_NAME `
        --zone=$ZONE `
        --project=$PROJECT_ID `
        --async
    
    Write-Host "✅ VM detenida (proceso asincrónico)" -ForegroundColor Green
}

function Start-VM {
    $VM_NAME = "$VM_BASE_NAME-$VMNumber"
    Write-Host "`n▶️  Iniciando $VM_NAME..." -ForegroundColor Yellow
    
    gcloud compute instances start $VM_NAME `
        --zone=$ZONE `
        --project=$PROJECT_ID `
        --async
    
    Write-Host "✅ VM iniciada (proceso asincrónico)" -ForegroundColor Green
}

# Ejecutar acción solicitada
switch ($Action) {
    "status" {
        Show-Status
    }
    "connect" {
        if ($VMNumber -lt 1 -or $VMNumber -gt 5) {
            Write-Host "❌ Número de VM debe estar entre 1 y 5" -ForegroundColor Red
            exit 1
        }
        Connect-VM
    }
    "logs" {
        if ($VMNumber -lt 1 -or $VMNumber -gt 5) {
            Write-Host "❌ Número de VM debe estar entre 1 y 5" -ForegroundColor Red
            exit 1
        }
        Show-Logs
    }
    "stop" {
        if ($VMNumber -lt 1 -or $VMNumber -gt 5) {
            Write-Host "❌ Número de VM debe estar entre 1 y 5" -ForegroundColor Red
            exit 1
        }
        Stop-VM
    }
    "start" {
        if ($VMNumber -lt 1 -or $VMNumber -gt 5) {
            Write-Host "❌ Número de VM debe estar entre 1 y 5" -ForegroundColor Red
            exit 1
        }
        Start-VM
    }
}

Write-Host "`n"
