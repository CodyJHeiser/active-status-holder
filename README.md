# Liar Liar I'm Active

## Description

A PowerShell script designed to simulate activity on your computer. It can be configured to run on specific days and times, simulating a keypress. The default is Monday-Friday from 8:00AM to 6:00PM. It will check every 5 minutes and press the `Num Lock` key when no keys have been pressed by the user for 2 minutes.

## Prerequisites

Before running the script, ensure that PowerShell is installed on your system and that script execution is enabled. To enable script execution, you may need to modify your PowerShell execution policy.

**Warning:** Changing the execution policy can have security implications. Only do this if you understand the risks.

To check your current execution policy, open PowerShell and run:

```powershell
Get-ExecutionPolicy
```

If it returns `Restricted`, you need to change it. To allow the execution of scripts, run:

```powershell
Set-ExecutionPolicy RemoteSigned
```

This will allow the execution of scripts written on your local machine but requires remote scripts to be signed by a trusted publisher.

## Installation

This can either be run in the folder or scroll down to [see instructions](#creating-and-setting-up-the-default-powershell-profile) on adding this to the `$profile` for global access.

1. Clone or download the script files (`idle.ps1`, `utilities.ps1`, `config.ps1`) to a folder on your computer.
2. Open the `config.ps1` file in a text editor and adjust the settings (`$sleepInterval`, `$lastInputInterval`, `$activeDays`, `$startTime`, `$endTime`) as per your needs.

## Usage

To run the script:

1. Open PowerShell.
2. Navigate to the directory where you saved the script.
3. Execute the script with the command:
   ```powershell
   .\idle.ps1
   ```
4. The script will display its status and can be terminated at any time by pressing `Ctrl+C`.

## Configuration

- `$sleepInterval`: The interval in seconds between checks for user activity.
- `$lastInputInterval`: The interval in seconds to consider for detecting inactivity.
- `$activeDays`: Days of the week when the script should be active, e.g., "Monday|Tuesday|Wednesday".
- `$startTime`: Start time for the script to run, in 24-hour format, e.g., "08:00".
- `$endTime`: End time for the script to run, in 24-hour format, e.g., "18:00".

Adjust these settings in the `config.ps1` file to suit your requirements.

Certainly! Below are instructions for creating the default PowerShell profile folder and setting up the profile script. These steps ensure that the `Idle` script can be invoked from any location within PowerShell.

---

## Creating and Setting Up the Default PowerShell Profile

### Creating the Default Profile Path

PowerShell uses a profile script to customize the user's environment. If you haven't already set up a profile, follow these steps to create one:

1. **Open PowerShell**:
   You can do this by:

   - Searching for PowerShell in the Start menu.
   - Pressing `Windows+r` and typing `powershell` in the run box.

2. **Check for Existing Profile**:

   - Run the following command to see if you already have a profile:
     ```powershell
     Test-Path $profile
     ```
   - If this returns `True`, you already have a profile set up. If it returns `False`, you'll need to create one.

3. **Create the Profile Folder**:

   - The default location for the PowerShell profile is `Documents\WindowsPowerShell`.
   - If the profile does not exist, you can create the directory by running:
     ```powershell
     New-Item -Path $HOME\Documents\WindowsPowerShell -ItemType Directory -Force
     ```

4. **Create the Profile File**:
   - If you don't have a profile file, create it with:
     ```powershell
     New-Item -Path $profile -ItemType File -Force
     ```

### Setting Up Your Profile for the Idle Script

1. **Edit the PowerShell Profile**:

   - Open the profile script in a text editor (like Notepad) with:
     ```powershell
     notepad $profile
     ```

2. **Add Script to Your Profile**:
   **_Option 1_**
   - In the profile script, add the following lines, replacing `<PathToYourScriptFolder>` with the actual path to the folder where `idle.ps1`, `utilities.ps1`, and `config.ps1` are located:
   ```powershell
   # Load Idle Script Functions
   . "<PathToYourScriptFolder>\utilities.ps1"
   . "<PathToYourScriptFolder>\config.ps1"
   function Global:Idle {
       . "<PathToYourScriptFolder>\idle.ps1"
   }
   ```
   **_Option 2_**
   - Copy and paste the file contents from `profile.ps1` into the profile document.
   - Close any previously open powershell windows to refresh the newly added profile.
   - Open a new powershell window and type `idle` to start the program.

- Save and close the profile script.

### Using the Idle Script

- After setting up your profile, restart PowerShell or open a new session.
- You can now use the `Idle` function globally in any PowerShell session by typing `Idle` and pressing Enter.
- The `$profile` script runs each time a PowerShell session starts, ensuring that the `Idle` function is readily available.

---

This setup allows you to invoke the `Idle` function from anywhere in PowerShell, offering a convenient and efficient way to use your script. Remember to replace `<PathToYourScriptFolder>` with the actual path to your script files.

---

## Disclaimer

Changing the execution policy can have security implications. Only do this if you understand the risks. Please use this program responsibly and with the permission of the device it is running on.
