# Roomie — Firestore Şema Notu (v2, K2 sonrası güncellendi)

G1 teslimi için hazırlanan 1 sayfalık şema notu. Kirwe = Ev/Gider/FCM tarafı, Adem = Auth/Görev/Kira tarafı.
Firebase projesi: **campusflow-fcf50** (Adem'in oluşturduğu proje; Kirwe'nin ayrıca oluşturduğu deneme projesi kullanılmıyor).

## Koleksiyonlar

### `users/{uid}` — gerçek alan adları (merge olmuş Auth koduna göre)
| Alan | Tip | Açıklama |
|---|---|---|
| uid | string | Auth PR'ında yazıldı |
| email | string | Auth PR'ında yazıldı |
| name | string | Auth PR'ında yazıldı (not: `displayName` değil, `name`) |
| university | string | Auth PR'ında yazıldı |
| bio | string | Auth PR'ında yazıldı |
| photoUrl | string? | Auth PR'ında yazıldı |
| currentHouseId | string? | **Kirwe ekliyor** — eve katılmadıysa null (K1) |
| fcmTokens | array\<string\> | **Kirwe, K3'te dolduracak** |
| createdAt | timestamp | Auth PR'ında yazıldı |

### `houses/{houseId}` — Kirwe sahibi (K1, kod yazıldı)
| Alan | Tip | Açıklama |
|---|---|---|
| name | string | Ev adı |
| inviteCode | string | 6 haneli, unique davet kodu |
| createdBy | uid | Evi oluşturan kullanıcı |
| createdAt | timestamp | |
| memberIds | array\<uid\> | Hızlı okuma için denormalize edilmiş üye listesi |

### `houses/{houseId}/memberships/{uid}` — Kirwe sahibi (K1, kod yazıldı)
| Alan | Tip | Açıklama |
|---|---|---|
| uid | string | |
| role | "owner" \| "member" | |
| joinedAt | timestamp | |

### `houseCodes/{code}` — YENİ, Kirwe sahibi (K1, kod yazıldı)
| Alan | Tip | Açıklama |
|---|---|---|
| houseId | string | Bu davet koduna sahip evin id'si |

Neden ayrı bir koleksiyon: `houses/{houseId}` sadece üyelere açık okunuyor, ama "davet koduyla katıl" akışında kullanıcı henüz üye değil — evi bulabilmesi gerekiyor. Bu küçük, hassas veri içermeyen eşleme koleksiyonu bu sorunu çözüyor (detay: `firestore.rules` içindeki yorum).

### `houses/{houseId}/expenses/{expenseId}` — Kirwe sahibi (K2, kod yazıldı)
| Alan | Tip | Açıklama |
|---|---|---|
| description | string | Ne için harcandı |
| amountKurus | number (int) | **Kuruş cinsinden**, örn. 45,50 TL = 4550 (ondalık/yuvarlama hatası olmasın diye) |
| paidBy | uid | Ödemeyi yapan (rules: sadece kendi adına girebilir) |
| splitBetween | array\<uid\> | Bölüşen kişiler (rules: sadece ev üyeleri olabilir) |
| createdAt | timestamp | |
| settled | boolean | Kapandı mı? (herhangi bir üye değiştirebilir) |

**Kuruş kuralı (eşit bölme):** `pay = amountKurus ~/ N`, `kalan = amountKurus % N`. Kalan kuruşlar, uid'lere göre alfabetik sıralanmış listenin baştaki `kalan` kişisine 1'er kuruş fazladan verilir (deterministik). Tam algoritma ve net bakiye hesaplaması: `lib/services/expense_calculator.dart` (Firebase'den bağımsız, saf fonksiyonlar, ayrı dosyada — K2 gereksinimi).

### `houses/{houseId}/tasks/{taskId}` — Adem sahibi (referans, henüz netleşmedi)
### `houses/{houseId}/rent/{rentId}` — Adem sahibi (referans, henüz netleşmedi)

## K1 durumu
`users.currentHouseId`, `houses`, `houses/memberships`, `houseCodes` — model, servis (`house_service.dart`), Riverpod provider'ları (`house_provider.dart`) ve 3 ekran (Evim, Ev Oluştur, Koda Katıl) yazıldı, test edildi, merge oldu.

## K2 durumu
`houses/expenses` — model (`expense.dart`), hesaplama mantığı (`expense_calculator.dart`), servis (`expense_service.dart`), Riverpod provider'ları (`expense_provider.dart`) ve 2 ekran (Giderler listesi + net bakiye, Gider Ekle) yazıldı. "Evim" ekranından "Giderler" kartıyla erişiliyor. 3 kişilik test senaryosu bekliyor.

## Açık sorular / bilinen sınırlamalar (Adem ile netleştirilecek)
1. Owner evden ayrılırsa ne olacak (ownership devri)? K1'de ele alınmadı, henüz netleşmedi.
2. `houses.update` kuralı şu an "üye olan/olacak herkes her alanı değiştirebilir" kadar gevşek (MVP hızı için). İleride sadece `memberIds` diff'ine izin verecek şekilde sıkılaştırılmalı.
3. `memberIds` denormalizasyonu yerine sadece `memberships` subcollection'a mı güvenelim? (Şimdilik ikisi de var, performans testinden sonra sadeleştirilebilir.)
4. Net bakiye şu an sadece "kim ne kadar alacaklı/borçlu" gösteriyor (basit net bakiye). "A, B'ye şu kadar öder" gibi kişi-kişiye sadeleştirilmiş borç listesi (debt simplification) K2 kapsamında yok — istenirse ayrı bir iyileştirme olarak eklenebilir.
