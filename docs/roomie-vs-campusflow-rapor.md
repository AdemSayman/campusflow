# CampusFlow v0.1 vs Roomie — Durum Analiz Raporu

**Tarih:** 30 Temmuz 2026  
**Analiz edilen repo:** `C:\Users\Aduket Sayman\Documents\GitHub\Roomie`  
**Karşılaştırma dayanağı:** CampusFlow `urun-dokumani.md` v0.1  
**Hazırlayan:** Adem + analiz (Cursor)  
**Amaç:** Kirwe’nin mevcut çalışmasının CampusFlow MVP’sine ne kadar uyduğunu netleştirmek

---

## 1. Yönetici özeti (tek bakışta)

| Soru | Cevap |
|------|--------|
| Roomie nedir? | Öğrenci evi yönetimi için **native Android (Kotlin)** prototipi |
| Flutter + Firebase mi? | **Hayır.** Flutter yok, Firebase yok |
| Veri nerede? | Cihaz içi **Room DB** + **SharedPreferences** (bulut yok) |
| v0.1 Evim (yönetim) fikrine yakın mı? | **Evet — domain olarak yakın** (ev, görev, gider, profil) |
| v0.1’e “kaldığı yerden devam” edilebilir mi? | **Doğrudan hayır** — stack farklı; mantık/ekran fikirleri taşınabilir |
| En kritik boşluklar | Bulut senkron, davet kodu, kira, keşif/ilan, gerçek borç özeti, iOS, güvenli auth |

**Kısa hüküm:** Roomie, CampusFlow’un **Evim yüzünün yerel (offline) proof-of-concept’i**. Ürün vizyonundaki **çok cihazlı / bulutlu / keşif + kira** katmanı yok. Dün geceki Flutter + Firebase kararıyla Roomie **aynı kod tabanı değil**; **ürün öğrenimi ve ekran envanteri** olarak değerlidir.

---

## 2. Roomie teknik kimlik kartı

| Alan | Durum |
|------|--------|
| Dil / platform | Kotlin, sadece **Android** (`minSdk 24`, `targetSdk 36`) |
| Mimari | Activity + Fragment → doğrudan Room DAO (ViewModel/Repository yok) |
| Auth | SharedPreferences, e-posta/şifre **cihaz içi**, şifre düz metin |
| Veritabanı | Room `roomie_database` v10 (destructive migration) |
| Ağ | Retrofit → Advice Slip API (günlük söz); Maps/Location |
| UI | Çoğunlukla kod ile View; 3 XML layout (splash, main, dashboard) |
| Alt navigasyon | Home, Tasks, Expenses, Market, Profile |
| iOS / Web | Yok |
| Firebase / Flutter | Yok |

**Kanıt:** `app\build.gradle.kts`, `app\src\main\java\com\example\roomie\*.kt`

---

## 3. Roomie’de ne var? (özellik envanteri)

| Özellik | Durum | Not |
|---------|--------|-----|
| Splash + giriş/kayıt | Var | Sadece yerel |
| Ev oluştur / seç / üye ekle-çıkar | Var | Aynı cihaz DB’si |
| Görev klasörleri + atama + tamamla | Var | |
| Gider klasörleri + eşit böl (kişi sayısı) | Var | Basit; “kim kime borçlu” ledger yok |
| Market / alışveriş listesi | Var | CampusFlow’da v2’ye yakın |
| Profil + foto (URI prefs) | Kısmi | Bazı drawable eksik riski |
| Ev yorumları (local feed) | Var | Chat / itibar sistemi değil |
| Kumbara (kişisel birikim) | Var | MVP’de yok; ekstra |
| İstatistik / grafik | Var | MVP’de yok; ekstra |
| Harita | Kısmi | “Yakın market” vaadi; fiilen konum gösterimi |
| Bildirim | Demo | Sabit metin; göreve bağlı değil |
| Kira takibi | **Yok** | |
| Davet kodu | **Yok** | |
| Keşfet / ilan / mesaj | **Yok** | |
| Google giriş | **Yok** | |
| Çok cihaz / bulut sync | **Yok** | |

---

## 4. Karşılaştırma matrisi — CampusFlow v0.1 MVP

Açıklama: **Var** = Roomie’de karşılığı çalışıyor · **Kısmi** = benzer ama eksik · **Yok** = yok · **Farklı** = başka şekilde çözülmüş

### 4.1 Hesap ve profil

