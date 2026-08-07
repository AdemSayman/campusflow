# CampusFlow — KIRWE Görev Rehberi (Full-Stack)

**Kişi:** Kirwe  
**Partner:** Adem  
**Versiyon:** 1.0 (ürün dökümanı v0.1 ile uyumlu)  
**Tarih:** Ağustos 2026  
**Dayanak:** `urun-dokumani.md` · `gorev-bolumleme.md` · README teknoloji sözleşmesi · Roomie sadece referans

---

## 0. ŞU AN NEREDEYİZ? (önce bunu oku)

Henüz Ev, Gider, Firebase feature’ları **yapılmadı**. Bu rehber “ilerideki 2.0” değil — **giriş + ilk MVP dilimlerin**.

| Yapıldı | Yapılmadı |
|---------|-----------|
| `campusflow` Flutter repo | Firebase Console projesi / FlutterFire |
| Adem’de Chrome counter denemesi | State / GoRouter kararı (README boş) |
| Ürün dökümanı v0.1, Roomie analizi | Ev oluştur / davet kodu |
| Senin eski Roomie (Kotlin) tecrüben | Gider+borç, FCM, Keşfet kodu |

**Sıra:** giriş (G0–G1, Adem G2) → senin Ev dilimin → Gider → FCM → Keşfet.  
Adem rehberi: `adem-gorev-rehberi.md` — Auth/Görev/Kira orada; o da önce girişi bitiriyor.

Roomie kodunu **taşımayın**; sadece ekran/akış fikri alın.

---

## 1. Senin rolün (özet)

Full-stack dilim = **UI + model + Firestore/service**. Sadece “backendci” değilsin.

| Kod | Aşama | Ne |
|-----|--------|-----|
| **G0** | GİRİŞ | Teknoloji sözleşmesi (Adem ile) |
| **G1** | GİRİŞ | Firebase + FlutterFire birlikte kurulum; rules temeli |
| **K1** | MVP | **Ev + davet kodu** uçtan uca (sen sahip) |
| **K2** | MVP | **Gider + borç** uçtan uca |
| **K3** | MVP | **FCM** iskelet |
| **K4** | Sonra | **Keşfet** ince (Evim oturunca) |

Adem sahip: App shell, Auth, Görevler, Kira. Sen onlarda buddy’sin.

```
GİRİŞ:  G0 → G1  (+ Adem G2 shell)
SONRA:  Sen: Ev → Gider → FCM → Keşfet
        Adem: Auth → Görev → Kira
```

---

## 2. GİRİŞ — G0: Teknoloji sözleşmesi (Adem ile)

README’deki boş tabloyu doldurun. Sen teknik tercihini söyle:

- State: Provider veya Riverpod → **bildiğin / rahat olduğun**  
- GoRouter: evet/hayır  

Adem tabloyu yazar. **Karar yazılmadan** ikiniz ayrı ayrı paket eklemeyin.

---

## 3. GİRİŞ — G1: Firebase kurulumu (birlikte, sen daha aktif)

### Firebase’i ne için kullanıyoruz?

| Servis | Kim ilk feature’da kullanır? |
|--------|------------------------------|
| Auth | Adem (A1) — sen kurulumda görür + buddy |
| Firestore | İkiniz (sen Ev/Gider; Adem Task/Kira/User) |
| FCM | Sen (K3) |
| Storage | Sonra (profil foto) |

### Senin yapacakların (G1)

1. Adem ile Console’da proje oluştur (veya sen oluştur, o izlesin).  
2. `flutterfire configure` — Web (+ Android).  
3. Firestore database oluştur; **allow all bırakıp unutma**.  
4. Rules v0 taslağı (kapalı varsayılan + `users` için Adem Auth gelince açılacak alan):

```
// fikir: başta gereksiz koleksiyonları kapalı tut
// users kurallarını Auth PR’ı ile netleştirin
```

5. Adem `main.dart` init PR’ını review et.  
6. İkiniz Chrome’da app’in hâlâ açıldığını doğrulayın.

