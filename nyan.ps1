$youtubeURL = "https://www.youtube.com/watch?v=mEJ_jxFJU_0"
$nircmdPath = ".\nircmd.exe"

# Check if NirCmd is present in the current directory
if (-not (Test-Path $nircmdPath)) {
    Write-Host "NirCmd not found. Downloading..."
    $nircmdUrl = "https://www.nirsoft.net/utils/nircmd.zip"
    $nircmdZipPath = ".\nircmd.zip"

    # Download NirCmd zip file
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($nircmdUrl, $nircmdZipPath)

    # Extract NirCmd from the zip file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($nircmdZipPath, ".")

    # Remove the zip file
    Remove-Item -Path $nircmdZipPath
}

# Maximize system volume
Start-Process -FilePath $nircmdPath -ArgumentList "setsysvolume 65535"

while ($true) {
    # Launch Edge browser and navigate to YouTube URL
    $edgeProcess = Start-Process -FilePath "msedge" -ArgumentList $youtubeURL -PassThru

    # Wait for the browser to open and load the page
    Start-Sleep -Seconds 5

    # Find the Edge browser window and maximize it
    $edgeWindow = Get-Process | Where-Object { $_.MainWindowTitle -like "*YouTube*" }
    $edgeWindow | ForEach-Object {
        $hwnd = $_.MainWindowHandle
        $null = [User32]::ShowWindow($hwnd, 3)  # Maximize the window
        $null = [User32]::SetForegroundWindow($hwnd)  # Bring the window to the front
    }

    # Send F11 key to enter full screen mode
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.SendKeys("{F11}")

    # Check if the Edge browser window is closed
    while ($edgeWindow -ne $null -and !$edgeWindow.HasExited) {
        Start-Sleep -Seconds 5
        $edgeWindow = Get-Process | Where-Object { $_.MainWindowTitle -like "*YouTube*" }
    }
}
