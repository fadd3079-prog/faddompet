# FadDompet PRD

## 1. Product Overview

**FadDompet** adalah aplikasi mobile personal money management untuk mencatat, memantau, dan menganalisis keuangan pribadi secara cepat, ringan, dan offline.

Nama FadDompet berasal dari gabungan **Fadd** dan **Dompet**. Aplikasi ini dibuat untuk penggunaan pribadi, terutama sebagai mahasiswa aktif, anak kos, dan freelance desainer/video editor yang memiliki pemasukan dari beberapa sumber serta pengeluaran harian yang perlu dipantau secara rapi.

FadDompet bukan aplikasi akuntansi kompleks, bukan aplikasi bank, dan bukan platform finansial online. Fokus utamanya adalah membantu pengguna memahami kondisi uang pribadi secara cepat: saldo tersisa, pemasukan bulan ini, pengeluaran bulan ini, kategori paling boros, budget, dan riwayat transaksi.

Aplikasi harus terasa **simple, elegant, premium, cepat, stabil, offline-first, dan iOS-like**, tetapi tetap nyaman digunakan di Android.

---

## 2. Product Vision

Membuat aplikasi pengelola keuangan pribadi yang terasa seperti aplikasi bawaan sistem modern: ringan, cepat, bersih, visualnya elegan, dan tidak membuat pengguna malas mencatat transaksi.

FadDompet harus membantu pengguna menjawab pertanyaan utama dalam beberapa detik:

- Uang saya sekarang tersisa berapa?
- Bulan ini saya sudah keluar uang berapa?
- Pemasukan saya dari mana saja?
- Pengeluaran terbesar saya untuk apa?
- Apakah budget bulan ini masih aman?
- Apakah pola keuangan saya membaik atau memburuk?

---

## 3. Target User

### Primary User

Pengguna utama adalah:

- Mahasiswa aktif
- Anak kos
- Freelance graphic designer / video editor
- Pengguna Android
- Mengelola uang saku, uang freelance, dan pengeluaran harian
- Ingin aplikasi offline dan privat
- Tidak ingin terlalu banyak mengetik
- Butuh dashboard visual yang mudah dibaca

### Primary Device

Target perangkat utama:

- Redmi 13
- Android 16
- HyperOS 3.0.3

Aplikasi harus terasa ringan dan stabil pada perangkat tersebut. Web preview hanya digunakan untuk development, bukan target utama produk.

---

## 4. Problem Statement

Pengguna membutuhkan aplikasi pencatat keuangan yang:

1. Cepat digunakan untuk input transaksi harian.
2. Bisa berjalan offline tanpa akun dan tanpa internet.
3. Menyimpan data secara lokal.
4. Memiliki dashboard dan analytics yang jelas.
5. Tidak terasa seperti spreadsheet atau aplikasi akuntansi berat.
6. Tidak memiliki UI generik seperti template dashboard biasa.
7. Cocok untuk pola hidup mahasiswa, anak kos, dan freelancer.

Masalah utama bukan hanya mencatat transaksi, tetapi membuat proses mencatat menjadi cukup mudah sehingga pengguna mau melakukannya setiap hari.

---

## 5. Product Goals

### Functional Goals

- Pengguna bisa mencatat pemasukan.
- Pengguna bisa mencatat pengeluaran.
- Pengguna bisa mencatat transfer antar-wallet.
- Pengguna bisa mengelola wallet seperti Cash, DANA, GoPay, rekening, dan tabungan.
- Pengguna bisa melihat riwayat transaksi.
- Pengguna bisa memfilter transaksi berdasarkan tanggal, tipe, kategori, dan wallet.
- Pengguna bisa melihat dashboard bulanan.
- Pengguna bisa melihat analytics visual.
- Pengguna bisa membuat budget bulanan.
- Pengguna bisa export dan import data lokal.

### Experience Goals

- Input transaksi harus cepat.
- UI harus terasa premium, minimal, dan tidak ramai.
- Pengguna tidak perlu banyak mengetik.
- Informasi utama harus terlihat jelas dalam sekali buka.
- Aplikasi harus nyaman dipakai setiap hari.
- Animasi harus halus tapi tidak berlebihan.
- Tampilan harus iOS-like, tetapi tetap cocok di Android.

### Technical Goals

- Offline-first.
- Data lokal.
- Ringan.
- Stabil.
- Mudah dikembangkan.
- Open-source ready.
- Tidak bergantung pada server.
- Tidak membutuhkan login.
- Tidak memakai dependency berlebihan.

