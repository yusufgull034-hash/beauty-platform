import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Appointment? activeAppointment;
final List<Map<String, dynamic>> cartItems = [];

const Map<String, List<String>> serviceCatalog = {
  'Berber': [
    'Saç kesimi',
    'Saç + sakal',
    'Sakal şekillendirme',
    'Çocuk saç kesimi',
    'Skin fade',
    'Saç yıkama',
    'Bıyık şekillendirme',
    'Damat tıraşı',
  ],
  'Kadın kuaförü': [
    'Saç kesimi',
    'Fön',
    'Boya',
    'Dip boya',
    'Ombre',
    'Röfle',
    'Balayage',
    'Keratin bakım',
    'Saç botoksu',
    'Saç kaynak uygulaması',
  ],
  'Makeup artist': [
    'Günlük makyaj',
    'Gece makyajı',
    'Porselen makyaj',
    'Davet makyajı',
    'Fotoğraf çekimi makyajı',
    'Doğal makyaj',
    'Erkek makyajı',
  ],
  'Gelin hazırlık': [
    'Gelin makyajı',
    'Gelin saçı',
    'Gelin başı',
    'Türban tasarımı',
    'Gelin türbanı hazırlama',
    'Gelin aksesuarı uygulama',
    'Gelin paketi',
    'Nişan makyajı',
    'Kına gecesi hazırlığı',
  ],
  'Cilt bakımı': [
    'Profesyonel cilt bakımı',
    'Hydrafacial',
    'Akne bakımı',
    'Leke bakımı',
    'Anti-aging bakım',
    'Enzim peeling',
    'Kimyasal peeling',
    'Cilt analizi',
  ],
  'Nail artist': [
    'Manikür',
    'Pedikür',
    'Kalıcı oje',
    'Jel tırnak',
    'Protez tırnak',
    'Nail art',
    'French manikür',
    'Tırnak güçlendirme',
  ],
  'Kaş & kirpik': [
    'Kaş tasarımı',
    'Kaş alımı',
    'Kaş laminasyonu',
    'Kirpik lifting',
    'İpek kirpik',
    'Kirpik dolgu',
  ],
  'Lazer epilasyon': [
    'Bölgesel lazer epilasyon',
    'Tüm vücut lazer epilasyon',
    'Yüz lazer epilasyonu',
    'Bikini bölgesi lazer epilasyonu',
    'Erkek lazer epilasyonu',
  ],
  'Masaj & spa': [
    'Klasik masaj',
    'Aromaterapi masajı',
    'Medikal masaj',
    'Bölgesel masaj',
    'Hamam',
    'Spa paketi',
  ],
  'Güzellik merkezi': [
    'Cilt bakımı',
    'Hydrafacial',
    'Profesyonel makyaj',
    'Kaş tasarımı',
    'Kirpik lifting',
    'Manikür',
    'Pedikür',
    'Lazer epilasyon',
    'Bölgesel incelme',
  ],
  'Hamam & kese': [
    'Kese',
    'Köpük banyosu',
    'Kese + köpük',
    'Geleneksel hamam',
    'VIP hamam paketi',
    'Çift kişilik hamam',
    'Sauna + hamam paketi',
  ],
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError(
      'Supabase bilgileri eksik. Uygulamayı --dart-define ile çalıştırın.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const BarberPlatformApp());
}

class BarberPlatformApp extends StatelessWidget {
  const BarberPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beauty Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB08A57),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F2EC),
        useMaterial3: true,
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(color: Color(0xFF1C1B19), fontSize: 20, fontWeight: FontWeight.w800),
          iconTheme: IconThemeData(color: Color(0xFF1C1B19)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFFB08A57), width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1C1B19),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFFE8EEF0),
          indicatorColor: Color(0xFFCFE7EC),
          labelTextStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) return const AuthPage();
        return const CustomerHomePage();
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.length < 6) {
      _showMessage('Geçerli bir e-posta ve en az 6 karakterli şifre gir.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(email: email, password: password);
        _showMessage('Kayıt başarılı. E-posta doğrulamanı kontrol et.');
      } else {
        await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Bir hata oluştu. Lütfen tekrar dene.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 52),
                  const SizedBox(height: 18),
                  Text(
                    _isSignUp ? 'Aramıza katıl' : 'Tekrar hoş geldin',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp ? 'Güzellik yolculuğunu bugün başlat.' : 'Randevuların ve favorilerin burada.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: Text(_isLoading ? 'Bekle...' : (_isSignUp ? 'Kayıt ol' : 'Giriş yap')),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(_isSignUp ? 'Zaten hesabın var mı? Giriş yap' : 'Yeni hesap oluştur'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const CustomerHomePage()),
                            ),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Üye olmadan göz at'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Merhaba 👋', style: TextStyle(fontSize: 14, color: Colors.black54)),
            Text('Kendine zaman ayır.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(onPressed: null, icon: Icon(Icons.notifications_none_rounded), tooltip: 'Bildirimler'),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              tooltip: 'Uzman olarak katıl',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountHubPage()),
              ),
              icon: const CircleAvatar(
                backgroundColor: Color(0xFFE8E3D8),
                child: Icon(Icons.person_outline_rounded, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _SearchBar(),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Ne arıyorsun?', action: 'Tümünü gör'),
          const SizedBox(height: 12),
          SizedBox(
            height: 104,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryCard(icon: Icons.content_cut_rounded, title: 'Saç', color: Color(0xFFE7DED2)),
                _CategoryCard(icon: Icons.face_retouching_natural, title: 'Makyaj', color: Color(0xFFDCE5E0)),
                _CategoryCard(icon: Icons.auto_awesome_rounded, title: 'Gelin', color: Color(0xFFE2E0EA)),
                _CategoryCard(icon: Icons.spa_rounded, title: 'Cilt', color: Color(0xFFE8E5D4)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF171717), borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kendine iyi\nbakmaya hazır mısın?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, height: 1.1)),
                      const SizedBox(height: 10),
                      const Text('Yakınındaki iyi uzmanları keşfet.', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BarberListPage()),
                          );
                        },
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                        child: const Text('Uzmanları keşfet'),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.content_cut_rounded, size: 72, color: Color(0xFFE4C98A)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _SectionTitle(title: 'Yakınındaki popüler uzmanlar'),
          const SizedBox(height: 12),
          const _BusinessPreviewList(),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kişisel bakım mağazaları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StoreDirectoryPage())), child: const Text('Tümünü gör')),
            ],
          ),
          const SizedBox(height: 12),
          const _StorePreviewList(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StoreDirectoryPage())),
            icon: const Icon(Icons.storefront_rounded),
            label: const Text('Mağazayı keşfet'),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Keşfet'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Randevularım'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Favoriler'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}

