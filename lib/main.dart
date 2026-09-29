import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const base = 'https://snowpanel.ir';
const cMidnight = Color(0xFF060B1A);
const cDeep = Color(0xFF0D1630);
const cIce = Color(0xFF7DE3FF);
const cViolet = Color(0xFF8B7BFF);
const cFrost = Color(0xFFEAF6FF);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: cMidnight,
  ));
  runApp(const SnowApp());
}

class SnowApp extends StatelessWidget {
  const SnowApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'اسنو پنل',
        debugShowCheckedModeBanner: false,
        locale: const Locale('fa'),
        builder: (c, w) => Directionality(textDirection: TextDirection.rtl, child: w!),
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Vazirmatn',
          scaffoldBackgroundColor: cMidnight,
          colorScheme: const ColorScheme.dark(primary: cIce, secondary: cViolet),
        ),
        home: const Splash(),
      );
}

// ---------- Snow particles ----------
class SnowLayer extends StatefulWidget {
  const SnowLayer({super.key});
  @override
  State<SnowLayer> createState() => _SnowLayerState();
}

class _SnowLayerState extends State<SnowLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  final _r = Random(7);
  late final flakes = List.generate(60, (_) => [_r.nextDouble(), _r.nextDouble(), _r.nextDouble() * 2.2 + 0.6, _r.nextDouble() * .6 + .2]);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(size: Size.infinite, painter: _SnowPainter(flakes, _c.value)),
        ),
      );
}

class _SnowPainter extends CustomPainter {
  final List<List<double>> f;
  final double t;
  _SnowPainter(this.f, this.t);
  @override
  void paint(Canvas canvas, Size s) {
    for (final p in f) {
      final y = ((p[1] + t * p[3]) % 1.0) * s.height;
      final x = (p[0] * s.width + sin((t * 6.28 * 2) + p[0] * 9) * 14) % s.width;
      canvas.drawCircle(Offset(x, y), p[2], Paint()..color = cFrost.withOpacity(.25 + p[3] * .5));
    }
  }

  @override
  bool shouldRepaint(_SnowPainter o) => true;
}

// ---------- Glass ----------
class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsets pad;
  final double r;
  final VoidCallback? onTap;
  const Glass({super.key, required this.child, this.pad = const EdgeInsets.all(16), this.r = 22, this.onTap});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Material(
            color: Colors.white.withOpacity(.06),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: pad,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r),
                  border: Border.all(color: Colors.white.withOpacity(.12)),
                ),
                child: child,
              ),
            ),
          ),
        ),
      );
}

Widget bg({required Widget child}) => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [cDeep, cMidnight]),
      ),
      child: Stack(children: [
        Positioned(top: -120, right: -80, child: _glow(cViolet, 320)),
        Positioned(top: 120, left: -140, child: _glow(cIce, 300)),
        const Positioned.fill(child: SnowLayer()),
        child,
      ]),
    );

Widget _glow(Color c, double s) => Container(
      width: s,
      height: s,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c.withOpacity(.28), c.withOpacity(0)])),
    );

// ---------- Splash ----------
class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const Shell(),
        transitionsBuilder: (_, a, __, w) => FadeTransition(opacity: a, child: w),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: bg(
          child: Center(
            child: ScaleTransition(
              scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
              child: FadeTransition(
                opacity: _c,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: cIce.withOpacity(.5), blurRadius: 60)],
                    ),
                    child: Image.asset('assets/logo.png', width: 110, errorBuilder: (_, __, ___) => const Text('❄', style: TextStyle(fontSize: 80))),
                  ),
                  const SizedBox(height: 18),
                  const Text('اسنو پنل', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: cFrost)),
                  const SizedBox(height: 6),
                  Text('پنل خدمات مجازی', style: TextStyle(color: cFrost.withOpacity(.6))),
                ]),
              ),
            ),
          ),
        ),
      );
}

