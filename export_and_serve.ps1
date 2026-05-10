# Adjust this if Godot is not in your PATH.
# Example: $GODOT = "C:\Users\you\AppData\Local\Programs\Godot\Godot_v4.6-stable_win64.exe"
$GODOT = "godot"

$EXPORT_DIR = "exports\web"
$PORT = 8080

# Ensure export directory exists
New-Item -ItemType Directory -Force -Path $EXPORT_DIR | Out-Null

# Export
Write-Host "Exporting project (release)..." -ForegroundColor Cyan
& $GODOT --headless --export-release "Web" "$EXPORT_DIR\index.html"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Export failed. Check that the 'Web' export preset exists in Godot." -ForegroundColor Red
    exit 1
}
Write-Host "Export complete." -ForegroundColor Green

# Kill anything already on the port
$conn = netstat -ano | Select-String ":$PORT\s.*LISTENING"
if ($conn) {
    $existingPid = ($conn.ToString().Trim() -split '\s+')[-1]
    Stop-Process -Id $existingPid -Force -ErrorAction SilentlyContinue
    Write-Host "Stopped process on port $PORT (PID $existingPid)."
}

# Start server (blocking — Ctrl+C to stop)
Write-Host "Starting server..." -ForegroundColor Cyan
python serve.py
