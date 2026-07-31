# CampusFlow — 2 Kişilik Görev Bölümlendirme

**Kişiler:** Adem · Kirwe  
**Dayanak:** [urun-dokumani.md](urun-dokumani.md) (v0.1)  
**Versiyon:** 0.1  
**Tarih:** Temmuz 2026  
**Amaç:** Kim ne yapacak, yaparken nelere dikkat edilecek

---

## 1. Rol özeti (tek bakışta)

| | **Adem** | **Kirwe** |
|--|----------|-----------|
| **Ana rol** | Ürün + Evim (yönetim) yüzü | Altyapı + veri + Keşfet |
| **Odak** | Ekranlar, akışlar, görev/gider/kira UI, pilot | Flutter iskeleti, Firebase, Auth, ev/üyelik, güvenlik, bildirim |
| **Sahip olduğu alan** | “Evim” sekmesi ve günlük kullanım deneyimi | Proje kurulumu, backend, “Keşfet” + mesaj iskeleti |
| **Ortak** | MVP kilidi, haftalık senkron, birbirinin PR/testi, pilot geri bildirimi | aynı |

> Bu bölünme varsayılandır. Biriniz Flutter’da daha güçlüyse roller yer değiştirebilir; önemli olan **tek sahibin** olması (aynı dosyada iki kişi aynı anda boğuşmasın).

---

## 2. Ortak kurallar (ikisi de)

1. **MVP dışına taşma.** Yorum, harita, AI eşleşme, ödeme entegrasyonu yok — ürün dökümanındaki “bilerek yok” listesine uy.
2. **Önce yönetim, sonra keşif.** Ev oluştur → katıl → görev/gider/kira çalışmadan Keşfet’e ağırlık verme.
3. **Tek kaynak gerçek:** Kararlar `urun-dokumani.md` + bu dosyada yazılsın; WhatsApp’ta kalan karar kaybolur.
4. **Haftada en az 1 senkron** (30 dk): ne bitti, ne takıldı, yarın ne.
5. **Birbirinin işini kırmadan birleştir:** Ortak modeller (`User`, `House`, `Task`…) önce birlikte netleştirilsin; sonra paralel kod.
6. **Test etmeden “bitti” deme:** En az kendi telefonunda / emülatörde mutlu yol (happy path) dene.
7. **Gizlilik:** Gerçek kullanıcı verisini rastgele paylaşma; pilot evlere ne topladığınızı söyleyin.

---

## 3. Fazlara göre kim ne yapacak

Ürün dökümanındaki geliştirme sırasına göre.

### Faz 0 — Fikri kilitlemek (1–3 gün)

| Görev | Sorumlu | Destek |
|-------|---------|--------|
| Ürün dökümanı tartışma sorularını cevaplamak | **Adem + Kirwe** | — |
| MVP’de Keşfet var mı / yok mu kararını yazmak | **Adem** (öneriyi getirir) | Kirwe onaylar |
| Pilot şehir / üniversite seçmek | **Adem** | Kirwe |
| Uygulama adı kararı | **İkisi** | — |
| Firebase vs Supabase (varsayılan: Firebase) | **Kirwe** (teknik öneri) | Adem onaylar |
| Bu iş bölümünü gözden geçirip imza atmak | **İkisi** | — |

**Dikkat (Faz 0):**
- “Her şeyi yapalım” tuzağına düşmeyin; listeyi kısaltmak başarıdır.
- İsim / renk tartışması Faz 0’ı sonsuza uzatmasın — 30 dk kuralı.

---

### Faz 1 — Proje iskeleti + Auth

