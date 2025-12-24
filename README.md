# Universal SSN System for FiveM

**Version 2.0**  
A fully rewritten and optimized Social Security Number (SSN) system for FiveM, supporting all major frameworks with automatic detection and standalone mode.

---

## ✨ Features

- 🔄 **Fully rewritten in v2.0**
- ⚡ Optimized database queries & logic
- 🧠 Automatic framework detection (`auto` mode)
- 🧩 Framework support:
  - ESX
  - QB-Core
  - OX Core
  - ND Core
  - Standalone
- 🆔 Automatic SSN generation for new characters
- 🗃️ Database-wide SSN generation (online & offline players)
- 📅 Birth-year based SSN formatting (framework-aware)
- 🧪 Safe fallback for standalone servers
- 🌍 Multi-language support via `Config.Translations`
- 📤 Discord webhook logging
- 🔌 Clean exports API for developers

---

## 🧠 How It Works

- The script automatically creates an `ssn` column in your `users` table
- SSNs are generated sequentially and **never duplicated**
- Birth year is taken from the character data when available
- Standalone servers fall back to system date
- Supports **custom SSN formats**

---