class ProfessionalOnboardingPage extends StatefulWidget {
  const ProfessionalOnboardingPage({super.key});

  @override
  State<ProfessionalOnboardingPage> createState() => _ProfessionalOnboardingPageState();
}

class _ProfessionalOnboardingPageState extends State<ProfessionalOnboardingPage> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Berber';
  bool _isSaving = false;

  final _categories = const [
    'Berber',
    'Kadın kuaförü',
    'Makeup artist',
    'Gelin hazırlık',
    'Cilt bakımı',
    'Nail artist',
    'Kaş & kirpik',
    'Lazer epilasyon',
    'Masaj & spa',
    'Güzellik merkezi',
    'Hamam & kese',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBusiness() async {
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();
    if (name.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşletme adı ve şehir alanlarını doldur.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw AuthException('Oturum bulunamadı.');

      await Supabase.instance.client.from('businesses').insert({
        'owner_id': user.id,
        'name': name,
        'category': _category,
        'city': city,
        'description': _descriptionController.text.trim(),
      }).select('id').single().then((business) async {
        await Supabase.instance.client.from('business_members').insert({
          'business_id': business['id'],
          'user_id': user.id,
          'role': 'owner',
        });
      });

      await Supabase.instance.client.from('profiles').update({'role': 'business_owner'}).eq('id', user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İşletmen başarıyla oluşturuldu.')));
      Navigator.of(context).pop();
    } on PostgrestException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uzman olarak katıl')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('İşletmeni ekle', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Müşteriler seni keşfetsin ve senden randevu alabilsin.'),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'İşletme adı', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
            items: _categories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'Şehir', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Kısa açıklama', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _isSaving ? null : _saveBusiness,
            child: Text(_isSaving ? 'Kaydediliyor...' : 'İşletmeyi oluştur'),
          ),
        ],
      ),
    );
  }
}

class _BusinessPreviewList extends StatelessWidget {
  const _BusinessPreviewList();

  Future<List<Map<String, dynamic>>> _loadBusinesses() async {
    final response = await Supabase.instance.client
        .from('businesses')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(5);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadBusinesses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const Text('Uzmanlar yüklenemedi.');
        }
        final businesses = snapshot.data ?? [];
        if (businesses.isEmpty) {
          return const Text('Henüz kayıtlı uzman bulunmuyor.');
        }
        return Column(
          children: [
            for (var index = 0; index < businesses.length; index++) ...[
              _BarberCard(
                businessId: businesses[index]['id'] as String,
                name: businesses[index]['name'] as String,
                location: businesses[index]['city'] as String? ?? 'Konum belirtilmedi',
                rating: 'Yeni',
                tag: businesses[index]['category'] as String? ?? 'Uzman',
              ),
              if (index < businesses.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class AccountHubPage extends StatefulWidget {
  const AccountHubPage({super.key});

  @override
  State<AccountHubPage> createState() => _AccountHubPageState();
}

class _AccountHubPageState extends State<AccountHubPage> {
  late Future<List<Map<String, dynamic>>> _businessesFuture;

  @override
  void initState() {
    super.initState();
    _businessesFuture = _loadBusinesses();
  }

  Future<List<Map<String, dynamic>>> _loadBusinesses() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final response = await Supabase.instance.client.from('businesses').select().eq('owner_id', user.id);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _openOnboarding() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfessionalOnboardingPage()));
    setState(() => _businessesFuture = _loadBusinesses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hesap merkezi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Nasıl devam etmek istiyorsun?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Tek hesapla müşteri olarak randevu alabilir, işletme panelinden işini yönetebilirsin.'),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.search_rounded)),
              title: const Text('Müşteri görünümü', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Uzmanları keşfet ve randevu al'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('İşletmelerim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _businessesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
              }
              final businesses = snapshot.data ?? [];
              if (businesses.isEmpty) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Henüz işletme eklemedin.'));
              }
              return Column(
                children: businesses.map((business) {
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.storefront_rounded)),
                      title: Text(business['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(business['category'] as String? ?? 'Güzellik işletmesi'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BusinessDashboardPage(
                            businessId: business['id'] as String,
                            businessName: business['name'] as String,
                            businessCategory: business['category'] as String? ?? 'Berber',
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openOnboarding,
            icon: const Icon(Icons.add_business_rounded),
            label: const Text('Yeni işletme ekle'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Çıkış yap'),
          ),
        ],
      ),
    );
  }
}

class BusinessDashboardPage extends StatefulWidget {
  const BusinessDashboardPage({super.key, required this.businessId, required this.businessName, required this.businessCategory});

  final String businessId;
  final String businessName;
  final String businessCategory;

  @override
  State<BusinessDashboardPage> createState() => _BusinessDashboardPageState();
}

class _BusinessDashboardPageState extends State<BusinessDashboardPage> {
  late Future<List<Map<String, dynamic>>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _loadServices();
  }

  Future<List<Map<String, dynamic>>> _loadServices() async {
    final response = await Supabase.instance.client
        .from('services')
        .select()
        .eq('business_id', widget.businessId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _addService() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ServiceCreatePage(businessId: widget.businessId, businessCategory: widget.businessCategory)),
    );
    setState(() => _servicesFuture = _loadServices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.businessName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('İşletme paneli', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Bugünkü operasyonunu tek ekrandan yönet.'),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: _DashboardMetric(label: 'Bugünkü randevu', value: '0', icon: Icons.calendar_today_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _ServiceMetric(future: _servicesFuture)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_rounded),
              title: const Text('Randevuları yönet'),
              subtitle: const Text('Gelen randevu taleplerini yönet'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BusinessAppointmentsPage(
                  businessId: widget.businessId,
                  businessName: widget.businessName,
                ),
              )),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.design_services_rounded),
              title: const Text('Hizmetlerini yönet'),
              subtitle: const Text('Hizmet, süre ve fiyat ekle'),
              onTap: _addService,
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.groups_rounded),
              title: const Text('Çalışanları yönet'),
              subtitle: const Text('Ekip üyeleri ve uzmanlıkları'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => StaffManagementPage(
                  businessId: widget.businessId,
                  businessName: widget.businessName,
                ),
              )),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.shopping_bag_rounded),
              title: const Text('Ürünlerimi yönet'),
              subtitle: const Text('Kişisel bakım ürünleri ve stok'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductManagementPage(businessId: widget.businessId))),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storefront_rounded),
              title: const Text('Mağazamı yönet'),
              subtitle: const Text('İşletme adına ürün mağazası oluştur'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoreManagementPage(businessId: widget.businessId))),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hizmetlerin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              TextButton.icon(onPressed: _addService, icon: const Icon(Icons.add), label: const Text('Ekle')),
            ],
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _servicesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final services = snapshot.data ?? [];
              if (services.isEmpty) return const Text('Henüz hizmet eklemedin.');
              return Column(
                children: services.map((service) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.spa_rounded),
                      title: Text(service['name'] as String),
                      subtitle: Text('${service['duration_minutes']} dk · ${service['price']} TL'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceMetric extends StatelessWidget {
  const _ServiceMetric({required this.future});

  final Future<List<Map<String, dynamic>>>? future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) => _DashboardMetric(
        label: 'Hizmetler',
        value: snapshot.hasData ? '${snapshot.data!.length}' : '-',
        icon: Icons.content_cut_rounded,
      ),
    );
  }
}

