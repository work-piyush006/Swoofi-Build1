import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() {
  runApp(const SwoofiApp());
}

class SwoofiApp extends StatelessWidget {
  const SwoofiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swoofi Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Swoofi", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("All rights reserved to @myswoofi"),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('profiles');
    if (data != null) {
      setState(() {
        profiles = jsonDecode(data);
      });
    }
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profiles', jsonEncode(profiles));
  }

  void _openAdminLogin() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController userCtrl = TextEditingController();
        TextEditingController passCtrl = TextEditingController();
        return AlertDialog(
          title: const Text("Admin Login"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "Username")),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (userCtrl.text == "Manii@2022" && passCtrl.text == "PIYUSH@2009") {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen(
                    profiles: profiles,
                    onSave: (newProfiles) {
                      setState(() {
                        profiles = newProfiles;
                      });
                      _saveProfiles();
                    },
                  )));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid login!")));
                }
              },
              child: const Text("Login"),
            ),
          ],
        );
      },
    );
  }

  void _openProfile(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(profile: profiles[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swoofi Profiles"),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _openAdminLogin)
        ],
      ),
      body: profiles.isEmpty
          ? const Center(child: Text("No profiles added yet."))
          : ListView.builder(
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(profiles[index]['name']),
                  onTap: () => _openProfile(index),
                );
              },
            ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  final List profiles;
  final Function(List) onSave;

  const AdminScreen({super.key, required this.profiles, required this.onSave});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late List profiles;

  @override
  void initState() {
    super.initState();
    profiles = List.from(widget.profiles);
  }

  void _editProfile(int? index) {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController dailyPostCtrl = TextEditingController();
    List<TextEditingController> contestCtrls =
        List.generate(8, (index) => TextEditingController());

    if (index != null) {
      var profile = profiles[index];
      nameCtrl.text = profile['name'] ?? '';
      dailyPostCtrl.text = profile['dailyPost'] ?? '';
      for (int i = 0; i < (profile['contestEntries']?.length ?? 0); i++) {
        contestCtrls[i].text = profile['contestEntries'][i];
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "Add Profile" : "Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: dailyPostCtrl, decoration: const InputDecoration(labelText: "Daily Post Link")),
                const SizedBox(height: 10),
                const Text("Contest Entries (up to 8)"),
                for (int i = 0; i < 8; i++)
                  TextField(controller: contestCtrls[i], decoration: InputDecoration(labelText: "Entry ${i + 1}")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Map<String, dynamic> profile = {
                  'name': nameCtrl.text,
                  'dailyPost': dailyPostCtrl.text,
                  'contestEntries': contestCtrls.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
                };

                if (index == null) {
                  if (profiles.length < 10) {
                    profiles.add(profile);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Max 10 profiles allowed.")));
                  }
                } else {
                  profiles[index] = profile;
                }

                widget.onSave(profiles);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(profiles[index]['name']),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editProfile(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editProfile(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfileDetailScreen extends StatelessWidget {
  final Map profile;
  const ProfileDetailScreen({super.key, required this.profile});

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(profile['name'] ?? 'Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Daily Post:", style: TextStyle(fontWeight: FontWeight.bold)),
            profile['dailyPost'] == null || profile['dailyPost'] == ''
                ? const Text("Not set by admin yet")
                : InkWell(
                    onTap: () => _launchUrl(profile['dailyPost']),
                    child: Text(profile['dailyPost'], style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                  ),
            const SizedBox(height: 20),
            const Text("Latest Month Contest Entries:", style: TextStyle(fontWeight: FontWeight.bold)),
            (profile['contestEntries'] as List).isEmpty
                ? const Text("Not set by admin yet")
                : Column(
                    children: (profile['contestEntries'] as List)
                        .map((entry) => InkWell(
                              onTap: () => _launchUrl(entry),
                              child: Text(entry, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
