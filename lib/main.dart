import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const base = 'https://snowpanel.ir';
const cBg = Color(0xFFF2F8FF);
const cInk = Color(0xFF0B1B3A);
const cBlue = Color(0xFF1E7BFF);
const cCyan = Color(0xFF27C4F5);
const cSoft = Color(0xFFE3F0FF);
const cMute = Color(0xFF6B7C99);
const grad = LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [cBlue, cCyan]);

void open(String u) => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
Route fade(Widget w) => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, __, ___) => w,
    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c));

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark, systemNavigationBarColor: Colors.white));
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
          scaffoldBackgroundColor: cBg,
          colorScheme: ColorScheme.fromSeed(seedColor: cBlue),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: cSoft,
            labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cInk)),
          ),
        ),
        home: const Splash(),
      );
}

// ---------- shared widgets ----------
class SnowLayer extends StatefulWidget {
  final Color color;
  const SnowLayer(this.color, {super.key});
  @override
  State<SnowLayer> createState() => _SnowState();
}

class _SnowState extends State<SnowLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  final _r = Random(3);
  late final f = List.generate(45, (_) => [_r.nextDouble(), _r.nextDouble(), _r.nextDouble() * 2.4 + .8, _r.nextDouble() * .5 + .2]);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(size: Size.infinite, painter: _P(f, _c.value, widget.color)),
        ),
      );
}

class _P extends CustomPainter {
  final List<List<double>> f;
  final double t;
  final Color c;
  _P(this.f, this.t, this.c);
  @override
  void paint(Canvas canvas, Size s) {
    for (final p in f) {
      final y = ((p[1] + t * p[3]) % 1.0) * s.height;
      final x = (p[0] * s.width + sin(t * 12.56 + p[0] * 9) * 12) % s.width;
      canvas.drawCircle(Offset(x, y), p[2], Paint()..color = c.withOpacity(.2 + p[3] * .5));
    }
  }

  @override
  bool shouldRepaint(_P o) => true;
}

Widget card({required Widget child, VoidCallback? onTap, EdgeInsets pad = const EdgeInsets.all(16)}) => Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      shadowColor: cBlue.withOpacity(.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: pad,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: cBlue.withOpacity(.08), blurRadius: 18, offset: const Offset(0, 6))]),
          child: child,
        ),
      ),
    );

Widget logo(double s) => Image.asset('assets/logo.png', width: s, errorBuilder: (_, __, ___) => Text('❄', style: TextStyle(fontSize: s * .8)));

class Btn extends StatelessWidget {
  final String t;
  final VoidCallback f;
  final bool filled;
  const Btn(this.t, this.f, {super.key, this.filled = true});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: f,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: filled ? grad : null,
              borderRadius: BorderRadius.circular(16),
              border: filled ? null : Border.all(color: cBlue, width: 1.5),
              boxShadow: filled ? [BoxShadow(color: cBlue.withOpacity(.35), blurRadius: 20, offset: const Offset(0, 8))] : null),
          child: Text(t, style: TextStyle(color: filled ? Colors.white : cBlue, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      );
}

// ---------- Splash ----------
class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () async {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fade(p.getBool('in') == true ? const Shell() : const Welcome()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: grad),
          child: Stack(children: [
            const Positioned.fill(child: SnowLayer(Colors.white)),
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: logo(80)),
                const SizedBox(height: 18),
                const Text('اسنو پنل', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
          ]),
        ),
      );
}