class ServiceCreatePage extends StatefulWidget {
  const ServiceCreatePage({super.key, required this.businessId, required this.businessCategory});

  final String businessId;
  final String businessCategory;

  @override
  State<ServiceCreatePage> createState() => _ServiceCreatePageState();
}

class _ServiceCreatePageState extends State<ServiceCreatePage> {
  final _customNameController = TextEditingController();
  final _durationController = TextEditingController(text: '60');
  final _priceController = TextEditingController();
  bool _isSaving = false;
  String? _selectedService;

  @override
  void dispose() {
    _customNameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _selectedService == 'Diğer / özel hizmet'
        ? _customNameController.text.trim()
        : _selectedService;
    final duration = int.tryParse(_durationController.text.trim());
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.'));
    if (name == null || duration == null || duration <= 0 || price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hizmet bilgilerini kontrol et.')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.from('services').insert({
        'business_id': widget.businessId,
        'name': name,
        'duration_minutes': duration,
        'price': price,
      });
      if (mounted) Navigator.of(context).pop();
    } on PostgrestException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hizmet ekle')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Kategori: ${widget.businessCategory}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _selectedService,
            decoration: const InputDecoration(labelText: 'Hizmet seç', border: OutlineInputBorder()),
            items: (serviceCatalog[widget.businessCategory] ?? const <String>[])
                .followedBy(const ['Diğer / özel hizmet'])
                .map((service) => DropdownMenuItem(value: service, child: Text(service)))
                .toList(),
            onChanged: (value) => setState(() => _selectedService = value),
          ),
          if (_selectedService == 'Diğer / özel hizmet') ...[
            const SizedBox(height: 14),
            TextField(
              controller: _customNameController,
              decoration: const InputDecoration(labelText: 'Özel hizmet adı', border: OutlineInputBorder()),
            ),
          ],
          const SizedBox(height: 14),
          TextField(controller: _durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Süre (dakika)', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          TextField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Fiyat (TL)', border: OutlineInputBorder())),
          const SizedBox(height: 22),
          FilledButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? 'Kaydediliyor...' : 'Hizmeti kaydet')),
        ],
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ]),
      ),
    );
  }
}

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key, required this.businessId, required this.businessName});

  final String businessId;
  final String businessName;

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  final _emailController = TextEditingController();
  bool _isSaving = false;
  late Future<List<Map<String, dynamic>>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _loadMembers();
  }

  Future<List<Map<String, dynamic>>> _loadMembers() async {
    final response = await Supabase.instance.client
        .from('business_members')
        .select('user_id, role, profiles(full_name, email)')
        .eq('business_id', widget.businessId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _addStaff() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.rpc('add_staff_member', params: {
        'p_business_id': widget.businessId,
        'p_email': email,
        'p_role': 'staff',
      });
      _emailController.clear();
      setState(() => _membersFuture = _loadMembers());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Çalışan eklendi.')));
    } on PostgrestException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Çalışanları yönet')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Ekibin', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Uygulamaya kayıtlı çalışanları e-posta adresleriyle işletmene ekle.'),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Çalışanın e-posta adresi', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _isSaving ? null : _addStaff,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(_isSaving ? 'Ekleniyor...' : 'Çalışan ekle'),
          ),
          const SizedBox(height: 28),
          const Text('Mevcut ekip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _membersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final members = snapshot.data ?? [];
              if (members.isEmpty) return const Text('Henüz çalışan eklenmedi.');
              return Column(children: members.map((member) {
                final profile = member['profiles'] as Map<String, dynamic>? ?? {};
          return Card(child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                  title: Text(profile['full_name'] as String? ?? profile['email'] as String? ?? 'Çalışan'),
                  subtitle: Text(member['role'] as String? ?? 'staff'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => StaffDetailPage(
                      businessId: widget.businessId,
                      staffUserId: member['user_id'] as String,
                      staffName: profile['full_name'] as String? ?? profile['email'] as String? ?? 'Çalışan',
                    ),
                  )),
                ));
              }).toList());
            },
          ),
        ],
      ),
    );
  }
}

class StaffDetailPage extends StatefulWidget {
  const StaffDetailPage({super.key, required this.businessId, required this.staffUserId, required this.staffName});

