# **ChronoSync: Real-Time File Backup and Versioning Tool**  

ChronoSync is a lightweight, real-time file backup and version control tool designed to simplify data protection and ensure the availability of previous file versions. By leveraging `rsync` for efficient synchronization and `inotifywait` for real-time monitoring, ChronoSync ensures that your critical files are backed up as soon as they are modified.

---

## **Features**  

1. **Real-Time Backup**: Automatically monitors and backs up files and directories as soon as changes are detected.  
2. **Version Control**: Saves backups with incremental version numbers (e.g., `File_v1.txt`, `File_v2.txt`), allowing easy access to historical versions.  
3. **Automatic Directory Creation**: If the specified backup destination doesn’t exist, it is automatically created.  
4. **Startup Integration**: Configured to run automatically on system startup, ensuring continuous protection.  
5. **Detailed Logs**: Maintains a `.csv` log file recording version number, timestamp, size, permissions, and file type for every backup.  
6. **Easy Configuration**: Simple configuration interface for defining source files and backup destinations. Configurations persist across restarts.  
7. **Error Handling**: Detects and handles common issues, such as missing dependencies (`rsync`, `inotifywait`) and invalid configurations.  

---

## **Use Cases**  

1. **Software Development**: Automatically back up source code changes to avoid data loss.  
2. **Document Management**: Keep versions of critical documents for auditing and compliance purposes.  
3. **Creative Workflows**: Protect evolving creative projects, such as design files or manuscripts.  
4. **Data Recovery**: Retrieve previous versions of files when accidental edits or deletions occur.  

---

## **How It Works**  

1. **Monitoring**: The script uses `inotifywait` to monitor specified files and directories for changes.  
2. **Incremental Backup**: Upon detecting a modification, it triggers `rsync` to back up the file/directory to the specified destination.  
3. **Version Tracking**: Each backup is saved with an incremented version number.  
4. **Logging**: Logs each backup operation in a `.csv` file for detailed tracking.  

---

## **Installation**  

Run the script on a Linux system. Dependencies (`rsync` and `inotifywait`) are checked and installed automatically if not present.  

1. **Clone or Download**: Save the `ChronoSync.sh` script to your system.  
2. **Run the Script**:  
   ```bash
   chmod +x ChronoSync.sh
   ./ChronoSync.sh --config
   ```  
3. **Configure Backups**: Follow the prompts to set up files and destinations for backup.  

---

## **Usage**  

### **Initial Setup**  
- Use the `--config` flag to add files or directories to the backup list.  
   ```bash
   ./ChronoSync.sh --config
   ```  

### **Run the Script**  
- Simply execute the script to start monitoring for changes:  
   ```bash
   ./ChronoSync.sh
   ```  

### **Startup Integration**  
- ChronoSync is automatically added to the system startup sequence.  

---

## **Log File Format**  

ChronoSync creates a `.csv` log file in the backup directory:  

| **Version** | **Timestamp**       | **File Name**      | **Size (KB)** | **Type** | **Permissions** |  
|-------------|---------------------|--------------------|---------------|----------|-----------------|  
| 1           | 2024-11-12 16:09:30 | TestFile.txt_v1    | 16            | File     | rw-r--r--       |  

---

## **System Requirements**  

- **OS**: Linux-based system  
- **Dependencies**:  
  - `rsync`: For efficient file synchronization  
  - `inotifywait`: For real-time file monitoring  
  - Bash shell  

---

## **License**  

ChronoSync is released under the MIT License. You are free to use, modify, and distribute it with proper attribution.  

---