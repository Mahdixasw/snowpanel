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
    transitionDuration: const Duration(milliseconds: 250),
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
        title: 'Ø§Ø³Ù†Ùˆ Ù¾Ù†Ù„',
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
        child: RepaintBoundary(
          child: CustomPaint(size: Size.infinite, painter: _P(f, _c, widget.color)),
        ),
      );
}

class _P extends CustomPainter {
  final List<List<double>> f;
  final Animation<double> a;
  final Color c;
  final Paint _paint = Paint();
  _P(this.f, this.a, this.c) : super(repaint: a);
  @override
  void paint(Canvas canvas, Size s) {
    final t = a.value;
    for (final p in f) {
      final y = ((p[1] + t * p[3]) % 1.0) * s.height;
      final x = (p[0] * s.width + sin(t * 12.56 + p[0] * 9) * 12) % s.width;
      _paint.color = c.withOpacity(.2 + p[3] * .5);
      canvas.drawCircle(Offset(x, y), p[2], _paint);
    }
  }

  @override
  bool shouldRepaint(_P o) => o.c != c;
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

Widget logo(double s) => Image.asset('assets/logo.png', width: s, errorBuilder: (_, __, ___) => Text('â„', style: TextStyle(fontSize: s * .8)));

class Btn extends StatelessWidget {
  final String t;
  final VoidCallback f;
  final bool filled;
  const Btn(this.t, this.f, {super.key, this.filled = true});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          f();
        },
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
    Future.delayed(const Duration(milliseconds: 900), () async {
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
                const Text('Ø§Ø³Ù†Ùˆ Ù¾Ù†Ù„', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
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
                const Text('Ø¨Ù‡ Ø§Ø³Ù†Ùˆ Ù¾Ù†Ù„ Ø®ÙˆØ´ Ø§ÙˆÙ…Ø¯ÛŒ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 36),
                  child: Text('ÙØ§Ù„ÙˆÙˆØ±ØŒ Ù…Ù…Ø¨Ø± Ùˆ Ø¨Ø§Ø²Ø¯ÛŒØ¯ Ù…Ø³ØªÙ‚ÛŒÙ… Ø§Ø² Ø§Ø±Ø§Ø¦Ù‡â€ŒØ¯Ù‡Ù†Ø¯Ù‡\nØ¨Ø¯ÙˆÙ† Ø±Ù…Ø²ØŒ Ø¨Ø§ Ø±Ù‡Ú¯ÛŒØ±ÛŒ Ø²Ù†Ø¯Ù‡ Ø³ÙØ§Ø±Ø´',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white, height: 1.8)),
                ),
                const SizedBox(height: 20),
                Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                  for (final t in ['ðŸ”’ Ø¨Ø¯ÙˆÙ† Ø±Ù…Ø²', 'ðŸ“¦ Ø±Ù‡Ú¯ÛŒØ±ÛŒ Ø²Ù†Ø¯Ù‡', 'ðŸŽ Ù‡Ø¯ÛŒÙ‡ Ø´Ø§Ø±Ú˜ Ø¨Ø§ SNOW5'])
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
                    Btn('ÙˆØ±ÙˆØ¯ Ø¨Ù‡ Ø­Ø³Ø§Ø¨', () => Navigator.of(context).push(fade(const AuthPage(false)))),
                    const SizedBox(height: 12),
                    Btn('Ø³Ø§Ø®Øª Ø­Ø³Ø§Ø¨ Ø±Ø§ÛŒÚ¯Ø§Ù†', () => Navigator.of(context).push(fade(const AuthPage(true))), filled: false),
                    const SizedBox(height: 10),
                    TextButton(onPressed: () => open('https://t.me/snowpanelsup'), child: const Text('Ù…Ø´Ú©Ù„ Ø¯Ø± ÙˆØ±ÙˆØ¯ØŸ Ù¾Ø´ØªÛŒØ¨Ø§Ù†ÛŒ ØªÙ„Ú¯Ø±Ø§Ù…', style: TextStyle(color: cMute))),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      );
}

// ---------- WebView helpers ----------
// Security: only these hosts (exact or sub-domain, https only) open inside the app.
const _trustedHosts = ['snowpanel.ir', 'zibal.ir', 'shaparak.ir'];
bool _trusted(Uri u) => u.scheme == 'https' && _trustedHosts.any((h) => u.host == h || u.host.endsWith('.$h'));
bool _isSite(String s) {
  final u = Uri.tryParse(s);
  return u != null && u.scheme == 'https' && (u.host == 'snowpanel.ir' || u.host.endsWith('.snowpanel.ir'));
}

// If the saved session is gone (site sends us to /login) -> back to Welcome, once.
bool _leaving = false;
Future<void> _guard(BuildContext ctx, String u) async {
  if (_leaving || !_isSite(u) || !Uri.parse(u).path.startsWith('/login')) return;
  _leaving = true;
  final sp = await SharedPreferences.getInstance();
  await sp.remove('in');
  if (ctx.mounted) Navigator.of(ctx).pushAndRemoveUntil(fade(const Welcome()), (_) => false);
  _leaving = false;
}

// Injected into every page: hides site-only parts (header/footer, mobile bottom bar,
// "back to site" links) and keeps the user logged in ("remember me" auto-ticked).
const _inject = r"""
(function(){
if(window.__snowRun){window.__snowRun();return;}
var d=document,R=function(){return d.head||d.documentElement;};
var KEYS=['Ø¨Ø§Ø²Ú¯Ø´Øª Ø¨Ù‡','Ø¨Ø±Ú¯Ø´Øª Ø¨Ù‡','Ø±ÙØªÙ† Ø¨Ù‡ Ø³Ø§ÛŒØª','ØµÙØ­Ù‡ Ø§ØµÙ„ÛŒ','back to','go to','return to','powered by','Ù‚Ø¯Ø±Øª Ú¯Ø±ÙØªÙ‡','Ø·Ø±Ø§Ø­ÛŒ Ø´Ø¯Ù‡'];
var BANNER=['ØªÛŒÚ©Øª Ø§Ø±Ø³Ø§Ù„ Ù†Ú©Ù†ÛŒØ¯','Ø¬ÙˆØ§Ø¨ Ø¯Ø§Ø¯Ù‡ Ù†Ù…ÛŒ'];
var TOP=/(^|[\s_-])(site-header|main-header|top-?bar|navbar|masthead|app-header|mobile-header|sticky-header|announce\w*|notice-bar|promo-bar|top-banner|alert-bar)/i;
var BOT=/(bottom|dock|tab-?bar|mobile-nav|mobile-menu|footer|nav)/i;
var m=d.querySelector('meta[name=viewport]');
if(!m){m=d.createElement('meta');m.name='viewport';R().appendChild(m);}
m.content='width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no';
var css='footer,.elementor-location-header,.elementor-location-footer,#wpadminbar,#wp-toolbar,#backtoblog,.back-to-site,[class*="back-to-"],[class*="backto"],[class*="bottom-nav"],[class*="bottom-bar"],[class*="mobile-bottom"],[class*="tabbar"],[class*="tab-bar"],[id*="bottom-nav"],[id*="mobile-bottom"],[class*="floating-cart"],[class*="topbar"],[class*="top-bar"],[class*="announcement"],[class*="notice-bar"],[class*="site-header"],[class*="main-header"],#masthead,[data-elementor-type="header"]{display:none!important}';
css+='html{margin-top:0!important;padding-top:0!important;scroll-behavior:auto!important}html,body{overflow-x:hidden!important;max-width:100vw!important}body{padding-top:0!important;padding-bottom:0!important;margin-bottom:0!important}*{-webkit-backdrop-filter:none!important;backdrop-filter:none!important}';
if(location.pathname.indexOf('/dashboard')<0)css+='header{display:none!important}';
var s=d.createElement('style');s.id='__snowcss';s.textContent=css;R().appendChild(s);

function isAuth(){return location.pathname.indexOf('/login')>-1||/action=register/.test(location.search);}
function hide(e){e.style.setProperty('display','none','important');e.__sn=1;}
function cls(e){return ((e.getAttribute('class')||'')+' '+(e.id||''));}
function clk(e){return e.querySelectorAll('a,button,[role=button]').length;}

function test(e){
 var t=e.tagName;
 if(!t||e.__sn||/^(SCRIPT|STYLE|LINK|META|HEAD|BODY|HTML|NOSCRIPT|SVG|PATH|IMG)$/i.test(t))return;
 var c=getComputedStyle(e);
 if(c.display==='none')return;
 var r=e.getBoundingClientRect();
 if(!r.width||!r.height)return;
 var w=innerWidth,h=innerHeight,fx=c.position==='fixed'||c.position==='sticky';
 var k=cls(e),n=clk(e),hasIn=!!e.querySelector('input,textarea,select');
 // bottom bars + floating cart button
 if(fx&&!hasIn&&r.top>=h*.6&&r.bottom>=h-120&&r.height<=200){
  var wide=r.width>=w*.6,round=r.width<=100&&r.height<=100&&n>=1;
  if(round||(wide&&(t==='NAV'||BOT.test(k)||n>=2))){hide(e);return;}
 }
 // top chrome: admin bar, notice banner, site header
 var top=r.top+(window.scrollY||0);
 if(top<420&&r.width>=w*.9&&r.height>=30&&r.height<=300){
  var img=!!e.querySelector('img,svg');
  if(t==='NAV'||(t==='HEADER'&&!e.closest('main,article'))||TOP.test(k)||(fx&&r.top<=10&&!hasIn)||(img&&n>=3&&!hasIn&&r.height<=200&&top<300))hide(e);
 }
}
var bd=0;
function banner(){
 if(bd)return;
 var l=d.querySelectorAll('p,span,div,h3,h4');
 for(var i=0;i<l.length;i++){
  var e=l[i];
  if(e.children.length>4)continue;
  var t=e.textContent||'';
  if(t.length>220)continue;
  for(var j=0;j<BANNER.length;j++){
   if(t.indexOf(BANNER[j])>-1){
    var x=e;
    while(x.parentElement&&x.parentElement!==d.body){
     var p=x.parentElement,r=p.getBoundingClientRect();
     if(r.width>=innerWidth*.9&&r.height<=420&&(p.textContent||'').length<500)x=p;else break;
    }
    hide(x);bd=1;return;
   }
  }
 }
}
function remember(){
 d.querySelectorAll('input[type=checkbox]').forEach(function(x){
  var l=x.closest('label'),k=((x.name||'')+(x.id||'')).toLowerCase(),t=((l&&l.textContent)||'').toLowerCase();
  if(k.indexOf('remember')>-1||t.indexOf('remember')>-1||t.indexOf('Ø¨Ù‡ Ø®Ø§Ø·Ø±')>-1||t.indexOf('Ø¨Ø®Ø§Ø·Ø±')>-1){
   if(!x.checked)x.click();
   hide(l||x.parentElement||x);
  }
 });
}
function keyHide(){
 d.querySelectorAll('a,button,span,p,li,div,small').forEach(function(e){
  if(e.__sn||e.children.length>3||e.querySelector('input,select,textarea,form'))return;
  var t=(e.textContent||'').replace(/\s+/g,' ').trim().toLowerCase();
  if(!t||t.length>32)return;
  for(var i=0;i<KEYS.length;i++){if(t.indexOf(KEYS[i])>-1){hide(e.closest('a,button')||e);return;}}
 });
}
var pend=[],q=0;
function flush(){
 q=0;
 var a=pend;pend=[];
 try{
  for(var i=0;i<a.length;i++){var e=a[i];if(e.isConnected)test(e);}
  banner();
  if(isAuth()){remember();keyHide();}
 }catch(x){}
}
function sched(){
 if(q)return;q=1;
 if(window.requestIdleCallback)requestIdleCallback(flush,{timeout:600});else setTimeout(flush,150);
}
function full(){
 pend=pend.concat(Array.prototype.slice.call(d.querySelectorAll('body>*,body>*>*,body>*>*>*,body>*>*>*>*')));
 d.querySelectorAll('img').forEach(function(im,i){if(i>1&&!im.getAttribute('loading'))im.loading='lazy';im.decoding='async';});
 sched();
}
window.__snowRun=full;
try{
 new MutationObserver(function(ms){
  for(var i=0;i<ms.length;i++){
   var a=ms[i].addedNodes;
   for(var j=0;j<a.length;j++){
    var n=a[j];if(n.nodeType!==1)continue;
    pend.push(n);
    var c=n.children;for(var k=0;k<c.length&&k<20;k++)pend.push(c[k]);
   }
  }
  sched();
 }).observe(d.documentElement,{childList:true,subtree:true});
}catch(e){}
d.addEventListener('DOMContentLoaded',full);
addEventListener('load',full);
setTimeout(full,1500);setTimeout(full,4000);
full();
})();
""";

WebViewController makeController(String url, {void Function(int)? onProgress, void Function(String)? onUrl}) {
  final c = WebViewController();
  c
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(cBg)
    ..enableZoom(false)
    ..setNavigationDelegate(NavigationDelegate(
      onProgress: onProgress,
      onPageStarted: (_) => c.runJavaScript(_inject),
      onPageFinished: (u) {
        c.runJavaScript(_inject);
        onUrl?.call(u);
      },
      onNavigationRequest: (r) {
        final u = Uri.tryParse(r.url);
        if (u == null) return NavigationDecision.prevent;
        if (!r.isMainFrame || u.scheme == 'about' || _trusted(u)) return NavigationDecision.navigate;
        // external links: only safe schemes, never file:/intent:/javascript:
        if (const ['https', 'tg', 'mailto', 'tel'].contains(u.scheme)) launchUrl(u, mode: LaunchMode.externalApplication);
        return NavigationDecision.prevent;
      },
    ))
    ..loadRequest(Uri.parse(url));
  return c;
}

class _Cover extends StatelessWidget {
  const _Cover();
  @override
  Widget build(BuildContext context) => Container(
        color: cBg,
        alignment: Alignment.center,
        child: const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3, color: cBlue)),
      );
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
    c = makeController(base + (widget.register ? '/login/?action=register' : '/login'), onProgress: (v) {
      if (mounted) setState(() => p = v);
    }, onUrl: (u) async {
      if (_isSite(u) && Uri.parse(u).path.startsWith('/dashboard')) {
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
          title: Text(widget.register ? 'Ø³Ø§Ø®Øª Ø­Ø³Ø§Ø¨' : 'ÙˆØ±ÙˆØ¯', style: const TextStyle(fontWeight: FontWeight.w700, color: cInk)),
          iconTheme: const IconThemeData(color: cInk),
          bottom: p < 100 ? PreferredSize(preferredSize: const Size.fromHeight(2), child: LinearProgressIndicator(value: p / 100, minHeight: 2, color: cCyan)) : null,
        ),
        body: Stack(children: [WebViewWidget(controller: c), if (p < 90) const Positioned.fill(child: _Cover())]),
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
    c = makeController(base + widget.url, onProgress: (v) {
      if (mounted) setState(() => p = v);
    }, onUrl: (u) => _guard(context, u));
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
        Expanded(child: Stack(children: [WebViewWidget(controller: c), if (p < 90) const Positioned.fill(child: _Cover())])),
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
  @override
  void initState() {
    super.initState();
    // pre-load the busiest tabs quietly so switching is instant
    for (final n in [2, 1]) {
      Future.delayed(Duration(milliseconds: n == 2 ? 2000 : 4000), () {
        if (mounted && !seen.contains(n)) setState(() => seen.add(n));
      });
    }
  }

  void go(int n) => setState(() {
        i = n;
        seen.add(n);
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: i, children: [
          Home(go),
          seen.contains(1) ? const WebTab('/services-3', 'Ù‡Ù…Ù‡ Ø®Ø¯Ù…Ø§Øª') : const SizedBox(),
          seen.contains(2) ? const WebTab('/dashboard/?action=orders&section=new', 'Ø³ÙØ§Ø±Ø´ Ø¬Ø¯ÛŒØ¯') : const SizedBox(),
          seen.contains(3) ? const WebTab('/dashboard/?action=add-credit', 'Ø´Ø§Ø±Ú˜ Ø­Ø³Ø§Ø¨') : const SizedBox(),
          const More(),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: i,
          onDestinationSelected: go,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: cBlue), label: 'Ø®Ø§Ù†Ù‡'),
            NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded, color: cBlue), label: 'Ø®Ø¯Ù…Ø§Øª'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle_rounded, color: cBlue), label: 'Ø³ÙØ§Ø±Ø´'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: cBlue), label: 'Ú©ÛŒÙ Ù¾ÙˆÙ„'),
            NavigationDestination(icon: Icon(Icons.menu_rounded), selectedIcon: Icon(Icons.menu_rounded, color: cBlue), label: 'Ø¨ÛŒØ´ØªØ±'),
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
                    const Expanded(child: Text('Ø§Ø³Ù†Ùˆ Ù¾Ù†Ù„', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white))),
                    IconButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Support())),
                        icon: const Icon(Icons.support_agent_rounded, color: Colors.white)),
                  ]),
                  const SizedBox(height: 18),
                  const Text('Ø³Ù„Ø§Ù…ØŒ Ø®ÙˆØ´ Ø§ÙˆÙ…Ø¯ÛŒ â„', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text('Ø³ÙØ§Ø±Ø´ Ø¨Ø¯Ù‡ØŒ Ø±Ù‡Ú¯ÛŒØ±ÛŒ Ú©Ù†ØŒ Ø±Ø´Ø¯ Ú©Ù†', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  Row(children: const [
                    Expanded(child: _Stat('Û²Û°Û°,Û°Û°Û°+', 'Ø³ÙØ§Ø±Ø´')),
                    SizedBox(width: 10),
                    Expanded(child: _Stat('Û±Û³,Û°Û°Û°+', 'Ù…Ø´ØªØ±ÛŒ')),
                    SizedBox(width: 10),
                    Expanded(child: _Stat('Û¶ Ø³Ø§Ù„', 'Ø³Ø§Ø¨Ù‚Ù‡')),
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
              _Quick(Icons.add_circle_rounded, 'Ø³ÙØ§Ø±Ø´ Ø¬Ø¯ÛŒØ¯', () => go(2)),
              _Quick(Icons.account_balance_wallet_rounded, 'Ø´Ø§Ø±Ú˜', () => go(3)),
              _Quick(Icons.grid_view_rounded, 'Ø®Ø¯Ù…Ø§Øª', () => go(1)),
              _Quick(Icons.support_agent_rounded, 'Ù¾Ø´ØªÛŒØ¨Ø§Ù†ÛŒ', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Support()))),
            ]),
            const SizedBox(height: 26),
            const Text('Ú©Ø¯Ø§Ù… Ø´Ø¨Ú©Ù‡ØŸ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cInk)),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final n in ['âœˆï¸ ØªÙ„Ú¯Ø±Ø§Ù…', 'ðŸ“¸ Ø§ÛŒÙ†Ø³ØªØ§Ú¯Ø±Ø§Ù…', 'ðŸŸ  Ø§ÛŒØªØ§', 'ðŸ”µ Ø±ÙˆØ¨ÛŒÚ©Ø§', 'â–¶ï¸ ÛŒÙˆØªÛŒÙˆØ¨', 'ðŸŽµ ØªÛŒÚ©â€ŒØªØ§Ú©', 'ðŸ¦ ØªÙˆÛŒÛŒØªØ±', 'ðŸŒ Ø¨Ù‚ÛŒÙ‡'])
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ú©Ø¯ SNOW5 Ú©Ù¾ÛŒ Ø´Ø¯')));
              },
              child: Row(children: [
                const Text('ðŸŽ', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                const Expanded(child: Text('Ù‡Ø¯ÛŒÙ‡ Ø§ÙˆÙ„ÛŒÙ† Ø´Ø§Ø±Ú˜\nÚ©Ø¯ Ø±Ø§ Ù‡Ù†Ú¯Ø§Ù… Ø´Ø§Ø±Ú˜ ÙˆØ§Ø±Ø¯ Ú©Ù†', style: TextStyle(height: 1.7, color: cInk, fontWeight: FontWeight.w700))),
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
          const Text('Ø¨ÛŒØ´ØªØ±', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: cInk)),
          const SizedBox(height: 16),
          tile(context, Icons.dashboard_rounded, 'Ø¯Ø§Ø´Ø¨ÙˆØ±Ø¯', 'Ø­Ø³Ø§Ø¨ØŒ Ø§Ø·Ù„Ø§Ø¹Ø§Øª Ùˆ ØªÛŒÚ©Øªâ€ŒÙ‡Ø§', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Page('Ø¯Ø§Ø´Ø¨ÙˆØ±Ø¯', '/dashboard')))),
          tile(context, Icons.account_balance_wallet_rounded, 'Ø´Ø§Ø±Ú˜ Ø­Ø³Ø§Ø¨', 'Ù¾Ø±Ø¯Ø§Ø®Øª Ø§Ù…Ù† Ø¨Ø§ Ø¯Ø±Ú¯Ø§Ù‡', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Page('Ø´Ø§Ø±Ú˜ Ø­Ø³Ø§Ø¨', '/dashboard/?action=add-credit')))),
          tile(context, Icons.receipt_long_rounded, 'Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§ÛŒ Ù…Ù†', 'Ø±Ù‡Ú¯ÛŒØ±ÛŒ ÙˆØ¶Ø¹ÛŒØª Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Page('Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§ÛŒ Ù…Ù†', '/dashboard/?action=orders')))),
          tile(context, Icons.support_agent_rounded, 'Ù¾Ø´ØªÛŒØ¨Ø§Ù†ÛŒ', 'ØªÙ„Ú¯Ø±Ø§Ù…ØŒ Ø±Ø¨Ø§Øª Ùˆ Ú©Ø§Ù†Ø§Ù„', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Support()))),
          tile(context, Icons.help_rounded, 'Ø³ÙˆØ§Ù„Ø§Øª Ù…ØªØ¯Ø§ÙˆÙ„', 'Ù¾Ø§Ø³Ø® Ú©ÙˆØªØ§Ù‡ Ø¨Ù‡ Ù¾Ø±Ø³Ø´â€ŒÙ‡Ø§ÛŒ Ù¾Ø±ØªÚ©Ø±Ø§Ø±', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Faq()))),
          tile(context, Icons.price_change_rounded, 'Ù„ÛŒØ³Øª Ù‚ÛŒÙ…Øª', 'Ù‚ÛŒÙ…Øª Ù‡Ù…Ù‡ Ø®Ø¯Ù…Ø§Øª', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Page('Ù„ÛŒØ³Øª Ù‚ÛŒÙ…Øª', '/price-service')))),
          const SizedBox(height: 10),
          Btn('Ø®Ø±ÙˆØ¬ Ø§Ø² Ø­Ø³Ø§Ø¨', () async {
            final sp = await SharedPreferences.getInstance();
            await sp.remove('in');
            await WebViewCookieManager().clearCookies();
            final wc = WebViewController();
            await wc.clearCache();
            await wc.clearLocalStorage();
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
  int p = 0;
  late final WebViewController c = makeController(base + widget.url, onProgress: (v) {
      if (mounted) setState(() => p = v);
    }, onUrl: (u) => _guard(context, u));
  @override
  Widget build(BuildContext context) => Stack(children: [WebViewWidget(controller: c), if (p < 90) const Positioned.fill(child: _Cover())]);
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
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: cInk), title: const Text('Ù¾Ø´ØªÛŒØ¨Ø§Ù†ÛŒ', style: TextStyle(fontWeight: FontWeight.w700, color: cInk))),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          card(
            child: const Text('Ø¨Ø±Ø§ÛŒ Ù¾Ø§Ø³Ø® Ø³Ø±ÛŒØ¹â€ŒØªØ±ØŒ Ù¾ÛŒØ§Ù… ØªÙ„Ú¯Ø±Ø§Ù… Ø¨Ø¯Ù‡. ØªÛŒÚ©Øª Ø¯Ø§Ø®Ù„ Ù¾Ù†Ù„ Ø¬ÙˆØ§Ø¨ Ø¯Ø§Ø¯Ù‡ Ù†Ù…ÛŒâ€ŒØ´ÙˆØ¯.', style: TextStyle(height: 1.8, color: cInk, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 14),
          item(Icons.support_agent_rounded, 'Ù¾Ø´ØªÛŒØ¨Ø§Ù†ÛŒ ØªÙ„Ú¯Ø±Ø§Ù…', '@snowpanelsup', 'https://t.me/snowpanelsup'),
          item(Icons.smart_toy_rounded, 'Ø±Ø¨Ø§Øª ØªÙ„Ú¯Ø±Ø§Ù…', '@snowpanelbot', 'https://t.me/snowpanelbot'),
          item(Icons.campaign_rounded, 'Ú©Ø§Ù†Ø§Ù„ ØªÙ„Ú¯Ø±Ø§Ù…', '@snowpanel', 'https://t.me/snowpanel'),
          item(Icons.camera_alt_rounded, 'Ø§ÛŒÙ†Ø³ØªØ§Ú¯Ø±Ø§Ù…', '@snowpanel', 'https://instagram.com/snowpanel'),
        ]),
      );
}