  final String businessId;
  final String staffUserId;
  final String staffName;

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  late Future<List<Map<String, dynamic>>> _servicesFuture;
  final Set<String> _selectedServices = {};
  final _startController = TextEditingController(text: '09:00');
  final _endController = TextEditingController(text: '18:00');
  int _weekday = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _loadServices();
    _loadAssignedServices();
  }

  Future<List<Map<String, dynamic>>> _loadServices() async {
    final response = await Supabase.instance.client.from('services').select('id, name').eq('business_id', widget.businessId).eq('is_active', true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _loadAssignedServices() async {
    final response = await Supabase.instance.client
        .from('staff_services')
        .select('service_id')
        .eq('business_id', widget.businessId)
        .eq('staff_user_id', widget.staffUserId);
    if (!mounted) return;
    setState(() {
      _selectedServices.addAll(
        List<Map<String, dynamic>>.from(response).map((item) => item['service_id'] as String),
      );
    });
  }

  Future<void> _saveServices() async {
    setState(() => _saving = true);
    try {
      await Supabase.instance.client
          .from('staff_services')
          .delete()
          .eq('business_id', widget.businessId)
          .eq('staff_user_id', widget.staffUserId);
      if (_selectedServices.isNotEmpty) {
        await Supabase.instance.client.from('staff_services').upsert(_selectedServices.map((id) => {
          'business_id': widget.businessId,
          'staff_user_id': widget.staffUserId,
          'service_id': id,
        }).toList());
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hizmet yetkileri kaydedildi.')));
    } on PostgrestException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveWorkingHours() async {
    final start = _startController.text.trim();
    final end = _endController.text.trim();
    if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(start) || !RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(end)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saatleri SS:DD biçiminde gir.')));
      return;
    }
    try {
      await Supabase.instance.client.from('staff_working_hours').upsert({
        'business_id': widget.businessId,
        'staff_user_id': widget.staffUserId,
        'weekday': _weekday,
        'starts_at': start,
        'ends_at': end,
        'is_active': true,
      }, onConflict: 'business_id,staff_user_id,weekday');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Çalışma saati kaydedildi.')));
    } on PostgrestException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return Scaffold(
      appBar: AppBar(title: Text(widget.staffName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Verebildiği hizmetler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _servicesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              return Column(children: (snapshot.data ?? []).map((service) {
                final id = service['id'] as String;
                return CheckboxListTile(
                  value: _selectedServices.contains(id),
                  title: Text(service['name'] as String),
                  onChanged: (value) => setState(() => value == true ? _selectedServices.add(id) : _selectedServices.remove(id)),
                );
              }).toList());
            },
          ),
          FilledButton(onPressed: _saving ? null : _saveServices, child: const Text('Hizmet yetkilerini kaydet')),
          const SizedBox(height: 28),
          const Text('Çalışma saati ekle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _weekday,
            decoration: const InputDecoration(labelText: 'Gün', border: OutlineInputBorder()),
            items: List.generate(7, (index) => DropdownMenuItem(value: index + 1, child: Text(weekdays[index]))),
            onChanged: (value) => setState(() => _weekday = value!),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _startController, decoration: const InputDecoration(labelText: 'Başlangıç', hintText: '09:00', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _endController, decoration: const InputDecoration(labelText: 'Bitiş', hintText: '18:00', border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _saveWorkingHours, child: const Text('Çalışma saatini kaydet')),
        ],
      ),
    );
  }
}

class BusinessAppointmentsPage extends StatefulWidget {
  const BusinessAppointmentsPage({super.key, required this.businessId, required this.businessName});

  final String businessId;
  final String businessName;

  @override
  State<BusinessAppointmentsPage> createState() => _BusinessAppointmentsPageState();
}

class StoreManagementPage extends StatefulWidget {
  const StoreManagementPage({super.key, required this.businessId});

  final String businessId;

  @override
  State<StoreManagementPage> createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends State<StoreManagementPage> {
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;

  Future<void> _createStore() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _nameController.text.trim().isEmpty || _slugController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('seller_stores').insert({
        'owner_id': user.id,
        'name': _nameController.text.trim(),
        'slug': _slugController.text.trim().toLowerCase().replaceAll(' ', '-'),
        'description': _descriptionController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mağaza oluşturuldu.')));
        Navigator.of(context).pop();
      }
    } on PostgrestException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mağazamı yönet')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('İşletme mağazanı oluştur', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Mağaza adı', hintText: 'Luna Beauty Store', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _slugController, decoration: const InputDecoration(labelText: 'Mağaza kısa adı', hintText: 'luna-beauty-store', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Mağaza açıklaması', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        FilledButton(onPressed: _saving ? null : _createStore, child: Text(_saving ? 'Oluşturuluyor...' : 'Mağazayı oluştur')),
      ]),
    );
  }
}

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key, required this.businessId});

  final String businessId;

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  late Future<List<Map<String, dynamic>>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<List<Map<String, dynamic>>> _loadProducts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final response = await Supabase.instance.client.from('products').select().eq('seller_id', user.id).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductCreatePage(businessId: widget.businessId)));
    setState(() => _productsFuture = _loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürünlerimi yönet')),
      floatingActionButton: FloatingActionButton.extended(onPressed: _openCreate, icon: const Icon(Icons.add), label: const Text('Ürün ekle')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data ?? [];
          if (products.isEmpty) return const Center(child: Text('Henüz ürün eklemedin.'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(child: ListTile(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
                leading: const CircleAvatar(child: Icon(Icons.shopping_bag_rounded)),
                title: Text(product['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${product['category']} · Stok: ${product['stock']}'),
                trailing: Text('${product['price']} TL', style: const TextStyle(fontWeight: FontWeight.w800)),
              ));
            },
          );
        },
      ),
    );
  }
}

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key, required this.businessId});

  final String businessId;

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();
  String _category = 'Cilt bakımı';
  bool _saving = false;

  final _categories = const ['Cilt bakımı', 'Saç bakımı', 'Makyaj', 'Parfüm', 'Vücut bakımı', 'Manikür & pedikür', 'Spa & wellness'];

  Future<void> _save() async {
    final user = Supabase.instance.client.auth.currentUser;
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.'));
    final stock = int.tryParse(_stockController.text.trim());
    if (user == null || name.isEmpty || price == null || stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ürün bilgilerini kontrol et.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('products').insert({
        'seller_id': user.id,
        'business_id': widget.businessId,
        'name': name,
        'brand': _brandController.text.trim(),
        'category': _category,
        'price': price,
        'stock': stock,
        'description': _descriptionController.text.trim(),
      });
      if (mounted) Navigator.of(context).pop();
    } on PostgrestException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün ekle')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Ürün adı', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Marka', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _category, decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()), items: _categories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setState(() => _category = value!)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Fiyat (TL)', border: OutlineInputBorder()))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _stockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Kaydediliyor...' : 'Ürünü kaydet')),
      ]),
    );
  }
}

