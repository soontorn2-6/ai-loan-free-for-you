$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskRootEnv = Join-Path $taskRoot '.env'
$taskApiEnv = Join-Path $taskRoot 'apps/api/.env'
if (-not (Test-Path -LiteralPath $taskRootEnv)) {
    $taskPassword = [guid]::NewGuid().ToString('N')
    @("POSTGRES_USER=loan_demo", "POSTGRES_PASSWORD=$taskPassword", "POSTGRES_DB=loan_demo", 'POSTGRES_PORT=5433') |
        Set-Content -LiteralPath $taskRootEnv -Encoding utf8
}
if (-not (Test-Path -LiteralPath $taskApiEnv)) {
    $taskSettings = @{}
    foreach ($taskLine in Get-Content -LiteralPath $taskRootEnv) {
        if ($taskLine -match '^([A-Z_]+)=(.*)$') { $taskSettings[$matches[1]] = $matches[2] }
    }
    foreach ($taskKey in @('POSTGRES_USER', 'POSTGRES_PASSWORD', 'POSTGRES_DB', 'POSTGRES_PORT')) {
        if (-not $taskSettings[$taskKey]) { throw "Missing $taskKey in local .env" }
    }
    $taskUser = [uri]::EscapeDataString($taskSettings['POSTGRES_USER'])
    $taskPass = [uri]::EscapeDataString($taskSettings['POSTGRES_PASSWORD'])
    $taskDb = [uri]::EscapeDataString($taskSettings['POSTGRES_DB'])
    $taskPort = $taskSettings['POSTGRES_PORT']
    @('APP_MODE=demo', 'PORT=3001', "DATABASE_URL=postgresql://${taskUser}:${taskPass}@127.0.0.1:${taskPort}/${taskDb}") |
        Set-Content -LiteralPath $taskApiEnv -Encoding utf8
}
Write-Output 'Local demo configuration ready; existing files preserved.'
