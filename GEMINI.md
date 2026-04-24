# 💎 GEMINI Developer Guide: Flutter BLoC Generator

Welcome to the ultimate guide for using the **Flutter BLoC Clean Architecture Generator**. This guide is designed to help you master the CLI tools and build production-ready applications with speed and precision.

---

## 🚀 CLI Commands & Tutorials

### **1. 🛠️ Project Initialization**
The first step for every new project. This command sets up the entire architecture and rebrands the project.

```bash
dart tools/generator.dart init <your_project_name>
```

**What it does:**
- **Project Rebranding**: Automatically renames the package in `pubspec.yaml`, Android namespace, iOS bundle ID, and all platform files.
- **Absolute Imports**: Hardens the codebase by using `package:your_project_name/...` absolute imports everywhere.
- **Folder Scaffolding**: Creates `core`, `features`, `shared`, and `routes` directories.
- **Base Files**: Generates `ApiClient`, `AppTheme`, `ServiceLocator`, and `AppRouter`.

> [!IMPORTANT]
> Always run `init` as your very first command. It ensures that all subsequent feature generations use the correct absolute imports.

---

### **2. 📦 Feature Scaffolding**
Create a full-stack feature module following Clean Architecture principles.

```bash
dart tools/generator.dart feature <feature_name>
```

**Usage Tutorial:**
1. Run the command: `dart tools/generator.dart feature products`.
2. It will generate:
   - **Data Layer**: Datasources, Models, and Repository Implementation.
   - **Domain Layer**: Entities, Repository Interface, and Services.
   - **Presentation Layer**: BLoC/Cubit, Pages, and Widgets.
3. **Auto-Routing**: It automatically registers the feature's route name in `route_names.dart`.

---

### **3. 📡 Offline-First Scaffolding**
The most powerful command for data-driven apps that need to work without internet.

```bash
dart tools/generator.dart offline <feature_name>
```

**Usage Tutorial:**
1. Run: `dart tools/generator.dart offline notes`.
2. **Drift Database**: It sets up a local SQLite database using Drift.
3. **Auto-Sync Logic**: Generates a Repository that automatically syncs local data to a remote API when connectivity is restored.
4. **BLoC Integration**: Creates a BLoC that listens to connection changes and updates the UI status (synced/pending).

---

### **4. 🛠️ Production Setup**
Harden your app with production-ready utilities.

```bash
dart tools/generator.dart setup all
```

**Sub-commands:**
- `setup env`: Secure environment variables with **Envied**.
- `setup l10n`: Multi-language support (i18n/l10n).
- `setup storage`: Type-safe local storage wrapper.
- `setup logger`: Advanced logging instead of `print()`.
- `setup native`: Automates launcher icon generation.
- `setup responsive`: Integrated **Sizer** for responsive UI.

---

## 🛠️ Generator Internals (Hardening)

This generator is built with **Hardened Logic** to ensure your project never breaks during refactoring:

1. **Regex-Based Injection**: Instead of simple string replacement, we use sophisticated `RegExp` patterns to find the exact place to inject routes or dependencies. This makes it resistant to code formatting changes.
2. **Absolute Import Enforcing**: We eliminated relative imports (`../../`) in generated core files. This prevents path breakage if you move files around later.
3. **Single Source of Truth**: The `getProjectName()` utility ensures that the generator always knows your project's current identity, even if you rename it multiple times.

---

## 💡 Pro Tips

- **Build Runner**: Always run `dart run build_runner build --delete-conflicting-outputs` after running `init`, `offline`, or `setup env`.
- **Naming Convention**: Use `snake_case` for arguments (e.g., `feature product_detail`). The generator will automatically convert them to `PascalCase` for classes.
- **DI Registration**: After creating a new feature or service, don't forget to register it in `lib/core/di/service_locator.dart`.

---

## 🛣️ Roadmap
- [x] Absolute Import Hardening
- [x] Integrated Rename System
- [x] Offline-First Sync Logic
- [ ] Unit Test Generation
- [ ] Integration Test Scaffolding

---

*Happy Coding with Gemini!* 🚀