class _BusinessAppointmentsPageState extends State<BusinessAppointmentsPage> {
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _loadAppointments();
  }

  Future<List<Map<String, dynamic>>> _loadAppointments() async {
    final response = await Supabase.instance.client
        .from('appointments')
        .select('id, starts_at, status, notes, services!inner(name, business_id)')
        .eq('services.business_id', widget.businessId)
        .order('starts_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _setStatus(String id, String status) async {
    await Supabase.instance.client.from('appointments').update({'status': status}).eq('id', id);
    setState(() => _appointmentsFuture = _loadAppointments());
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed': return 'Onaylandı';
      case 'completed': return 'Tamamlandı';
      case 'cancelled': return 'İptal edildi';
      default: return 'Bekliyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Randevular')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Randevular yüklenemedi.'));
          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) return const Center(child: Text('Henüz randevu talebi yok.'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final service = appointment['services'] as Map<String, dynamic>? ?? {};
              final status = appointment['status'] as String? ?? 'pending';
              final date = DateTime.tryParse(appointment['starts_at'] as String? ?? '')?.toLocal();
              final dateText = date == null ? 'Tarih belirtilmedi' : '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(service['name'] as String? ?? 'Hizmet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(dateText),
                    const SizedBox(height: 6),
                    Text(_statusLabel(status), style: const TextStyle(color: Colors.black54)),
                    if (status == 'pending') ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: FilledButton(onPressed: () => _setStatus(appointment['id'] as String, 'confirmed'), child: const Text('Onayla'))),
                        const SizedBox(width: 8),
                        Expanded(child: OutlinedButton(onPressed: () => _setStatus(appointment['id'] as String, 'cancelled'), child: const Text('Reddet'))),
                      ]),
                    ],
                    if (status == 'confirmed') ...[
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: () => _setStatus(appointment['id'] as String, 'completed'), child: const Text('Tamamlandı olarak işaretle')),
                    ],
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StorePreviewList extends StatelessWidget {
  const _StorePreviewList();

  Future<List<Map<String, dynamic>>> _loadStores() async {
    final response = await Supabase.instance.client.from('seller_stores').select().eq('is_active', true).order('created_at', ascending: false).limit(4);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadStores(),
      builder: (context, snapshot) {
        final stores = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
        if (stores.isEmpty) return const Text('Henüz mağaza eklenmedi.');
        return Column(children: stores.map((store) => Card(child: ListTile(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoreDetailPage(store: store))),
          leading: const CircleAvatar(child: Icon(Icons.storefront_rounded)),
          title: Text(store['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(store['is_verified'] == true ? 'Doğrulanmış mağaza' : 'Kişisel bakım mağazası'),
          trailing: const Icon(Icons.chevron_right_rounded),
        ))).toList());
      },
    );
  }
}

class StoreDirectoryPage extends StatelessWidget {
  const StoreDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kişisel bakım mağazaları')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client.from('seller_stores').select().eq('is_active', true).order('created_at', ascending: false).then((value) => List<Map<String, dynamic>>.from(value)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final stores = snapshot.data ?? [];
          if (stores.isEmpty) return const Center(child: Text('Henüz mağaza bulunmuyor.'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: stores.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => Card(child: ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoreDetailPage(store: stores[index]))),
              leading: const CircleAvatar(radius: 28, child: Icon(Icons.storefront_rounded)),
              title: Text(stores[index]['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(stores[index]['description'] as String? ?? 'Kişisel bakım ürünleri mağazası'),
              trailing: const Icon(Icons.chevron_right_rounded),
            )),
          );
        },
      ),
    );
  }
}

class StoreDetailPage extends StatelessWidget {
  const StoreDetailPage({super.key, required this.store});

  final Map<String, dynamic> store;

  @override
  Widget build(BuildContext context) {
    final storeId = store['id'] as String;
    return Scaffold(
      appBar: AppBar(title: Text(store['name'] as String)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage())),
        icon: const Icon(Icons.shopping_cart_rounded),
        label: Text('Sepetim (${cartItems.length})'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client.from('products').select().eq('store_id', storeId).eq('is_active', true).gt('stock', 0).order('created_at', ascending: false).then((value) => List<Map<String, dynamic>>.from(value)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data ?? [];
          return ListView(padding: const EdgeInsets.all(20), children: [
            Text(store['name'] as String, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(store['description'] as String? ?? 'Kişisel bakım ürünleri mağazası'),
            const SizedBox(height: 20),
            if (products.isEmpty) const Text('Bu mağazada henüz ürün bulunmuyor.'),
            ...products.map((product) => Card(child: ListTile(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
              leading: const CircleAvatar(child: Icon(Icons.shopping_bag_rounded)),
              title: Text(product['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${product['brand'] ?? product['category']} · Stok: ${product['stock']}'),
              trailing: Text('${product['price']} TL', style: const TextStyle(fontWeight: FontWeight.w800)),
            )))
          ]);
        },
      ),
    );
  }
}

class ProductMarketplacePage extends StatelessWidget {
  const ProductMarketplacePage({super.key});

