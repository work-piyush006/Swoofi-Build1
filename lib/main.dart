import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SwoofiApp());
}

class SwoofiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swoofi Support App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF9C27B0),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF9C27B0),
          secondary: Color(0xFFE1BEE7),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF9C27B0),
          foregroundColor: Colors.white,
        ),
      ),
      home: SplashScreen(),
    );
  }
}

//////////////////////////////////////
// Splash Screen
//////////////////////////////////////
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bubble_chart, size: 80, color: Color(0xFF9C27B0)),
            SizedBox(height: 20),
            Text("Swoofi",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0))),
            SizedBox(height: 8),
            Text("Connecting Creators • Inspiring Growth",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////
// Home Screen
//////////////////////////////////////
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList("profiles") ?? [];
    setState(() {
      profiles = saved.map((e) => Map<String, dynamic>.fromUri(Uri.parse(e))).toList();
    });
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      "profiles",
      profiles.map((e) => Uri(queryParameters: e).toString()).toList(),
    );
  }

  void _addProfile(Map<String, dynamic> profile) {
    if (profiles.length >= 10) return;
    setState(() {
      profiles.add(profile);
    });
    _saveProfiles();
  }

  void _editProfile(int index, Map<String, dynamic> profile) {
    setState(() {
      profiles[index] = profile;
    });
    _saveProfiles();
  }

  void _deleteProfile(int index) {
    setState(() {
      profiles.removeAt(index);
    });
    _saveProfiles();
  }

  final List<Widget> _pages = [];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _launchLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPages = [
      ProfileListPage(profiles: profiles, onRefresh: _loadProfiles),
      WebsitePage(),
      RateUsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Swoofi Support App"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminLoginPage(
                    profiles: profiles,
                    onAdd: _addProfile,
                    onEdit: _editProfile,
                    onDelete: _deleteProfile,
                  ),
                ),
              ).then((_) => _loadProfiles());
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.black12,
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(text: "ALL RIGHTS RESERVED TO "),
                  TextSpan(
                      text: "@myswoofi",
                      style: TextStyle(
                          color: Color(0xFF9C27B0),
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => _launchLink("https://instagram.com/myswoofi")),
                  TextSpan(text: " or "),
                  TextSpan(
                      text: "Swoofi.app",
                      style: TextStyle(
                          color: Color(0xFF9C27B0),
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _launchLink("https://swoofi.app")),
                ],
              ),
            ),
          ),
          Expanded(child: userPages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Color(0xFF9C27B0),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "Profiles"),
          BottomNavigationBarItem(icon: Icon(Icons.language), label: "Website"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Rate Us"),
        ],
      ),
    );
  }
}

//////////////////////////////////////
// Profile List + Details
//////////////////////////////////////
class ProfileListPage extends StatelessWidget {
  final List<Map<String, dynamic>> profiles;
  final VoidCallback onRefresh;

  ProfileListPage({required this.profiles, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return Center(child: Text("No profiles added yet"));
    }
    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (_, i) {
        final p = profiles[i];
        return ListTile(
          title: Text(p["name"] ?? "Unnamed"),
          subtitle: Text(p["dailyPost"]?.isNotEmpty == true
              ? "Daily Post Available"
              : "Links aren't set by admin yet"),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileDetailPage(profile: p),
              ),
            );
          },
        );
      },
    );
  }
}

class ProfileDetailPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  ProfileDetailPage({required this.profile});

  Future<void> _launchLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(profile["name"] ?? "Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daily Post Link:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            profile["dailyPost"]?.isNotEmpty == true
                ? InkWell(
                    child: Text(profile["dailyPost"],
                        style: TextStyle(color: Colors.blue)),
                    onTap: () => _launchLink(profile["dailyPost"]),
                  )
                : Text("Links aren't set by admin yet"),
            SizedBox(height: 20),
            Text("Latest Month Contest Entry:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            for (int i = 1; i <= 8; i++)
              if ((profile["contest$i"] ?? "").isNotEmpty)
                ListTile(
                  leading: Text("$i."),
                  title: InkWell(
                    child: Text(profile["contest$i"],
                        style: TextStyle(color: Colors.blue)),
                    onTap: () => _launchLink(profile["contest$i"]),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////
// Website Page
//////////////////////////////////////
class WebsitePage extends StatelessWidget {
  final String website = "https://swoofi.app";
  Future<void> _launchLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)),
        onPressed: () => _launchLink(website),
        child: Text("Visit Website", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

//////////////////////////////////////
// Rate Us Page (internal)
//////////////////////////////////////
class RateUsPage extends StatefulWidget {
  @override
  _RateUsPageState createState() => _RateUsPageState();
}

class _RateUsPageState extends State<RateUsPage> {
  double rating = 0;
  final TextEditingController feedbackCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("Rate Us", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return IconButton(
                icon: Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    rating = i + 1.0;
                  });
                },
              );
            }),
          ),
          SizedBox(height: 20),
          TextField(
            controller: feedbackCtrl,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Write your feedback...",
            ),
            maxLines: 3,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Thanks for your feedback!")),
              );
            },
            child: Text("Submit", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

//////////////////////////////////////
// Admin Panel
//////////////////////////////////////
class AdminLoginPage extends StatefulWidget {
  final List<Map<String, dynamic>> profiles;
  final Function(Map<String, dynamic>) onAdd;
  final Function(int, Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  AdminLoginPage(
      {required this.profiles,
      required this.onAdd,
      required this.onEdit,
      required this.onDelete});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loggedIn = false;

  void _checkLogin() {
    if (userCtrl.text == "Manii@2022" && passCtrl.text == "Piyush@2009") {
      setState(() => loggedIn = true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid credentials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text("Admin Login")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: userCtrl, decoration: InputDecoration(labelText: "Username")),
              TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: "Password")),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)),
                onPressed: _checkLogin,
                child: Text("Login", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    return AdminPanel(
      profiles: widget.profiles,
      onAdd: widget.onAdd,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
    );
  }
}

class AdminPanel extends StatelessWidget {
  final List<Map<String, dynamic>> profiles;
  final Function(Map<String, dynamic>) onAdd;
  final Function(int, Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  AdminPanel(
      {required this.profiles,
      required this.onAdd,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: ListView(
        children: [
          for (int i = 0; i < profiles.length; i++)
            ListTile(
              title: Text(profiles[i]["name"] ?? "Unnamed"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileForm(
                                  profile: profiles[i],
                                  onSave: (data) => onEdit(i, data))),
                        );
                      }),
                  IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(i)),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: profiles.length < 10
          ? FloatingActionButton(
              backgroundColor: Color(0xFF9C27B0),
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ProfileForm(onSave: (data) => onAdd(data))),
                );
              },
            )
          : null,
    );
  }
}

class ProfileForm extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final Function(Map<String, dynamic>) onSave;

  ProfileForm({this.profile, required this.onSave});

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final nameCtrl = TextEditingController();
  final dailyCtrl = TextEditingController();
  final contestCtrls = List.generate(8, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      nameCtrl.text = widget.profile!["name"] ?? "";
      dailyCtrl.text = widget.profile!["dailyPost"] ?? "";
      for (int i = 0; i < 8; i++) {
        contestCtrls[i].text = widget.profile!["contest${i + 1}"] ?? "";
      }
    }
  }

  void _save() {
    final data = {
      "name": nameCtrl.text,
      "dailyPost": dailyCtrl.text,
      for (int i = 0; i < 8; i++) "contest${i + 1}": contestCtrls[i].text,
    };
    widget.onSave(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Form")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Name")),
          TextField(controller: dailyCtrl, decoration: InputDecoration(labelText: "Daily Post Link")),
          for (int i = 0; i < 8; i++)
            TextField(controller: contestCtrls[i], decoration: InputDecoration(labelText: "Contest Entry ${i + 1}")),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)),
            onPressed: _save,
            child: Text("Save", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