---

## 6. Non-Goals

FadDompet v1.0 tidak bertujuan menjadi:

- Aplikasi bank.
- Aplikasi investasi.
- Aplikasi crypto.
- Aplikasi akuntansi profesional.
- Aplikasi invoice freelance lengkap.
- Aplikasi pajak.
- Aplikasi multi-user.
- Aplikasi cloud finance.
- Aplikasi dengan login/register.
- Aplikasi dengan iklan.
- Aplikasi tracking pengguna.

Fokus v1.0 adalah pengelolaan keuangan pribadi secara lokal.

---

## 7. Platform Scope

### Main Platform

- Android

### Development Preview

- Flutter Web localhost preview

### Future Optional

- Windows desktop
- Export PDF
- Manual cloud backup
- Google Drive backup
- Advanced financial report

---

## 8. Core Features

## 8.1 Onboarding

Onboarding muncul saat pertama kali aplikasi dibuka.

Data yang dikumpulkan:

- Nama pengguna
- Mata uang default: IDR
- Wallet awal
- Saldo awal opsional
- Preferensi tema: system, light, dark

Onboarding harus singkat. Jangan membuat pengguna mengisi terlalu banyak hal di awal.

### Acceptance Criteria

- Pengguna bisa menyelesaikan onboarding kurang dari 1 menit.
- Pengguna bisa mulai memakai aplikasi setelah onboarding.
- Wallet default bisa dibuat otomatis.
- Onboarding tidak terasa seperti form panjang.

---

## 8.2 Dashboard

Dashboard adalah halaman utama aplikasi.

Dashboard harus menampilkan:

- Total saldo
- Pemasukan bulan ini
- Pengeluaran bulan ini
- Net cashflow
- Rata-rata pengeluaran harian
- Budget progress
- Kategori pengeluaran terbesar
- Recent transactions
- Quick add transaction

Dashboard harus menjawab kondisi keuangan pengguna secara cepat dan visual.

### Acceptance Criteria

- Pengguna bisa melihat total saldo dengan jelas.
- Pengguna bisa melihat ringkasan pemasukan dan pengeluaran bulan ini.
- Pengguna bisa langsung menambah transaksi dari dashboard.
- Dashboard tetap rapi walaupun belum ada data.
- Empty state harus informatif dan tidak terasa kosong.

---

## 8.3 Transaction Input

FadDompet harus mengutamakan input transaksi yang cepat.

Jenis transaksi:

- Pemasukan
- Pengeluaran
- Transfer antar-wallet

Field transaksi:

- Nominal
- Tipe transaksi
- Kategori
- Wallet
- Tanggal
- Catatan opsional

Input harus minim mengetik. Gunakan:

- Custom number pad
- Segmented control
- Category picker
- Wallet picker
- Quick template
- Date picker
- Chip atau button selection

### Acceptance Criteria

- Pengguna bisa input transaksi umum kurang dari 10 detik.
- Pengguna tidak wajib mengisi catatan.
- Nominal mudah diketik dengan keypad.
- Kategori dan wallet bisa dipilih tanpa mengetik.
- Transaksi langsung mempengaruhi saldo dan dashboard.

---

## 8.4 Categories

Kategori digunakan untuk mengelompokkan pemasukan dan pengeluaran.

### Expense Categories

Default kategori pengeluaran:

- Makan
- Minum
- Kos
- Laundry
- Galon
- Listrik
- Bensin
- Transport
- Kuliah
- Print/Tugas
- Buku
- Kesehatan
- Obat
- Pakaian
- Hiburan
- Bioskop
- Nongkrong
- Liburan
- Digital/Software
- Kuota
- Freelance Tools
- Sosial/Donasi
- Lainnya

### Income Categories

Default kategori pemasukan:

- Uang saku orang tua
- Desain grafis
- Video editing
- PPT / desain presentasi
- Project kerja
- Part-time
- Hadiah
- Refund
- Cashback
- Lainnya

### Acceptance Criteria

- Kategori default tersedia saat pertama kali aplikasi digunakan.
- Pengguna bisa memilih kategori dengan cepat.
- Kategori bisa dibedakan berdasarkan tipe income atau expense.
- Kategori bisa diedit atau ditambahkan pada versi fitur lanjutan.

---

## 8.5 Wallet Management

Wallet adalah tempat uang pengguna disimpan.

