import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() {
  runApp(SwoofiApp());
}

class SwoofiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swoofi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF9C27B0),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF9C27B0),
          elevation: 1,
          titleTextStyle: TextStyle(
            color: Color(0xFF9C27B0),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF9C27B0),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on, size: 80, color: Color(0xFF9C27B0)), // Replace with logo asset
            SizedBox(height: 20),
            Text("Swoofi",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0))),
            SizedBox(height: 10),
            Text("Connecting Creators, Inspiring Futures",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [HomeScreen(), SocialPage(), WebsitePage(), RateUsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Social"),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: "Website"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Rate Us"),
        ],
      ),
    );
  }
}

// ================= HOME SCREEN =================
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("profiles");
    if (data != null) {
      setState(() {
        profiles = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("profiles", jsonEncode(profiles));
  }

  void _openAdminLogin() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController userCtrl = TextEditingController();
        TextEditingController passCtrl = TextEditingController();
        return AlertDialog(
          title: Text("Admin Login"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: userCtrl, decoration: InputDecoration(labelText: "Username")),
              TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Login"),
              onPressed: () {
                if (userCtrl.text == "Manii@2022" && passCtrl.text == "Piyush@2009") {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPanel(profiles, _updateProfiles)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid credentials")));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateProfiles(List<Map<String, dynamic>> updated) {
    setState(() => profiles = updated);
    _saveProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            final url = Uri.parse("https://swoofi.app");
            if (await canLaunchUrl(url)) launchUrl(url);
          },
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                    text: "ALL RIGHTS RESERVED TO ",
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: "@myswoofi ",
                    style: TextStyle(color: Color(0xFF9C27B0)),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = Uri.parse("https://instagram.com/myswoofi");
                        if (await canLaunchUrl(url)) launchUrl(url);
                      }),
                TextSpan(
                    text: "or ",
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: "Swoofi.app",
                    style: TextStyle(color: Color(0xFF9C27B0)),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = Uri.parse("https://swoofi.app");
                        if (await canLaunchUrl(url)) launchUrl(url);
                      }),
              ],
            ),
          ),
        ),
        actions: [IconButton(icon: Icon(Icons.settings), onPressed: _openAdminLogin)],
      ),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(profile["name"] ?? "Unnamed"),
              subtitle: Text("Tap to view details"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileDetailPage(profile)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// =============== PROFILE DETAIL =================
class ProfileDetailPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  ProfileDetailPage(this.profile);

  @override
  Widget build(BuildContext context) {
    List<dynamic> entries = profile["entries"] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text(profile["name"] ?? "Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daily Post Link:", style: TextStyle(fontWeight: FontWeight.bold)),
            profile["postLink"] != null && profile["postLink"].toString().isNotEmpty
                ? InkWell(
                    child: Text(profile["postLink"], style: TextStyle(color: Color(0xFF9C27B0))),
                    onTap: () async {
                      final url = Uri.parse(profile["postLink"]);
                      if (await canLaunchUrl(url)) launchUrl(url);
                    },
                  )
                : Text("Links aren't set by admin yet"),
            SizedBox(height: 20),
            Text("Latest Month Contest Entries:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...entries.map((e) => InkWell(
                  child: Text("• ${e["title"]} (As on ${e["date"]})",
                      style: TextStyle(color: Color(0xFF9C27B0))),
                  onTap: () async {
                    final url = Uri.parse(e["link"]);
                    if (await canLaunchUrl(url)) launchUrl(url);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ================= ADMIN PANEL =================
class AdminPanel extends StatefulWidget {
  final List<Map<String, dynamic>> profiles;
  final Function(List<Map<String, dynamic>>) onSave;

  AdminPanel(this.profiles, this.onSave);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late List<Map<String, dynamic>> profiles;

  @override
  void initState() {
    super.initState();
    profiles = List<Map<String, dynamic>>.from(widget.profiles);
  }

  void _addProfile() {
    if (profiles.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Max 10 profiles allowed")));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileForm(onSave: (profile) {
          setState(() {
            profiles.add(profile);
          });
          widget.onSave(profiles);
        })));
  }

  void _editProfile(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileForm(
          profile: profiles[index],
          onSave: (updated) {
            setState(() {
              profiles[index] = updated;
            });
            widget.onSave(profiles);
          },
        ),
      ),
    );
  }

  void _deleteProfile(int index) {
    setState(() {
      profiles.removeAt(index);
    });
    widget.onSave(profiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(profile["name"] ?? "Unnamed"),
              subtitle: Text("Tap to edit"),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteProfile(index),
              ),
              onTap: () => _editProfile(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF9C27B0),
        onPressed: _addProfile,
      ),
    );
  }
}

