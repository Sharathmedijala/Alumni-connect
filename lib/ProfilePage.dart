import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'googlelogin.dart';
import 'CommunitiesPage.dart';
import 'MentoringPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  bool isLoading = true;
  bool isEditMode = false;
  Map<String, dynamic>? userData;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    userData = doc.data();
    _skillsController.text = userData?['skills'] ?? '';
    _experienceController.text = userData?['experience'] ?? '';
    setState(() => isLoading = false);
  }

  Future<void> _saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'skills': _skillsController.text.trim(),
      'experience': _experienceController.text.trim(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    setState(() => isEditMode = false);
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CommunitiesPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MentoringPage()),
        );
        break;
      case 2:
        break;
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open email app")));
    }
  }

  Future<void> _reportIssue() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: '22bcs064@iiitdwd.ac.in',
      query: Uri.encodeQueryComponent("subject=App Issue Report"),
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch email app")),
      );
    }
  }

  Widget _buildField(
    String label,
    String value,
    TextEditingController controller,
    bool isEditable,
  ) {
    if (!isEditable && value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        isEditable
            ? TextField(
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Enter your $label...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            )
            : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.trim(),
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const GoogleLogin()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                user.photoURL ?? '',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.displayName ?? "No Name",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.email ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Joined Communities: ${userData?['joinedCommunities']?.length ?? 0}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildField(
                      "Skills",
                      _skillsController.text,
                      _skillsController,
                      isEditMode,
                    ),
                    _buildField(
                      "Experience",
                      _experienceController.text,
                      _experienceController,
                      isEditMode,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isEditMode) {
                          _saveProfile();
                        } else {
                          setState(() => isEditMode = true);
                        }
                      },
                      icon: Icon(isEditMode ? Icons.save : Icons.edit),
                      label: Text(isEditMode ? "Save Changes" : "Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isEditMode ? Colors.green : Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// 📬 Help Section
                    Card(
                      color: Colors.deepPurple[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Need Help?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "For support, contact us at:",
                              style: TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap:
                                  () => _launchEmail("22bcs064@iiitdwd.ac.in"),
                              child: const Text(
                                "📧 22bcs064@iiitdwd.ac.in",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () => _launchEmail("22bcs069@iiitdwd.ac.in"),
                              child: const Text(
                                "📧 22bcs069@iiitdwd.ac.in",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _reportIssue,
                              icon: const Icon(Icons.bug_report_outlined),
                              label: const Text("Report an Issue"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Communities',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Mentoring'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