| v0.1 gereksinim | Roomie | Değerlendirme |
|-----------------|--------|----------------|
| E-posta + Google giriş | Kısmi | Sadece e-posta/şifre, yerel; Google yok |
| Profil: ad, foto, üniversite, bio | Kısmi | Ad/iş/foto var; üniversite/bio/ev durumu zayıf |
| “Şu an X evinde” / “ev arıyor” | Kısmi | Aktif ev var; “ev arıyor” durumu yok |

### 4.2 Ev

| v0.1 gereksinim | Roomie | Değerlendirme |
|-----------------|--------|----------------|
| Ev oluştur | Var | |
| Davet kodu ile katıl | Yok | Üye e-posta ile ekleniyor (aynı cihaz) |
| Üye listesi | Var | |
| Evden ayrıl | Kısmi | Üye silme / ev silme var; “ayrıl” akışı net ürünleşmemiş |
| Semt / adres | Yok | Evde çoğunlukla ad + owner |

### 4.3 Görevler

| v0.1 gereksinim | Roomie | Değerlendirme |
|-----------------|--------|----------------|
| Oluştur / ata / tamamla | Var | Klasör + item modeli |
| Tarih / due date | Kısmi / zayıf | v0.1’deki tarih vurgusu zayıf |
| Basit rota | Yok | |
| Push hatırlatma | Yok | Demo bildirim var |

### 4.4 Giderler

| v0.1 gereksinim | Roomie | Değerlendirme |
|-----------------|--------|----------------|
| Gider ekle | Var | |
| Kategori | Kısmi | Klasör başlığı; market/fatura/diğer standart değil |
| Kim ödedi | Yok / zayıf | Ledger mantığı yok |
| Eşit / özel pay | Kısmi | `personCount` ile eşit böl |
| Kim kime borçlu özeti | Yok | Kritik MVP boşluğu |
| Ödendi işaretle | Yok | |

### 4.5 Kira

| v0.1 gereksinim | Roomie | Değerlendirme |
|-----------------|--------|----------------|
| Aylık kira + kişi payı | Yok | |
| Ödendi / ödenmedi | Yok | |
| Ay seçimi | Yok | |

### 4.6 Keşif (ince katman)

| v0.1 gereksinim | Roomie | Değerlendirme |
|-----------------|--------|----------------|
| İlan aç / listele / filtre | Yok | |
| İlan detay + mesaj | Yok | |
| Harita keşfi | Yok | Map başka amaçlı ve yarım |

### 4.7 Altyapı (dün gece karar + v0.1 mimari)

| v0.1 / sözleşme | Roomie | Değerlendirme |
|-----------------|--------|----------------|
| Flutter (iOS+Android) | Yok | Sadece Android Kotlin |
| Firebase Auth / Firestore / Storage / FCM | Yok | Room + prefs |
| Security rules / bulut | Yok | Tek cihaz |

### 4.8 Roomie’de olup v0.1 MVP’de olmayanlar

Bunlar “kötü” değil; **kapsam şişirme riski** veya **v2 adayı**:

- Market / alışveriş listesi → ürün dökümanında **v2**
- Ev içi yorum feed’i → v0.1’de itibar yorumu farklı ve **v2**
- Kumbara → MVP dışı
- Stats / ev skoru / grafik → MVP dışı
- Günlük nasihat API → ürün değeri düşük, eğlencelik
- Harita → v0.1’de bilinçli olarak ağır keşif yok (v3’e yakın)

---

## 5. Uyum skoru (kabaca)

| Alan | Tahmini uyum | Yorum |
|------|--------------|--------|
| Ürün domain’i (ev yaşamı) | **%70** | Doğru probleme bakılmış |
| MVP Evim özellikleri | **%40–50** | Ev/görev/gider var; kira + borç özeti + davet kodu yok |
| MVP Keşfet | **%0** | Yok |
| Hedef mimari (Flutter+Firebase) | **%0** | Farklı stack |
| Yayınlanabilir çok kullanıcılı ürün | **%15** | Sync/auth/güvenlik uygun değil |

**Genel:** Roomie = **fikir doğrulama + Android UI denemesi**. CampusFlow v0.1 = **yeni (veya yeniden) inşa** gerektirir.

---

## 6. Kalite / risk notları (Roomie kodu)

