# FadDompet Design System

## 1. Design Direction

FadDompet menggunakan pendekatan visual **iOS-inspired premium mobile interface** yang diadaptasi untuk Android.

Arah desain ini mengambil inspirasi dari kualitas visual iOS modern seperti:

- hierarchy yang bersih
- spacing lega
- large title
- surface lembut
- card stack yang rapi
- transisi halus
- komponen minimal
- interaksi yang terasa natural
- fokus pada konten utama

Namun FadDompet **bukan clone iOS**, bukan Apple Wallet clone, dan bukan aplikasi yang memaksakan pola iPhone mentah ke Android.

Targetnya adalah:

> Aplikasi Android yang terasa premium, calm, minimal, cepat, dan iOS-like, tetapi tetap nyaman digunakan di Redmi 13 Android 16 HyperOS 3.0.3.

---

## 2. Design Personality

FadDompet harus terasa:

- calm
- premium
- elegant
- minimal
- precise
- friendly but not playful
- modern
- private
- lightweight
- personal

FadDompet tidak boleh terasa:

- generic AI dashboard
- template SaaS analytics
- default Flutter app
- default Material app
- terlalu ramai
- terlalu corporate
- terlalu childish
- terlalu banyak gradient
- terlalu banyak icon
- terlalu banyak border
- terlalu mirip aplikasi bank berat

---

## 3. Product Feel

Ketika pengguna membuka FadDompet, kesan yang harus muncul:

1. Uang saya mudah dipahami.
2. Aplikasi ini ringan dan cepat.
3. Tampilannya rapi dan mahal.
4. Tidak bikin malas input transaksi.
5. Tidak terlihat seperti template gratisan.
6. Semua elemen punya alasan dan hierarchy.

Aplikasi harus terasa seperti **daily personal tool**, bukan dashboard presentasi.

---

## 4. Target Device

Primary target:

- Redmi 13
- Android 16
- HyperOS 3.0.3

Design harus diuji dengan orientasi:

- portrait mobile
- one-hand usage
- touch target besar
- layout aman untuk layar Android
- smooth scrolling
- tidak berat karena efek visual berlebihan

Web preview hanya digunakan untuk development. Keputusan UI final harus tetap mempertimbangkan Android mobile.

---

## 5. Core Visual Principles

## 5.1 Calm Hierarchy

Informasi penting harus terlihat jelas tanpa perlu berpikir lama.

Hierarchy utama:

1. Total saldo
2. Pemasukan dan pengeluaran bulan ini
3. Cashflow
4. Budget status
5. Insight
6. Recent transactions
7. Detail lanjutan

Jangan menampilkan semua informasi dengan bobot visual yang sama.

---

## 5.2 Soft Depth

Gunakan depth yang halus, bukan shadow kasar.

Gunakan:

- soft shadow
- translucent layer secukupnya
- rounded card
- subtle contrast
- elevated surface yang lembut

Hindari:

- shadow hitam tebal
- elevation Material default yang terlalu kasar
- border terlalu banyak
- card terlalu flat tanpa hierarchy
- glassmorphism berlebihan

---

## 5.3 Large, Readable Numbers

Karena ini aplikasi keuangan, angka adalah konten utama.

Nominal uang harus:

- besar
- jelas
- tebal
- mudah dipindai
- tidak tertutup elemen dekoratif

Contoh hierarchy nominal:

```txt
Total saldo              : 36-44 px / weight 800-900
Summary card amount      : 20-26 px / weight 800
Transaction amount       : 15-17 px / weight 700-800
Small caption amount     : 12-14 px / weight 600
````

---

## 5.4 Minimal Chrome

UI tidak perlu banyak garis, navbar berat, atau header besar yang mengganggu.

Gunakan:

* clean background
* simple navigation
* card-based content
* bottom sheet
* large title
* subtle divider

Hindari:

* app bar berat
* toolbar terlalu ramai
* terlalu banyak button di atas
* terlalu banyak floating element

---

## 5.5 Intentional Motion

Motion harus membantu rasa premium, bukan sekadar dekorasi.

Gunakan motion untuk:

* tab switching
* bottom sheet
* card press state
* number transition
* empty state reveal
* page transition
* add transaction flow

Hindari:

* animasi terlalu lambat
* animasi bouncing berlebihan
* motion yang bikin aplikasi terasa berat
* efek yang tidak membantu navigasi

---

## 6. Color System

## 6.1 Brand Palette

Primary brand FadDompet:

```txt
Primary Teal       #0F766E
Primary Dark       #134E4A
Deep Navy          #0C2949
Soft Mint          #DDF7F2
```

Financial colors:

```txt
Income Green       #16A34A
Expense Red        #DC2626
Info Blue          #2563EB
Warning Orange     #F97316
Neutral Gray       #6B7280
```

---

## 6.2 Light Mode

```txt
Background         #F7F7F8
Background Soft    #F3F4F6
Surface            #FFFFFF
Surface Elevated   #FFFFFF
Surface Soft       #F1F3F5

