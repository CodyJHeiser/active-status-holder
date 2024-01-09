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

# Include the utilities and configuration files
. .\utilities.ps1
. .\config.ps1

function idle {
    # Initialize the COM object for simulating keypresses
    $wshell = $null
    try {
        $wshell = New-Object -ComObject wscript.shell
    } catch {
        Write-Error "Failed to create wscript.shell COM object: $_"
        return
    }

    # Initialize counters and current day tracking
    $keyCount = 0
    $actualWorkCount = 0
    $lastInputIntervalSeconds = $lastInputInterval * 1000; # Convert seconds to milliseconds
    $currentDay = (Get-Date).DayOfWeek

    # Display script running information
    "Running on $activeDays from $startTime to $endTime."
    "Press CTL+C to cancel.`n"

    # Configure the script to treat Ctrl+C as input rather than an interrupt
    [console]::TreatControlCAsInput = $true

    # Main loop
    while ($true) {
        $currentDateTime = Get-Date

        # Check if the day has changed, reset counters if it has
        if ($currentDay -ne $currentDateTime.DayOfWeek) {
            $keyCount = 0
            $actualWorkCount = 0
            $currentDay = $currentDateTime.DayOfWeek
        }

        # Responsive sleep loop to check for Ctrl+C keypress
        $sleepEndTime = [DateTime]::Now.AddSeconds($sleepInterval)
        while ([DateTime]::Now -lt $sleepEndTime) {
            if ([console]::KeyAvailable) {
                $key = [console]::ReadKey($true)
                # Check if the key pressed is Ctrl+C
                if ($key.Key -eq "C" -and $key.Modifiers -eq "Control") {
                    Write-Host "`nExiting..."
                    return
                }
            }
            # Short sleep to allow for responsive key detection
            Start-Sleep -Milliseconds 50
        }

        # Get the last input info to determine user activity
        $lastInputInfo = New-Object LASTINPUTINFO
        $lastInputInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($lastInputInfo)
        [void][User32]::GetLastInputInfo([ref]$lastInputInfo)

        # Calculate time since last user input
        $systemUptime = [Environment]::TickCount
        $timeSinceLastInput = $systemUptime - $lastInputInfo.dwTime

        # Parse active time start and end from the configuration
        $activeTimeStart = [TimeSpan]::Parse($startTime)
        $activeTimeEnd = [TimeSpan]::Parse($endTime)

        # Check and update status based on the current day and time
        switch ($currentDay) {
            { $_ -match $activeDays } {
                # Update actual work count
                if ($timeSinceLastInput -lt $lastInputIntervalSeconds) {
                    $actualWorkCount++
                }
                # Simulate activity and update key count
                if (($currentDateTime.TimeOfDay -ge $activeTimeStart) -and ($currentDateTime.TimeOfDay -le $activeTimeEnd) -and ($timeSinceLastInput -ge $lastInputIntervalSeconds)) {
                    try {
                        $wshell.SendKeys('+')
                        $keyCount++
                    } catch {
                        Write-Error "Failed to send key: $_"
                    }
                }

                # Clear the console line and display the status message
                Write-Host "`r$(' ' * $host.UI.RawUI.BufferSize.Width)" -NoNewline
                Write-Host "`rLast updated at $currentDateTime. You've looked busy $keyCount times today. You've actually been working $actualWorkCount times today." -NoNewline
            }
        }
    }
}

# Start the idle function
idle