| Görev | Sorumlu | Dikkat edilecekler |
|-------|---------|-------------------|
| Flutter proje kurulumu, klasör yapısı, routing (3 sekme: Evim / Keşfet / Profil) | **Kirwe** | Sekme isimleri ürün dökümanıyla aynı kalsın; gereksiz paket ekleme. |
| Firebase proje + Auth (e-posta + Google) | **Kirwe** | iOS/Android config dosyalarını `.gitignore`’a koy; API anahtarlarını sohbete yapıştırma. |
| Giriş / kayıt ekranı UI | **Adem** | Kısa metin, marka adı görünsün; kalabalık form olmasın. |
| Profil modeli iskeleti (ad, üniversite, bio, foto) | **Kirwe** (model + Firestore) | Alan isimlerini baştan sabitleyin; sonra değiştirmek pahalı. |
| Profil ekranı UI | **Adem** | Foto yükleme Storage’a Kirwe’nin verdiği API üzerinden. |

**Birlikte dikkat:**
- Auth olmadan diğer ekranlara “sahte kullanıcı” ile devam etmeyin — erken bağlayın.
- Ortak `User` şemasını 1 sayfalık not olarak yazın.

---

### Faz 2 — Ev + üyelik

| Görev | Sorumlu | Dikkat edilecekler |
|-------|---------|-------------------|
| House / Membership modeli, davet kodu üretimi | **Kirwe** | Kod kısa ve çakışmasız olsun (örn. 6 hane); brute-force’a karşı basit rate limit / tek kullanımlık düşünün. |
| Ev oluştur + koda katıl ekranları | **Adem** | Ev yokken Evim’de net CTA: “Ev oluştur” / “Koda katıl”. |
| Üye listesi | **Adem** (UI) + **Kirwe** (sorgu) | Sadece kendi evinin üyeleri görünsün. |
| Evden ayrıl | **İkisi** (Kirwe logic, Adem UI) | Ayrılınca görev/gider ekranları boş/kilitli kalsın; veri sızıntısı olmasın. |
| Firestore Security Rules (ev üyeliği) | **Kirwe** | “Herkese açık okuma” bırakmayın; üye değilse house verisi yok. |

**Dikkat:**
- Admin / member rolünü erken netleştirin (ilan açma kimde?).
- Aynı anda iki ev üyeliği MVP’de gerekmez — basitleştirin (tek `currentHouseId`).

---

### Faz 3 — Görev + gider + kira (MVP kalbi)

Bu faz ürünün asıl değeri. **Adem UI ve akış sahibi; Kirwe veri/hesap motoru.**

#### Görevler

| Parça | Sorumlu | Dikkat |
|-------|---------|--------|
| Task modeli, CRUD, atama | **Kirwe** | `houseId` zorunlu; ev dışı görev olmasın. |
| Görev listesi + ekle + tamamla UI | **Adem** | Filtre: Benim / Tümü / Tamamlanan. Kart yağmuru yapma. |
| Basit rota (isteğe bağlı MVP) | **Kirwe** logic, **Adem** UI | Karmaşık rota motoru yazmayın; “sıradaki kişi” yeter. |

#### Giderler

| Parça | Sorumlu | Dikkat |
|-------|---------|--------|
| Expense modeli, split hesabı, borç özeti | **Kirwe** | Eşit böl + basit özel pay. Yuvarlama (kuruş) kuralını yazın. “Kim kime borçlu” net ve test edilmiş olsun. |
| Gider listesi + ekle formu UI | **Adem** | “Kim ödedi” ve “kimler paylaşıyor” zorunlu alan; yanlış varsayılan seçim borç bozar. |
| “Ödendi / kapatıldı” işaretleme | **İkisi** | Gerçek para transferi yok; sadece takip. Kullanıcıya bunu net söyleyin. |

#### Kira

| Parça | Sorumlu | Dikkat |
|-------|---------|--------|
| Rent modeli (ay, paylar, paid flag) | **Kirwe** | Ay anahtarı net olsun (`2026-07` gibi). |
| Kira ekranı UI | **Adem** | Her üye satırında pay + ödendi anahtarı; toplam ile paylar tutarlı mı kontrol. |

