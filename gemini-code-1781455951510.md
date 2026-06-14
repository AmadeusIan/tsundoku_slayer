# DEV MASTER DOC: TSUNDOKU SLAYER 🌸

---

## 1. Project Identity & Philosophy
*   **App Name:** Tsundoku Slayer (Tentative)
*   **Platform:** Android (Native via Flutter)
*   **Purpose:** Proyek Portofolio pendaftaran Apple Developer Academy.
*   **Core Concept:** Aplikasi *habit-tracker* produktivitas membaca buku dengan elemen gamifikasi RPG dan *Trading Card Game* (MTG).
*   **Design Philosophy:** Mengadopsi *Challenge Based Learning* (CBL) dan *Human-Centered / Empathetic Design*. Aplikasi dirancang untuk memaafkan pengguna dan mencegah demotivasi, bukan menghukum kegagalan target harian.

---

## 2. Core Mechanics & Gamification
*   **Multi-Book Management:** Sistem memisahkan status buku antara yang sedang dibaca (ACTIVE) dan antrean tumpukan buku (BACKLOG).
*   **Flexible Pomodoro (Early Surrender):** Pengguna dapat menghentikan pengatur waktu sebelum selesai. Mereka kehilangan bonus waktu, tetapi EXP dari halaman yang dibaca tetap tersimpan.
*   **Flexible Pomodoro (Flow State Extension):** Opsi penambahan waktu +10 atau +25 menit tanpa memutus sesi *timer* yang sedang berjalan.
*   **Dynamic Page Recalculation:** Sisa target halaman yang gagal diselesaikan hari ini tidak akan hangus, melainkan didistribusikan secara merata ke target hari-hari berikutnya.
*   **Streak Shield:** Item pasif berbatas maksimal 2 buah. Item ini otomatis terpakai pada pukul 23:59 untuk menyelamatkan *streak* jika hari itu pengguna gagal membaca.
*   **Emergency Quest:** Misi darurat penyelamatan *streak* yang otomatis muncul pada pukul 21:00 (misi membaca ringan: 2 menit atau 1 halaman).
*   **Revive Potion:** Item aktif berharga sangat mahal di dalam *Shop* untuk menyambung *streak* yang terlanjur putus. Pembelian wajib dilakukan dalam jendela waktu 24 jam dengan sistem *cooldown* ketat.
*   **Vacation Mode:** Cuti membaca terjadwal maksimal 7 hari untuk membekukan *streak*, diberlakukan *cooldown* 14 hari setelah pemakaian.

---

## 3. UI/UX & Aesthetic Theme
*   **Vibe Utama:** Cozy Fantasy / Spring Vibe, terinspirasi dari estetika Stardew Valley dan Studio Ghibli.
*   **Color Palette:** Beige (`#F5F5DC`) untuk latar belakang kertas perkamen hangat, Pink Sakura (`#xFFFFB7C5`) untuk warna aksen, dan Coklat Hangat (`#FF5D4037`) untuk teks.
*   **Buku (Grimoire):** Representasi buku menggunakan desain *Data Cards* menyerupai buku sihir.
*   **Streak (Pohon Sakura):** Pertumbuhan *streak* divisualisasikan dengan Pohon Sakura yang bunganya semakin lebat.
*   **Timer Animasi:** Menggunakan LottieFiles berbentuk kuncup bunga teratai atau sakura raksasa yang mekar secara perlahan.
*   **The Shopkeeper:** Antarmuka toko dijaga oleh NPC Kucing Hitam berbulu lebat, bertopi penyihir ujung terlipat, bermonikel, dan berkomunikasi melalui *Micro-conversational UI*.

---

## 4. Tech Stack & Database Architecture
*   **Frontend:** Flutter (Dart) memanfaatkan *Implicit Animations* dan sistem `.withValues(alpha: ...)` modern.
*   **Backend & Storage:** Sistem *Offline-First* menggunakan `sqflite` lokal.
*   **Tabel users:** Menyimpan `username`, `current_exp`, `current_level`, `current_streak`, serta logika pelacakan waktu (`last_revive_date`, waktu liburan).
*   **Tabel books:** Menyimpan `title`, `total_pages`, `current_page`, `target_days`, dan `status`.
*   **Tabel inventory:** Melacak `item_code` (contoh: STREAK_SHIELD) dan `quantity`.
*   **Tabel reading_sessions:** Mencatat histori log harian, `duration_minutes`, `pages_read`, `exp_earned`, dan status penyelesaian sesi.

---

## 5. Current Implementation State (Fase 1 Selesai)
*   **Database Init:** Skema 4 tabel di dalam `database_helper.dart` telah sukses diinisialisasi beserta fungsi otomatis penyuntikan profil pengguna awal.
*   **Dashboard Screen:** Antarmuka telah dirender menggunakan data memori lokal secara *live*, memuat sistem *Custom EXP Bar* dinamis, dan palet warna bebas *error* depresiasi kode.