// ---------- Shell ----------
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  final visited = <int>{0};
  static const tabs = [
    ['خانه', Icons.ac_unit_rounded, ''],
    ['خدمات', Icons.grid_view_rounded, '/services-3'],
    ['سفارش', Icons.add_circle_rounded, '/dashboard/?action=orders&section=new'],
    ['شارژ', Icons.account_balance_wallet_rounded, '/dashboard/?action=add-credit'],
    ['حساب', Icons.person_rounded, '/dashboard'],
  ];

  void go(int n) => setState(() {
        i = n;
        visited.add(n);
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        body: IndexedStack(index: i, children: [
          Home(onGo: go),
          for (var n = 1; n < tabs.length; n++)
            visited.contains(n) ? WebTab(url: base + (tabs[n][2] as String)) : const SizedBox(),
        ]),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Glass(
            r: 28,
            pad: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Row(children: [
              for (var n = 0; n < tabs.length; n++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => go(n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: i == n ? const LinearGradient(colors: [cIce, cViolet]) : null,
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(tabs[n][1] as IconData, size: 22, color: i == n ? cMidnight : cFrost.withOpacity(.6)),
                        const SizedBox(height: 2),
                        Text(tabs[n][0] as String,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: i == n ? cMidnight : cFrost.withOpacity(.6))),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      );
}

// ---------- Home ----------
class Home extends StatelessWidget {
  final void Function(int) onGo;
  const Home({super.key, required this.onGo});

  static const cats = [
    ['تلگرام', '✈️', 'ممبر، بازدید، ری‌اکشن'],
    ['اینستاگرام', '📸', 'فالوور، لایک، ویو'],
    ['ایتا', '🟠', 'ممبر و بازدید'],
    ['روبیکا', '🔵', 'فالوور و ممبر'],
    ['یوتیوب', '▶️', 'سابسکرایب و ویو'],
    ['تیک‌تاک', '🎵', 'فالوور و لایک'],
  ];

  @override
  Widget build(BuildContext context) => bg(
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: [
            Row(children: [
              Image.asset('assets/logo.png', width: 38, errorBuilder: (_, __, ___) => const Text('❄', style: TextStyle(fontSize: 30))),
              const SizedBox(width: 10),
              const Expanded(child: Text('اسنو پنل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
              IconButton(
                onPressed: () => launchUrl(Uri.parse('https://t.me/snowpanelsup'), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.support_agent_rounded, color: cIce),
              ),
            ]),
            const SizedBox(height: 22),
            Glass(
              r: 30,
              pad: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ارزان‌ترین پنل SMM\nبا ۶ سال سابقه',
                    style: TextStyle(fontSize: 26, height: 1.5, fontWeight: FontWeight.w700, color: cFrost)),
                const SizedBox(height: 8),
                Text('مستقیم از ارائه‌دهنده، بدون رمز، با رهگیری زنده سفارش',
                    style: TextStyle(color: cFrost.withOpacity(.65), height: 1.7)),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onGo(2),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(colors: [cIce, cViolet]),
                          boxShadow: [BoxShadow(color: cIce.withOpacity(.4), blurRadius: 24, offset: const Offset(0, 8))],
                        ),
                        child: const Text('ثبت سفارش', style: TextStyle(color: cMidnight, fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => onGo(1),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: cIce.withOpacity(.5))),
                      child: const Text('قیمت‌ها', style: TextStyle(color: cIce, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            Row(children: const [
              Expanded(child: _Stat('۲۰۰,۰۰۰+', 'سفارش تکمیل‌شده')),
              SizedBox(width: 10),
              Expanded(child: _Stat('۱۳,۰۰۰+', 'مشتری فعال')),
              SizedBox(width: 10),
              Expanded(child: _Stat('۲۰+', 'شبکه اجتماعی')),
            ]),
            const SizedBox(height: 26),
            const Text('کدام شبکه؟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                for (final c in cats)
                  Glass(
                    onTap: () => onGo(1),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(c[1], style: const TextStyle(fontSize: 26)),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c[0], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(c[2], style: TextStyle(fontSize: 11, color: cFrost.withOpacity(.55))),
                      ]),
                    ]),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Glass(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'SNOW5'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد SNOW5 کپی شد')));
              },
              child: Row(children: [
                const Text('🎁', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('هدیه اولین شارژ', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('کد را هنگام شارژ وارد کن', style: TextStyle(fontSize: 12, color: cFrost.withOpacity(.6))),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: cIce.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
                  child: const Text('SNOW5', style: TextStyle(color: cIce, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Glass(
              onTap: () => launchUrl(Uri.parse('$base/api-smm'), mode: LaunchMode.externalApplication),
              child: Row(children: [
                const Icon(Icons.hub_rounded, color: cViolet, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('نمایندگی و API', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('پنل خودت را بساز و بفروش', style: TextStyle(fontSize: 12, color: cFrost.withOpacity(.6))),
                  ]),
                ),
                const Icon(Icons.chevron_left_rounded),
              ]),
            ),
          ]),
        ),
      );
}

class _Stat extends StatelessWidget {
  final String v, l;
  const _Stat(this.v, this.l);
  @override
  Widget build(BuildContext context) => Glass(
        r: 18,
        pad: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(children: [
          Text(v, style: const TextStyle(color: cIce, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, color: cFrost.withOpacity(.6))),
        ]),
      );
}

// ---------- Web tab ----------
class WebTab extends StatefulWidget {
  final String url;
  const WebTab({super.key, required this.url});
  @override
  State<WebTab> createState() => _WebTabState();
}

class _WebTabState extends State<WebTab> with AutomaticKeepAliveClientMixin {
  late final WebViewController c;
  int p = 0;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(cMidnight)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (v) => setState(() => p = v),
        onNavigationRequest: (r) {
          final u = Uri.parse(r.url);
          if (u.host.endsWith('snowpanel.ir') || u.host.contains('zibal.ir') || u.host.contains('shaparak.ir')) {
            return NavigationDecision.navigate;
          }
          launchUrl(u, mode: LaunchMode.externalApplication);
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        if (await c.canGoBack()) c.goBack();
      },
      child: Container(
        color: cMidnight,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 96),
        child: Column(children: [
          if (p < 100) LinearProgressIndicator(value: p / 100, minHeight: 2, color: cIce, backgroundColor: Colors.transparent),
          Expanded(child: WebViewWidget(controller: c)),
        ]),
      ),
    );
  }
}
