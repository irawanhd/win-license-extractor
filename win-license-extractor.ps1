# ========================================
# Windows License Extractor (Personal Use)
# ========================================
# Usage: Extracts or recovers Windows product keys for personal use.
# Supports: Windows 10, 11, and Windows Server editions.
# Modes: Extract from the current system or recover from an external Windows installation.

# Store the current execution policy to restore after script execution
$OriginalPolicy = Get-ExecutionPolicy

# Temporarily allow script execution for this session only
Set-ExecutionPolicy Bypass -Scope Process -Force

# --------------------------------------
# Function: Extract Windows License Key from Current PC
# --------------------------------------
function Extract-WindowsKey {
    Write-Host "[*] Extracting Windows License Key from Current PC..."
    try {
        # Get the Windows Product Key from the local registry
        $ProductKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name BackupProductKeyDefault).BackupProductKeyDefault
        
        if ($ProductKey) {
            Write-Host "[+] License Key Found: $ProductKey"
        } else {
            Write-Host "[!] License Key Not Found!"
        }
    } catch {
        Write-Host "[!] Error extracting the key: $_"
    }
}

# --------------------------------------
# Function: Recover Windows License Key from an External Drive
# --------------------------------------
function Recover-WindowsKey {
    # Prompt user for the drive letter of the external Windows installation
    do {
        $OfflineDrive = Read-Host "Enter the drive letter of the external Windows installation (e.g., D)"
    } until ($OfflineDrive -match "^[A-Za-z]$")  # Validate input as a single letter (A-Z)

    # Construct full path to the Windows registry hive
    $OfflineWindowsPath = "$OfflineDrive`:\Windows"
    $SoftwareHive = "$OfflineWindowsPath\System32\config\SOFTWARE"
    $RegistryMountPoint = "HKLM\RecoveredWindows"

    Write-Host "[*] Loading registry hive from $SoftwareHive..."
    
    # Attempt to load the registry hive
    $LoadResult = reg load $RegistryMountPoint $SoftwareHive 2>&1

    if ($LoadResult -match "The operation completed successfully") {
        try {
            Write-Host "[*] Recovering Windows License Key from External Windows..."
            # Get the Windows Product Key from the loaded registry hive
            $ProductKey = Get-ItemProperty -Path "$RegistryMountPoint\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name BackupProductKeyDefault | Select-Object -ExpandProperty BackupProductKeyDefault
            
            if ($ProductKey) {
                Write-Host "[+] Recovered License Key: $ProductKey"
            } else {
                Write-Host "[!] No License Key Found!"
            }
        } catch {
            Write-Host "[!] Error recovering the key: $_"
        } finally {
            # Ensure the registry hive is unloaded after use
            Write-Host "[*] Unloading registry hive..."
            reg unload $RegistryMountPoint | Out-Null
        }
    } else {
        Write-Host "[!] Failed to load registry. Ensure the drive contains a valid Windows installation."
    }
}

# --------------------------------------
# Menu Selection: User Chooses Extraction or Recovery Mode
# --------------------------------------
Write-Host "================================"
Write-Host " Windows License Extractor (Personal Use) "
Write-Host "================================"
Write-Host "1. Extract from Current PC"
Write-Host "2. Recover from External Windows Installation"
Write-Host "3. Exit"
Write-Host "================================"
$Choice = Read-Host "Enter your choice (1/2/3)"

switch ($Choice) {
    "1" { Extract-WindowsKey }
    "2" { Recover-WindowsKey }
    "3" { Write-Host "[*] Exiting script."; exit }
    default { Write-Host "[!] Invalid choice. Please select 1, 2, or 3." }
}

# Restore the original execution policy after script execution
Set-ExecutionPolicy $OriginalPolicy -Scope Process -Force

Write-Host "[+] Process completed!"
