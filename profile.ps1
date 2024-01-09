# Description: PowerShell profile script
# Author: Cody Heiser
# Date: 2024-01-09
# Version: 1.0.0
# Usage: Place this file in the PowerShell profile directory
#   - To find the profile directory, run $profile in PowerShell
#   - If the profile directory/file doesn't exist, create it
#   - Append the contents of this file to it
#   - Restart PowerShell
#   - Run the command "idle" to start the script
#   - Press Ctrl+C to stop the script
function idle {
    # Configuration settings
    $sleepInterval = 5 # Interval in seconds to send keypresses
    $lastInputInterval = 120 # Interval in seconds to check for user activity
    $activeDays = "Monday|Tuesday|Wednesday|Thursday|Friday" # Days when the script is active
    $startTime = "08:00" # Start time in 24-hour format
    $endTime = "18:00" # End time in 24-hour format

    $wshell = $null
    try {
        $wshell = New-Object -ComObject wscript.shell
    } catch {
        Write-Error "Failed to create wscript.shell COM object: $_"
        return
    }

    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    public class User32 {
        [DllImport("user32.dll")]
        public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
    }
"@

    $keyCount = 0
    $actualWorkCount = 0
    $lastInputIntervalSeconds = $lastInputInterval * 1000; # Convert seconds to milliseconds
    $currentDay = (Get-Date).DayOfWeek
    "Running on $activeDays from $startTime to $endTime."
    "Press CTL+C to cancel.`n"

    # Make Ctrl+C not terminate the script immediately
    [console]::TreatControlCAsInput = $true

    while ($true) {
        $currentDateTime = Get-Date
        if ($currentDay -ne $currentDateTime.DayOfWeek) {
            $keyCount = 0
            $actualWorkCount = 0
            $currentDay = $currentDateTime.DayOfWeek
        }

        # Check for Ctrl+C keypress
        $sleepEndTime = [DateTime]::Now.AddSeconds($sleepInterval)
        while ([DateTime]::Now -lt $sleepEndTime) {
            if ([console]::KeyAvailable) {
                $key = [console]::ReadKey($true)
                if ($key.Key -eq "C" -and $key.Modifiers -eq "Control") {
                    Write-Host "`nExiting..."
                    return
                }
            }
            Start-Sleep -Milliseconds 50
        }

        $lastInputInfo = New-Object LASTINPUTINFO
        $lastInputInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($lastInputInfo)
        [void][User32]::GetLastInputInfo([ref]$lastInputInfo)

        $systemUptime = [Environment]::TickCount
        $timeSinceLastInput = $systemUptime - $lastInputInfo.dwTime

        $activeTimeStart = [TimeSpan]::Parse($startTime)
        $activeTimeEnd = [TimeSpan]::Parse($endTime)

        switch ($currentDay) {
            { $_ -match $activeDays } {
                if ($timeSinceLastInput -lt $lastInputIntervalSeconds) {
                    $actualWorkCount++
                }
                if (($currentDateTime.TimeOfDay -ge $activeTimeStart) -and ($currentDateTime.TimeOfDay -le $activeTimeEnd) -and ($timeSinceLastInput -ge $lastInputIntervalSeconds)) {
                    try {
                        $wshell.SendKeys('+')
                        $keyCount++
                    } catch {
                        Write-Error "Failed to send key: $_"
                    }
                }

                # Clear the entire line, then write the new message
                Write-Host "`r$(' ' * $host.UI.RawUI.BufferSize.Width)" -NoNewline
                Write-Host "`rLast updated at $currentDateTime. You've looked busy $keyCount times today. You've actually been working $actualWorkCount times today." -NoNewline
            }
        }
    }
}