Text Primary       #111827
Text Secondary     #6B7280
Text Tertiary      #9CA3AF

Border Subtle      rgba(17, 24, 39, 0.06)
Shadow Soft        rgba(15, 23, 42, 0.08)
```

Light mode harus terasa bersih, soft, dan premium. Jangan terlalu putih polos seperti halaman kosong.

---

## 6.3 Dark Mode

```txt
Background         #080A0D
Background Soft    #0B1016
Surface            #111827
Surface Elevated   #17202B
Surface Soft       #1F2937

Text Primary       #F9FAFB
Text Secondary     #9CA3AF
Text Tertiary      #6B7280

Border Subtle      rgba(255, 255, 255, 0.06)
Shadow Soft        rgba(0, 0, 0, 0.30)
```

Dark mode harus terasa deep, calm, dan tidak menyilaukan.

---

## 6.4 Color Usage Rules

Gunakan warna berdasarkan makna:

* Hijau untuk pemasukan dan kondisi positif.
* Merah untuk pengeluaran dan kondisi negatif.
* Orange untuk budget warning.
* Biru untuk informasi netral.
* Teal untuk brand action utama.
* Navy untuk depth dan hero section.

Jangan gunakan warna random untuk sekadar mempercantik UI.

---

## 6.5 Gradient Rules

Gradient boleh digunakan, tetapi terbatas.

Boleh digunakan untuk:

* balance hero card
* selected premium surface
* onboarding hero visual
* empty state background halus

Hindari:

* semua card memakai gradient
* gradient terlalu neon
* gradient terlalu ramai
* gradient tanpa fungsi hierarchy

Gradient utama:

```txt
Balance Gradient:
#0F766E -> #134E4A -> #0C2949
```

Alternative soft gradient:

```txt
Soft Mint Gradient:
#EFFFFB -> #F7F7F8
```

---

## 7. Typography

## 7.1 Font Strategy

Gunakan font sistem Flutter terlebih dahulu untuk performa dan stabilitas.

Jika nanti ingin lebih branded, opsi font:

* Inter
* Plus Jakarta Sans
* SF-like system fallback

Untuk v1.0, prioritaskan:

* readability
* hierarchy
* performance
* konsistensi

---

## 7.2 Type Scale

```txt
Display Large      40-44 px / weight 900 / letter spacing -1.4
Display Medium     34-38 px / weight 900 / letter spacing -1.2
Page Title         28-32 px / weight 800-900 / letter spacing -0.8
Section Title      18-22 px / weight 700-800
Card Title         15-17 px / weight 700-800
Body               14-16 px / weight 400-500
Body Strong        14-16 px / weight 600-700
Caption            12-13 px / weight 500-600
Micro              10-11 px / weight 600
```

---

## 7.3 Typography Rules

Do:

* gunakan large title untuk halaman utama
* gunakan angka besar untuk saldo
* gunakan weight tebal untuk nominal
* gunakan caption halus untuk konteks
* jaga line height agar nyaman

Do not:

* memakai terlalu banyak ukuran font
* membuat semua teks bold
* memakai text terlalu kecil untuk nominal
* memakai uppercase berlebihan
* membuat line height terlalu rapat

---

## 8. Spacing System

Gunakan spacing scale konsisten:

```txt
2
4
6
8
10
12
14
16
18
20
24
28
32
40
48
56
64
```

Rekomendasi utama:

```txt
Screen horizontal padding       20
Mobile section gap              20-28
Card inner padding              16-24
Small component gap             8-12
Button vertical padding         14-18
Bottom sheet padding            20-28
```

UI FadDompet harus terasa lega. Jangan padat seperti aplikasi admin dashboard.

---

## 9. Radius System

Gunakan radius besar dan konsisten.

```txt
Radius XS           8
Radius SM           12
Radius MD           16
Radius LG           20
Radius XL           24
Radius 2XL          28
Radius Hero         32
Radius Full         999
```

Usage:

```txt
Small chip          999
Button              16-20
Input field          18-22
Metric card          22-26
Hero card            28-34
Bottom sheet         28-32 top radius
Modal                28-32
```

Jangan mencampur terlalu banyak radius secara acak.

---

## 10. Shadow and Elevation

## 10.1 Soft Shadow

Gunakan shadow lembut.

Contoh karakter shadow:

```txt
Soft Card Shadow:
color: rgba(15, 23, 42, 0.06)
blur: 20-32
offset: 0, 10-18

