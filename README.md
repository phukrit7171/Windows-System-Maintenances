# Windows System Cleanup Tool

A comprehensive Windows batch script for cleaning temporary files, system maintenance, and performance optimization.

## 📋 Overview

This script provides an interactive way to clean up your Windows system by removing temporary files, clearing caches, and optionally running system integrity checks. It's designed with safety and user control in mind.

## ✨ Features

- **Interactive Menu System**: Choose exactly what you want to clean
- **Safety First**: Built-in error handling and administrator privilege checking
- **Flexible Cleanup Options**: From basic temp file cleanup to full system maintenance
- **Progress Feedback**: Clear status messages throughout the process
- **Non-Destructive**: Only removes temporary and cache files, not user data

## 🚀 Quick Start

1. **Download** the script file (`cleanup.bat`)
2. **Right-click** the file and select "Run as administrator" (recommended)
3. **Follow** the interactive menu prompts
4. **Choose** your preferred cleanup level

## 📊 Cleanup Options

### Option 1: Temporary Files Only
- Removes `.tmp` files from current directory
- Cleans user temp folder (`%temp%`)
- Clears Windows temp folder
- Cleans user profile temp directory

### Option 2: Temporary Files + Recent Items
- Everything from Option 1
- Clears Windows "Recent Items" history

### Option 3: Full Cleanup
- Everything from Option 2
- Removes Windows Prefetch files (improves boot time)

### Option 4: Full Cleanup + System Repairs
- Everything from Option 3
- Runs DISM (Deployment Image Servicing and Management) health check
- Executes System File Checker (SFC) scan

## 🔧 System Requirements

- **OS**: Windows 7/8/10/11
- **Privileges**: Some features require administrator rights
- **Disk Space**: Minimal (the script itself is lightweight)

## ⚡ Performance Benefits

After running this script, you may experience:

- **Faster Boot Times**: Prefetch cleanup optimizes startup
- **More Disk Space**: Removal of accumulated temporary files
- **Improved Stability**: System file integrity checks fix corruption
- **Cleaner System**: Removal of unnecessary cache files

## 🛡️ Safety Information

### What This Script Does NOT Touch
- ❌ Personal files (Documents, Pictures, etc.)
- ❌ Installed programs or applications
- ❌ System registry (beyond standard repairs)
- ❌ User settings or configurations

### What Gets Cleaned
- ✅ Temporary files (`.tmp`, temp folders)
- ✅ Windows cache files
- ✅ Prefetch files (if selected)
- ✅ Recent items history (if selected)

## 🔐 Administrator Privileges

While the script can run without admin rights, some features require elevated privileges:

| Feature | Requires Admin | Impact if Missing |
|---------|----------------|-------------------|
| User temp cleanup | No | Full functionality |
| Windows temp cleanup | **Yes** | Limited effectiveness |
| Prefetch cleanup | **Yes** | Feature unavailable |
| System repairs | **Yes** | Feature unavailable |

## 💡 Usage Tips

### Before Running
- **Close applications**: For better file access and cleanup effectiveness
- **Run as administrator**: For full functionality
- **Free up space**: Consider which cleanup level you need

### After Running
- **Restart recommended**: Especially after system repairs
- **Check results**: Review any warning messages
- **Regular maintenance**: Run monthly for optimal performance

## 🐛 Troubleshooting

### Common Issues

**"Access Denied" Errors**
- **Solution**: Run as administrator
- **Alternative**: Choose a lower cleanup level

**"Path Not Found" Errors**
- **Cause**: Normal on some Windows configurations
- **Impact**: No negative effects, script continues

**System Repair Takes Too Long**
- **Normal**: DISM and SFC scans can take 15-60 minutes
- **Tip**: Don't interrupt the process

**Script Stops Responding**
- **Wait**: System repairs are intensive operations
- **Monitor**: Check Task Manager for DISM/SFC activity

## 📈 Advanced Usage

### Command Line Arguments
Currently, this script runs interactively. For automated deployment, you can modify the choice commands or create wrapper scripts.

### Scheduling
To run automatically:
1. Open Task Scheduler
2. Create Basic Task
3. Set to run script with administrator privileges
4. Modify script to auto-select options for unattended operation

### Customization
The script is modular - you can easily:
- Add new cleanup targets
- Modify existing cleanup rules
- Integrate with other maintenance tools

## 🔄 What Happens During Each Step

### Temporary File Cleanup
```
[TASK] Cleaning temporary files...
  - Removing .tmp files from current directory...
  - Cleaning user temp folder...
  - Cleaning Windows temp folder...
  - Cleaning user profile temp...
[DONE] Temporary files cleanup completed
```

### System Repairs
```
[SCAN] Running DISM health check...
[SCAN] Running DISM restore health...
[SCAN] Running System File Checker...
[DONE] System file check completed successfully
```

## 📝 Change Log

### Version 2.0 (Current)
- Added interactive menu system
- Improved error handling
- Added administrator privilege checking
- Modular function design
- Enhanced user feedback

### Version 1.0 (Original)
- Basic temp file cleanup
- System repair functionality
- Simple batch operations

## 🤝 Contributing

Found a bug or have a suggestion? Feel free to:
- Report issues with specific error messages
- Suggest additional cleanup targets
- Propose safety improvements

## ⚠️ Disclaimer

This script is provided as-is for system maintenance purposes. While designed to be safe:
- **Test first** on a non-critical system if possible
- **Backup important data** before major system changes
- **Review the code** if you have concerns about specific operations

The script only targets temporary and cache files, but users should always exercise caution when running system maintenance tools.

## 🏷️ License

This script is provided for educational and maintenance purposes. Feel free to modify and distribute according to your needs.

---

**Last Updated**: August 2025  
**Compatibility**: Windows 7/8/10/11  
**Status**: Actively maintained