// ---------- Welcome (login gate) ----------
class Welcome extends StatelessWidget {
  const Welcome({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: grad),
          child: Stack(children: [
            const Positioned.fill(child: SnowLayer(Colors.white)),
            SafeArea(
              child: Column(children: [
                const Spacer(flex: 2),
                Container(padding: const EdgeInsets.all(18), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: logo(64)),
                const SizedBox(height: 20),
                const Text('به اسنو پنل خوش اومدی', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 36),
                  child: Text('فالوور، ممبر و بازدید مستقیم از ارائه‌دهنده\nبدون رمز، با رهگیری زنده سفارش',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white, height: 1.8)),
                ),
                const SizedBox(height: 20),
                Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                  for (final t in ['🔒 بدون رمز', '📦 رهگیری زنده', '🎁 هدیه شارژ با SNOW5'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ),
                ]),
                const Spacer(flex: 3),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  decoration: const BoxDecoration(color: cBg, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Btn('ورود به حساب', () => Navigator.of(context).push(fade(const AuthPage(false)))),
                    const SizedBox(height: 12),
                    Btn('ساخت حساب رایگان', () => Navigator.of(context).push(fade(const AuthPage(true))), filled: false),
                    const SizedBox(height: 10),
                    TextButton(onPressed: () => open('https://t.me/snowpanelsup'), child: const Text('مشکل در ورود؟ پشتیبانی تلگرام', style: TextStyle(color: cMute))),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      );
}

// ---------- WebView helpers ----------
const _inject = '''
var m=document.querySelector('meta[name=viewport]');
if(!m){m=document.createElement('meta');m.name='viewport';document.head.appendChild(m);}
m.content='width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no';
var s=document.createElement('style');
var css='footer,.elementor-location-header,.elementor-location-footer{display:none!important}html,body{overflow-x:hidden!important;max-width:100vw!important}';
if(location.pathname.indexOf('/dashboard')<0){css+='header{display:none!important}';}
s.innerHTML=css;document.head.appendChild(s);
''';

WebViewController makeController(String url, {void Function(int)? onProgress, void Function(String)? onUrl}) {
  final c = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(cBg)
    ..enableZoom(false)
    ..setNavigationDelegate(NavigationDelegate(
      onProgress: onProgress,
      onPageFinished: (u) {
        onUrl?.call(u);
      },
      onNavigationRequest: (r) {
        final u = Uri.parse(r.url);
        if (u.host.endsWith('snowpanel.ir') || u.host.contains('zibal.ir') || u.host.contains('shaparak.ir')) return NavigationDecision.navigate;
        launchUrl(u, mode: LaunchMode.externalApplication);
        return NavigationDecision.prevent;
      },
    ))
    ..loadRequest(Uri.parse(url));
  return c;
}

class AuthPage extends StatefulWidget {
  final bool register;
  const AuthPage(this.register, {super.key});
  @override
  State<AuthPage> createState() => _AuthState();
}

class _AuthState extends State<AuthPage> {
  late final WebViewController c;
  int p = 0;
  @override
  void initState() {
    super.initState();
    c = makeController(base + (widget.register ? '/login/?action=register' : '/login'), onProgress: (v) => setState(() => p = v), onUrl: (u) async {
      c.runJavaScript(_inject);
      if (u.contains('/dashboard')) {
        final sp = await SharedPreferences.getInstance();
        await sp.setBool('in', true);
        if (mounted) Navigator.of(context).pushAndRemoveUntil(fade(const Shell()), (_) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(widget.register ? 'ساخت حساب' : 'ورود', style: const TextStyle(fontWeight: FontWeight.w700, color: cInk)),
          iconTheme: const IconThemeData(color: cInk),
          bottom: p < 100 ? PreferredSize(preferredSize: const Size.fromHeight(2), child: LinearProgressIndicator(value: p / 100, minHeight: 2, color: cCyan)) : null,
        ),
        body: WebViewWidget(controller: c),
      );
}

class WebTab extends StatefulWidget {
  final String url, title;
  const WebTab(this.url, this.title, {super.key});
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
    c = makeController(base + widget.url, onProgress: (v) => setState(() => p = v), onUrl: (_) => c.runJavaScript(_inject));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        if (await c.canGoBack()) c.goBack();
      },
      child: Column(children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 8, 8),
          child: Row(children: [
            Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cInk))),
            IconButton(onPressed: c.reload, icon: const Icon(Icons.refresh_rounded, color: cBlue)),
          ]),
        ),
        if (p < 100) LinearProgressIndicator(value: p / 100, minHeight: 2, color: cCyan, backgroundColor: cSoft),
        Expanded(child: WebViewWidget(controller: c)),
      ]),
    );
  }
}

// ---------- Shell ----------
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  final seen = <int>{0};
  void go(int n) => setState(() {
        i = n;
        seen.add(n);
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: i, children: [
          Home(go),
          seen.contains(1) ? const WebTab('/services-3', 'همه خدمات') : const SizedBox(),
          seen.contains(2) ? const WebTab('/dashboard/?action=orders&section=new', 'سفارش جدید') : const SizedBox(),
          seen.contains(3) ? const WebTab('/dashboard/?action=add-credit', 'شارژ حساب') : const SizedBox(),
          const More(),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: go,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: cBlue), label: 'خانه'),
            NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded, color: cBlue), label: 'خدمات'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle_rounded, color: cBlue), label: 'سفارش'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: cBlue), label: 'کیف پول'),
            NavigationDestination(icon: Icon(Icons.menu_rounded), selectedIcon: Icon(Icons.menu_rounded, color: cBlue), label: 'بیشتر'),
          ],
        ),
      );
}