Hero Shadow:
color: rgba(15, 118, 110, 0.18)
blur: 28-40
offset: 0, 16-24
```

---

## 10.2 Elevation Rules

Do:

* gunakan shadow hanya untuk elemen penting
* gunakan surface layering
* gunakan contrast halus

Do not:

* semua card diberi shadow
* shadow terlalu gelap
* shadow terlihat seperti template lama
* menggunakan elevation Material default tanpa styling

---

## 11. Component System

FadDompet harus memakai custom reusable components. Jangan terlalu bergantung pada widget default tanpa styling.

## 11.1 Required Components

Komponen inti:

```txt
FadDompetApp
MainShell
FadDompetScaffold
PremiumBottomNav
BalanceHeroCard
MoneyMetricCard
InsightCard
SectionHeader
TransactionTile
WalletCard
CategoryChip
BudgetProgressCard
QuickActionButton
EmptyState
LoadingState
ErrorState
AddTransactionSheet
AmountKeypad
SegmentedTransactionType
DateSelector
WalletSelector
CategoryPicker
```

---

## 11.2 Component Rules

Setiap component harus:

* punya tujuan jelas
* reusable
* konsisten dengan design token
* tidak terlalu banyak logic
* tidak mengandung data dummy permanen
* tidak memakai style random

Jika component terlalu besar, pecah menjadi subcomponent.

---

## 12. App Shell

## 12.1 Main Structure

Struktur utama aplikasi:

```txt
MainShell
  DashboardPage
  TransactionsPage
  AnalyticsPage
  WalletsPage
  SettingsPage
