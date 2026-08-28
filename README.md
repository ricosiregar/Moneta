<div align="center">

# 💰 Moneta — Personal Finance Tracker

**Aplikasi Mobile Pengelola Keuangan Pribadi Berbasis Flutter dengan AI Insight & Scan Struk Otomatis**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State_Management-BLoC_9.1.1-blue?logo=flutter)](https://pub.dev/packages/flutter_bloc)
[![Freezed](https://img.shields.io/badge/Code_Gen-Freezed_3.2.5-violet)](https://pub.dev/packages/freezed)
[![Backend](https://img.shields.io/badge/Backend-Supabase-emerald?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](./LICENSE)

</div>

---

## 📋 Daftar Isi

- [Tentang Proyek](#-tentang-proyek)
- [Fitur Utama](#-fitur-utama)
- [Arsitektur Clean Architecture (BLoC + Freezed)](#-arsitektur-clean-architecture-bloc--freezed)
- [Analogi Restoran (Clean Architecture + BLoC + Freezed)](#-analogi-restoran-clean-architecture--bloc--freezed)
- [Tutorial: Urutan Pembuatan File Clean Arch](#-tutorial-urutan-pembuatan-file-clean-arch)
- [Code Generation (Build Runner)](#-code-generation-build-runner)
- [Struktur Proyek](#-struktur-proyek)
- [Tech Stack](#-tech-stack)
- [Konfigurasi Environment](#-konfigurasi-environment)
- [Cara Menjalankan Aplikasi](#-cara-menjalankan-aplikasi)
- [Ringkasan Command Penting](#-ringkasan-command-penting)

---

## 🏢 Tentang Proyek

**Moneta** adalah aplikasi *personal finance tracker* modern berbasis **Flutter** yang dirancang untuk membantu pengguna mengelola pencatatan keuangan harian, penganggaran (*budgeting*), serta analisis finansial secara otomatis dan cerdas.

Aplikasi Moneta mengintegrasikan teknologi terkini seperti:
- **AI Financial Advisor (Google Gemini API)** untuk memberikan analisis kebiasaan belanja dan rekomendasi penghematan.
- **Scan Struk Otomatis (Google ML Kit OCR)** untuk mencatat transaksi langsung dari foto struk belanja.
- **Auto-Deteksi Transaksi** via listener notifikasi e-wallet dan SMS bank.
- **Backend Supabase & Database Local Drift** untuk mendukung arsitektur *offline-first* dan sinkronisasi cloud yang handal.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
| --- | --- |
| 💸 **Pencatatan Transaksi & Kategori** | Catat pemasukan dan pengeluaran secara terorganisir lengkap dengan tag dan kategori. |
| 🤖 **AI Financial Advisor & Insight** | Analisis kebiasaan finansial dan rekomendasi budget pintar berbasis **Google Gemini AI**. |
| 🧾 **Scan Struk Otomatis (OCR)** | Ekstraksi otomatis nominal, tanggal, dan nama item dari foto struk belanja via **Google ML Kit**. |
| 🔔 **Auto-Deteksi Notifikasi Transaksi** | Pembaca notifikasi otomatis dari SMS Bank / E-Wallet (`notification_listener_service`). |
| 📈 **Visualisasi Grafik & Laporan** | Grafik statistik pengeluaran interaktif menggunakan **FL Chart**. |
| 📁 **Ekspor Laporan CSV** | Fitur ekspor riwayat transaksi ke format CSV untuk pembukuan mandiri. |
| 🎯 **Spending Challenge** | Mode tantangan hemat bulanan untuk membangun kebiasaan finansial yang bijak. |
| 🔒 **Enkripsi & Storage Secure** | Keamanan token dan data pengguna berbasis **Flutter Secure Storage** & **Supabase Auth**. |

---

## 🏛️ Arsitektur Clean Architecture (BLoC + Freezed)

Aplikasi Moneta menerapkan **Clean Architecture** berbasis **Feature-First Modularization**. Pendekatan ini memastikan pemisahan tanggung jawab (*Separation of Concerns*), kemudahan pengujian (*testability*), dan skala pengembangan yang efisien.

Berbeda dengan arsitektur terdahulu yang berbasis Riverpod, Moneta menggunakan kombinasi **BLoC (flutter_bloc)** untuk state management reaktif berbasis Event-State stream dan **Freezed** untuk pembentukan kelas imutabel (*immutable classes*), *pattern matching*, serta *code generation*.

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                      │
│               (UI · Widgets · BLoC / Cubit)                 │
│                                                             │
│  ┌────────────┐  ┌────────────┐  ┌───────────────────────┐  │
│  │   Pages    │  │  Widgets   │  │       BLoC / Cubit    │  │
│  │            │  │            │  │(Events & Freezed State) │  │
│  └────────────┘  └────────────┘  └───────────────────────┘  │
└──────────────────────────────┬──────────────────────────────┘
                               │ depends on (abstractions)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│                (Business Logic — Pure Dart)                 │
│                                                             │
│  ┌────────────┐  ┌────────────┐  ┌───────────────────────┐  │
│  │  Entities  │  │ Use Cases  │  │ Repository Interfaces │  │
│  │ (Freezed)  │  │            │  │                       │  │
│  └────────────┘  └────────────┘  └───────────────────────┘  │
└──────────────────────────────┬──────────────────────────────┘
                               │ implemented by
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        DATA LAYER                           │
│       (Supabase API · Local DB Drift · External Services)   │
│                                                             │
│  ┌────────────────────────┐  ┌───────────┐  ┌────────────┐  │
│  │  Data Sources          │  │  Models   │  │    Repo    │  │
│  │ (Remote/Local/OCR/AI)  │  │ (Freezed) │  │   Impls    │  │
│  └────────────────────────┘  └───────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Pola Desain & Library Utama

- **State Management (BLoC + Freezed)**:
  - **BLoC (`flutter_bloc`)**: State management yang berbasis pada aliran kejadian (*Event-driven Stream*). Komponen UI mengirimkan **Event**, dan BLoC mengolah logika bisnis lalu memancarkan **State**.
  - **Freezed (`freezed`)**: Digunakan untuk membuat BLoC State & Event menjadi *sealed classes* yang *immutable*. Memungkinkan penggunaan fitur *pattern matching* (`state.when`, `state.maybeWhen`) sehingga penanganan kondisi UI (Initial, Loading, Success, Error) menjadi sangat deklaratif dan bebas dari *null-safety bugs*.
- **Dependency Injection (Injectable + GetIt)**:
  - Menggunakan **`injectable`** dan **`get_it`** untuk melakukan *Dependency Injection* secara otomatis melalui anotasi (`@injectable`, `@lazySingleton`, `@module`).
- **Routing & Navigasi Deklaratif (GoRouter)**:
  - Mengelola navigasi aplikasi secara deklaratif dan *type-safe* pada `lib/routes/app_router.dart`.
- **Functional Error Handling (Dartz)**:
  - Menggunakan tipe `Either<Failure, Success>` untuk penanganan error yang eksplisit di Domain dan Data Layer.

---

## 🍽️ Analogi Restoran (Clean Architecture + BLoC + Freezed)

Bayangkan sistem **Clean Architecture BLoC & Freezed** seperti alur kerja di **Restoran Berbintang Modern**:

```
 ┌───────────────────────────────────────────────────────────┐
 │                      PELANGGAN (User)                     │
 └────────────────────────────┬──────────────────────────────┘
                              │ Menekan Tombol / Memesan
                              ▼
 ┌───────────────────────────────────────────────────────────┐
 │             HOSTESS / ROUTING (GoRouter)                  │
 │  • Mengarahkan Pelanggan ke Ruangan / Meja yang Tepat     │
 └────────────────────────────┬──────────────────────────────┘
                              │ Duduk & Berinteraksi
                              ▼
 ┌───────────────────────────────────────────────────────────┐
 │       PRESENTATION LAYER (Pelayan BLoC + Form Freezed)    │
 │  • UI / Page    : Meja Makan & Tampilan Layar             │
 │  • BLoC         : Pelayan Digital Penerima Tiket Event    │
 │  • Freezed Event: Tiket Pesanan Resmi Bersegel (Immutable)│
 │  • Freezed State: Status Sajian (Loading/Success/Error)   │
 └────────────────────────────┬──────────────────────────────┘
                              │ Meneruskan Tiket Pesanan
                              ▼
 ┌───────────────────────────────────────────────────────────┐
 │             DOMAIN LAYER (Head Chef / Koki Utama)         │
 │  • Use Case     : Resep Rahasia Memasak & Aturan Finansial│
 │  • Entity       : Standar Kualitas Porsi Murni (Freezed)  │
 │  • Repo Interface: Daftar Kebutuhan Bahan Baku Koki       │
 └────────────────────────────┬──────────────────────────────┘
                              │ Meminta Bahan
                              ▼
 ┌───────────────────────────────────────────────────────────┐
 │             DATA LAYER (Pantry, API & AI Services)        │
 │  • Data Source  : Supabase Cloud, Local DB Drift, ML Kit  │
 │  • Model        : Bahan Mentah Kardus API (Freezed JSON)  │
 │  • Repo Impl    : Petugas Pantry yang Memproses Bahan     │
 └───────────────────────────────────────────────────────────┘
               ▲
               │ Menyiapkan & Mendaftarkan Seluruh Koki & Supplier
 ┌─────────────┴─────────────────────────────────────────────┐
 │       SISTEM OTOMASI PERALATAN (Injectable + GetIt)       │
 │  • Otomatis Menyuntikkan (Inject) Dependency via Anotasi  │
 └───────────────────────────────────────────────────────────┘
```

1. **Pelanggan (User)**
   - Pengguna aplikasi yang menekan tombol *Add Transaction*, melakukan scan struk, atau membaca laporan AI.

2. **Hostess (GoRouter)**
   - Penerima tamu yang memastikan navigasi antar halaman terarah dengan tepat (`/dashboard`, `/scan-receipt`, `/ai-insight`).

3. **Pelayan & Tiket Pesanan (BLoC + Freezed Event/State)**
   - **Freezed Event** adalah **Tiket Pesanan Resmi Bersegel** (misal: `TransactionEvent.addTransaction(data)`). Tiket ini bersifat imutabel (*tidak bisa diubah atau dipalsukan di jalan*).
   - **BLoC** adalah **Pelayan Digital** yang menerima Tiket Event tersebut dan memprosesnya ke Dapur.
   - **Freezed State** adalah **Status Sajian** yang dipancarkan oleh Pelayan ke meja makan. Dengan *Freezed Pattern Matching*, UI cukup mengecek:
     - `loading()` ➔ Tampilkan indikator putar/skeleton.
     - `success(data)` ➔ Tampilkan data transaksi / grafik.
     - `error(message)` ➔ Tampilkan snackbar peringatan.

4. **Head Chef (Domain Layer)**
   - **Entities**: Standar kualitas data murni (*Freezed Entity*).
   - **Use Cases**: Aturan bisnis (misal: perhitungan batas anggaran, pembuatan prompt AI).
   - **Repository Interface**: Deklarasi kebutuhan data murni tanpa terikat database eksternal.

5. **Pantry & Supplier (Data Layer)**
   - **Models (Freezed + JSON)**: Format data mentah dari API Supabase atau Gemini AI yang dikonversi menjadi Entity.
   - **Data Sources**: Sumber data eksternal (Supabase Remote, Local Drift DB, ML Kit OCR).
   - **Repository Implementation**: Petugas pantry yang mengambil data dan mengembalikan `Either<Failure, Success>`.

6. **Sistem Otomasi Peralatan (Injectable + GetIt)**
   - Menggunakan anotasi `@injectable` / `@lazySingleton` sehingga peralatan dapur, Koki (Use Case), dan Petugas Pantry (Repository) dirakit secara otomatis oleh generator tanpa perlu instansiasi manual (`new Repo()`).

---

## 📝 Tutorial: Urutan Pembuatan File Clean Arch

Ketika menambahkan fitur baru (contoh: **`transaction`**), ikuti alur pengembangan **Inside-Out (Domain ➔ Data ➔ Presentation)**:

---

### 📌 Langkah 1: Domain Layer (Definisikan Aturan Bisnis)

1. **Buat Entity (`domain/entities/transaction_entity.dart`)**

   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';

   part 'transaction_entity.freezed.dart';

   @freezed
   abstract class TransactionEntity with _$TransactionEntity {
     const factory TransactionEntity({
       required String id,
       required String title,
       required double amount,
       required String category,
       required DateTime date,
       String? note,
     }) = _TransactionEntity;
   }
   ```

2. **Buat Repository Interface (`domain/repositories/transaction_repository.dart`)**

   ```dart
   import 'package:dartz/dartz.dart';
   import '../../../core/error/failures.dart';
   import '../entities/transaction_entity.dart';

   abstract class TransactionRepository {
     Future<Either<Failure, List<TransactionEntity>>> getTransactions();
     Future<Either<Failure, Unit>> addTransaction(TransactionEntity transaction);
   }
   ```

3. **Buat Use Case (`domain/usecases/add_transaction_usecase.dart`)**

   ```dart
   import 'package:dartz/dartz.dart';
   import 'package:injectable/injectable.dart';
   import '../../../core/error/failures.dart';
   import '../entities/transaction_entity.dart';
   import '../repositories/transaction_repository.dart';

   @lazySingleton
   class AddTransactionUseCase {
     final TransactionRepository repository;

     AddTransactionUseCase(this.repository);

     Future<Either<Failure, Unit>> call(TransactionEntity transaction) {
       return repository.addTransaction(transaction);
     }
   }
   ```

---

### 📌 Langkah 2: Data Layer (Implementasi Data & Model)

4. **Buat Data Model (`data/models/transaction_model.dart`)**

   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   import '../../domain/entities/transaction_entity.dart';

   part 'transaction_model.freezed.dart';
   part 'transaction_model.g.dart';

   @freezed
   abstract class TransactionModel with _$TransactionModel {
     const TransactionModel._();

     const factory TransactionModel({
       required String id,
       required String title,
       required double amount,
       required String category,
       required String date,
       String? note,
     }) = _TransactionModel;

     factory TransactionModel.fromJson(Map<String, dynamic> json) =>
         _$TransactionModelFromJson(json);

     TransactionEntity toEntity() => TransactionEntity(
           id: id,
           title: title,
           amount: amount,
           category: category,
           date: DateTime.parse(date),
           note: note,
         );

     factory TransactionModel.fromEntity(TransactionEntity entity) =>
         TransactionModel(
           id: entity.id,
           title: entity.title,
           amount: entity.amount,
           category: entity.category,
           date: entity.date.toIso8601String(),
           note: entity.note,
         );
   }
   ```

5. **Buat Remote Data Source (`data/datasources/transaction_remote_datasource.dart`)**

   ```dart
   import 'package:injectable/injectable.dart';
   import 'package:supabase_flutter/supabase_flutter.dart';
   import '../models/transaction_model.dart';

   abstract class TransactionRemoteDataSource {
     Future<void> addTransaction(TransactionModel model);
   }

   @LazySingleton(as: TransactionRemoteDataSource)
   class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
     final SupabaseClient supabaseClient;

     TransactionRemoteDataSourceImpl(this.supabaseClient);

     @override
     Future<void> addTransaction(TransactionModel model) async {
       await supabaseClient.from('transactions').insert(model.toJson());
     }
   }
   ```

6. **Buat Repository Implementation (`data/repositories/transaction_repository_impl.dart`)**

   ```dart
   import 'package:dartz/dartz.dart';
   import 'package:injectable/injectable.dart';
   import '../../../core/error/failures.dart';
   import '../../domain/entities/transaction_entity.dart';
   import '../../domain/repositories/transaction_repository.dart';
   import '../datasources/transaction_remote_datasource.dart';
   import '../models/transaction_model.dart';

   @LazySingleton(as: TransactionRepository)
   class TransactionRepositoryImpl implements TransactionRepository {
     final TransactionRemoteDataSource remoteDataSource;

     TransactionRepositoryImpl(this.remoteDataSource);

     @override
     Future<Either<Failure, Unit>> addTransaction(TransactionEntity transaction) async {
       try {
         final model = TransactionModel.fromEntity(transaction);
         await remoteDataSource.addTransaction(model);
         return const Right(unit);
       } catch (e) {
         return Left(ServerFailure(e.toString()));
       }
     }

     @override
     Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
       // Implementasi get data...
       throw UnimplementedError();
     }
   }
   ```

---

### 📌 Langkah 3: Presentation Layer (BLoC + Freezed State/Event & UI)

7. **Buat BLoC Event (`presentation/bloc/transaction_event.dart`)**

   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   import '../../domain/entities/transaction_entity.dart';

   part 'transaction_event.freezed.dart';

   @freezed
   abstract class TransactionEvent with _$TransactionEvent {
     const factory TransactionEvent.addTransaction(TransactionEntity transaction) =
         _AddTransaction;
     const factory TransactionEvent.fetchTransactions() = _FetchTransactions;
   }
   ```

8. **Buat BLoC State (`presentation/bloc/transaction_state.dart`)**

   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   import '../../domain/entities/transaction_entity.dart';

   part 'transaction_state.freezed.dart';

   @freezed
   abstract class TransactionState with _$TransactionState {
     const factory TransactionState.initial() = _Initial;
     const factory TransactionState.loading() = _Loading;
     const factory TransactionState.success(List<TransactionEntity> transactions) =
         _Success;
     const factory TransactionState.failure(String message) = _Failure;
   }
   ```

9. **Buat BLoC Logic (`presentation/bloc/transaction_bloc.dart`)**

   ```dart
   import 'package:flutter_bloc/flutter_bloc.dart';
   import 'package:injectable/injectable.dart';
   import '../../domain/usecases/add_transaction_usecase.dart';
   import 'transaction_event.dart';
   import 'transaction_state.dart';

   @injectable
   class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
     final AddTransactionUseCase addTransactionUseCase;

     TransactionBloc(this.addTransactionUseCase)
         : super(const TransactionState.initial()) {
       on<_AddTransaction>(_onAddTransaction);
     }

     Future<void> _onAddTransaction(
       _AddTransaction event,
       Emitter<TransactionState> emit,
     ) async {
       emit(const TransactionState.loading());
       final result = await addTransactionUseCase(event.transaction);
       result.fold(
         (failure) => emit(TransactionState.failure(failure.message)),
         (_) => emit(const TransactionState.success([])),
       );
     }
   }
   ```

10. **Buat Page UI (`presentation/pages/add_transaction_page.dart`)**

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_bloc/flutter_bloc.dart';
   import '../../../core/di/injection.dart';
   import '../bloc/transaction_bloc.dart';
   import '../bloc/transaction_event.dart';
   import '../bloc/transaction_state.dart';

   class AddTransactionPage extends StatelessWidget {
     const AddTransactionPage({Key? key}) : super(key: key);

     @override
     Widget build(BuildContext context) {
       return BlocProvider(
         create: (_) => getIt<TransactionBloc>(),
         child: Scaffold(
           appBar: AppBar(title: const Text('Add Transaction')),
           body: BlocConsumer<TransactionBloc, TransactionState>(
             listener: (context, state) {
               state.maybeWhen(
                 failure: (msg) => ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(msg)),
                 ),
                 success: (_) => Navigator.pop(context),
                 orElse: () {},
               );
             },
             builder: (context, state) {
               return state.maybeWhen(
                 loading: () => const Center(child: CircularProgressIndicator()),
                 orElse: () => Center(
                   child: ElevatedButton(
                     onPressed: () {
                       // Trigger event
                     },
                     child: const Text('Submit Transaction'),
                   ),
                 ),
               );
             },
           ),
         ),
       );
     }
   }
   ```

---

## ⚡ Code Generation (Build Runner)

Karena project ini menggunakan **Freezed**, **JSON Serializable**, dan **Injectable**, Jalankan perintah build runner setiap kali menambahkan atau mengubah file bertanda `part '*.freezed.dart'`, `part '*.g.dart'`, atau anotasi `@injectable`:

```bash
# Sekali jalankan (One-time build)
dart run build_runner build --delete-conflicting-outputs

# Jalankan secara kontinu saat pengodingan (Watch mode)
dart run build_runner watch --delete-conflicting-outputs
```

---

## 📁 Struktur Proyek

```
moneta/
├── lib/
│   ├── core/                         # Utilitas global, tema, base error & DI
│   │   ├── di/                       # Setup Injectable & GetIt (injection.dart)
│   │   ├── error/                    # Handling Exception & Failures (Dartz)
│   │   ├── network/                  # Setup Dio & Supabase Client
│   │   ├── storage/                  # Secure Storage & SharedPreferences
│   │   ├── theme/                    # Design Tokens (Warna, Tipografi, Style)
│   │   └── utils/                    # Helper & Extensions (Date, Currency)
│   │
│   ├── features/                     # Modul fitur (Feature-First Architecture)
│   │   ├── ai_insight/               # Fitur AI Financial Advisor (Google Gemini)
│   │   │   ├── data/                 # DataSources, Models, Repo Impls
│   │   │   ├── domain/               # Entities, Use Cases, Repo Interfaces
│   │   │   └── presentation/         # BLoC/Cubit, Pages, Widgets
│   │   │
│   │   ├── auth/                     # Fitur Autentikasi User (Supabase Auth)
│   │   ├── challenge/                # Fitur Spending Challenge & Target Hemat
│   │   ├── dashboard/                # Ringkasan Saldo, Top Bar & Quick Actions
│   │   ├── notification_detector/    # Auto-Deteksi Notifikasi Transaksi (SMS/E-Wallet)
│   │   ├── reports/                  # Laporan Visual (FL Chart) & Export CSV
│   │   ├── scan_receipt/             # Fitur Scan Struk Otomatis (Google ML Kit OCR)
│   │   └── transaction/              # Fitur Manajemen Transaksi & Kategori
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   ├── models/           # Freezed Models (+ json_serializable)
│   │       │   └── repositories/
│   │       ├── domain/
│   │       │   ├── entities/         # Freezed Entities
│   │       │   ├── repositories/
│   │       │   └── usecases/
│   │       └── presentation/
│   │           ├── bloc/             # BLoC (Event & State Freezed)
│   │           ├── pages/            # Pages / Screens
│   │           └── widgets/          # Local Widgets
│   │
│   ├── routes/                       # Navigasi & Routing (GoRouter)
│   └── main.dart                     # Entry point utama aplikasi
│
├── assets/
│   ├── icons/                        # Asset ikon SVG & Grafis
│   └── images/                       # Asset gambar & ilustrasi
│
├── .env                              # Environment Variables (Supabase, Gemini API Key)
├── analysis_options.yaml             # Aturan Linting Code
├── pubspec.yaml                      # Deklarasi Dependensi & Generator
└── README.md                         # Dokumentasi Proyek
```

---

## 🛠️ Tech Stack

### Core Framework

| Komponen | Package | Versi |
| --- | --- | --- |
| Framework | `flutter` | SDK |
| Language | `dart` | `^3.9.2` |

### State Management & Code Generation

| Komponen | Package | Versi | Keterangan |
| --- | --- | --- | --- |
| State Management | `flutter_bloc` | `^9.1.1` | Event-driven State Management |
| BLoC Concurrency | `bloc_concurrency` | `^0.3.0` | Event transformers (droppable, restartable, dll) |
| Model Generation | `freezed` + `freezed_annotation` | `^3.2.5` / `^3.0.0` | Immutable data classes & pattern matching |
| JSON Serialization | `json_serializable` + `json_annotation` | `^6.14.1` / `^4.9.0` | Auto JSON mapping |
| Code Generator Runner | `build_runner` | `^2.5.4` | Executor generator code |

### Dependency Injection & Routing

| Komponen | Package | Versi |
| --- | --- | --- |
| Dependency Injection | `get_it` + `injectable` | `^9.2.1` / `^3.0.0` |
| Code Generator DI | `injectable_generator` | `^3.0.0` |
| Routing | `go_router` | `^14.8.0` |

### Backend, Database & Storage

| Komponen | Package | Versi |
| --- | --- | --- |
| Cloud Backend & Auth | `supabase_flutter` | `^2.17.2` |
| Local Database (Offline-First) | `drift` + `sqlite3_flutter_libs` | `^2.31.0` / `^0.5.35` |
| Key-Value Storage | `shared_preferences` | `^2.5.5` |
| HTTP Client | `dio` | `^5.9.2` |

### AI, OCR & Auto-Deteksi

| Komponen | Package | Versi | Keterangan |
| --- | --- | --- | --- |
| AI Financial Advisor | `google_generative_ai` | `^0.4.7` | Integrasi Gemini API |
| OCR Struk Belanja | `google_mlkit_text_recognition` | `^0.16.0` | Scan teks struk dari gambar |
| Image Picker | `image_picker` | `^1.2.2` | Ambil gambar dari galeri / kamera |
| Auto-Deteksi Notifikasi | `notification_listener_service` | `^1.0.0` | Tangkap notifikasi SMS/E-Wallet |

### Analytics, Laporan & Utilities

| Komponen | Package | Versi |
| --- | --- | --- |
| Visual Grafik | `fl_chart` | `^1.2.0` |
| Export CSV | `csv` + `share_plus` | `^6.0.0` / `^12.0.2` |
| Functional Programming | `dartz` | `^0.10.1` |
| Environment Config | `flutter_dotenv` | `^6.0.1` |

---

## ⚙️ Konfigurasi Environment

Aplikasi ini menggunakan file **`.env`** di root directory project untuk menyimpan kunci API sensitif:

```env
SUPABASE_URL=https://your-supabase-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
GEMINI_API_KEY=your-google-gemini-api-key
```

---

## 🚀 Cara Menjalankan Aplikasi

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Jalankan Code Generation**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

---

## 🔁 Ringkasan Command Penting

| Tujuan | Perintah Command Line |
| --- | --- |
| Install Package Dependencies | `flutter pub get` |
| Build Code Generator (Sekali) | `dart run build_runner build --delete-conflicting-outputs` |
| Watch Code Generator (Auto) | `dart run build_runner watch --delete-conflicting-outputs` |
| Run App Development | `flutter run` |
| Analisis Kode & Linting | `flutter analyze` |
| Build APK Release | `flutter build apk --release` |

---

<div align="center">

© 2026 Moneta Personal Finance. All Rights Reserved.

</div>
