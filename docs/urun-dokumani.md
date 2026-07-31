# CampusFlow — Ürün Dökümanı

**Versiyon:** 0.1 (tartışma taslağı)  
**Tarih:** Temmuz 2026  
**Amaç:** Fikri ortaklaşa netleştirmek — özellikler, mimari, örnek tasarım  
**Not:** Çalışma adı “CampusFlow” değiştirilebilir.

---

## 1. Ürün özeti

### Tek cümle

Öğrencilerin hem ev arkadaşı / oda bulduğu, hem de aynı evde görev–gider–kira yönettiği, profil ve yorumlarla güven inşa eden mobil uygulama.

### Problem

Öğrenci evlerinde hayat genelde şöyle yürüyor:

- Görevler WhatsApp’ta unutuluyor veya “senin sıran” tartışmasına dönüyor
- Giderler ve kira Excel / not / “ben ödedim sen ver” ile yönetiliyor; kim kime borçlu belirsiz
- Yeni ev veya ev arkadaşı ararken Sahibinden / ilan siteleri / tanıdık ağı dağınık
- Birlikte yaşamadan önce kişinin güvenilirliği (temizlik, ödeme, uyum) bilinmiyor

### Çözüm

Uygulama iki yüzlü ama tek döngülü:

1. **Keşfet / eşleş** — yakınındaki veya üniversite çevresindeki kişi arayan evleri gör  
2. **Eve katıl** — kabul edil / davet kodu ile gir  
3. **Evi yönet** — görev, gider, kira  
4. **Yorum / itibar bırak** — ayrılınca profil güçlensin → sonraki eşleşmeleri kolaylaştırsın  

### Hedef kullanıcı (ilk aşama)

- Üniversite öğrencisi
- Paylaşımlı öğrenci evinde kalan veya kalacak kişi arayan
- İlk pilot: 1 şehir / 1–2 üniversite çevresi (tartışılacak)

### Bilinçli olmayanlar (şimdilik)

- Emlakçı / ev sahibi kiralama platformu değiliz
- Banka / gerçek para transferi zorunlu değil (MVP’de takip yeter)
- Genel “sosyal medya feed”i değiliz; odak ev yaşamı

---

## 2. Başlangıçta olacak özellikler (MVP)

MVP’nin amacı: **2–3 gerçek öğrenci evi uygulamayı haftalık kullansın.**  
Öneri: yönetim ağırlıklı + çok ince keşif katmanı.

### 2.1 Hesap ve profil

| Özellik | Açıklama |
|--------|----------|
| Kayıt / giriş | E-posta + Google |
| Profil | Ad, foto, üniversite, kısa bio |
| Ev durumu | “Şu an X evinde” veya “ev arıyor” |

### 2.2 Ev

| Özellik | Açıklama |
|--------|----------|
| Ev oluştur | Ev adı, adres/semt (basit), üye limiti |
| Davet kodu | Arkadaşlar kod ile katılır |
| Üye listesi | Kimler bu evde |
| Evden ayrıl | Üyelik sonlanır |

### 2.3 Görevler

| Özellik | Açıklama |
|--------|----------|
| Görev oluştur | Başlık, açıklama, tarih |
| Ata | Bir veya birden fazla kişiye |
| Tamamla | İşaretle / geri al |
| Basit rota | Örn. çöp nöbeti sırayla (v1’de basit tutulur) |
| Hatırlatma | Push bildirim (iskelet) |

### 2.4 Giderler

| Özellik | Açıklama |
|--------|----------|
| Gider ekle | Tutar, kategori (market, fatura, diğer), kim ödedi |
| Bölüşüm | Eşit böl veya özel paylar |
| Borç özeti | Kim kime ne borçlu |
| Kapatıldı işaretle | “Ödendi” (manuel; ödeme entegrasyonu yok) |

### 2.5 Kira

| Özellik | Açıklama |
|--------|----------|
| Aylık kira | Toplam tutar + kişi payı |
| Durum | Ödendi / ödenmedi (kişi bazlı) |
| Ay seçimi | Hangi ay için takip |

### 2.6 Keşif (ince katman — MVP’de isteğe bağlı)

| Özellik | Açıklama |
|--------|----------|
| İlan aç | “Evimiz kişi arıyor” — semt, kira payı, kaç kişi, kısa açıklama |
| Listele / filtre | Şehir veya üniversite |
| İlan detayı | Ev özeti + iletişime geç |
| Basit mesaj | İlan sahibi ile kısa sohbet (veya ilk sürümde sadece “iletişim isteği”) |

### 2.7 MVP’de bilerek yok

- AI uyum skoru  
- Harita ağırlıklı sosyal keşif  
- Yorum / puan sistemi  
- Foto kanıtlı görev, XP, oyunlaştırma  
- iyzico / gerçek ödeme  
- Web paneli  