// ---------- FAQ ----------
class Faq extends StatelessWidget {
  const Faq({super.key});
  static const q = [
    ['Ø¢ÛŒØ§ Ø¨Ø±Ø§ÛŒ Ø³ÙØ§Ø±Ø´ Ø¨Ù‡ Ø±Ù…Ø² Ø¹Ø¨ÙˆØ± Ù†ÛŒØ§Ø² Ø§Ø³ØªØŸ', 'Ø®ÛŒØ±. ÙÙ‚Ø· Ù„ÛŒÙ†Ú© Ø¹Ù…ÙˆÙ…ÛŒ Ù¾ÛŒØ¬ØŒ Ú©Ø§Ù†Ø§Ù„ ÛŒØ§ Ù¾Ø³Øª Ù„Ø§Ø²Ù… Ø§Ø³Øª. Ø±Ù…Ø² Ùˆ Ú©Ø¯ Ø¯ÙˆÙ…Ø±Ø­Ù„Ù‡â€ŒØ§ÛŒ Ø±Ø§ Ø¨Ù‡ Ù‡ÛŒÚ†â€ŒÚ©Ø³ Ù†Ø¯Ù‡ÛŒØ¯.'],
    ['Ú†Ø·ÙˆØ± Ø§ÙˆÙ„ÛŒÙ† Ø³ÙØ§Ø±Ø´ Ø±Ø§ Ø«Ø¨Øª Ú©Ù†Ù…ØŸ', 'Ø«Ø¨Øªâ€ŒÙ†Ø§Ù… Ú©Ù†ÛŒØ¯ØŒ Ø­Ø³Ø§Ø¨ Ø±Ø§ Ø´Ø§Ø±Ú˜ Ú©Ù†ÛŒØ¯ØŒ Ø³Ø±ÙˆÛŒØ³ Ø±Ø§ Ø§Ù†ØªØ®Ø§Ø¨ Ùˆ Ù„ÛŒÙ†Ú© Ø±Ø§ ÙˆØ§Ø±Ø¯ Ú©Ù†ÛŒØ¯. Ø¨Ø§ ÛŒÚ© Ø³ÙØ§Ø±Ø´ ØªØ³Øª Ú©ÙˆÚ†Ú© Ø´Ø±ÙˆØ¹ Ú©Ù†ÛŒØ¯.'],
    ['Ø§Ø±Ø§Ø¦Ù‡â€ŒØ¯Ù‡Ù†Ø¯Ù‡ Ù…Ø³ØªÙ‚ÛŒÙ… ÛŒØ¹Ù†ÛŒ Ú†Ù‡ØŸ', 'ÛŒØ¹Ù†ÛŒ Ø§Ø³Ù†Ùˆ Ù¾Ù†Ù„ Ø®Ø¯Ù…Ø§Øª Ø±Ø§ Ø§Ø² ÙˆØ§Ø³Ø·Ù‡ Ù†Ù…ÛŒâ€ŒØ®Ø±Ø¯Ø› Ù…Ø³ÛŒØ± Ø®Ø±ÛŒØ¯ Ú©ÙˆØªØ§Ù‡â€ŒØªØ± Ùˆ Ù‚ÛŒÙ…Øª Ù…Ø¹Ù…ÙˆÙ„Ø§Ù‹ Ù¾Ø§ÛŒÛŒÙ†â€ŒØªØ± Ø§Ø³Øª.'],
    ['Ø±ÛŒÙÛŒÙ„ Ùˆ Ø±ÛŒØ²Ø´ Ú†ÛŒØ³ØªØŸ', 'Ø¯Ø± Ø³Ø±ÙˆÛŒØ³â€ŒÙ‡Ø§ÛŒ Ø¯Ø§Ø±Ø§ÛŒ Ú¯Ø§Ø±Ø§Ù†ØªÛŒØŒ Ø§Ú¯Ø± ØªØ¹Ø¯Ø§Ø¯ Ø¨Ø¹Ø¯ Ø§Ø² ØªØ­ÙˆÛŒÙ„ Ú©Ù… Ø´ÙˆØ¯ØŒ Ø·Ø¨Ù‚ Ø´Ø±Ø§ÛŒØ· Ù‡Ù…Ø§Ù† Ø³Ø±ÙˆÛŒØ³ Ø¯ÙˆØ¨Ø§Ø±Ù‡ ØªÚ©Ù…ÛŒÙ„ Ù…ÛŒâ€ŒØ´ÙˆØ¯.'],
    ['Ø®Ø¯Ù…Ø§Øª Ø§ÛŒØ±Ø§Ù†ÛŒ Ø¯Ø§Ø±ÛŒØ¯ØŸ', 'Ø¨Ù„Ù‡. Ù…Ù…Ø¨Ø± Ø§ÛŒØªØ§ØŒ Ø±ÙˆØ¨ÛŒÚ©Ø§ØŒ Ø³Ø±ÙˆØ´ Ù¾Ù„Ø§Ø³ØŒ Ø¨Ù„Ù‡ØŒ Ø¢ÛŒâ€ŒÚ¯Ù¾ØŒ Ú¯Ù¾ Ùˆ Ø¢Ù¾Ø§Ø±Ø§Øª Ø¯Ø± Ø¯Ø³ØªØ±Ø³ Ø§Ø³Øª.'],
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: cInk), title: const Text('Ø³ÙˆØ§Ù„Ø§Øª Ù…ØªØ¯Ø§ÙˆÙ„', style: TextStyle(fontWeight: FontWeight.w700, color: cInk))),
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
