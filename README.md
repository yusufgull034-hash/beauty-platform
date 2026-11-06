# Kişisel Bakım ve Güzellik Platformu

Müşteriler için kolay randevu, profesyoneller için daha dolu takvim ve güvenilir kişisel bakım alışverişi.

Bu proje; müşterilerin berber, kadın kuaförü, güzellik salonu, makeup artist, gelin hazırlık uzmanı ve diğer kişisel bakım profesyonellerini keşfedip randevu almasını sağlayan Android ve iOS platformudur. İleride kişisel bakım ürünlerinin satışı da desteklenecektir.

## Gelir yaklaşımı

İlk aşamada temel randevu alma özelliği ücretsiz tutulacaktır. Gelir modeli şu katmanlarla kurulacaktır:

1. **Profesyonel Pro üyeliği:** gelişmiş raporlar, kampanyalar, müşteri yönetimi ve ekip özellikleri.
2. **Hizmet komisyonu:** platform üzerinden tamamlanan randevulardan şeffaf komisyon.
3. **Ürün satış marjı:** kişisel bakım ürünleri ve profesyonel ekipman satışından gelir.
4. **Öne çıkarma:** işletme ve freelancerların bölgelerinde görünür olması için tanıtım paketi.
5. **Kurumsal paket:** çok şubeli salonlar ve ekipler için gelişmiş yönetim.

Temel randevu akışını ücretli duvarın arkasına koymayacağız. Böylece müşteri deneyimi korunurken berberler uygulamayı deneyebilecek.

## İlk sürüm kapsamı

- Müşteri ve profesyonel hesapları
- İşletme/freelancer profili ve hizmet listesi
- Kişisel bakım kategorileri ve ürün kataloğu altyapısı
- Çalışma saatleri ve müsaitlik
- Randevu oluşturma, değiştirme ve iptal
- Salon, freelancer ve ekip yönetim ekranı
- Randevu hatırlatmaları
- Puanlama ve yorum
- Basit gelir, randevu ve hizmet performans raporu

## Teknik yön

- Mobil: Flutter
- Backend: Supabase
- Veritabanı: PostgreSQL
- Kimlik doğrulama: Supabase Auth
- Git akışı: küçük ve açıklayıcı commit'ler

## Yol haritası

- [x] Ürün vizyonu ve gelir yaklaşımı
- [ ] Kullanıcı araştırması ve fiyatlandırma doğrulaması
- [ ] Marka adı ve görsel kimlik
- [x] Flutter proje kurulumu
- [ ] Veritabanı şeması
- [ ] Kimlik doğrulama
- [ ] Randevu çekirdeği
- [ ] Berber paneli
- [ ] Ödeme ve abonelik
- [ ] Mağaza yayın hazırlığı

## Geliştirme ilkeleri

- Önce gerçek kullanıcı problemini doğrula.
- Her yeni özellik için kullanıcıya ve gelire katkısını ölç.
- Randevu akışını mümkün olduğunca kısa tut.
- Ödeme, abonelik ve kişisel verilerde şeffaf ol.
- Her sürümü GitHub'da açıklanabilir bir değişiklik olarak yayınla.
