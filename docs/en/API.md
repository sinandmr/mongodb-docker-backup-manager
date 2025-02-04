# MongoDB Docker Backup Manager API Documentation

## Functions and Usage

### 1. Container Management

#### `select_container()`

- **Description**: Lists Docker containers and allows selection
- **Return Value**: Selected container ID and name
- **Example Usage**:

```bash
select_container
```

### 2. Backup Operations

#### `do_backup()`

- **Description**: Takes backup of selected database
- **Parameters**:
  - `backup_type`: Backup type (full/collection-based)
- **Example Usage**:

```bash
do_backup "full"
```

### 3. Restore Operations

#### `do_restore()`

- **Description**: Restores selected backup
- **Parameters**:
  - `restore_type`: Restore type (full/collection-based)
- **Example Usage**:

```bash
do_restore "full"
```

### 4. Database Operations

#### `select_database()`

- **Description**: Performs database selection
- **Return Value**: Selected database name
- **Example Usage**:

```bash
select_database
```

### 5. Collection Operations

#### `select_collections()`

- **Description**: Performs collection selection
- **Return Value**: List of selected collections
- **Example Usage**:

```bash
select_collections
```

### 6. Backup Management

#### `list_backups()`

- **Description**: Lists available backups
- **Example Usage**:

```bash
list_backups
```

#### `delete_backup()`

- **Description**: Deletes selected backup
- **Example Usage**:

```bash
delete_backup
```

### 7. Statistics and Analysis

#### `show_db_stats()`

- **Description**: Shows database statistics
- **Example Usage**:

```bash
show_db_stats
```

#### `show_backup_content()`

- **Description**: Shows detailed backup content
- **Example Usage**:

```bash
show_backup_content
```

### 8. Comparison Operations

#### `compare_backups()`

- **Description**: Compares two backups
- **Example Usage**:

```bash
compare_backups
```

## Error Codes and Descriptions

- `ERR_NO_CONTAINERS`: No MongoDB container found in Docker
- `ERR_AUTH_FAILED`: Authentication failed
- `ERR_BACKUP_FAILED`: Backup operation failed
- `ERR_RESTORE_FAILED`: Restore operation failed
- `ERR_INVALID_CHOICE`: Invalid selection
- `ERR_NO_DATABASE`: Database not found
- `ERR_NO_BACKUPS`: No backups found

## Security Notes

1. Store credentials securely
2. Keep backups in encrypted storage
3. Securely delete backups containing sensitive data
4. Regularly review authorization controls
