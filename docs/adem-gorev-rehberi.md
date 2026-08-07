# CampusFlow — ADEM Görev Rehberi (Full-Stack)

**Kişi:** Adem  
**Partner:** Kirwe  
**Versiyon:** 1.0 (ürün dökümanı v0.1 ile uyumlu)  
**Tarih:** Ağustos 2026  
**Dayanak:** `urun-dokumani.md` · `gorev-bolumleme.md` · README teknoloji sözleşmesi

---

## 0. ŞU AN NEREDEYİZ? (önce bunu oku)

Henüz Auth, Ev, Firebase falan **yapılmadı**. “2.0 / ileri sprint” yok — **giriş aşamasındasınız.**

| Yapıldı | Yapılmadı |
|---------|-----------|
| Repo açıldı (`campusflow`) | Firebase projesi |
| Flutter kuruldu, Chrome’da counter açıldı | Teknoloji sözleşmesi doldurulmadı (state / GoRouter) |
| Ürün + eski iş bölümü dökümanları | 3 sekme kabuğu (Evim/Keşfet/Profil) |
| Roomie analizi (referans) | Giriş/kayıt ekranı |
| | Ev, görev, gider, kira kodu |

**Bu rehberin sırası:** önce giriş (G0–G2) → sonra senin full-stack dilimlerin (Auth → Görev → Kira).

Kirwe’nin rehberi: `kirwe-gorev-rehberi.md` — o da aynı girişten başlıyor.

---

## 1. Senin rolün (özet)

Full-stack dilim = **hem UI hem Firebase/service**. Sadece ekran değil.

| Kod | Aşama | Ne |
|-----|--------|-----|
| **G0** | GİRİŞ | Teknoloji sözleşmesi + README (Kirwe ile) |
| **G1** | GİRİŞ | Firebase’i birlikte kurmak (ekran paylaşımı) |
| **G2** | GİRİŞ | App shell: counter’ı kaldır, 3 sekme |
| **A1** | MVP | **Auth** uçtan uca (sen sahip) |
| **A2** | MVP | **Görevler** uçtan uca (Ev hazır olunca) |
| **A3** | MVP | **Kira** uçtan uca |

Kirwe sahip: Ev+davet, Gider+borç, FCM, Keşfet (sonra).  
Sen onlarda **buddy** olursun (oku, review, küçük PR).

```
GİRİŞ:  G0 → G1 → G2
SONRA:  Sen: Auth → (Kirwe Ev) → Görevler → Kira
        Kirwe: Ev → Gider → FCM → Keşfet
```

---

## 2. GİRİŞ — G0: Teknoloji sözleşmesi (1 oturum, ikiniz)

Önceki dökümanlarda yazdığımız ama **henüz doldurulmayan** kısım. README’deki tabloyu birlikte doldurun:

| Karar | Ne seçilecek? | Senin işin |
|--------|----------------|------------|
| State | Provider **veya** Riverpod (tek) | Tartışmayı yönet, kararı yaz |
| Routing | GoRouter evet/hayır | Kararı yaz |
| Backend | Firebase (sabit) | Onay |
| Flutter | stable (zaten kurulu) | Not düş |

**Nasıl?**

1. Kirwe ile 30–45 dk oturun.  
2. Kirwe “ben şununla rahatım” derse state’te onu seçin (sen 3 gün karşılaştırma yapma).  
3. `README.md` içindeki boşlukları doldur, commit:

```
docs: fill tech contract in README
```

**Bitmeden** Auth/paket eklemeye geçmeyin — yoksa ikiniz farklı state öğrenirsiniz.

---

## 3. GİRİŞ — G1: Firebase’i birlikte kurmak (1 oturum)

İkiniz de ilk kez (veya sen ilk kez) olabilirsiniz. **Ekran paylaşarak** yapın.

### Adımlar (sırayla)

1. https://console.firebase.google.com → Add project (`campusflow`).  
2. Authentication ve Firestore menülerinin yerini birlikte görün (henüz feature yazmayın).  
3. Terminalde (proje klasörü):

```powershell
cd "C:\Users\Aduket Sayman\Projects\campusflow"
flutter pub add firebase_core firebase_auth cloud_firestore
dart pub global activate flutterfire_cli
flutterfire configure
```

4. Platform: en az **Web** (+ Android varsa).  
5. **Sen** `main.dart`’a init ekleyeceksin (G2 ile de birleşebilir):

- `WidgetsFlutterBinding.ensureInitialized();`  
- `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`  
- `runApp(...)`  

6. Chrome’da app hâlâ açılıyor mu kontrol.  
7. Secret’lar: native config’ler `.gitignore`’da kalsın; `firebase_options.dart` genelde commit edilir.

**Senin teslimin (G1):** Firebase bağlı, app açılıyor, Kirwe ile “kurduk” notu.

