# MongoDB Docker Backup Manager Contributing Guide

## 1. Getting Started

### 1.1 Development Environment Setup

1. Clone the repository:

```bash
git clone https://github.com/username/mongo-backup-manager.git
cd mongo-backup-manager
```

2. Prepare test environment:

```bash
# Start MongoDB test container
docker run -d --name mongodb-test -p 27017:27017 mongo:latest

# Install required dependencies
# (According to project needs)
```

### 1.2 Code Standards

- Follow Bash script writing conventions
- Use descriptive function and variable names
- Add comments for each function
- Don't forget error handling
- Test your code

## 2. Contributing Process

### 2.1 Creating Issues

1. Open a new issue on GitHub
2. Use the issue template
3. Provide detailed description
4. Add relevant labels

### 2.2 Pull Request Process

1. Create a new branch:

```bash
git checkout -b feature/new-feature
# or
git checkout -b fix/bug-fix
```

2. Make changes and commit:

```bash
git add .
git commit -m "feat: added new feature"
# or
git commit -m "fix: fixed bug"
```

3. Open pull request:

- Use PR template
- Describe changes in detail
- Include test results

## 3. Development Guidelines

### 3.1 Commit Messages

Commit messages should follow this format:

- `feat: new feature`
- `fix: bug fix`
- `docs: documentation update`
- `style: code format update`
- `refactor: code improvement`
- `test: add/modify tests`
- `chore: general maintenance`

### 3.2 Branch Naming

- `feature/`: For new features
- `fix/`: For bug fixes
- `docs/`: For documentation updates
- `refactor/`: For code improvements
- `test/`: For adding tests

## 4. Testing

### 4.1 Test Scenarios

1. Tests for basic functions:

- Container selection
- Backup operation
- Restore operation
- Error cases

2. Tests for special cases:

- Large databases
- Connection loss
- Disk full

### 4.2 Test Environment

```bash
# Create test container
docker run -d --name mongodb-test mongo:latest

# Create test database
mongosh mongodb://localhost:27017/test

# Add test data
db.test.insertMany([...])
```

## 5. Documentation

### 5.1 Code Documentation

- Add description for each function
- Specify parameters and return values
- Include examples

Example:

```bash
# Function: do_backup
# Description: Takes database backup
# Parameters:
#   - backup_type: Backup type (full/collection)
# Returns: 0 success, 1 error
do_backup() {
    local backup_type="$1"
    ...
}
```

### 5.2 User Documentation

- README.md updates
- Usage examples
- Frequently asked questions

## 6. Security

### 6.1 Security Checks

- Check sensitive information
- Verify authorizations
- Test security vulnerabilities

### 6.2 Security Reporting

1. If you find a security vulnerability:

- Don't open public issue
- Report privately
- Include POC

## 7. Performance

### 7.1 Performance Improvements

- Optimize code
- Measure resource usage
- Add benchmark tests

### 7.2 Performance Tests

```bash
# Performance test example
time ./mongo_backup_manager.sh backup
```

## 8. Version Management

### 8.1 Versioning

Use Semantic Versioning (SemVer):

- MAJOR.MINOR.PATCH
- Example: 1.0.0, 1.1.0, 1.1.1

### 8.2 Release Process

1. Version bump
2. Update changelog
3. Create tag
4. Release notes

## 9. Community

### 9.1 Communication Channels

- GitHub Issues
- Discussions
- Email

### 9.2 Code of Conduct

1. Be respectful
2. Provide constructive feedback
3. Follow community guidelines

## 10. License

This project is distributed under the MIT license. By contributing:

1. You agree to distribute your code under MIT license
2. You declare that your contribution is your own work
3. You agree to report third-party licenses
