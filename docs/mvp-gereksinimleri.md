# MVP Ürün Gereksinimleri: Kişisel Bakım Platformu

## Geçici ürün adı

Marka adı daha sonra belirlenecek. Kod ve dokümantasyonda şimdilik `beauty-platform` adı kullanılacaktır.

## Ürün amacı

Müşterinin uygun kişisel bakım uzmanını veya işletmesini bulup hızlıca randevu almasını; profesyonelin ise çalışma saatlerini, randevularını ve temel işletme verilerini yönetmesini sağlamak.

## Kullanıcı rolleri

### Müşteri

- Hesap oluşturur ve profilini yönetir.
- Konumuna veya aramasına göre berberleri keşfeder.
- Hizmet, çalışan ve uygun saat seçer.
- Randevu oluşturur, değiştirir veya iptal eder.
- Randevu geçmişini ve favorilerini görür.
- Hizmet sonrasında puan ve yorum bırakır.

### Profesyonel / işletme sahibi

- İşletme veya freelancer profili oluşturur.
- Hizmetleri, fiyatları ve süreleri tanımlar.
- Çalışma saatlerini ve izinleri ayarlar.
- Randevuları onaylar, reddeder veya yönetir.
- Müşteri geçmişini ve temel raporları görür.
- Uzmanlık alanlarını seçer: erkek berberi, kadın kuaförü, makeup, gelin hazırlık, tırnak, cilt bakımı vb.

### Ürün satıcısı

- Kişisel bakım ürünleri veya profesyonel ekipman listeler.
- Stok, fiyat ve teslimat bilgilerini yönetir.
- Sipariş ve satış raporlarını takip eder.

### Yönetici

- İşletme ve kullanıcıları yönetir.
- Şikâyetleri ve yorumları inceler.
- Kategori ve şehir verilerini yönetir.
- Platform metriklerini takip eder.

## İlk randevu akışı

1. Müşteri kategori veya konum seçer.
2. Profesyonel/işletme profilini ve yorumlarını inceler.
3. Hizmet seçer.
4. Tarih ve uygun saat seçer.
5. Randevu detaylarını onaylar.
6. Müşteri ve berbere bildirim gider.
7. Randevu tamamlandıktan sonra yorum istenir.

## İlk kategori seti

- Erkek berberi
- Kadın kuaförü
- Saç ve boya
- Makeup artist
- Gelin hazırlık
- Tırnak ve manikür
- Cilt bakımı
- Kirpik ve kaş

## MVP dışında bırakılanlar

İlk sürümde ürün pazaryeri, kargo, ödeme, sadakat puanı, çoklu şube, gelişmiş yapay zekâ önerileri ve kapsamlı kampanya sistemi zorunlu değildir. Önce randevu ve profesyonel keşif çekirdeği doğrulanacaktır.

## Gelirle bağlantılı MVP kararları

- Ücretsiz profesyonel profili ve temel randevu alma olacaktır.
- Pro özellikleri için altyapı ilk günden genişletilebilir tasarlanacaktır.
- İşletme raporları, ekip yönetimi, kampanyalar ve ürün kataloğu ileride Pro pakete bağlanacaktır.
- Ürün satışı randevu sisteminden ayrı bir sipariş modülü olarak tasarlanacaktır.
- Ödeme entegrasyonu eklenmeden önce kullanıcıların randevu davranışı ölçülecektir.

## Başarı ölçütleri

- Yeni müşterinin ilk randevuyu beş dakikadan kısa sürede tamamlaması.
- Profesyonelin çalışma saatlerini ve ilk hizmetini kolayca tanımlayabilmesi.
- Randevu çakışmasının sistem tarafından engellenmesi.
- Randevu iptal ve değişikliklerinin kayıt altında tutulması.
- Kullanıcıların tekrar randevu alma oranının ölçülebilmesi.