// ---------- Home ----------
class Home extends StatelessWidget {
  final void Function(int) go;
  const Home(this.go, {super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: EdgeInsets.zero, children: [
        Container(
          decoration: const BoxDecoration(gradient: grad, borderRadius: BorderRadius.vertical(bottom: Radius.circular(36))),
          child: Stack(children: [
            const Positioned.fill(child: SnowLayer(Colors.white)),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: logo(26)),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('اسنو پنل', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white))),
                    IconButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Support())),
                        icon: const Icon(Icons.support_agent_rounded, color: Colors.white)),
                  ]),
                  const SizedBox(height: 18),
                  const Text('سلام، خوش اومدی ❄', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text('سفارش بده، رهگیری کن، رشد کن', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  Row(children: const [
                    Expanded(child: _Stat('۲۰۰,۰۰۰+', 'سفارش')),
                    SizedBox(width: 10),
                    Expanded(child: _Stat('۱۳,۰۰۰+', 'مشتری')),
                    SizedBox(width: 10),
                    Expanded(child: _Stat('۶ سال', 'سابقه')),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _Quick(Icons.add_circle_rounded, 'سفارش جدید', () => go(2)),
              _Quick(Icons.account_balance_wallet_rounded, 'شارژ', () => go(3)),
              _Quick(Icons.grid_view_rounded, 'خدمات', () => go(1)),
              _Quick(Icons.support_agent_rounded, 'پشتیبانی', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Support()))),
            ]),
            const SizedBox(height: 26),
            const Text('کدام شبکه؟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cInk)),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final n in ['✈️ تلگرام', '📸 اینستاگرام', '🟠 ایتا', '🔵 روبیکا', '▶️ یوتیوب', '🎵 تیک‌تاک', '🐦 توییتر', '🌐 بقیه'])
                GestureDetector(
                  onTap: () => go(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: cBlue.withOpacity(.08), blurRadius: 12)]),
                    child: Text(n, style: const TextStyle(fontWeight: FontWeight.w700, color: cInk)),
                  ),
                ),
            ]),
            const SizedBox(height: 22),
            card(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'SNOW5'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد SNOW5 کپی شد')));
              },
              child: Row(children: [
                const Text('🎁', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                const Expanded(child: Text('هدیه اولین شارژ\nکد را هنگام شارژ وارد کن', style: TextStyle(height: 1.7, color: cInk, fontWeight: FontWeight.w700))),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: cSoft, borderRadius: BorderRadius.circular(12)),
                    child: const Text('SNOW5', style: TextStyle(color: cBlue, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
              ]),
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ]);
}

class _Stat extends StatelessWidget {
  final String v, l;
  const _Stat(this.v, this.l);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          Text(l, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ]),
      );
}

class _Quick extends StatelessWidget {
  final IconData i;
  final String t;
  final VoidCallback f;
  const _Quick(this.i, this.t, this.f);
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: f,
          child: Column(children: [
            Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: cBlue.withOpacity(.12), blurRadius: 14, offset: const Offset(0, 5))]),
                child: Icon(i, color: cBlue, size: 28)),
            const SizedBox(height: 8),
            Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cInk)),
          ]),
        ),
      );
}

// ---------- More ----------
class More extends StatelessWidget {
  const More({super.key});
  Widget tile(BuildContext c, IconData i, String t, String s, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: card(
          onTap: f,
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: cSoft, borderRadius: BorderRadius.circular(14)), child: Icon(i, color: cBlue)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.w700, color: cInk)),
              Text(s, style: const TextStyle(fontSize: 12, color: cMute)),
            ])),
            const Icon(Icons.chevron_left_rounded, color: cMute),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('بیشتر', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: cInk)),
          const SizedBox(height: 16),
          tile(context, Icons.dashboard_rounded, 'داشبورد', 'حساب، اطلاعات و تیکت‌ها', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Page('داشبورد', '/dashboard')))),
          tile(context, Icons.account_balance_wallet_rounded, 'شارژ حساب', 'پرداخت امن با درگاه', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Page('شارژ حساب', '/dashboard/?action=add-credit')))),
          tile(context, Icons.receipt_long_rounded, 'سفارش‌های من', 'رهگیری وضعیت سفارش‌ها', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Page('سفارش‌های من', '/dashboard/?action=orders')))),
          tile(context, Icons.support_agent_rounded, 'پشتیبانی', 'تلگرام، ربات و کانال', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Support()))),
          tile(context, Icons.help_rounded, 'سوالات متداول', 'پاسخ کوتاه به پرسش‌های پرتکرار', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Faq()))),
          tile(context, Icons.price_change_rounded, 'لیست قیمت', 'قیمت همه خدمات', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Page('لیست قیمت', '/price-service')))),
          const SizedBox(height: 10),
          Btn('خروج از حساب', () async {
            final sp = await SharedPreferences.getInstance();
            await sp.remove('in');
            await WebViewCookieManager().clearCookies();
            if (context.mounted) Navigator.of(context).pushAndRemoveUntil(fade(const Welcome()), (_) => false);
          }, filled: false),
        ]),
      );
}

