# Define parameter for config file path
param(
    [string]$ConfigFile = "config.yaml"  # Default to config.yaml if no argument provided
)

# Check if the OPENROUTER_API_KEY environment variable is set
if (-not $env:OPENROUTER_API_KEY) {
    Write-Host "OPENROUTER_API_KEY is not set. Please set it before running this script."
    exit 1
}

# Check if config file exists
if (-not (Test-Path $ConfigFile)) {
    Write-Host "Config file '$ConfigFile' not found."
    exit 1
}

# Start litellm
$litellmProcess = Start-Process -NoNewWindow -FilePath "litellm" -ArgumentList "--config", $ConfigFile -PassThru
$LITELLM_PID = $litellmProcess.Id
Write-Host "Started litellm with PID $LITELLM_PID"

# Start oai2ollama
$oai2ollamaProcess = Start-Process -NoNewWindow -FilePath "oai2ollama" -ArgumentList "--api-key", "any", "--base-url", "http://localhost:4000" -PassThru
$OAI2OLLAMA_PID = $oai2ollamaProcess.Id
Write-Host "Started oai2ollama with PID $OAI2OLLAMA_PID"

# Forward signals and cleanup
function Cleanup {
    Write-Host "`nStopping background processes..."
    if (Get-Process -Id $LITELLM_PID -ErrorAction SilentlyContinue) {
        Stop-Process -Id $LITELLM_PID -Force
    }
    if (Get-Process -Id $OAI2OLLAMA_PID -ErrorAction SilentlyContinue) {
        Stop-Process -Id $OAI2OLLAMA_PID -Force
    }
    exit 0
}

# Set up signal handling
$handler = Register-ObjectEvent -InputObject ([System.Console]) -EventName "CancelKeyPress" -Action { Cleanup }

# Wait for both background processes
Wait-Process -Id $LITELLM_PID
Wait-Process -Id $OAI2OLLAMA_PID
