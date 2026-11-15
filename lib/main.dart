import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

const gold = Color(0xFFD6B36A);
const ink = Color(0xFF090909);
const panel = Color(0xFF171717);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch (_) {}
  runApp(const WindApp());
}

class WindApp extends StatelessWidget {
  const WindApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'WIND',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ink,
      colorScheme: const ColorScheme.dark(primary: gold, secondary: gold, surface: panel),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: panel,
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    ),
    home: const AuthGate(),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) return const PhoneLoginScreen(preview: true);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, s) => s.data == null ? const PhoneLoginScreen() : const MainShell(),
    );
  }
}

class PhoneLoginScreen extends StatefulWidget {
  final bool preview;
  const PhoneLoginScreen({super.key, this.preview = false});
  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}
class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final phone = TextEditingController(), otp = TextEditingController();
  String? verificationId;
  bool sent = false, busy = false;
  void msg(String s) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s))); }
  Future<void> sendOtp() async {
    if (phone.text.trim().length != 10) { msg('10-digit mobile number enter karein.'); return; }
    if (widget.preview || Firebase.apps.isEmpty) { msg('Real OTP ke liye Firebase setup zaroori hai.'); return; }
    setState(() => busy = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${phone.text.trim()}',
        verificationCompleted: (c) async => FirebaseAuth.instance.signInWithCredential(c),
        verificationFailed: (e) => msg(e.message ?? 'OTP send nahi hua.'),
        codeSent: (id, _) { setState(() { verificationId = id; sent = true; }); msg('OTP bhej diya gaya.'); },
        codeAutoRetrievalTimeout: (id) => verificationId = id,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) { msg('Error: $e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> verify() async {
    if (verificationId == null) { msg('Pehle OTP bhejein.'); return; }
    try {
      final c = PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: otp.text.trim());
      await FirebaseAuth.instance.signInWithCredential(c);
    } catch (_) { msg('OTP galat hai ya expire ho gaya.'); }
  }
  @override
  void dispose() { phone.dispose(); otp.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 38),
        const Icon(Icons.air_rounded, color: gold, size: 54),
        const SizedBox(height: 10),
        const Text('WIND', textAlign: TextAlign.center,
          style: TextStyle(color: gold, fontSize: 42, letterSpacing: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Your World. Your People. Your Vibe.',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 54),
        const Text('Welcome to WIND', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Connect, share and discover your world.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 25),
        TextField(controller: phone, keyboardType: TextInputType.phone, maxLength: 10,
          decoration: const InputDecoration(prefixText: '+91  ', hintText: 'Mobile number', counterText: '')),
        if (sent) ...[
          const SizedBox(height: 12),
          TextField(controller: otp, keyboardType: TextInputType.number, maxLength: 6,
            decoration: const InputDecoration(hintText: '6-digit OTP', counterText: '')),
        ],
        const SizedBox(height: 18),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: ink, padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: busy ? null : (sent ? verify : sendOtp),
          child: Text(busy ? 'PLEASE WAIT...' : (sent ? 'VERIFY OTP' : 'CONTINUE WITH MOBILE')),
        ),
        const SizedBox(height: 16),
        const Text('By continuing, you agree to our Terms & Privacy Policy.',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
        if (widget.preview) const Padding(padding: EdgeInsets.only(top: 22),
          child: Text('PREVIEW MODE • Firebase setup required for real OTP',
            textAlign: TextAlign.center, style: TextStyle(color: gold, fontSize: 11))),
      ]),
    ))),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [FeedScreen(), SearchScreen(), CreateScreen(), ActivityScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: ink,
      title: const Text('WIND', style: TextStyle(color: gold, letterSpacing: 5, fontWeight: FontWeight.w800)),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline))],
    ),
    body: pages[index],
    bottomNavigationBar: NavigationBar(
      backgroundColor: panel, indicatorColor: gold.withOpacity(.16),
      selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.add_box_outlined), label: 'Create'),
        NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Activity'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ),
  );
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(children: [
    SizedBox(height: 104, child: ListView(scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      children: const [Story(label: 'Your story', own: true), Story(label: 'Aarav'),
        Story(label: 'Meera'), Story(label: 'Kabir'), Story(label: 'Anaya')])),
    const Divider(color: Colors.white12),
    const PostCard(user: 'wind_official', caption: 'A fresh space to connect, share and discover. Welcome to WIND. ✨'),
    const PostCard(user: 'your_daily_vibe', caption: 'Your world. Your people. Your vibe. 🖤'),
    const Padding(padding: EdgeInsets.all(24), child: Text('You’re all caught up for now.',
      textAlign: TextAlign.center, style: TextStyle(color: Colors.white38))),
  ]);
}
class Story extends StatelessWidget {
  final String label; final bool own;
  const Story({super.key, required this.label, this.own = false});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(right: 16),
    child: Column(children: [
      Container(width: 58, height: 58, padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gold, width: 1.5)),
        child: CircleAvatar(backgroundColor: panel, child: own ? const Icon(Icons.add, color: gold)
          : Text(label[0], style: const TextStyle(color: gold, fontSize: 20)))),
      const SizedBox(height: 5), Text(label, style: const TextStyle(fontSize: 11)),
    ]));
}
class PostCard extends StatefulWidget {
  final String user, caption;
  const PostCard({super.key, required this.user, required this.caption});
  @override
  State<PostCard> createState() => _PostCardState();
}
class _PostCardState extends State<PostCard> {
  bool liked = false;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    ListTile(leading: const CircleAvatar(backgroundColor: panel, child: Icon(Icons.person, color: gold)),
      title: Text(widget.user, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: const Text('WIND community', style: TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: const Icon(Icons.more_horiz)),
    Container(height: 270, margin: const EdgeInsets.symmetric(horizontal: 12), width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF302719), Color(0xFF101010), Color(0xFF29231A)])),
      child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.air, color: gold, size: 40), SizedBox(height: 12),
        Text('WIND', style: TextStyle(color: gold, fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.bold)),
        Text('YOUR WORLD • YOUR VIBE', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2)),
      ]))),
    Row(children: [
      IconButton(onPressed: () => setState(() => liked = !liked),
        icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.redAccent : Colors.white)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.mode_comment_outlined)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.send_outlined)),
      const Spacer(), IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
    ]),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(liked ? '1 like' : 'Be the first to like this', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
    Padding(padding: const EdgeInsets.fromLTRB(16, 7, 16, 18),
      child: Text.rich(TextSpan(children: [
        TextSpan(text: '${widget.user}  ', style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: widget.caption),
      ]))),
    const Divider(color: Colors.white10),
  ]);
}
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Discover', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18),
      const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search people and posts')),
      const SizedBox(height: 24), const Text('Explore WIND', style: TextStyle(color: gold, fontSize: 16)),
      const SizedBox(height: 8), const Text('Discover creators, friends and new perspectives.', style: TextStyle(color: Colors.white60)),
    ]));
}
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.add_a_photo_outlined, color: gold, size: 54), SizedBox(height: 16),
    Text('Create a post', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
    SizedBox(height: 8), Padding(padding: EdgeInsets.all(20), child: Text('Photo and video uploads are planned for the next build.',
      textAlign: TextAlign.center, style: TextStyle(color: Colors.white60))),
  ]));
}
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.notifications_none, color: gold, size: 48), SizedBox(height: 12),
    Text('Activity'), SizedBox(height: 6),
    Text('Your notifications will appear here.', style: TextStyle(color: Colors.white60)),
  ]));
}
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const SizedBox(height: 12),
    const Center(child: CircleAvatar(radius: 42, backgroundColor: panel, child: Icon(Icons.person, color: gold, size: 42))),
    const SizedBox(height: 12),
    const Text('Your Name', textAlign: TextAlign.center, style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const Text('@your_username', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
    const SizedBox(height: 20),
    const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Stat(label: 'Posts', value: '0'), Stat(label: 'Followers', value: '0'), Stat(label: 'Following', value: '0')]),
    const SizedBox(height: 22), OutlinedButton(onPressed: () {}, child: const Text('Edit profile')),
    const SizedBox(height: 12),
    OutlinedButton(onPressed: () async { if (Firebase.apps.isNotEmpty) await FirebaseAuth.instance.signOut(); },
      child: const Text('Log out')),
  ]);
}
class Stat extends StatelessWidget {
  final String label, value;
  const Stat({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    Text(label, style: const TextStyle(color: Colors.white60)),
  ]);
}