---

## 3. Olması gereken özellikler (sonraki sürümler)

Bunlar vizyonda var; MVP’den sonra tartışılıp sıralanacak.

### v2 — Güven ve büyüme

- Önceki ev arkadaşlarından **yorum / itibar**
- Yaşam tarzı tercihleri (sigara, misafir, temizlik, sessizlik…)
- Daha iyi ilan filtreleri
- Ev takvimi (misafir, fatura tarihi, ev sahibi ziyareti)
- Ortak alışveriş listesi

### v3 — Güçlü ürün

- Konuma göre “yakınımdakiler” (harita)
- Gelişmiş eşleşme önerileri
- Ödeme entegrasyonu veya “öde” linki
- Fotoğraflı görev kanıtı
- Bildirim kuralları (kişiselleştirme)
- Moderasyon / şikayet / güvenlik ipuçları

### Uzun vadeli fikirler (şimdilik rafa)

- Gamification (ev XP’si, rozet)
- Yurt / karma modeller
- Ev sahibi tarafı
- Premium ilan öne çıkarma (gelir modeli)

---

## 4. Rakip manzarası (kısa)

| Tip | Örnekler | Ne yapıyor | Ne eksik |
|-----|----------|------------|----------|
| Gider | Splitwise | Borç hesaplama | Görev + ev arkadaşı bulma yok |
| Ev yönetimi | Flatastic, HOMEi, Roomiz | Chore + bill | TR öğrenci + keşif zayıf |
| Ev arkadaşı ilanı (TR) | Evarkadasin, EvArkadasiBul, UniDeApp… | İlan + mesaj | Ev içi yönetim yok |
| Birleşik denemeler | Platuni, CoHabby vb. | Eşleşme + yönetim vaadi | TR öğrenci pazarında yerleşik lider yok |

**Fırsat:** Türkiye’de öğrenci odaklı **yönetim + keşif + itibar** birleşimi henüz güçlü oturmamış.

**Strateji önerisi:** Önce yönetimle gerçek kullanım yarat → sonra keşif ve yorum ile büyü.

---

## 5. Sistem mimarisi

### 5.1 Önerilen stack

| Katman | Teknoloji | Neden |
|--------|-----------|-------|
| Mobil | **Flutter** | Tek kod iOS + Android |
| Auth | **Firebase Auth** | E-posta + Google hızlı |
| Veri | **Cloud Firestore** | Gerçek zamanlı, hızlı prototip |
| Dosya | **Firebase Storage** | Profil foto |
| Bildirim | **FCM** | Görev / borç hatırlatma |
| Alternatif | Supabase | SQL tercih edilirse (tartışma maddesi) |

### 5.2 Yüksek seviye mimari

```
┌─────────────────────────────────────┐
│         Flutter mobil uygulama       │
│   (Evim | Keşfet | Profil sekmeleri) │
└──────────────┬──────────────────────┘
               │
     ┌─────────┼─────────┬────────────┐
     ▼         ▼         ▼            ▼
 Firebase   Firestore  Storage       FCM
   Auth      (veri)    (foto)     (bildirim)
```

### 5.3 Ana veri modelleri

| Model | Örnek alanlar |
|-------|----------------|
| **User** | id, ad, email, üniversite, bio, fotoUrl, currentHouseId |
| **House** | id, ad, semt, inviteCode, createdBy, memberIds |
| **Membership** | userId, houseId, role (admin/member), joinedAt |
| **Task** | houseId, title, assigneeIds, dueDate, status, rotation? |
| **Expense** | houseId, amount, paidBy, splits[], category, settled |
| **Rent** | houseId, month, total, shares[{userId, amount, paid}] |
| **Listing** | houseId, title, rentShare, city, uni, active |
| **Message** | listingId veya threadId, from, to, text, createdAt |
| **Review** | fromUser, toUser, houseId, rating, text *(v2)* |

### 5.4 Güvenlik (MVP notu)

- Firestore Security Rules: kullanıcı sadece kendi evi / kendi verisini okuyup yazar
- Davet kodu ile üyelik kontrolü
- İlan ve mesajlarda kişisel telefon zorunlu tutulmaz (in-app iletişim tercih)

### 5.5 Geliştirme yaklaşımı

1. Flutter iskeleti + Auth  
2. Ev + üyelik  
3. Görev + gider + kira  
4. Bildirim  
5. (İsteğe bağlı) ince keşif  
6. Pilot: 2–3 gerçek ev  

---

## 6. Örnek uygulama tasarımı

### 6.1 Ana navigasyon (3 sekme)

