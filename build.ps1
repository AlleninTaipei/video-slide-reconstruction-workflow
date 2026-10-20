param(
    [Parameter(Mandatory = $true)]
    [string]$Spec,
    [string]$OutputName = "reconstructed-deck",
    [string]$Python = "python"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$specPath = (Resolve-Path -LiteralPath $Spec).Path
$outputDir = Join-Path $repoRoot "output"
$pptxPath = Join-Path $outputDir "$OutputName.pptx"
$pdfPath = Join-Path $outputDir "$OutputName.pdf"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

& $Python (Join-Path $repoRoot "scripts/build_pptx.py") $specPath $pptxPath
if ($LASTEXITCODE -ne 0) { throw "PPTX build failed." }

& $Python (Join-Path $repoRoot "scripts/build_pdf.py") $specPath $pdfPath
if ($LASTEXITCODE -ne 0) { throw "PDF build failed." }

& $Python (Join-Path $repoRoot "scripts/validate_pptx.py") $pptxPath
if ($LASTEXITCODE -ne 0) { throw "PPTX validation failed." }

& $Python (Join-Path $repoRoot "scripts/validate_pdf.py") $pdfPath
if ($LASTEXITCODE -ne 0) { throw "PDF validation failed." }

Write-Output "PPTX: $pptxPath"
Write-Output "PDF:  $pdfPath"