  Future<List<Map<String, dynamic>>> _loadProducts() async {
    final response = await Supabase.instance.client.from('products').select().eq('is_active', true).gt('stock', 0).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürünleri keşfet')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage())),
        icon: const Icon(Icons.shopping_cart_rounded),
        label: Text('Sepetim (${cartItems.length})'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data ?? [];
          if (products.isEmpty) return const Center(child: Text('Henüz ürün bulunmuyor.'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(child: ListTile(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
                leading: const CircleAvatar(radius: 28, child: Icon(Icons.shopping_bag_rounded)),
                title: Text(product['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${product['brand'] ?? product['category']} · Stok: ${product['stock']}'),
                trailing: IconButton(
                  tooltip: 'Sepete ekle',
                  onPressed: () {
                    final existing = cartItems.indexWhere((item) => item['id'] == product['id']);
                    if (existing >= 0) {
                      cartItems[existing]['quantity'] = (cartItems[existing]['quantity'] as int) + 1;
                    } else {
                      cartItems.add({...product, 'quantity': 1});
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ürün sepete eklendi.')));
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                ),
              ));
            },
          );
        },
      ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Map<String, dynamic> product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  void _addToCart() {
    final product = widget.product;
    final existingIndex = cartItems.indexWhere((item) => item['id'] == product['id']);
    if (existingIndex >= 0) {
      cartItems[existingIndex]['quantity'] = (cartItems[existingIndex]['quantity'] as int) + _quantity;
    } else {
      cartItems.add({...product, 'quantity': _quantity});
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ürün sepete eklendi.')));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün detayı'),
        actions: [IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage())), icon: const Icon(Icons.shopping_cart_outlined))],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(height: 220, decoration: BoxDecoration(color: const Color(0xFFE8E3D8), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.shopping_bag_rounded, size: 80)),
        const SizedBox(height: 20),
        Text(product['name'] as String, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('${product['brand'] ?? product['category']}', style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
        Text('${product['price']} TL', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Text(product['description'] as String? ?? 'Kişisel bakım rutinin için özenle seçilmiş ürün.'),
        const SizedBox(height: 24),
        Row(children: [
          IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove_circle_outline)),
          Text('$_quantity', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          IconButton(onPressed: _quantity < (product['stock'] as int? ?? 1) ? () => setState(() => _quantity++) : null, icon: const Icon(Icons.add_circle_outline)),
        ]),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _addToCart, icon: const Icon(Icons.add_shopping_cart_rounded), label: const Text('Sepete ekle')),
      ]),
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _saving = false;

  double get _total => cartItems.fold<double>(0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)));

  Future<void> _createOrder() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sipariş vermek için önce giriş yapmalısın.')));
      return;
    }
    if (cartItems.isEmpty) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.rpc('create_product_order', params: {
        'p_items': cartItems.map((item) => {
          'product_id': item['id'],
          'quantity': item['quantity'],
        }).toList(),
      });
      cartItems.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sipariş oluşturuldu.')));
        Navigator.of(context).pop();
      }
    } on PostgrestException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Sepetin henüz boş.'))
          : ListView(padding: const EdgeInsets.all(20), children: [
              ...cartItems.map((item) => Card(child: ListTile(
                title: Text(item['name'] as String),
                subtitle: Text('${item['quantity']} adet'),
                trailing: Text('${((item['price'] as num).toDouble() * (item['quantity'] as int)).toStringAsFixed(2)} TL'),
              ))),
              const SizedBox(height: 20),
              Text('Toplam: ${_total.toStringAsFixed(2)} TL', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              FilledButton(onPressed: _saving ? null : _createOrder, child: Text(_saving ? 'Oluşturuluyor...' : 'Siparişi oluştur')),
            ]),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Uzman, hizmet veya bölge ara',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        if (action != null) TextButton(onPressed: () {}, child: Text(action!)),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.icon, required this.title, required this.color});

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BarberCard extends StatelessWidget {
  const _BarberCard({this.businessId, required this.name, required this.location, required this.rating, required this.tag});

  final String? businessId;
  final String name;
  final String location;
  final String rating;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BarberProfilePage(businessId: businessId, name: name, location: location, rating: rating),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(color: const Color(0xFFE8E3D8), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.storefront_rounded, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(location, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFE2A93B)),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Text(tag, style: const TextStyle(color: Color(0xFF39705A))),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class BarberListPage extends StatelessWidget {
  const BarberListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uzmanları keşfet')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Sana uygun uzmanı bul', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Konumuna ve ihtiyacına göre uzmanları keşfet.'),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Uzman veya bölge ara',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          _BarberCard(name: 'The Gentlemen Studio', location: 'Kadıköy · 1.2 km', rating: '4.9', tag: 'Bugün müsait'),
          const SizedBox(height: 12),
          _BarberCard(name: 'North Barber Club', location: 'Beşiktaş · 2.8 km', rating: '4.8', tag: 'Yeni'),
          const SizedBox(height: 12),
          _BarberCard(name: 'Makas Atelier', location: 'Moda · 3.4 km', rating: '4.7', tag: 'Popüler'),
        ],
      ),
    );
  }
}

class BarberProfilePage extends StatelessWidget {
  const BarberProfilePage({super.key, this.businessId, required this.name, required this.location, required this.rating});