1. **Stack uyumsuzluğu** — Flutter kararıyla kod tabanı paylaşımı yok.  
2. **Auth güvensiz** — şifre plaintext SharedPreferences.  
3. **Çok kullanıcılı senaryo çalışmaz** — ev üyeleri aynı telefona bağımlı.  
4. **Ev silince cascade yok** — görev/gider/market/yorum artıkları kalabilir.  
5. **Eksik drawable riski** — `roomie_logo`, `profile_icon_2` referansları; repo’da launcher dışında zayıf.  
6. **Ölü kod** — kullanılmayan Adapter’lar.  
7. **Map API key** manifest’te (sızıntı riski).  
8. **Bildirimler gerçek görevlere bağlı değil.**  
9. **Mimari** — büyük fragment’lar, tekrarlayan tema kodu; öğrenmek için OK, büyütmek için zor.

---

## 7. Ne korunabilir? (Roomie → CampusFlow)

Kod kopyalamak yerine **bilgi ve ürün kararları** taşıyın:

| Koru / uyarla | Neden |
|---------------|--------|
| Ev → görev / gider kapsamı | Domain doğru |
| Klasör + item UX fikri | Görev/gider gruplama işe yarıyor olabilir |
| Market listesi | v2 backlog’a yaz |
| Alt nav yapısı | Evim odaklı navigasyon fikri |
| “Aktif ev” kavramı | `currentHouseId` ile uyumlu |
| Türkçe kopya / akış hissi | Öğrenci diline yakın |

| Taşıma | Öneri |
|--------|--------|
| Kotlin Room şeması | Firestore modeline **yeniden tasarla** (House merkezli v0.1) |
| SharedPreferences auth | Firebase Auth |
| Stats / kumbara / nasihat | MVP’ye alma |
| Map | Ertele |

---

## 8. Önerilen strateji (ikiniz için)

### Seçenek A — Önerilen: Yeşil alan Flutter + Firebase

1. Yeni CampusFlow Flutter reposu  
2. Roomie’yi **referans ürün / ekran checklist** olarak kullanın  
3. MVP sırası: Auth → Ev+davet kodu → Görev → Gider+borç özeti → Kira → (isteğe) Keşfet  
4. Roomie’deki market/stats’ı bilinçli erteleyin  

### Seçenek B — Roomie’yi Android-only ilerletmek

Flutter + iOS hedefini bırakır. Dünkü karar ve v0.1 mimari ile **çelişir**. Önerilmez (store + iki platform hedefi varsa).

### Seçenek C — Hibrit “önce Roomie patch”

Kısa vadede Roomie’ye kira/davet eklemek cazip görünür ama bulut + Flutter’a sonra yine yeniden yazılır → **çift iş**.

**Tavsiye: A.**

---

## 9. Gap listesi — CampusFlow MVP için yapılacaklar (Roomie’den sonra)

Öncelik sırasıyla:

1. Flutter proje iskeleti + 3 sekme  
2. Firebase Auth (e-posta + Google)  
3. House + invite code + membership (Firestore)  
4. Task CRUD + atama  
5. Expense + **kim ödedi + borç özeti + settled**  
6. Rent (ay / pay / paid)  
7. Profil (üniversite, bio, foto Storage)  
8. FCM iskelet  
9. (Karar varsa) ince Keşfet  

Roomie’den gelen ama MVP’ye **sokulmayacaklar:** kumbara, stats, harita, nasihat API.

---

## 10. Sonuç cümlesi

Kirwe’nin Roomie’si boşuna yazılmamış: **ev içi yönetim problemini Android’de somutlaştırmış**. Ancak CampusFlow v0.1’in “olması gerekenleri” açısından bakınca proje **yaklaşık yarı-yolda bir Evim prototipi** ve **hedef stack’ten ayrı**. Bundan sonrası: Roomie’yi arşiv/referans sayıp **Flutter + Firebase ile v0.1 MVP’yi bilinçli inşa etmek**.

---

## 11. Bir sonraki konuşma soruları (Adem + Kirwe)

1. Roomie’yi tamamen referans mı sayıyoruz, yoksa bazı ekran akışlarını birebir mi kopyalayacağız?  
2. Market listesi MVP’ye girsin mi, v2’de mi kalsın? (v0.1’e göre v2)  
3. Flutter reposunu kim açacak, ne zaman?  
4. State / GoRouter sözleşmesi dün kilitlendi mi? Yazılı mı?  

---

*Bu rapor Roomie kod tabanının 30.07.2026 tarihli haline ve CampusFlow ürün dökümanı v0.1’e dayanır.*
