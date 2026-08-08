# CampusFlow

Öğrenci evleri için görev, gider ve kira yönetimi + ince keşif katmanı.  
Çalışma adı değiştirilebilir.

## Stack (teknoloji sözleşmesi)

| Karar | Seçim |
|--------|--------|
| Mobil | Flutter (iOS + Android) |
| Backend | Firebase (Auth, Firestore, Storage, FCM) |
| State | **Riverpod** |
| Routing | **GoRouter** (evet) |
| Flutter | stable (kurulu: 3.44.x / Dart 3.12.x) |

Supabase şimdilik yok. Roomie (Kotlin) sadece referans; bu repo yeşil alan.

## MVP odağı (ilk sprint)

1. Auth (e-posta + Google)  
2. Ev oluştur / davet kodu ile katıl  
3. Görev · Gider (+ borç özeti) · Kira  

**Bilerek sonra:** ağır Keşfet, market listesi, stats, kumbara, yorum/itibar.

## Kurulum

```bash
# Flutter PATH'te olmalı (Windows: C:\src\flutter\bin)
flutter pub get
flutter run
```

> Not: Emülatör/cihaz için Android Studio + SDK gerekir. İlk commit için zorunlu değil.

## Dokümanlar

- [`docs/urun-dokumani.md`](docs/urun-dokumani.md) — ürün v0.1  
- [`docs/gorev-bolumleme.md`](docs/gorev-bolumleme.md) — ilk iş bölümü taslağı  
- [`docs/adem-gorev-rehberi.md`](docs/adem-gorev-rehberi.md) — Adem full-stack rehber v1.0 (giriş önce)  
- [`docs/kirwe-gorev-rehberi.md`](docs/kirwe-gorev-rehberi.md) — Kirwe full-stack rehber v1.0 (giriş önce)  
- [`docs/roomie-vs-campusflow-rapor.md`](docs/roomie-vs-campusflow-rapor.md) — eski Roomie analizi  
- [`docs/sistem-diyagramlari.md`](docs/sistem-diyagramlari.md) — mimari diyagramlar  

## Sahiplik

| Alan | Sahip |
|------|--------|
| UI / Evim akışları | Adem |
| Firebase / veri modelleri | Kirwe |
