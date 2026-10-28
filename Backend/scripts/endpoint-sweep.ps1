$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$outLog = Join-Path $projectRoot "sweep-boot.out.log"
$errLog = Join-Path $projectRoot "sweep-boot.err.log"
$port = 8089

if (Test-Path $outLog) { Remove-Item $outLog -Force }
if (Test-Path $errLog) { Remove-Item $errLog -Force }

$proc = Start-Process -FilePath "$projectRoot\gradlew.bat" -ArgumentList ":pocketledger-service:bootRun", "--args=--server.port=$port" -WorkingDirectory $projectRoot -PassThru -RedirectStandardOutput $outLog -RedirectStandardError $errLog

try {
  $ready = $false
  for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Seconds 2
    try {
      $code = (Invoke-WebRequest -Uri "http://localhost:$port/api-docs" -Method Get -TimeoutSec 2).StatusCode
      $ready = $true
      break
    }
    catch {
      if ($_.Exception.Response) {
        $ready = $true
        break
      }
    }
  }

  if (-not $ready) {
    Write-Output "SERVICE_NOT_READY"
    if (Test-Path $outLog) { Get-Content $outLog -Tail 80 | Out-String | Write-Output }
    if (Test-Path $errLog) { Get-Content $errLog -Tail 80 | Out-String | Write-Output }
    exit 1
  }

  function Get-Status($Method, $Uri, $Headers = $null, $Body = $null) {
    try {
      $params = @{ Method = $Method; Uri = $Uri; TimeoutSec = 8 }
      if ($Headers) { $params.Headers = $Headers }
      if ($Body) {
        $params.ContentType = 'application/json'
        $params.Body = ($Body | ConvertTo-Json -Depth 8)
      }
      $resp = Invoke-WebRequest @params
      return [int]$resp.StatusCode
    }
    catch {
      if ($_.Exception.Response) { return [int]$_.Exception.Response.StatusCode }
      return -1
    }
  }

  $rows = @()
  $stamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  $registerBody = @{ email = "sweep_$stamp@pocketledger.com"; password = 'password123'; fullName = 'Sweep Tester'; currency = 'USD' }
  $registerStatus = -1
  $token = $null

  try {
    $regResp = Invoke-WebRequest -Method Post -Uri "http://localhost:$port/api/v1/auth/register" -ContentType 'application/json' -Body ($registerBody | ConvertTo-Json) -TimeoutSec 8
    $registerStatus = [int]$regResp.StatusCode
    if ($registerStatus -in 200, 201) {
      $token = ($regResp.Content | ConvertFrom-Json).token
    }
  }
  catch {
    if ($_.Exception.Response) { $registerStatus = [int]$_.Exception.Response.StatusCode }
  }
  $rows += [pscustomobject]@{ Endpoint = 'auth.register'; Status = $registerStatus }

  if ($token) {
    $headers = @{ Authorization = "Bearer $token" }

    $rows += [pscustomobject]@{ Endpoint = 'auth.me'; Status = (Get-Status -Method Get -Uri "http://localhost:$port/api/v1/auth/me" -Headers $headers) }

    $txBody = @{ amount = 120.50; type = 'EXPENSE'; category = 'FOOD'; transactionDate = '2026-10-28'; description = 'Groceries' }
    $rows += [pscustomobject]@{ Endpoint = 'transaction.create'; Status = (Get-Status -Method Post -Uri "http://localhost:$port/api/v1/transactions" -Headers $headers -Body $txBody) }
    $rows += [pscustomobject]@{ Endpoint = 'transaction.list'; Status = (Get-Status -Method Get -Uri "http://localhost:$port/api/v1/transactions" -Headers $headers) }

    $budgetBody = @{ category = 'FOOD'; monthlyLimit = 500.00; month = 10; year = 2026 }
    $rows += [pscustomobject]@{ Endpoint = 'budget.set'; Status = (Get-Status -Method Post -Uri "http://localhost:$port/api/v1/budgets" -Headers $headers -Body $budgetBody) }
    $rows += [pscustomobject]@{ Endpoint = 'budget.progress'; Status = (Get-Status -Method Get -Uri "http://localhost:$port/api/v1/budgets/progress?year=2026&month=10" -Headers $headers) }

    $goalBody = @{ title = 'Emergency Fund'; targetAmount = 2000.00; targetDate = '2027-06-01' }
    $rows += [pscustomobject]@{ Endpoint = 'savingsGoal.create'; Status = (Get-Status -Method Post -Uri "http://localhost:$port/api/v1/savings-goals" -Headers $headers -Body $goalBody) }
    $rows += [pscustomobject]@{ Endpoint = 'savingsGoal.list'; Status = (Get-Status -Method Get -Uri "http://localhost:$port/api/v1/savings-goals" -Headers $headers) }

    $rows += [pscustomobject]@{ Endpoint = 'analytics.monthlySummary'; Status = (Get-Status -Method Get -Uri "http://localhost:$port/api/v1/analytics/monthly-summary?year=2026&month=10" -Headers $headers) }
  }

  $rows | Format-Table -AutoSize | Out-String | Write-Output
}
finally {
  if ($proc -and -not $proc.HasExited) {
    Stop-Process -Id $proc.Id -Force
  }
}