**Teslim (G1):** Proje bağlı, şema için 1 sayfalık not (users / houses / …), rules tehlikeli değil.

---

## 4. Adem G2 (shell) sırasında sen ne yaparsın?

Adem 3 sekmeyi yaparken sen:

- PR review  
- Keşfet placeholder’a 1 cümle (küçük buddy PR)  
- Ev feature için model taslağını kağıda / README’ye yaz (henüz kod şart değil)

**Auth bitmeden** Ev’e üye bağlayamazsın — Adem Auth’u bitirene kadar House kodunu **hazırlayabilirsin** ama join’i Auth’suz test edemezsin. Sync: “Auth PR merge oldu mu?”

---

## 5. MVP — K1: EV + DAVET KODU (giriş + Auth sonrası)

### Ne?

Roomie’deki “aynı cihaz üyesi” yerine: **bulut + davet kodu**.

### Sen yazarsın (full-stack)

- Modeller: House, Membership  
- `house_service`: createHouse, joinWithCode, leaveHouse, watchMembers  
- UI: Ev oluştur / Koda katıl / Üyeler / ev yokken CTA  

### Test

Hesap A oluştur → kod → Hesap B katıl → B ayrıl.

### Buddy (Adem)

join validasyonu + akış şeması.

**G0–G1 ve Adem Auth olmadan K1’i “bitti” sayma.**

---

## 6. MVP — K2: GİDER + BORÇ (Ev merge sonrası)

- Expense model + **ayrı** calculator dosyası (sadece sen)  
- Eşit böl, kuruş kuralı yazılı  
- UI: liste, form, net borç, settled  
- 3 kişilik test senaryosu zorunlu  

Buddy: Adem kağıtta senaryo çözer.

---

## 7. MVP — K3 / K4

- **FCM:** izin, token, 1 test bildirimi (Evim oturunca)  
- **Keşfet:** ince listing; Evim’den önce şişirme  

---

## 8. Buddy — Adem’in işleri

| Adem | Sen |
|------|-----|
| Shell | Review + Keşfet placeholder |
| Auth | AuthService oku, 5 not, küçük UI; Adem sana anlatsın |
| Görev / Kira | Empty state / küçük polish |

Auth’u mutlaka oku — sen de Auth bilmiş olursun.

---

## 9. Takvim (giriş önce)

### Hafta 0 — GİRİŞ

| Oturum | Ne |
|--------|-----|
| 1 | G0 sözleşmesi |
| 2 | G1 Firebase + rules notu |
| 3 | Adem shell PR review + Ev şema taslağı |

### Ondan sonra

| Sıra | Sen | Adem |
|------|-----|------|
| 1 | Auth buddy | Auth |
| 2 | **K1 Ev** | Auth polish / Ev buddy |
| 3 | **K2 Gider** | Görevler |
| 4 | FCM | Kira |
| 5 | Keşfet ince | Pilot hazırlık |

“14 günde her şey bitti” yok; **giriş tamamlanmadan Ev/Gider takvimde yok.**

---

## 10. Git / çakışma (kısa)

Branch: `feature/kirwe-firebase-setup`, `feature/kirwe-house`, …  
Klasörlerin: `features/home|expenses|discover`, house/expense/listing models & services.  
Adem’in auth/tasks/rent dosyalarına aynı anda yazma.  
pubspec: Adem’e haber.  
PR ile merge.

---

## 11. Şimdi yapman gereken TEK şey

1. Bu PDF’i oku.  
2. Adem ile **G0** (state + GoRouter).  
3. Birlikte **G1** Firebase.  
4. Adem shell bitince Auth’u bekle / buddy ol → sonra **K1 Ev**.

Gider ve Keşfet’e atlama.

---

## 12. Onay

Kirwe — giriş aşamasını (G0–G1) ve Adem Auth yolunu gözetmeden Ev/Gider’i “bitmiş MVP” saymayacağımı anladım.

Tarih: __________ Onay: __________