| Sekme | Amaç |
|-------|------|
| **Evim** | Görev, gider, kira, üyeler — günlük kullanım |
| **Keşfet** | İlanlar, filtre, ilan detayı |
| **Profil** | Kendi profili, ayarlar, evden ayrıl |

Ev yoksa “Evim” ekranı: **Ev oluştur** veya **Koda katıl** CTA’sı gösterir.

### 6.2 Kritik ekranlar (wireframe seviyesi)

**1) Açılış / giriş**  
Logo + “Öğrenci evini birlikte yönet” + Google / e-posta giriş.

**2) Evim — özet (home)**  
Üstte ev adı. Hızlı özet: bugünün görevleri, senden beklenen borç, bu ay kira durumu. Altında kısayollar: Görevler | Giderler | Kira | Üyeler.

**3) Görev listesi**  
Liste: başlık, atanan kişi, durum. FAB: “Görev ekle”. Filtre: Benim / Tümü / Tamamlanan.

**4) Gider listesi + borç özeti**  
Üstte “Senin net durumun: Ali’ye 120₺ borçlusun”. Altta gider kartları. FAB: “Gider ekle”.

**5) Gider ekle**  
Tutar, açıklama, kategori, kim ödedi, kimler paylaşıyor (checkbox). Kaydet.

**6) Kira**  
Ay seçici. Her üye satırı: pay tutarı + ödendi anahtarı.

**7) Keşfet listesi**  
Filtre çubuğu (şehir / üniversite). Kart: semt, kira payı, “2 kişi kalıyor, 1 yer boş”.

**8) İlan detayı**  
Açıklama, kurallar özeti, “Mesaj gönder” butonu.

**9) Profil**  
Foto, ad, üniversite, bio, mevcut ev, (ileride) yorumlar.

**10) Ev oluştur / koda katıl**  
Basit form veya 6 haneli kod girişi.

### 6.3 İki örnek kullanıcı akışı

**Akış A — Eve katıl ve gider ekle**

1. Kayıt ol  
2. Arkadaşın verdiği davet kodunu gir  
3. Evim’de görün  
4. Market fişini gider olarak ekle, eşit böl  
5. Herkes borç özetini görür  

**Akış B — Kişi ara / ilan aç**

1. Ev admin’i Keşfet’ten “İlan oluştur”  
2. Kira payı + semt + kısa metin  
3. Ev arayan öğrenci Keşfet’te görür  
4. Mesajlaşır / tanışma süreci uygulama dışında da sürebilir  
5. Kabul edilince davet kodu ile eve katılır → Akış A’ya döner  

### 6.4 Görsel yön (tasarım ilkeleri — tartışma)

- Mobil öncelikli, sade, az gürültü  
- İlk ekranda “dashboard kalabalığı” olmasın; Evim özeti kısa tutulsun  
- Kart yağmuru yerine net liste + güçlü tipografi  
- Marka adı (CampusFlow veya seçilecek isim) girişte ve Evim’de görünür olsun  
- Renk / font kararı Figma aşamasında netleşir; bu döküman wireframe seviyesindedir  

---

## 7. Başarı ölçütleri (pilot)

| Metrik | Hedef (öneri) |
|--------|----------------|
| Pilot ev sayısı | 2–3 gerçek öğrenci evi |
| Kullanım | 2 haftada ev üyelerinin çoğu haftada ≥3 açılış |
| Değer kanıtı | En az gider veya görev düzenli kullanılsın |
| Geri bildirim | “WhatsApp’tan daha mı iyi?” sorusuna net cevap |

---

## 8. Tartışma soruları (ikimize)

Aşağıdakileri birlikte cevaplayalım; cevaplar dökümanın bir sonraki versiyonuna yazılacak.

1. **MVP’de Keşfet olsun mu**, yoksa ilk sürüm sadece Evim (yönetim) mi?  
2. İlk **pilot şehir / üniversite** hangisi?  
3. Backend: **Firebase mi, Supabase mi?** (varsayılan öneri: Firebase)  
4. **Yorum / itibar** ne zaman gelsin? (öneri: v2)  
5. Uygulama **adı** CampusFlow mu kalsın, başka bir isim mi?  
6. Para modeli şimdi konuşulsun mu, yoksa “önce kullanım” mı?  
7. İkimizden kim **Flutter / backend / tasarım**a daha yakın — iş bölümü nasıl?

---

## 9. Sonraki adımlar (özet)

1. Bu dökümanı birlikte okuyup tartışma sorularını cevapla  
2. MVP listesini kilitle (ne var / ne yok)  
3. 8–10 ekranı Figma veya kâğıt wireframe’e çevir  
4. Flutter + Firebase ile iskelet kur  
5. 2–3 evle pilot  

---

*Bu belge tartışma taslağıdır. Kararlar değiştikçe güncellenecektir.*
