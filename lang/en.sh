#!/bin/bash

# English language pack

# Menu texts
MENU_TITLE="MongoDB Backup Manager"
MENU_CONTAINER_SELECT="Select Container"
MENU_DATABASE_SELECT="Select Database"
MENU_DATABASE_CHANGE="Change Database"
MENU_BACKUP="Create Backup"
MENU_RESTORE="Restore Backup"
MENU_LIST="List Backups"
MENU_DELETE="Delete Backup"
MENU_CONTAINER_CHANGE="Change Container"
MENU_HISTORY="Recent Operations"
MENU_EXIT="Exit"

# Info messages
INFO_SELECTED_CONTAINER="Selected Container"
INFO_SELECTED_DATABASE="Selected Database"
INFO_AUTH="Authentication"
INFO_BACKUP_DIR="Backup Directory"
INFO_OS="Operating System"
INFO_DISTRIBUTION="Distribution"
INFO_BACKUP_DESC="Backup Description"
INFO_AVAILABLE_BACKUPS="Available Backups"
INFO_BACKUP_HISTORY="Recent Operations"
INFO_RESTORE_OPTIONS="Restore Options"
INFO_DELETABLE_BACKUPS="Deletable Backups"

# Additional info messages
INFO_DATE="Date"
INFO_SIZE="Size"
INFO_WARNING="WARNING"

# Operation messages
MSG_BACKUP_STARTED="Starting backup..."
MSG_BACKUP_COMPLETED="Backup completed"
MSG_RESTORE_STARTED="Starting restore..."
MSG_RESTORE_COMPLETED="Restore completed"
MSG_TESTING_CONNECTION="Testing MongoDB connection..."
MSG_AUTH_REQUIRED="Authentication required for this MongoDB instance."
MSG_AUTH_SUCCESS="Connection successful (no auth required)"
MSG_AUTH_TESTING="Testing credentials..."
MSG_SINGLE_CONTAINER="Single container found, automatically selected"
MSG_NO_BACKUPS="No backups available yet"
MSG_ENTER_BACKUP_DESC="Enter a description for this backup"
MSG_DEFAULT_DESC="No description provided"
MSG_CONFIRM_DELETE="Are you sure?"

# Additional operation messages
MSG_COPYING_FILES="Copying backup files to container..."
MSG_WARNING="WARNING"
MSG_BACKUP_DELETED="Backup deleted"
MSG_DELETE_CANCELLED="Delete operation cancelled"

# Error messages
ERR_NO_CONTAINERS="No running MongoDB containers found!"
ERR_INVALID_CHOICE="Invalid selection!"
ERR_NO_DATABASE="Please select a database first!"
ERR_AUTH_FAILED="Authentication failed!"
ERR_MAX_ATTEMPTS="Maximum attempts reached!"
ERR_BACKUP_FAILED="MongoDB dump operation failed!"
ERR_COPY_FAILED="Failed to copy backup files!"
ERR_RESTORE_FAILED="MongoDB restore operation failed!"
ERR_DIR_CREATE="Failed to create directory"
ERR_DIR_PERMS="Failed to set directory permissions"

# Additional error messages
ERR_BACKUP_NOT_FOUND="Specified backup directory not found"

# Options
OPT_DEFAULT_DIR="Default directory"
OPT_CUSTOM_DIR="Specify custom directory"
OPT_ALL_DBS="All Databases"
OPT_RESTORE_DROP="Drop existing data and restore backup"
OPT_RESTORE_KEEP="Keep existing data and restore backup"

# Prompt messages
PROMPT_CONTINUE="Press ENTER to continue..."
PROMPT_RETRY="Would you like to try again? (Y/n)"
PROMPT_CHOICE="Your choice"
PROMPT_CHOICE_RANGE="Enter your choice (%d-%d): "
PROMPT_CHOICE_SINGLE="Enter your choice (%d): "
PROMPT_BACKUP_NUMBER="Enter the number of the backup to restore"
PROMPT_DELETE_NUMBER="Enter the number of the backup to delete (0 to cancel)"
PROMPT_BACKUP_DIR="Full path of backup directory"
MSG_NO_HISTORY="No operation history available yet"

# Additional operation messages
MSG_NO_HISTORY="No operation history available yet" 