class Page extends StatelessWidget {
  final String title, url;
  const Page(this.title, this.url, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: cInk), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: cInk))),
        body: _Web(url),
      );
}

class _Web extends StatefulWidget {
  final String url;
  const _Web(this.url);
  @override
  State<_Web> createState() => _WebS();
}

class _WebS extends State<_Web> {
  late final WebViewController c = makeController(base + widget.url, onUrl: (_) => c.runJavaScript(_inject));
  @override
  Widget build(BuildContext context) => WebViewWidget(controller: c);
}

// ---------- Support ----------
class Support extends StatelessWidget {
  const Support({super.key});
  Widget item(IconData i, String t, String s, String u) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: card(
          onTap: () => open(u),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(16)), child: Icon(i, color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.w700, color: cInk)),
              Text(s, style: const TextStyle(fontSize: 12, color: cMute)),
            ])),
            const Icon(Icons.open_in_new_rounded, color: cMute, size: 20),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: cInk), title: const Text('پشتیبانی', style: TextStyle(fontWeight: FontWeight.w700, color: cInk))),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          card(
            child: const Text('برای پاسخ سریع‌تر، پیام تلگرام بده. تیکت داخل پنل جواب داده نمی‌شود.', style: TextStyle(height: 1.8, color: cInk, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 14),
          item(Icons.support_agent_rounded, 'پشتیبانی تلگرام', '@snowpanelsup', 'https://t.me/snowpanelsup'),
          item(Icons.smart_toy_rounded, 'ربات تلگرام', '@snowpanelbot', 'https://t.me/snowpanelbot'),
          item(Icons.campaign_rounded, 'کانال تلگرام', '@snowpanel', 'https://t.me/snowpanel'),
          item(Icons.camera_alt_rounded, 'اینستاگرام', '@snowpanel', 'https://instagram.com/snowpanel'),
        ]),
      );
}

// ---------- FAQ ----------
class Faq extends StatelessWidget {
  const Faq({super.key});
  static const q = [
    ['آیا برای سفارش به رمز عبور نیاز است؟', 'خیر. فقط لینک عمومی پیج، کانال یا پست لازم است. رمز و کد دومرحله‌ای را به هیچ‌کس ندهید.'],
    ['چطور اولین سفارش را ثبت کنم؟', 'ثبت‌نام کنید، حساب را شارژ کنید، سرویس را انتخاب و لینک را وارد کنید. با یک سفارش تست کوچک شروع کنید.'],
    ['ارائه‌دهنده مستقیم یعنی چه؟', 'یعنی اسنو پنل خدمات را از واسطه نمی‌خرد؛ مسیر خرید کوتاه‌تر و قیمت معمولاً پایین‌تر است.'],
    ['ریفیل و ریزش چیست؟', 'در سرویس‌های دارای گارانتی، اگر تعداد بعد از تحویل کم شود، طبق شرایط همان سرویس دوباره تکمیل می‌شود.'],
    ['خدمات ایرانی دارید؟', 'بله. ممبر ایتا، روبیکا، سروش پلاس، بله، آی‌گپ، گپ و آپارات در دسترس است.'],
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: cInk), title: const Text('سوالات متداول', style: TextStyle(fontWeight: FontWeight.w700, color: cInk))),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          for (final e in q)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(e[0], style: const TextStyle(fontWeight: FontWeight.w700, color: cInk, fontSize: 14)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [Text(e[1], style: const TextStyle(height: 1.9, color: cMute))],
                  ),
                ),
              ),
            ),
        ]),
      );
}