  final String? businessId;
  final String name;
  final String location;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berber profili')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(color: const Color(0xFFE8E3D8), borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.storefront_rounded, size: 72),
          ),
          const SizedBox(height: 20),
          Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(location, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFE2A93B)),
              const SizedBox(width: 4),
              Text('$rating · 128 yorum', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          if (businessId != null) ...[
            const SizedBox(height: 8),
            _ReviewSummary(businessId: businessId!),
          ],
          const SizedBox(height: 28),
          const Text('Hizmetler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (businessId == null) ...[
            _ServiceTile(title: 'Saç kesimi', duration: '45 dk', price: '450 TL'),
            _ServiceTile(title: 'Saç + sakal', duration: '60 dk', price: '650 TL'),
            _ServiceTile(title: 'Sakal şekillendirme', duration: '25 dk', price: '250 TL'),
          ] else
            FutureBuilder<List<Map<String, dynamic>>>(
              future: Supabase.instance.client.from('services').select().eq('business_id', businessId!).eq('is_active', true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator());
                }
                final services = List<Map<String, dynamic>>.from(snapshot.data ?? []);
                if (services.isEmpty) return const Text('Bu işletme henüz hizmet eklememiş.');
                return Column(
                  children: services.map((service) => _ServiceTile(
                    title: service['name'] as String,
                    duration: '${service['duration_minutes']} dk',
                    price: '${service['price']} TL',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AppointmentPage(
                        barberName: name,
                        businessId: businessId,
                        serviceId: service['id'] as String,
                        serviceName: service['name'] as String,
                        serviceDuration: service['duration_minutes'] as int,
                        servicePrice: '${service['price']} TL',
                      ),
                    )),
                  )).toList(),
                );
              },
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () async {
              if (businessId == null) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AppointmentPage(barberName: name)));
                return;
              }
              final services = await Supabase.instance.client
                  .from('services')
                  .select()
                  .eq('business_id', businessId!)
                  .eq('is_active', true)
                  .limit(1);
              if (!context.mounted) return;
              if (services.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bu işletme henüz hizmet eklememiş.')),
                );
                return;
              }
              final service = services.first;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AppointmentPage(
                  barberName: name,
                  serviceId: service['id'] as String,
                  serviceName: service['name'] as String,
                  serviceDuration: service['duration_minutes'] as int,
                  servicePrice: '${service['price']} TL',
                ),
              ));
            },
            icon: const Icon(Icons.calendar_month_rounded),
            label: const Text('Randevu al'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.title, required this.duration, required this.price, this.onTap});

  final String title;
  final String duration;
  final String price;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(duration),
      trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.businessId});

  final String businessId;

  Future<List<Map<String, dynamic>>> _loadReviews() async {
    final response = await Supabase.instance.client
        .from('reviews')
        .select('business_rating')
        .eq('business_id', businessId)
        .eq('is_visible', true);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadReviews(),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) return const Text('Henüz değerlendirme yok', style: TextStyle(color: Colors.black54));
        final total = reviews.fold<double>(0, (sum, review) => sum + ((review['business_rating'] as num?)?.toDouble() ?? 0));
        final average = total / reviews.length;
        return Row(children: [
          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF39705A)),
          const SizedBox(width: 5),
          Text('${average.toStringAsFixed(1)} · ${reviews.length} değerlendirme', style: const TextStyle(color: Color(0xFF39705A), fontWeight: FontWeight.w700)),
        ]);
      },
    );
  }
}

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({
    super.key,
    required this.barberName,
    this.businessId,
    this.serviceId,
    this.serviceName = 'Saç + sakal',
    this.serviceDuration = 60,
    this.servicePrice = '650 TL',
  });

  final String barberName;
  final String? businessId;
  final String? serviceId;
  final String serviceName;
  final int serviceDuration;
  final String servicePrice;

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  int selectedDay = 0;
  String? selectedTime;
  String? selectedStaffId;
  late Future<List<Map<String, dynamic>>> _staffFuture;

  final days = const [
    ('Bugün', '22 Eki'),
    ('Yarın', '23 Eki'),
    ('Cuma', '24 Eki'),
    ('Cumartesi', '25 Eki'),
  ];

  final times = const ['10:00', '10:30', '11:30', '13:00', '14:30', '16:00', '17:30'];

  @override
  void initState() {
    super.initState();
    _staffFuture = _loadStaff();
  }

  Future<List<Map<String, dynamic>>> _loadStaff() async {
    if (widget.serviceId == null || widget.businessId == null) return [];
    final response = await Supabase.instance.client
        .from('staff_services')
        .select('staff_user_id, profiles(full_name, email)')
        .eq('business_id', widget.businessId!)
        .eq('service_id', widget.serviceId!);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<String>> _loadAvailableTimes() async {
    if (widget.serviceId == null || widget.businessId == null || selectedStaffId == null) return times;
    final response = await Supabase.instance.client
        .from('appointments')
        .select('starts_at, ends_at')
        .eq('business_id', widget.businessId!)
        .eq('staff_user_id', selectedStaffId!)
        .inFilter('status', ['pending', 'confirmed']);
    final booked = List<Map<String, dynamic>>.from(response);
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day + selectedDay);
    return times.where((time) {
      final parts = time.split(':');
      final candidateStart = DateTime(day.year, day.month, day.day, int.parse(parts[0]), int.parse(parts[1]));
      final candidateEnd = candidateStart.add(Duration(minutes: widget.serviceDuration));
      return !booked.any((appointment) {
        final start = DateTime.tryParse(appointment['starts_at'] as String? ?? '')?.toLocal();
        final end = DateTime.tryParse(appointment['ends_at'] as String? ?? '')?.toLocal();
        if (start == null || end == null) return false;
        return candidateStart.isBefore(end) && candidateEnd.isAfter(start);
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Randevu al')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.barberName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Hizmet ve uygun zamanı seçerek randevunu oluştur.'),
          const SizedBox(height: 28),
          const Text('Hizmet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Icon(Icons.content_cut_rounded),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.serviceName, style: const TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('${widget.serviceDuration} dk · ${widget.servicePrice}', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_rounded, color: Color(0xFF39705A)),
              ],
            ),
          ),
          if (widget.serviceId != null) ...[
            const SizedBox(height: 24),
            const Text('Uzman seç', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _staffFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                final staff = snapshot.data ?? [];
                if (staff.isEmpty) return const Text('Bu hizmet için henüz çalışan atanmadı.');
                return DropdownButtonFormField<String>(
                  value: selectedStaffId,
                  decoration: const InputDecoration(labelText: 'Hizmeti verecek uzman', border: OutlineInputBorder()),
                  items: staff.map((member) {
                    final profile = member['profiles'] as Map<String, dynamic>? ?? {};
                    final name = profile['full_name'] as String? ?? profile['email'] as String? ?? 'Uzman';
                    return DropdownMenuItem(value: member['staff_user_id'] as String, child: Text(name));
                  }).toList(),
                  onChanged: (value) => setState(() {
                    selectedStaffId = value;
                    selectedTime = null;
                  }),
                );
              },
            ),
          ],
          const SizedBox(height: 28),
          const Text('Gün seç', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final selected = selectedDay == index;
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedDay = index;
                    selectedTime = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 82,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF171717) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(day.$1, style: TextStyle(color: selected ? Colors.white70 : Colors.black54, fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(day.$2, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          const Text('Saat seç', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          FutureBuilder<List<String>>(
            future: _loadAvailableTimes(),
            builder: (context, snapshot) {
              if (widget.serviceId != null && selectedStaffId == null) {
                return const Text('Önce hizmet verecek uzmanı seç.');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              final availableTimes = snapshot.data ?? [];
              if (availableTimes.isEmpty) return const Text('Bu gün için müsait saat yok.');
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: availableTimes.map((time) {
                  final selected = selectedTime == time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: selected,
                    onSelected: (_) => setState(() => selectedTime = time),
                    selectedColor: const Color(0xFF171717),
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.w700),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: selectedTime == null
                ? null
                : () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Randevu almak için önce giriş yapmalısın.')),
                      );
                      return;
                    }
                    if (widget.serviceId != null) {
                      if (selectedStaffId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen hizmet verecek uzmanı seç.')));
                        return;
                      }
                      final timeParts = selectedTime!.split(':');
                      final now = DateTime.now();
                      final startsAt = DateTime(
                        now.year,
                        now.month,
                        now.day + selectedDay,
                        int.parse(timeParts[0]),
                        int.parse(timeParts[1]),
                      ).toUtc();
                      try {
                        await Supabase.instance.client.from('appointments').insert({
                          'customer_id': user.id,
                          'service_id': widget.serviceId,
                          'business_id': widget.businessId,
                          'staff_user_id': selectedStaffId,
                          'starts_at': startsAt.toIso8601String(),
                          'ends_at': startsAt.add(Duration(minutes: widget.serviceDuration)).toIso8601String(),
                        });
                      } on PostgrestException catch (error) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
                        }
                        return;
                      }
                    }
                    activeAppointment = Appointment(
                      barberName: widget.barberName,
                      day: days[selectedDay].$2,
                      time: selectedTime!,
                      service: widget.serviceName,
                      price: widget.servicePrice,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.barberName} için randevu talebin hazırlandı.')),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AppointmentsPage()),
                    );
                  },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
            child: const Text('Randevuyu onayla'),
          ),
        ],
      ),
    );
  }
}