Default wallet:

- Cash
- DANA
- GoPay
- ShopeePay
- OVO
- Rekening
- Tabungan

Setiap transaksi harus terkait dengan satu wallet.

### Acceptance Criteria

- Pengguna bisa melihat daftar wallet.
- Pengguna bisa melihat saldo per wallet.
- Pengguna bisa menambah wallet.
- Pengguna bisa mengedit wallet.
- Pengguna bisa melakukan transfer antar-wallet.
- Saldo wallet dihitung dari saldo awal dan transaksi.

---

## 8.6 Transaction History

Riwayat transaksi menampilkan semua pemasukan, pengeluaran, dan transfer.

Fitur riwayat:

- List transaksi
- Filter tanggal
- Filter tipe transaksi
- Filter kategori
- Filter wallet
- Search catatan
- Edit transaksi
- Hapus transaksi

### Acceptance Criteria

- Riwayat transaksi mudah dibaca.
- Pemasukan dan pengeluaran terlihat berbeda secara visual.
- Filter tidak membuat UI terasa padat.
- Pengguna bisa mengubah atau menghapus transaksi yang salah.

---

## 8.7 Analytics

Analytics membantu pengguna memahami pola keuangan.

Analytics utama:

- Donut chart pengeluaran per kategori
- Line chart cashflow harian
- Bar chart pengeluaran mingguan/bulanan
- Top 5 kategori pengeluaran
- Sumber pemasukan terbesar
- Perbandingan bulan ini vs bulan lalu

Analytics harus fokus pada insight, bukan sekadar grafik dekoratif.

### Acceptance Criteria

- Grafik tetap rapi di layar Android.
- Grafik mudah dibaca.
- Analytics tetap punya empty state saat belum ada data.
- Warna grafik konsisten dengan makna finansial.
- Tidak terlalu banyak grafik dalam satu layar.

---

## 8.8 Budget

Budget membantu pengguna mengontrol pengeluaran bulanan.

Jenis budget:

- Budget total bulanan
- Budget per kategori

Status budget:

- Aman
- Mendekati limit
- Terlampaui

### Acceptance Criteria

- Pengguna bisa membuat budget bulanan.
- Pengguna bisa melihat progress budget.
- Aplikasi bisa memberi indikator visual jika budget hampir habis.
- Budget dihitung berdasarkan transaksi bulan berjalan.

---

## 8.9 Backup, Export, and Import

Karena aplikasi offline-first, backup adalah fitur penting.

Fitur wajib:

- Export JSON
- Import JSON
- Export CSV

Fitur opsional lanjutan:

- Export PDF
- Manual backup ke folder lokal
- Manual backup ke cloud storage

### Acceptance Criteria

- Pengguna bisa export semua data.
- Pengguna bisa import ulang data dari file backup.
- CSV bisa digunakan untuk analisis di spreadsheet.
- Data backup tidak bergantung pada server.

---

## 8.10 Security

Security untuk v1.0 atau lanjutan:

- Hide balance toggle
- PIN lock
- Biometric lock
- Auto-lock timeout

### Acceptance Criteria

- Pengguna bisa menyembunyikan nominal saldo.
- Pengguna bisa mengaktifkan lock app.
- Biometric bersifat opsional.
- Security tidak mengganggu input cepat.

---

## 9. UX Requirements

## 9.1 Input Experience

Aplikasi harus menghindari form panjang.

Prioritaskan:

- Tap
- Select
- Chip
- Segmented button
- Quick template
- Number keypad
- Bottom sheet
- Large touch target

Hindari:

- Banyak TextField
- Form terlalu panjang
- Navigasi berlapis terlalu dalam
- Input yang membutuhkan banyak keyboard typing

---

## 9.2 Navigation

Navigasi utama menggunakan bottom navigation.

Tab utama:

- Beranda
- Transaksi
- Analitik
- Wallet
- Setting

Tombol tambah transaksi harus mudah dijangkau. Pada Android, tombol tambah boleh menggunakan floating action button atau bottom-centered quick action selama tidak terasa seperti Material default yang generik.

---

## 9.3 Empty State

Setiap halaman yang belum memiliki data harus tetap terasa selesai.

Empty state harus:

- Menjelaskan kondisi kosong
- Memberi arahan tindakan berikutnya
- Tidak terlalu ramai
- Tidak memakai ilustrasi berlebihan
- Tetap sesuai visual premium

Contoh:

