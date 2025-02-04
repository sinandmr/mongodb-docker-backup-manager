# MongoDB Docker Backup Manager Usage Scenarios

## 1. Basic Usage Scenarios

### 1.1 First Time Usage

```bash
# Run the script
./mongo_backup_manager.sh

# Select language (1: Turkish, 2: English)
# Select container
# Select database
```

### 1.2 Taking Full Backup

```bash
1) Select Take Backup option
1) Select Full Backup option
# Enter backup description
```

### 1.3 Taking Collection-Based Backup

```bash
1) Select Take Backup option
2) Select Collection-Based Backup option
# Select collections
# Enter backup description
```

### 1.4 Restoring Backup

```bash
2) Select Restore Backup option
# Select backup
1) Overwrite or 2) Keep Existing Data option
```

## 2. Advanced Usage Scenarios

### 2.1 Comparing Backups

```bash
10) Select Compare Backups option
# Select first backup
# Select second backup
# Review comparison results
```

### 2.2 Viewing Database Statistics

```bash
8) Select Database Statistics option
# Review statistics
```

### 2.3 Examining Backup Content

```bash
9) Select Backup Content option
# Select backup to examine
```

## 3. Management Scenarios

### 3.1 Cleaning Old Backups

```bash
4) Select Delete Backup option
# Select backup to delete
# Confirm deletion
```

### 3.2 Changing Container

```bash
5) Select Change Container option
# Select new container
```

### 3.3 Changing Database

```bash
6) Select Change Database option
# Select new database
```

## 4. Monitoring and Reporting Scenarios

### 4.1 Reviewing Backup History

```bash
7) Select Recent Operations option
# Review operation history
```

### 4.2 Examining Backup Sizes

```bash
3) Select List Backups option
# Review backup sizes and dates
```

## 5. Security Scenarios

### 5.1 Connecting to Database Requiring Authentication

```bash
# After container selection
MongoDB username: [enter username]
MongoDB password: [enter password]
Authentication database: [enter auth db name]
```

### 5.2 Using SSL/TLS Connection

```bash
# Ensure container's SSL/TLS certificates are properly configured
# Follow normal connection steps
```

## 6. Error Handling Scenarios

### 6.1 Connection Error Situation

```bash
# Check error message
# Verify container is running
# Check credentials
# Retry
```

### 6.2 Insufficient Disk Space Situation

```bash
# Free up space in backup directory
# Clean old backups
# Retry backup operation
```

## 7. Performance Optimization Scenarios

### 7.1 Backing Up Large Databases

```bash
# Check disk space before backup
# Use collection-based backup
# Schedule backup during quiet hours
```

### 7.2 Optimizing Backups

```bash
# Regularly clean old backups
# Exclude unnecessary collections
# Store backups in compressed format
```