**Faz 3 genel dikkat (çok önemli):**
- Gider hesabı **yanlış olursa güven biter** — Kirwe unit/manuel test yazsın; Adem 3 kişilik örnek senaryoyla doğrulasın.
- Evim özet ekranı kalabalık olmasın: bugünün görevleri + net borç + kira durumu yeter.
- İki kişi aynı anda `Expense` formülünü değiştirmesin — sahip: **Kirwe**.

---

### Faz 4 — Bildirimler

| Görev | Sorumlu | Dikkat |
|-------|---------|--------|
| FCM kurulumu | **Kirwe** | İzin metni kullanıcıya anlaşılır olsun; spam bildirim göndermeyin. |
| Görev hatırlatma / borç hatırlatma tetikleri | **Kirwe** | MVP’de iskelet yeter (manuel veya basit scheduled). |
| Bildirim metinleri / hangi olayda gideceği listesi | **Adem** | Kısa, net, suçlayıcı dil yok (“Hâlâ borçlusun!” yerine “Paylaşılmış gider güncellendi”). |

---

### Faz 5 — Keşfet (ince / isteğe bağlı)

MVP’de “olsun” derseniz:

| Görev | Sorumlu | Dikkat |
|-------|---------|--------|
| Listing modeli, liste + filtre (şehir/üniversite) | **Kirwe** | Aktif/pasif ilan; sahte konum şişirmeyin. |
| Keşfet listesi + ilan detay + ilan oluştur UI | **Adem** | Evim kadar cilalı olması gerekmez; net bilgi yeter. |
| Basit mesaj veya “iletişim isteği” | **Kirwe** (backend) + **Adem** (UI) | Telefon numarasını zorunlu tutmayın; in-app tutun. |
| İlan açma yetkisi (ev admin) | **Kirwe** | Üye olmayan ilan açamasın. |

**Dikkat:** Keşfet, Evim’i bitirmeden ana iş olmasın. Cold start’ta boş liste normal — pilot metnini hazırlayın.

---

### Faz 6 — Pilot (2–3 gerçek ev)

| Görev | Sorumlu | Dikkat |
|-------|---------|--------|
| Pilot ev bulmak, kurulumu anlatmak | **Adem** | 2–3 ev yeter; “herkese yayalım” yok. |
| Kurulum / bug triage / crash takibi | **Kirwe** | Log’a bak; pilot sırasında breaking change yapmayın. |
| Geri bildirim formu (3–5 soru) | **Adem** | “WhatsApp’tan daha mı iyi?”yi sorun. |
| Haftalık metrik notu (kaç açılış, gider/görev kullanımı) | **Adem** yazar, **Kirwe** teknik veri sağlar | Ölçmeden özellik eklemeyin. |

---

## 4. Ekran bazlı sahiplik (ürün dökümanı §6)

| Ekran | UI sahibi | Veri / logic sahibi |
|-------|-----------|---------------------|
| Giriş / kayıt | Adem | Kirwe |
| Evim özet | Adem | Kirwe |
| Görev listesi / ekle | Adem | Kirwe |
| Gider listesi / ekle / borç özeti | Adem | Kirwe |
| Kira | Adem | Kirwe |
| Ev oluştur / koda katıl | Adem | Kirwe |
| Üyeler | Adem | Kirwe |
| Keşfet listesi / ilan detay | Adem | Kirwe |
| Profil | Adem | Kirwe |
| Bildirim altyapısı | — | Kirwe |
| Security rules | — | Kirwe |

---

## 5. Adem — nelere özellikle dikkat etmeli

1. **Kapsam bekçisi ol.** “Şunu da ekleyelim” isteklerini v2 listesine yaz; MVP’yi şişirme.
2. **Evim sade kalsın.** Dashboard’a istatistik, rozet, 5 kart yığma.
3. **Formlar hatasız varsayılanlarla gelsin.** Özellikle gider: kim ödedi / kim paylaşıyor boş kalmasın.
4. **Metinler öğrenci dilinde, kısa.** Jargon ve uzun onboarding yok.
5. **Kirwe’nin modelini beklemeden sahte hardcode UI yazabilirsin** ama birleştirirken şemaya uy.
6. **Pilot insan ilişkisi sende.** Kullanıcıyı boğma; 10 dk’da kurulum + 3 soruluk feedback.
7. **Tasarım tutarlılığı:** Aynı buton stilleri, aynı boş durum (empty state) dili.

