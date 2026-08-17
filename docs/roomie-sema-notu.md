# Roomie — Firestore Şema Notu (v1, K1 sonrası güncellendi)

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

### `houses/{houseId}/expenses/{expenseId}` — Kirwe sahibi (K2, sonra)
| Alan | Tip | Açıklama |
|---|---|---|
| description | string | |
| amount | number | **Kuruş cinsinden int** tutulacak (ondalık/yuvarlama hatası olmasın diye) |
| paidBy | uid | |
| splitBetween | array\<uid\> | |
| createdAt | timestamp | |
| settled | boolean | |

### `houses/{houseId}/tasks/{taskId}` — Adem sahibi (referans, henüz netleşmedi)
### `houses/{houseId}/rent/{rentId}` — Adem sahibi (referans, henüz netleşmedi)

## K1 durumu
`users.currentHouseId`, `houses`, `houses/memberships`, `houseCodes` — model, servis (`house_service.dart`), Riverpod provider'ları (`house_provider.dart`) ve 3 ekran (Evim, Ev Oluştur, Koda Katıl) yazıldı. Test edilmeyi bekliyor.

## Açık sorular / bilinen sınırlamalar (Adem ile netleştirilecek)
1. Owner evden ayrılırsa ne olacak (ownership devri)? K1'de ele alınmadı, K2 öncesi konuşulacak.
2. `houses.update` kuralı şu an "üye olan/olacak herkes her alanı değiştirebilir" kadar gevşek (MVP hızı için). K2'de sadece `memberIds` diff'ine izin verecek şekilde sıkılaştırılmalı.
3. `memberIds` denormalizasyonu yerine sadece `memberships` subcollection'a mı güvenelim? (Şimdilik ikisi de var, performans testinden sonra sadeleştirilebilir.)
