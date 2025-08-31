import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SwoofiApp());
}

class SwoofiApp extends StatelessWidget {
  const SwoofiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Swoofi Support App",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF9C27B0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> profiles = [];

  @override
  void initState() {
    super.initState();
    loadProfiles();
  }

  Future<void> saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = profiles.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('profiles', data);
  }

  Future<void> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? saved = prefs.getStringList('profiles');
    if (saved != null) {
      profiles = saved.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    }
    setState(() {});
  }

  void _openLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _openAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminLogin(
          onProfilesUpdated: (updated) {
            setState(() {
              profiles = updated;
            });
            saveProfiles();
          },
          profiles: profiles,
        ),
      ),
    );
  }

  void _openRateUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RateUsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swoofi Support App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_rate),
            onPressed: _openRateUs,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openAdminLogin,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.deepPurple.shade50,
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    const TextSpan(text: "ALL RIGHTS RESERVED TO "),
                    TextSpan(
                      text: "@myswoofi ",
                      style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _openLink("https://instagram.com/myswoofi");
                        },
                    ),
                    const TextSpan(text: "or "),
                    TextSpan(
                      text: "Swoofi.app",
                      style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _openLink("https://swoofi.app");
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: profiles.isEmpty
                ? const Center(child: Text("No profiles available"))
                : ListView.builder(
                    itemCount: profiles.length.clamp(0, 10),
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      return ListTile(
                        title: Text(profile["name"] ?? "Unnamed"),
                        subtitle: Text(profile["dailyPost"]?.isNotEmpty == true
                            ? "Daily Post Link available"
                            : "Links aren't set by admin yet"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDetailPage(profile: profile),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ProfileDetailPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  const ProfileDetailPage({super.key, required this.profile});

  void _openLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> contestEntries = profile["contestEntries"] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(profile["name"] ?? "Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Daily Post Link", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            profile["dailyPost"]?.isNotEmpty == true
                ? InkWell(
                    onTap: () => _openLink(profile["dailyPost"]),
                    child: Text(profile["dailyPost"], style: const TextStyle(color: Colors.blue)),
                  )
                : const Text("Links aren't set by admin yet"),
            const SizedBox(height: 20),
            const Text("Latest Month Contest Entries", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...contestEntries.map((e) => InkWell(
                  onTap: () => _openLink(e.toString()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(e.toString(), style: const TextStyle(color: Colors.blue)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class AdminLogin extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onProfilesUpdated;
  final List<Map<String, dynamic>> profiles;
  const AdminLogin({super.key, required this.onProfilesUpdated, required this.profiles});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? error;

  void _login() {
    if (_userCtrl.text == "Manii@2022" && _passCtrl.text == "Piyush@2009") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminPanel(
            profiles: widget.profiles,
            onProfilesUpdated: widget.onProfilesUpdated,
          ),
        ),
      );
    } else {
      setState(() {
        error = "Invalid username or password!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
            if (error != null) Padding(padding: const EdgeInsets.all(8.0), child: Text(error!, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}

class AdminPanel extends StatefulWidget {
  final List<Map<String, dynamic>> profiles;
  final Function(List<Map<String, dynamic>>) onProfilesUpdated;
  const AdminPanel({super.key, required this.profiles, required this.onProfilesUpdated});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late List<Map<String, dynamic>> profiles;

  @override
  void initState() {
    super.initState();
    profiles = List.from(widget.profiles);
  }

  void _addOrEditProfile({Map<String, dynamic>? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?["name"]);
    final dailyCtrl = TextEditingController(text: existing?["dailyPost"]);
    final contestCtrl = TextEditingController(text: existing?["contestEntries"]?.join("\n") ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? "Add Profile" : "Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: dailyCtrl, decoration: const InputDecoration(labelText: "Daily Post Link")),
              TextField(controller: contestCtrl, decoration: const InputDecoration(labelText: "Contest Entries (1 per line)"), maxLines: 5),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final profile = {
                "name": nameCtrl.text,
                "dailyPost": dailyCtrl.text,
                "contestEntries": contestCtrl.text.split("\n").where((e) => e.trim().isNotEmpty).toList(),
              };
              setState(() {
                if (existing != null && index != null) {
                  profiles[index] = profile;
                } else if (profiles.length < 10) {
                  profiles.add(profile);
                }
              });
              widget.onProfilesUpdated(profiles);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteProfile(int index) {
    setState(() {
      profiles.removeAt(index);
    });
    widget.onProfilesUpdated(profiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          return ListTile(
            title: Text(profile["name"] ?? "Unnamed"),
            subtitle: Text(profile["dailyPost"] ?? ""),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _addOrEditProfile(existing: profile, index: index)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteProfile(index)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: profiles.length < 10
          ? FloatingActionButton(onPressed: () => _addOrEditProfile(), child: const Icon(Icons.add))
          : null,
    );
  }
}

class RateUsPage extends StatelessWidget {
  const RateUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rate Us")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Rate your experience with Swoofi Support App:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => const Icon(Icons.star, color: Colors.amber, size: 36),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thanks for rating us!")));
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