class Appointment {
  const Appointment({required this.barberName, required this.day, required this.time, required this.service, required this.price});

  final String barberName;
  final String day;
  final String time;
  final String service;
  final String price;
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _loadAppointments();
  }

  Future<List<Map<String, dynamic>>> _loadAppointments() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final response = await Supabase.instance.client
        .from('appointments')
        .select('id, starts_at, status, business_id, staff_user_id, service_id, services(name, businesses(name)), reviews(id)')
        .eq('customer_id', user.id)
        .order('starts_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed': return 'Onaylandı';
      case 'completed': return 'Tamamlandı';
      case 'cancelled': return 'İptal edildi';
      default: return 'Bekliyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localAppointment = activeAppointment;

    return Scaffold(
      appBar: AppBar(title: const Text('Randevularım')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty && localAppointment == null) return const Center(child: Text('Henüz bir randevun yok.'));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Randevularım', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Randevularını ve değerlendirmelerini buradan takip edebilirsin.'),
              const SizedBox(height: 20),
              if (localAppointment != null && appointments.isEmpty)
                Card(child: ListTile(
                  leading: const Icon(Icons.calendar_month_rounded),
                  title: Text(localAppointment.barberName),
                  subtitle: Text('${localAppointment.day} · ${localAppointment.time}'),
                )),
              ...appointments.map((appointment) {
                final service = appointment['services'] as Map<String, dynamic>? ?? {};
                final business = service['businesses'] as Map<String, dynamic>? ?? {};
                final status = appointment['status'] as String? ?? 'pending';
                final date = DateTime.tryParse(appointment['starts_at'] as String? ?? '')?.toLocal();
                final dateText = date == null ? 'Tarih belirtilmedi' : '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                final reviews = appointment['reviews'] as List<dynamic>? ?? [];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(business['name'] as String? ?? 'İşletme', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(service['name'] as String? ?? 'Hizmet'),
                      Text(dateText, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Text(_statusLabel(status), style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (status == 'completed' && reviews.isEmpty) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReviewPage(
                              appointmentId: appointment['id'] as String,
                              businessId: appointment['business_id'] as String,
                              serviceId: appointment['service_id'] as String,
                              staffUserId: appointment['staff_user_id'] as String?,
                              businessName: business['name'] as String? ?? 'İşletme',
                            )));
                            setState(() => _appointmentsFuture = _loadAppointments());
                          },
                          icon: const Icon(Icons.star_rounded),
                          label: const Text('Değerlendir'),
                        ),
                      ],
                      if (reviews.isNotEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Değerlendirildi ✓')),
                    ]),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key, required this.appointmentId, required this.businessId, required this.serviceId, required this.staffUserId, required this.businessName});

  final String appointmentId;
  final String businessId;
  final String serviceId;
  final String? staffUserId;
  final String businessName;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _businessRating = 0;
  int _staffRating = 0;
  final _textController = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _businessRating == 0) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('reviews').insert({
        'appointment_id': widget.appointmentId,
        'customer_id': user.id,
        'business_id': widget.businessId,
        'staff_user_id': widget.staffUserId,
        'service_id': widget.serviceId,
        'business_rating': _businessRating,
        'staff_rating': widget.staffUserId == null ? null : (_staffRating == 0 ? _businessRating : _staffRating),
        'review_text': _textController.text.trim(),
      });
      if (mounted) Navigator.of(context).pop();
    } on PostgrestException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _ratingRow(String label, int value, ValueChanged<int> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      Row(children: List.generate(5, (index) => IconButton(
        onPressed: () => onChanged(index + 1),
        icon: Icon(index < value ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFE2A93B), size: 32),
      ))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Değerlendir')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(widget.businessName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        _ratingRow('İşletme puanı', _businessRating, (value) => setState(() => _businessRating = value)),
        if (widget.staffUserId != null) _ratingRow('Uzman puanı', _staffRating, (value) => setState(() => _staffRating = value)),
        const SizedBox(height: 12),
        TextField(controller: _textController, maxLines: 4, decoration: const InputDecoration(labelText: 'Yorumun', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        FilledButton(onPressed: _saving || _businessRating == 0 ? null : _save, child: Text(_saving ? 'Kaydediliyor...' : 'Değerlendirmeyi gönder')),
      ]),
    );
  }
}
