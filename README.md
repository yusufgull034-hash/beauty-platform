# Berber Randevu Platformu

Müşteriler için kolay randevu, berberler için daha dolu takvim ve daha iyi işletme yönetimi.

Bu proje; müşterilerin berberleri keşfedip randevu almasını, berberlerin ise takvimlerini, müşterilerini ve gelirlerini tek yerden yönetmesini sağlayan Android ve iOS uygulamasıdır.

## Gelir yaklaşımı

İlk aşamada temel randevu alma özelliği ücretsiz tutulacaktır. Gelir modeli şu katmanlarla kurulacaktır:

1. **Berber Pro üyeliği:** gelişmiş raporlar, kampanyalar, müşteri yönetimi ve çoklu çalışan özellikleri.
2. **Öne çıkarma:** berberlerin bölgelerinde daha görünür olması için isteğe bağlı tanıtım paketi.
3. **Ödeme komisyonu:** uygulama içi ödeme kullanıldığında açıkça gösterilen makul hizmet bedeli.
4. **Kurumsal paket:** çok şubeli işletmeler için gelişmiş yetkilendirme ve raporlama.

Temel randevu akışını ücretli duvarın arkasına koymayacağız. Böylece müşteri deneyimi korunurken berberler uygulamayı deneyebilecek.

## İlk sürüm kapsamı

- Müşteri ve berber hesapları
- Berber profili ve hizmet listesi
- Çalışma saatleri ve müsaitlik
- Randevu oluşturma, değiştirme ve iptal
- Berber yönetim ekranı
- Randevu hatırlatmaları
- Puanlama ve yorum
- Basit gelir ve randevu raporu

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
- [ ] Flutter proje kurulumu
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
