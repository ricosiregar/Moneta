<div align="center">

# 💰 Moneta — Personal Finance

**Aplikasi Mobile Pengelola Keuangan Pribadi _Offline-First_ Berbasis Flutter dengan Arsitektur Clean Architecture, Sinkronisasi Cloud Supabase, dan Deteksi Transaksi Otomatis**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State_Management-BLoC_9.1.1-blue?logo=flutter)](https://pub.dev/packages/flutter_bloc)
[![Drift](https://img.shields.io/badge/Local_DB-Drift_2.31-amber)](https://drift.simonbinder.eu)
[![Backend](https://img.shields.io/badge/Cloud_Sync-Supabase-emerald?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](./LICENSE)

</div>

---

## 📋 Daftar Isi

- [Tentang Proyek](#-tentang-proyek)
- [Fitur Utama](#-fitur-utama)
- [Arsitektur Clean Architecture](#-arsitektur-clean-architecture)
- [Mekanisme Offline-First & Cloud Sync](#-mekanisme-offline-first--cloud-sync)
- [Struktur Proyek](#-struktur-proyek)
- [Tech Stack](#-tech-stack)
- [Code Generation (Build Runner)](#-code-generation-build-runner)
- [Konfigurasi Environment](#-konfigurasi-environment)
- [Cara Menjalankan Aplikasi](#-cara-menjalankan-aplikasi)
- [Ringkasan Command Penting](#-ringkasan-command-penting)

---

## 🏢 Tentang Proyek

**Moneta** adalah aplikasi _personal finance tracker_ modern berbasis **Flutter** dengan antarmuka **Pastel Aurora & Liquid Glassmorphism**. Aplikasi ini dirancang dengan pendekatan **Offline-First** menggunakan database lokal **SQLite (Drift)** yang terintegrasi dengan **Supabase** untuk autentikasi dan sinkronisasi data dua arah (_pull & push_) antar perangkat.

Seluruh pencatatan transaksi, perhitungan saldo dompet berbasis _ledger_, perencanaan anggaran (_budgeting_), celengan digital (_saving jars_), hingga jadwal otomatis berjalan instan di perangkat tanpa bergantung pada koneksi internet, lalu disinkronkan secara aman ke cloud saat online.

---

## ✨ Fitur Utama

| Fitur                                           | Deskripsi                                                                                                                                                                                                                |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 👛 **Manajemen Dompet & Hierarki Parent–Child** | Kelola dompet Tunai, Bank, dan E-Wallet lengkap dengan struktur **Dompet Induk (Parent)** & **Dompet Anak (Child)** serta preset ekosistem bank digital (`Bank Jago → GoPay`, `SeaBank → ShopeePay`, `Superbank → OVO`). |
| 💸 **Pencatatan Transaksi & Pindah Uang**       | Catat pemasukan, pengeluaran, dan transfer antar dompet (termasuk biaya admin) dengan perhitungan saldo berbasis _ledger_ secara _real-time_.                                                                            |
| 🔔 **Deteksi Otomatis Notifikasi Bank (Beta)**  | Tangkap notifikasi transaksi masuk/keluar secara otomatis di latar belakang Android untuk **Bank Jago**, **SeaBank**, dan **Superbank** dengan _auto-assign_ ke dompet terkait (beserta pilihan dompet Induk/Anak).      |
| 📊 **Budgeting Plan & Auto-Schedule**           | Tetapkan batas anggaran bulanan per kategori dan atur jadwal transaksi/alokasi otomatis bulanan (_Auto-Transfer_ & _Auto-Expense_).                                                                                      |
| 🐷 **Celengan Digital (Saving Jars)**           | Buat target tabungan impian lengkap dengan fitur setor dan tarik dana yang terhubung langsung ke saldo dompet.                                                                                                           |
| 📈 **Analitik & Riwayat Aktivitas**             | Pantau grafik arus kas, proporsi pengeluaran per kategori, serta filter aktivitas berdasarkan rentang tanggal, dompet, dan kategori.                                                                                     |
| ☁️ **Two-Way Cloud Sync & Backup Mandiri**      | Sinkronisasi otomatis saat login dan sinkronisasi dua arah (`Drift ↔ Supabase`), dilengkapi fitur Ekspor/Impor cadangan lokal (`.json` & `.csv`).                                                                        |

---

## 🏛️ Arsitektur Clean Architecture

Moneta menerapkan **Clean Architecture** dengan pendekatan **Feature-First Modularization** yang memisahkan kode ke dalam tiga lapisan utama:

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                      │
│               (Pages · Widgets · BLoC / Cubit)              │
│                                                             │
│  ┌────────────┐  ┌────────────┐  ┌───────────────────────┐  │
│  │   Pages    │  │  Widgets   │  │     BLoC / Cubit      │  │
│  │            │  │            │  │  (Events & States)    │  │
│  └────────────┘  └────────────┘  └───────────────────────┘  │
└──────────────────────────────┬──────────────────────────────┘
                               │ depends on
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│                (Business Logic — Pure Dart)                 │
│                                                             │
│  ┌────────────┐  ┌────────────┐  ┌───────────────────────┐  │
│  │  Entities  │  │ Use Cases  │  │ Repository Contracts  │  │
│  │ (Freezed)  │  │            │  │                       │  │
│  └────────────┘  └────────────┘  └───────────────────────┘  │
└──────────────────────────────┬──────────────────────────────┘
                               │ implemented by
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        DATA LAYER                           │
│      (Local Drift SQLite · Supabase Auth/DB · Services)     │
│                                                             │
│  ┌────────────────────────┐  ┌───────────┐  ┌────────────┐  │
│  │  Data Sources & Core   │  │  Models   │  │ Repository │  │
│  │ (Drift / Supabase / OS)│  │ (Freezed) │  │   Impls    │  │
│  └────────────────────────┘  └───────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Prinsip Teknis Utama

- **State Management (`flutter_bloc`)**: Menggunakan `Bloc` untuk alur berbasis event kompleks (seperti `AuthBloc`) dan `Cubit` reaktif berbasis stream database untuk fitur-fitur domain (`HomeCubit`, `WalletsCubit`, `TransactionsCubit`, `BudgetsCubit`, `JarsCubit`, `DetectedInboxCubit`, dll.).
- **Immutable Entities & Models (`freezed`)**: Seluruh entitas domain dan model data menggunakan code generation `freezed` untuk menjamin imutabilitas dan keamanan tipe data.
- **Functional Error Handling (`dartz`)**: Kontrak repository dan use case mengembalikan `Either<Failure, T>` sehingga error tertangani secara eksplisit tanpa _unhandled exception_ di lapisan UI.
- **Dependency Injection (`get_it`)**: Seluruh repository, use case, service, dan BLoC/Cubit diregistrasikan terpusat di `lib/core/di/injection.dart`.

---

## 🔄 Mekanisme Offline-First & Cloud Sync

1. **Database Lokal sebagai Single Source of Truth UI**:
   - Seluruh layar membaca data dari SQLite lokal (**Drift**) melalui _reactive stream_ (`.watch()`).
   - Setiap penambahan, perubahan, atau penghapusan (_soft-delete_ via `deleted_at`) langsung disimpan ke SQLite dengan status `sync_status = 'dirty'`.
2. **Sinkronisasi Dua Arah (`SyncService`)**:
   - **Pull**: Menarik baris terbaru dari Supabase berdasarkan _server cursor_ (`synced_at`), tanpa menimpa perubahan lokal yang masih berstatus `dirty`.
   - **Push**: Mengirim seluruh baris berstatus `dirty` secara _batch upsert_ ke Supabase sesuai urutan ketergantungan _foreign key_, lalu menandainya menjadi `synced`.
   - **Auto-Restore saat Login / Reinstall**: Saat pengguna login di perangkat baru atau setelah menginstal ulang aplikasi, `SyncService` otomatis melakukan _full pull_ dari Supabase sebelum menginisialisasi kategori bawaan.

---

## 📁 Struktur Proyek

```
personal_finance/
├── android/                          # Konfigurasi Android & Native Notification Listener
├── ios/                              # Konfigurasi iOS
├── lib/
│   ├── core/                         # Modul inti lintas fitur
│   │   ├── backup/                   # Ekspor & Impor cadangan JSON / CSV (BackupService)
│   │   ├── components/               # Design System (AuroraHeader, AppGlassSheet, AppGlassDialog, AppToast, FunWidgets)
│   │   ├── constants/                # Konstanta aplikasi
│   │   ├── database/                 # Schema Drift SQLite (tables.dart, app_database.dart, repositories)
│   │   ├── di/                       # Dependency Injection (GetIt setup)
│   │   ├── network/                  # Error Failures, Network Info & Supabase Logging Interceptor
│   │   ├── routes/                   # Konfigurasi navigasi GoRouter (routes.dart)
│   │   ├── storage/                  # Local Storage wrapper (SharedPreferences)
│   │   ├── sync/                     # Mesin sinkronisasi Drift <-> Supabase (SyncService)
│   │   ├── theme/                    # Palet warna & token desain (AppColors)
│   │   └── utils/                    # Base UseCase, Formatter Error & Helper
│   │
│   ├── features/                     # Modul fitur (Clean Architecture: data / domain / presentation)
│   │   ├── analytic/                 # Statistik, ringkasan periode & grafik analitik
│   │   ├── auth/                     # Login, Register, Lupa Password & Supabase Auth
│   │   ├── budgets/                  # Perencanaan & pemantauan batas anggaran bulanan
│   │   ├── categories/               # Manajemen kategori pemasukan & pengeluaran
│   │   ├── home/                     # Beranda, ringkasan aset, tab anggaran & celengan
│   │   ├── jars/                     # Celengan Digital (Saving Jars)
│   │   ├── main/                     # Main Shell, Liquid Glass Navbar & aksi cepat
│   │   ├── notifications/            # Deteksi otomatis notifikasi bank (Jago, SeaBank, Superbank)
│   │   ├── profile/                  # Profil pengguna, backup/restore data & pengaturan
│   │   ├── schedules/                # Jadwal transaksi & transfer otomatis bulanan
│   │   ├── transactions/             # Input transaksi, pindah uang & riwayat aktivitas
│   │   └── wallets/                  # Manajemen dompet, hierarki Parent-Child & alokasi
│   │
│   └── main.dart                     # Entry point & bootstrap aplikasi
│
├── test/                             # Unit & integration tests (Database, Sync, Parser, Cubit)
├── .env                              # Environment variables (Supabase URL & Key)
├── pubspec.yaml                      # Konfigurasi paket & aset
└── README.md                         # Dokumentasi proyek
```

---

## 🛠️ Tech Stack

| Kategori                 | Package                                   | Versi                            | Kegunaan                                                    |
| ------------------------ | ----------------------------------------- | -------------------------------- | ----------------------------------------------------------- |
| **Framework & SDK**      | `flutter` / `dart`                        | `^3.9.2`                         | UI Framework & Bahasa Pemrograman                           |
| **State Management**     | `flutter_bloc`                            | `^9.1.1`                         | BLoC & Cubit Reaktif                                        |
| **Code Generation**      | `freezed` + `json_serializable`           | `^3.2.5` / `^6.14.1`             | Immutable Entities, Models & State                          |
| **Local Database**       | `drift` + `sqlite3_flutter_libs`          | `^2.31.0`                        | Offline-first SQLite ORM & Reactive Queries                 |
| **Cloud Backend**        | `supabase_flutter`                        | `^2.17.2`                        | Autentikasi & Sinkronisasi Database Cloud                   |
| **Dependency Injection** | `get_it` + `injectable`                   | `^9.2.1` / `^3.0.0`              | Service Locator & DI                                        |
| **Routing**              | `go_router`                               | `^14.8.0`                        | Navigasi Deklaratif & Auth Guard                            |
| **UI & Visual**          | `liquid_glass_widgets`, `fl_chart`        | `^1.9.0` / `^1.2.0`              | Efek Liquid Glass & Grafik Keuangan                         |
| **Auto-Deteksi Bank**    | `notification_listener_service`           | `^1.0.0`                         | Listener Notifikasi Bank di Android                         |
| **Backup & Berkas**      | `csv`, `share_plus`, `file_picker`        | `^6.0.0` / `^12.0.2` / `^11.0.3` | Ekspor & Impor Data Transaksi                               |
| **Utilitas**             | `dartz`, `intl`, `uuid`, `flutter_dotenv` | —                                | Functional Error Handling, Lokalisasi `id_ID` & Konfigurasi |

---

## ⚡ Code Generation (Build Runner)

Jalankan perintah berikut setiap kali mengubah file yang memiliki direktif `part '*.freezed.dart'` atau `part '*.g.dart'` (termasuk tabel Drift):

```bash
# Build sekali jalan
dart run build_runner build --delete-conflicting-outputs

# Watch mode (otomatis generate saat file disimpan)
dart run build_runner watch --delete-conflicting-outputs
```

---

## ⚙️ Konfigurasi Environment (Hybrid Mode)

Aplikasi mendukung **Hybrid Environment Loading**:

1. **Mode Debugging (`fvm flutter run`)**: Otomatis membaca file **`.env`** di dalam root proyek.
2. **Mode Build Release (`.apk` / `.aab`)**: Mendukung injeksi _compile-time_ menggunakan `--dart-define-from-file=.env` atau `--dart-define`.

Contoh isi file **`.env`**:

```env
SUPABASE_URL=https://your-supabase-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

---

## 🚀 Cara Menjalankan & Build Aplikasi

1. **Install Dependencies**:

   ```bash
   fvm flutter pub get
   ```

2. **Jalankan Code Generation (bila diperlukan)**:

   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```

3. **Jalankan saat Debugging (Otomatis baca `.env` lokal)**:

   ```bash
   fvm flutter run
   ```

4. **Build Release `.apk` / `.aab` (Inject Environment + Obfuscation)**:

   Gunakan `--dart-define-from-file=.env` untuk menginjeksi kredensial ke dalam binary (`libapp.so`) dan `--obfuscate` untuk mengacak simbol kode agar lebih aman dari *reverse engineering*:

   ```bash
   # Build APK Release (Inject Env + Code Obfuscation)
   fvm flutter build apk --release --obfuscate --split-debug-info=build/debug-info --dart-define-from-file=.env

   # Build App Bundle (.aab) Release (Inject Env + Code Obfuscation)
   fvm flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info --dart-define-from-file=.env
   ```

   > **💡 Tips Keamanan Saat Rilis Produksi:**
   > Sebelum menjalankan perintah *build release* di atas, kamu bisa memberi komentar (`# - .env`) pada bagian `assets:` di `pubspec.yaml` agar file `.env` mentah tidak ikut disalin ke dalam folder `flutter_assets` di dalam `.apk`/`.aab`.

---

## 🔁 Ringkasan Command Penting

| Tujuan                              | Perintah Command Line                                                                                              |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Install Dependencies                | `fvm flutter pub get`                                                                                              |
| Generate Kode (`Freezed` / `Drift`) | `fvm dart run build_runner build --delete-conflicting-outputs`                                                     |
| Menjalankan Aplikasi (Debug)        | `fvm flutter run`                                                                                                  |
| Analisis Kode & Linting             | `fvm flutter analyze`                                                                                              |
| Menjalankan Unit Test               | `fvm flutter test`                                                                                                 |
| Build APK Release (Aman)            | `fvm flutter build apk --release --obfuscate --split-debug-info=build/debug-info --dart-define-from-file=.env`       |
| Build AAB Release (Aman)            | `fvm flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info --dart-define-from-file=.env` |

---

<div align="center">

© 2026 Moneta Personal Finance. All Rights Reserved.

</div>