// =============== PROFILE FORM =================
class ProfileForm extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final Function(Map<String, dynamic>) onSave;

  ProfileForm({this.profile, required this.onSave});

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController postCtrl = TextEditingController();
  List<Map<String, String>> entries = [];

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      nameCtrl.text = widget.profile!["name"] ?? "";
      postCtrl.text = widget.profile!["postLink"] ?? "";
      entries = List<Map<String, String>>.from(widget.profile!["entries"] ?? []);
    }
  }

  void _addEntry() {
    TextEditingController titleCtrl = TextEditingController();
    TextEditingController linkCtrl = TextEditingController();
    TextEditingController dateCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Contest Entry"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: linkCtrl, decoration: InputDecoration(labelText: "Link")),
            TextField(controller: dateCtrl, decoration: InputDecoration(labelText: "Date")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  entries.add({"title": titleCtrl.text, "link": linkCtrl.text, "date": dateCtrl.text});
                });
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }

  void _saveProfile() {
    final profile = {
      "name": nameCtrl.text,
      "postLink": postCtrl.text,
      "entries": entries,
    };
    widget.onSave(profile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.profile == null ? "Add Profile" : "Edit Profile")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Profile Name")),
            TextField(controller: postCtrl, decoration: InputDecoration(labelText: "Daily Post Link")),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addEntry,
              icon: Icon(Icons.add),
              label: Text("Add Contest Entry"),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  return ListTile(
                    title: Text(e["title"] ?? ""),
                    subtitle: Text("As on ${e["date"]}"),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text("Save"),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SOCIAL PAGE =================
class SocialPage extends StatelessWidget {
  final List<String> handles = [
    "https://instagram.com/handle1",
    "https://instagram.com/handle2",
    "https://instagram.com/handle3",
    "https://instagram.com/handle4",
    "https://instagram.com/handle5",
    "https://instagram.com/handle6",
    "https://instagram.com/handle7",
    "https://instagram.com/handle8",
    "https://instagram.com/handle9",
    "https://instagram.com/handle10",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Follow us on Social Media")),
      body: ListView(
        children: handles
            .map((h) => ListTile(
                  title: Text(h),
                  onTap: () async {
                    final url = Uri.parse(h);
                    if (await canLaunchUrl(url)) launchUrl(url);
                  },
                ))
            .toList(),
      ),
    );
  }
}

// ================= WEBSITE PAGE =================
class WebsitePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Swoofi Website")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final url = Uri.parse("https://swoofi.app");
            if (await canLaunchUrl(url)) launchUrl(url);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)),
          child: Text("Visit swoofi.app"),
        ),
      ),
    );
  }
}

// ================= RATE US PAGE =================
class RateUsPage extends StatefulWidget {
  @override
  _RateUsPageState createState() => _RateUsPageState();
}

class _RateUsPageState extends State<RateUsPage> {
  int rating = 0;
  TextEditingController feedbackCtrl = TextEditingController();

  void _submit() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("rating", rating);
    prefs.setString("feedback", feedbackCtrl.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Thanks for your feedback!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rate Us")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("How would you rate Swoofi?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  icon: Icon(Icons.star, color: i < rating ? Color(0xFF9C27B0) : Colors.grey),
                  onPressed: () => setState(() => rating = i + 1),
                );
              }),
            ),
            TextField(controller: feedbackCtrl, decoration: InputDecoration(labelText: "Write feedback (optional)")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)),
