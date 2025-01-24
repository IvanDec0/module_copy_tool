# 🚀 Module Copy Tool v1.1.0

**A smart module duplication system with enterprise-grade features**  
✨ _Clone complex code modules while maintaining naming conventions and project structure_ ✨

![CLI Demo](https://via.placeholder.com/800x200.png?text=Module+Copy+CLI+Demo+Animation) <!-- Replace with actual gif -->

## 🌟 Features

| Feature                 | Description                                                        |
| ----------------------- | ------------------------------------------------------------------ |
| 🧩 **Smart Renaming**   | Case-sensitive replacements (PascalCase, snake_case, UPPERCASE)    |
| ⏳ **Time-Travel**      | Automatic timestamped backups with easy restoration                |
| 🧪 **Dry-Run Mode**     | Simulate changes without modifying files                           |
| 🛡️ **Validation**       | Pre-flight checks for naming conventions and path safety           |
| 📊 **Interactive UI**   | Colorized output with progress indicators and confirmation prompts |
| 🔄 **Cross-Platform**   | macOS & Linux support with automatic platform detection            |
| 📜 **Activity Logging** | Detailed operation logs with session tracking                      |

## 🚦 Quick Start

### Installation

```bash
git clone https://github.com/IvanDec0/module_copy_tool.git
cd module-tools
chmod +x bin/module-copy
```

### Basic Usage

```bash
./bin/module-copy --module products --new services
```

## 🛠️ Core Commands

### 🔄 Copy Module

```bash
module-copy -m <EXISTING_MODULE> -n <NEW_MODULE> [OPTIONS]
```

### ⏪ Restore Module

```bash
module-copy --restore <MODULE_NAME> [OPTIONS]
```

### 📋 List Backups

```bash
module-copy --module <MODULE_NAME> --list-backups
```

## 📚 Usage Examples

### Example 1: Simple Module Copy

```bash
$ module-copy -m user -n customer
✅ Success: Created 'customer' module from 'user'
📦 Backup stored at: backups/modules/user_20231025153045

```

### Example 2: Dry-Run Simulation

```bash
$ module-copy -m payment -n invoice --dry-run
🧪 Dry Run Results:
- Would create 23 files
- Would make 148 replacements
- Backup location: backups/modules/payment_20231025153200
```

### Example 3: Force Restoration

```bash
$ module-copy --restore product --force
⏳ Restoring product from backup_20231025120000
✅ Success: Restored 45 files from backup
```

## ⚙️ Advanced Options

| Flag                    | Description                       |
| ----------------------- | --------------------------------- |
| `-d, --dry-run`         | Simulation mode (no changes made) |
| `-f, --force`           | Skip confirmation prompts         |
| `-b, --backup-dir`      | Custom backup directory           |
| `-l, --log-file`        | Specify custom log path           |
| `-y, --non-interactive` | Disable interactive mode (CI/CD)  |

## 🔐 Backup System

```text
backups/modules/
└── products_20231025153045/  # Timestamp format: YYYYMMDDHHMMSS
    ├── controllers/
    ├── services/
    └── dto/
```

- **Automatic Versioning**: Each operation creates timestamped backup
- **Restore Any Version**: List backups with `--list-backups`
- **Cross-Operation Safety**: Original modules never modified directly

## 🚨 Troubleshooting

| Error Message                | Solution                        |
| ---------------------------- | ------------------------------- |
| `Invalid name format`        | Use lowercase a-z, 0-9, hyphens |
| `Destination already exists` | Remove existing directory first |
| `Permission denied`          | Run with `sudo` or fix perms    |
| `Missing dependencies`       | Install `gsed` on macOS         |

## 🤝 Contributing

```bash
# 1. Fork repo
# 2. Create feature branch
git checkout -b feat/awesome-feature
# 3. Commit changes
git commit -m 'feat: add awesome feature'
# 4. Push to branch
git push origin feat/awesome-feature
# 5. Open PR
```

---

📄 **License**: MIT © 2025 Ivan
🐛 **Report Issues**: [GitHub Issues](https://github.com/IvanDec0/module_copy_tool/issues)
