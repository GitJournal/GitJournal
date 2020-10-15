# Uninstalling an app

Real Devices: ideviceinstaller -U io.gitjournal.gitjournal
For Simulators: xcrun simctl uninstall booted io.gitjournal.gitjournal

# List Devices

xcrun instruments -s devices

# Access File System

cd ~/Library/Developer/CoreSimulator/Devices/

Get deivce ID from List Devices. This doesn't seem to work for actual devices.

# Logs