**Buddy:** Kirwe Console’da proje sahibi/ayarları doğrular.

---

## 4. GİRİŞ — G2: App shell (senin ilk solo PR’ın)

### Ne?

Chrome’daki mor **Flutter Demo / counter** gidecek. Yerine:

- Alt navigasyon: **Evim | Keşfet | Profil**  
- Her sekmede şimdilik basit metin (“Evim — yakında”)  
- Başlık: CampusFlow  

### Nasıl?

1. Branch: `feature/adem-app-shell`  
2. G0’da seçilen routing/state ile 3 sekme  
3. Dosya önerisi:
   - `lib/app.dart`  
   - `lib/features/home/home_placeholder_page.dart`  
   - `lib/features/discover/discover_placeholder_page.dart`  
   - `lib/features/profile/profile_placeholder_page.dart`  
4. `main.dart` sade kalsın: Firebase init + `MyApp`  
5. PR → Kirwe “sekmeler geçiyor mu?” bakar  

### Git

```
git checkout main
git pull
git checkout -b feature/adem-app-shell
# ...
git commit -m "feat(shell): replace counter with 3-tab CampusFlow shell"
git push -u origin HEAD
```

**G0–G2 bitmeden A1 Auth’a geçme.**

---

## 5. MVP — A1: AUTH (giriş bittikten sonra, full-stack)

### Auth nedir? (kısa)

- **Firebase Auth** = kim bu kullanıcı? (e-posta/şifre, Google)  
- **Firestore `users/{uid}`** = sizin eklediğiniz profil (ad, üniversite, bio, currentHouseId)

### Console

Authentication → Email/Password aç · Google aç.

### Sen yazarsın

- `lib/services/auth_service.dart` — kayıt, giriş, Google, çıkış, profil dokümanı oluştur  
- `lib/features/auth/login_page.dart` · `register_page.dart`  
- Giriş yoksa login, varsa 3 sekme  

### Test

Kayıt → Console’da user → Firestore’da `users/{uid}` → çıkış → giriş.

### Buddy (Kirwe)

AuthService’i okur, 5 not, küçük UI (ör. disabled “şifremi unuttum”).

Detaylı metod listesi önceki uzun anlatımla aynı; **önce G0–G2 şart.**

---

## 6. MVP — A2: Görevler (Kirwe Ev’i merge ettikten sonra)

`houseId` olmadan görev yazma.  
Sen: Task model + service + liste/ekle/tamamla UI.  
Buddy: Kirwe empty state / TaskTile.

---

## 7. MVP — A3: Kira (Ev + üyeler hazırken)

Sen: Rent model + service + ay/pay/ödendi UI.

---

## 8. Buddy olduğun Kirwe işleri

| Kirwe | Sen |
|-------|-----|
| Ev + davet | Akış şeması çiz; join validasyonu küçük PR |
| Gider + borç | Kağıtta 2 senaryo; empty state |
| FCM | Bildirim metinleri |
| Keşfet | Kart polish (Evim oturunca) |

---

## 9. Takvim (gerçekçi — giriş önce)

### Hafta 0 — GİRİŞ (bu hafta / ilk oturumlar)

| Oturum | Ne |
|--------|-----|
| 1 | G0 teknoloji sözleşmesi + README |
| 2 | G1 Firebase birlikte |
| 3 | G2 app shell + PR |

### Ondan sonra (Hafta 1+)

| Sıra | Sen | Kirwe (paralel/sıralı) |
|------|-----|-------------------------|
| 1 | A1 Auth | Buddy + Ev’e hazırlık |
| 2 | Auth polish + buddy Ev | K1 Ev+davet |
| 3 | A2 Görevler | K2 Gider (Ev sonrası) |
| 4 | A3 Kira | FCM / Keşfet ince |

Eski “14 günde her şey” baskısı yok; **giriş bitmeden Auth takvime yazılmaz.**

---

## 10. Git / çakışma (kısa)

Branch: `feature/adem-app-shell`, `feature/adem-auth`, …  
Senin klasörler: `features/auth|tasks|rent`, ilgili models/services.  
`pubspec` değiştirirken Kirwe’ye haber ver.  
`main`’e direkt push yok.  
Cursor co-author istemiyorsan Windows Terminal’den commit.

---

## 11. Şimdi yapman gereken TEK şey

1. Bu PDF’i oku.  
2. Kirwe ile **G0** için 45 dk ayırın (state + GoRouter).  
3. Sonra **G1** Firebase.  
4. Sonra **G2** 3 sekme.  

Auth’a “hemen” atlama.

---

## 12. Onay

Adem — giriş aşamasını (G0–G2) bitirmeden MVP dilimlerine geçmeyeceğimi anladım.

Tarih: __________ Onay: __________