---

## 6. Kirwe — nelere özellikle dikkat etmeli

1. **Veri modeli tek gerçek.** `User`, `House`, `Task`, `Expense`, `Rent` alanlarını dökümana / kısa şema notuna yazmadan kodlama.
2. **Güvenlik rules’u sonraya bırakma.** Prototype’ta `allow read, write: if true` ile canlıya çıkmayın.
3. **Borç hesabını test et.** 3 kişilik senaryo: A ödedi, B/C borçlu; settle sonrası sıfır.
4. **Ev sınırını her sorguda koru.** `houseId` filtrelemeden koleksiyon tarama.
5. **Paket / mimari şişirme.** MVP için Firebase yeterliyse ekstra microservice yok.
6. **Secret yönetimi.** `.env` / `google-services.json` / `GoogleService-Info.plist` commit edilmesin (gerekirse örnek `*.example` koy).
7. **Adem’e net API yüzeyi ver.** “Şu fonksiyonu çağır, şu modeli döner” — UI’nın tahmin etmesine bırakma.
8. **Breaking change’i haber ver.** Alan adı değişince Adem’in ekranı kırılır; senkron mesajı at.

---

## 7. Birlikte yapılacaklar (sahip yok, ikisi şart)

| Konu | Ne zaman |
|------|----------|
| Ortak veri şeması v1 | Faz 1 başı |
| MVP feature freeze (liste kilit) | Faz 0 sonu |
| Haftalık 30 dk sync | Her hafta |
| Birbirinin mutlu yol testi | Her faz bitişi |
| Pilot sonrası “ne ekleyeceğiz / ne sileceğiz” | Faz 6 sonu |
| v2 (yorum, harita…) planı | Pilot kanıtından sonra |

---

## 8. Önerilen ilk 2 haftalık checklist

### Hafta 1
- [ ] Tartışma soruları cevaplandı (ikisi)
- [ ] Flutter + Firebase ayakta (Kirwe)
- [ ] Giriş + boş kabuk 3 sekme (Kirwe iskelet, Adem giriş UI)
- [ ] Ev oluştur / koda katıl çalışıyor (ikisi)

### Hafta 2
- [ ] Görev CRUD (Kirwe + Adem)
- [ ] Gider + borç özeti doğru hesap (Kirwe + Adem doğrulama)
- [ ] Kira ekranı (ikisi)
- [ ] En az 1 iç test evi (ikiniz + 1 arkadaş)

Keşfet ve FCM: Evim stabil olduktan sonra.

---

## 9. Takılınca ne yapın

| Durum | Ne yapılır |
|-------|------------|
| Aynı dosyada çakışma | Sahip kimse o bitirir; diğeri bekler veya ekranı ayırır |
| “Keşfet mi Evim mi?” tartışması | Ürün dökümanı kuralı: Evim önce |
| Hesap / borç anlaşmazlığı | Kirwe formülü yazar + 1 örnek senaryo; Adem UI’da gösterir |
| Süre yetmiyor | Önce kira’yı veya rota’yı kes; gider+görev+ev kalsın |
| Motivasyon / belirsizlik | Bu dosyadaki checklist’e dön; yeni özellik uydurma |

---

## 10. İmza / onay

Bu bölünmeyi okuduk, kabul ediyoruz (veya aşağıdaki notlarla değiştiriyoruz):

| | Ad | Tarih | İmza / onay |
|--|----|-------|-------------|
| 1 | Adem | | |
| 2 | Kirwe | | |

**Değişiklik notları (varsa):**  
_……………………………………………………………………………………_

---

*Bu belge, ürün dökümanındaki görevlere göre hazırlanmış tartışma / çalışma taslağıdır. Roller değişirse bu dosya güncellenir.*