```

Navigation utama:

```txt
Beranda
Transaksi
Analitik
Wallet
Setting
```

---

## 12.2 Bottom Navigation

Bottom navigation harus terasa premium dan soft.

Karakter:

* tinggi cukup
* label kecil tapi jelas
* active state lembut
* icon konsisten
* tidak terlalu Material default
* tidak terlalu ramai

Boleh memakai:

* rounded container
* translucent/frosted feel
* subtle top border
* active pill
* animated active state

Jangan:

* memakai warna terlalu kuat
* membuat nav terlalu tinggi
* memakai icon random
* memakai label Inggris jika UI utama Bahasa Indonesia

---

## 13. Dashboard Design

Dashboard adalah halaman paling penting.

## 13.1 Dashboard Hierarchy

Urutan visual:

1. Greeting / app identity
2. Total balance hero card
3. Monthly summary cards
4. Budget / insight
5. Recent transactions
6. Quick templates

---

## 13.2 Dashboard Must Answer

Dashboard harus menjawab:

* total uang sekarang
* bulan ini masuk berapa
* bulan ini keluar berapa
* cashflow aman atau tidak
* budget aman atau tidak
* transaksi terakhir apa
* kategori mana yang paling banyak keluar

---

## 13.3 Balance Hero Card

Balance hero card harus menjadi elemen paling premium.

Isi:

* label kecil: Total Saldo
* nominal besar
* hide balance toggle
* wallet count
* monthly status
* subtle visual depth

Visual:

* radius besar
* gradient terbatas
* shadow lembut
* typography besar
* tidak terlalu banyak icon

Jangan buat hero card terlalu mirip kartu bank.

---

## 13.4 Metric Cards

Metric cards:

* Pemasukan
* Pengeluaran
* Cashflow
* Budget

Setiap card harus punya:

* icon kecil
* label
* nominal
* caption
* warna makna finansial

Cards harus compact tapi tetap lega.

---

## 14. Transaction Input Design

Input transaksi adalah fitur harian paling penting.

## 14.1 Input Principles

Input harus:

* cepat
* minim mengetik
* mudah dengan satu tangan
* jelas
* tidak terasa seperti form pajak

---

## 14.2 Input Flow

Alur ideal:

1. Pilih tipe: Pengeluaran / Pemasukan / Transfer
2. Masukkan nominal
3. Pilih kategori
4. Pilih wallet
5. Pilih tanggal
6. Catatan opsional
7. Simpan

Default value:

* tanggal = hari ini
* wallet = wallet terakhir
* kategori = dari quick template jika ada

---

## 14.3 Amount Keypad

Custom keypad harus:

* besar
* nyaman disentuh
* tidak kecil
* responsif
* mendukung clear/delete
* mendukung nominal Rupiah

Hindari terlalu mengandalkan keyboard bawaan.

---

## 14.4 Picker UI

Gunakan:

* chip grid
* icon category
* bottom sheet
* segmented control
* selected state yang jelas

Hindari:

* dropdown default yang kaku
* text input manual untuk kategori utama
* list terlalu panjang tanpa grouping

---

## 15. Analytics Design

Analytics harus informatif, bukan sekadar dekorasi.

## 15.1 Chart Rules

Grafik harus:

* mudah dibaca
* warna konsisten
* tidak terlalu banyak label
* tidak terlalu kecil
* punya empty state
* punya summary teks

Grafik utama:

* donut expense category
* line cashflow
* bar weekly/monthly expense
* top category list

---

## 15.2 Analytics Page Structure

Urutan:

1. Page title
2. Period selector
3. Summary insight
4. Donut chart
5. Cashflow chart
6. Bar chart
7. Top category list

Jangan menampilkan semua chart sekaligus tanpa hierarchy.

---

## 16. Wallet Design

Wallet page harus membuat pengguna paham uangnya ada di mana.

Wallet card harus menampilkan:

* nama wallet
* tipe wallet
* saldo
* icon
* warna aksen
* action edit/detail

Default wallet:

* Cash
* DANA
* GoPay
* ShopeePay
* OVO
* Rekening
* Tabungan

Wallet tidak boleh terlihat seperti kartu bank palsu yang terlalu ramai.

---

## 17. Settings Design

Settings harus bersih dan tidak padat.

Group settings:

* Tampilan
* Data & Backup
* Keamanan
* Tentang FadDompet

List tile harus:

* punya icon
* title jelas
* subtitle singkat
* chevron jika masuk detail
* spacing nyaman

---

## 18. Empty State System

Empty state harus terasa intentional.

Format:

* icon halus
* title jelas
* message singkat
* optional action button

Contoh tone:

```txt
Belum ada transaksi
Tambahkan transaksi pertama agar FadDompet bisa mulai membaca pola keuanganmu.
```

Empty state tidak boleh terasa seperti halaman rusak atau kosong.

---

## 19. Loading State

Loading state harus ringan.

Gunakan:

* skeleton card
* shimmer optional
* simple placeholder
* progress halus

Jangan:

* spinner besar terus-menerus
* loading yang terlihat seperti error
* animasi berat

---

## 20. Error State

Error state harus jelas dan actionable.

Format:

* masalah singkat
* penyebab jika diketahui
* tombol coba lagi
* jangan pakai pesan teknis mentah ke pengguna

---

## 21. Language and Copywriting

Bahasa UI utama: Bahasa Indonesia.

Tone:

* singkat
* jelas
* natural
* tidak terlalu formal
* tidak alay
* tidak terlalu teknis

Gunakan:

```txt
Beranda
Transaksi
Analitik
Wallet
Setting
Pemasukan
Pengeluaran
Total Saldo
Bulan ini
Tambah Transaksi
Belum ada transaksi
```

Hindari:

```txt
Financial Overview
Expense Breakdown
Cashflow Summary
User Wallet Management
```

Kecuali untuk dokumentasi teknis, bukan UI.

---

## 22. Microcopy Rules

Microcopy harus membantu.

Contoh baik:

```txt
Tambahkan transaksi pertama agar FadDompet bisa membaca pola keuanganmu.
Budget makan sudah terpakai 80%.
Pengeluaran bulan ini lebih rendah dari bulan lalu.
```

Contoh buruk:

```txt
No data available.
Something went wrong.
Track your finance with amazing dashboard.
```

---

## 23. Interaction Rules

## 23.1 Touch Target

Minimum touch target:

```txt
44 x 44 px
```

Recommended:

```txt
48 x 48 px
```

Untuk input utama, gunakan area sentuh lebih besar.

---

## 23.2 Press Feedback

Setiap elemen interaktif harus punya feedback:

* opacity
* scale subtle
* ripple yang sangat halus
* animated state

Jangan memakai feedback kasar yang mengganggu visual premium.

---

## 23.3 Bottom Sheet

Bottom sheet digunakan untuk:

* tambah transaksi
* pilih kategori
* pilih wallet
* pilih tanggal
* filter transaksi

Bottom sheet style:

* top radius besar
* drag handle halus
* padding lega
* background surface
* tidak penuh kecuali perlu

---

## 24. Animation Rules

Durasi:

```txt
Fast        120ms
Normal      180ms
Slow        240ms
Page        260ms
```

Curve:

```txt
easeOutCubic
easeInOutCubic
decelerate
```

Gunakan animation untuk:

* tab switch
* bottom sheet
* card reveal
* selected state
* filter expand
* number update

Jangan:

* animasi terlalu lama
* terlalu banyak efek masuk bersamaan
* motion yang membuat UX lambat

---

## 25. Icon Rules

Gunakan icon yang:

* sederhana
* konsisten
* tidak terlalu detail
* mudah dibaca
* relevan dengan kategori

Icon style harus konsisten. Jangan campur terlalu banyak style.

Gunakan icon hanya saat membantu pemahaman. Jangan tambahkan icon untuk semua teks jika tidak perlu.

---

## 26. Layout Rules

## 26.1 Mobile Layout

Screen padding:

```txt
horizontal: 20
top: 16-24
bottom: safe area + nav
```

Content width:

* mobile full width
* web preview boleh centered max width agar tidak terlalu melebar

Untuk web preview:

```txt
max content width: 480-540 px
```

Agar preview tetap menyerupai mobile.

---

## 26.2 Responsive Rules

Fokus utama Android mobile.

Jika web preview lebar:

* jangan paksa layout desktop dashboard kompleks
* gunakan mobile frame atau max width
* pertahankan rasa mobile app

---

## 27. Dark Mode Rules

Dark mode harus:

* tidak terlalu hitam pekat di semua permukaan
* menggunakan layer surface yang jelas
* menjaga kontras
* tetap lembut
* tidak mengubah makna warna finansial

Jangan:

* hanya invert warna light mode
* membuat background abu-abu terlalu terang
* membuat card menyatu dengan background
* membuat teks secondary terlalu redup

---

## 28. Accessibility Rules

FadDompet harus memperhatikan:

* kontras teks
* touch target
* label icon
* ukuran font
* warna bukan satu-satunya indikator
* nominal mudah dibaca
* dark mode aman di mata

Jika menggunakan warna hijau/merah, tetap gunakan tanda plus/minus atau label pemasukan/pengeluaran.

---

## 29. Anti-Generic Checklist

Sebelum menerima perubahan UI, cek:

1. Apakah ini masih terlihat seperti default Material?
2. Apakah card terlalu generik?
3. Apakah gradient dipakai tanpa alasan?
4. Apakah spacing cukup lega?
5. Apakah nominal uang paling mudah dibaca?
6. Apakah bottom nav terasa premium?
7. Apakah dashboard menjawab kebutuhan utama?
8. Apakah UI terasa konsisten?
9. Apakah tampilan cocok di Android?
10. Apakah ada elemen yang hanya dekoratif tapi tidak berguna?

Jika banyak jawaban negatif, UI harus direvisi.

---

## 30. Flutter Implementation Notes

## 30.1 Theme

Gunakan `ThemeData` untuk global baseline, tetapi jangan mengandalkan default Material style mentah.

Global theme harus mengatur:

* color scheme
* scaffold background
* text theme
* card theme
* bottom sheet theme
* navigation theme
* input theme
* button theme

---

## 30.2 Custom Tokens

Buat token terpisah:

```txt
AppColors
AppSpacing
AppRadius
AppTypography
AppShadows
AppDurations
```

Jangan hardcode terlalu banyak value di setiap widget.

---

## 30.3 Component Extraction

Jika UI pattern dipakai lebih dari 1 kali, buat component.

Contoh:

```txt
MoneyMetricCard
SectionHeader
FrostedSurface
PremiumListTile
PrimaryActionButton
```

---

## 30.4 Avoid

Hindari:

* inline style berulang
* widget build terlalu panjang
* file terlalu besar
* warna hardcode acak
* padding random
* border radius random
* dummy data tersebar di banyak file

---

## 31. Quality Bar

Setiap screen harus memenuhi standar:

* terlihat selesai walaupun data kosong
* punya hierarchy jelas
* punya spacing konsisten
* punya komponen reusable
* tidak generik
* nyaman dilihat lama
* ringan untuk Android
* mudah dikembangkan

---

## 32. Final Design Statement

FadDompet should feel like a calm, premium, iOS-inspired personal finance app adapted for Android. It must prioritize fast input, readable financial information, soft visual hierarchy, elegant surfaces, smooth motion, and offline-first practicality.

The design must never look like a generic AI-generated dashboard or default Flutter Material app.