- Belum ada transaksi
- Belum ada analytics
- Belum ada budget
- Belum ada wallet tambahan

---

## 10. UI Direction

## 10.1 Design Personality

FadDompet harus terasa:

- iOS-like
- Premium
- Minimal
- Calm
- Elegant
- Soft
- Precise
- Modern
- Tidak berisik
- Tidak generik

Referensi iOS digunakan sebagai inspirasi visual, bukan untuk disalin mentah. Aplikasi tetap harus nyaman di Android.

---

## 10.2 Visual Principles

Prinsip visual:

- Background bersih dan lembut
- Surface/card terasa melayang halus
- Radius besar dan konsisten
- Shadow soft, bukan kasar
- Typography besar untuk angka penting
- Warna terbatas
- Divider sangat halus
- Icon sederhana
- Layout lega
- Animasi halus dan cepat

---

## 10.3 Anti-Generic UI Rules

FadDompet tidak boleh terlihat seperti:

- Default Flutter counter app
- Default Material purple theme
- Dashboard template generik
- UI SaaS analytics biasa
- Card collection dengan gradient acak
- Glassmorphism berlebihan
- UI terlalu ramai
- UI dengan terlalu banyak icon
- UI yang dibuat hanya agar terlihat “rame”

UI harus terasa disengaja, bukan hasil template cepat.

---

## 10.4 iOS-like Adaptation Rules

Yang diambil dari iOS-like design:

- Calm hierarchy
- Large title
- Minimal chrome
- Soft card stack feel
- Floating surfaces
- Subtle blur/frosted impression jika dibutuhkan
- Consistent spacing
- Smooth transition
- High-quality typography
- Focus on content

Yang tidak boleh disalin mentah:

- Komponen yang terlalu spesifik iPhone
- Navigasi yang tidak cocok untuk Android
- Apple branding
- Apple Wallet clone
- iOS-only interaction yang aneh di Android

FadDompet harus menjadi aplikasi Android yang terinspirasi iOS, bukan aplikasi yang pura-pura menjadi iPhone.

---

## 11. Data Requirements

Data utama:

### Transactions

- id
- type
- amount
- category_id
- wallet_id
- transfer_wallet_id optional
- date
- note optional
- created_at
- updated_at

### Categories

- id
- name
- type
- icon
- color
- is_default
- created_at
- updated_at

### Wallets

- id
- name
- type
- initial_balance
- created_at
- updated_at

### Budgets

- id
- category_id optional
- month
- limit_amount
- created_at
- updated_at

### Quick Templates

- id
- title
- transaction_type
- default_amount optional
- category_id
- wallet_id
- icon
- color

### App Settings

- user_name
- currency
- theme_mode
- hide_balance
- app_lock_enabled
- onboarding_completed

---

## 12. Technical Requirements

Recommended stack:

- Flutter
- Dart
- Drift
- SQLite
- Riverpod
- fl_chart
- shared_preferences
- intl
- path_provider
- file_picker
- share_plus
- csv
- local_auth

Rules:

- Core app must work offline.
- No backend for v1.0.
- No login/register for v1.0.
- No tracking.
- No ads.
- No unnecessary package.
- Web preview is allowed only for development.
- Android is the primary target.

---

## 13. Performance Requirements

FadDompet harus:

- Cepat dibuka
- Tidak berat saat scroll
- Tidak delay saat input transaksi
- Tidak menggunakan animasi berat berlebihan
- Tidak memakai asset besar tanpa kebutuhan
- Tetap nyaman di Redmi 13
- Tetap bisa berjalan offline

Target pengalaman:

- App launch terasa cepat.
- Navigasi antar-tab terasa instan.
- Input transaksi tidak terasa lambat.
- Dashboard tetap smooth walaupun transaksi bertambah banyak.

---

## 14. Accessibility Requirements

FadDompet harus memperhatikan:

- Kontras teks yang cukup
- Ukuran teks nyaman dibaca
- Touch target cukup besar
- Warna tidak menjadi satu-satunya pembeda
- Icon harus didukung label
- Nominal uang harus mudah dibaca
- Dark mode tidak menyilaukan

---

## 15. Open Source Requirements

Karena FadDompet akan diunggah sebagai repo open-source, project harus memiliki:

- README.md
- LICENSE
- ROADMAP.md
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md
- SECURITY.md
- PRD.md
- DESIGN_SYSTEM.md
- ARCHITECTURE.md

Kode harus:

