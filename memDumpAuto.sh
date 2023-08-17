# Define the URL to download WinPMEM from
$winpmemURL = "https://github.com/Velocidex/WinPmem/releases/download/v4.0.rc1/winpmem_mini_x64_rc2.exe"
$winpmemPath = Join-Path -Path (Get-Location) -ChildPath "winpmem_mini_x64_rc2.exe"

# Download the WinPMEM executable
Invoke-WebRequest -Uri $winpmemURL -OutFile $winpmemPath

# Check if the download was successful
if (-not (Test-Path $winpmemPath)) {
    Write-Error "Failed to download WinPMEM executable."
    exit
}

# Define the output file name based on the hostname and current date/time
$hostname = [System.Net.Dns]::GetHostName()
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputFile = Join-Path -Path (Get-Location) -ChildPath "${hostname}_${timestamp}_memory_image.raw"

# Define a spinner
$spinner = '|', '/', '-', '\'
$i = 0

# Start the memory capture and spinner in parallel
$job = Start-Job -ScriptBlock {
    & $using:winpmemPath $using:outputFile
}

# Display spinner while job is running
while ((Get-Job -Id $job.Id).State -eq 'Running') {
    Write-Host "`rCapturing memory $($spinner[$i % $spinner.Length])" -NoNewline
    Start-Sleep -Milliseconds 200
    $i++
}

# Remove the job and print completion message
Remove-Job -Id $job.Id
if ($? -eq $True) {
    Write-Host "`nMemory capture completed and saved to $outputFile"
} else {
    Write-Error "Memory capture failed."
}