- Rapi
- Modular
- Mudah dibaca
- Tidak menyimpan data pribadi asli
- Tidak menyertakan credential
- Tidak menyertakan file backup pribadi
- Tidak menyertakan data transaksi asli pengguna

---

## 16. Release Scope

## 16.1 Version 1.0 Scope

FadDompet v1.0 dianggap layak digunakan jika sudah memiliki:

- Onboarding
- Dashboard
- Add income
- Add expense
- Transfer wallet
- Transaction history
- Wallet management
- Category default
- Analytics dasar
- Budget dasar
- Export/import JSON
- Export CSV
- Settings
- Offline storage
- Android build

---

## 16.2 Out of Scope for v1.0

Fitur berikut tidak masuk v1.0:

- Cloud sync
- Login/register
- Multi-device sync
- Firebase/Supabase
- OCR struk
- AI financial assistant
- Invoice freelance lengkap
- Tax report
- Bank integration
- Subscription tracking otomatis
- Push notification kompleks

---

## 17. Development Phases

## Phase 1 - Product Foundation

Tujuan: membuat fondasi aplikasi yang rapi dan tidak generik.

Scope:

- App shell
- Theme system
- Design tokens
- Bottom navigation
- Dashboard static
- Empty states
- Basic page structure

Output:

- UI awal sudah terasa seperti FadDompet, bukan Flutter starter app.

---

## Phase 2 - Local Data Foundation

Tujuan: membuat fondasi data offline.

Scope:

- Drift setup
- SQLite database
- Tables
- DAOs
- Repository
- Seed categories
- Seed wallets

Output:

- Data lokal siap dipakai oleh fitur transaksi.

---

## Phase 3 - Transaction System

Tujuan: membuat fitur transaksi utama.

Scope:

- Add income
- Add expense
- Transfer wallet
- Edit transaction
- Delete transaction
- Transaction history
- Filter transaction

Output:

- Pengguna sudah bisa mencatat keuangan harian.

---

## Phase 4 - Dashboard and Analytics

Tujuan: menghubungkan data ke visual.

Scope:

- Real dashboard data
- Monthly summary
- Donut chart
- Line chart
- Bar chart
- Top category
- Income source breakdown

Output:

- Pengguna bisa membaca kondisi keuangan dari dashboard dan analytics.

---

## Phase 5 - Budget and Backup

Tujuan: membuat aplikasi layak dipakai jangka panjang.

Scope:

- Budget total
- Budget per category
- Export JSON
- Import JSON
- Export CSV
- Reset data

Output:

- Aplikasi aman digunakan karena data bisa dicadangkan.

---

## Phase 6 - Security and Polish

Tujuan: membuat aplikasi terasa matang.

Scope:

- Hide balance
- PIN lock
- Biometric lock
- Dark mode polish
- Animation polish
- Responsive Android layout
- README screenshot
- Release APK

Output:

- FadDompet siap dipakai pribadi dan dipublikasikan sebagai open-source project.

---

## 18. Success Metrics

FadDompet berhasil jika:

- Pengguna bisa mencatat transaksi harian tanpa merasa ribet.
- Aplikasi bisa dipakai offline.
- Dashboard langsung memberi gambaran kondisi uang.
- UI tidak terasa generik.
- Aplikasi berjalan stabil di Android.
- Data bisa dibackup.
- Repo GitHub terlihat rapi dan profesional.
- Project bisa dilanjutkan dengan Codex tanpa arah yang kabur.

---

## 19. Design Quality Bar

Setiap perubahan UI harus melewati pertanyaan berikut:

1. Apakah tampilan ini masih terasa premium?
2. Apakah ini terlalu mirip template dashboard generik?
3. Apakah informasi utama mudah dibaca?
4. Apakah spacing sudah lega?
5. Apakah warna terlalu ramai?
6. Apakah komponen ini terasa seperti bagian dari satu design system?
7. Apakah ini nyaman digunakan di Android?
8. Apakah animasi membantu, bukan mengganggu?
9. Apakah input masih cepat?
10. Apakah ini sesuai karakter FadDompet?

Jika jawabannya lemah, desain harus direvisi.

---

## 20. Final Product Statement

FadDompet is an offline-first personal money management app for Android, designed for students, boarding house life, and freelance income tracking. It focuses on fast transaction input, clear financial summaries, useful analytics, and a premium iOS-inspired interface adapted for Android.

The app must be private, lightweight, stable, elegant, and practical for daily use.