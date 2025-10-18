import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MentorshipDetails.dart';
import 'CommunitiesPage.dart';
import 'ProfilePage.dart';

class MentoringPage extends StatefulWidget {
  const MentoringPage({super.key});

  @override
  State<MentoringPage> createState() => _MentoringPageState();
}

class _MentoringPageState extends State<MentoringPage> {
  int _selectedIndex = 1; // Mentoring is at index 1

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
        // Already on MentoringPage, do nothing
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentoring Sessions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('mentoring').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No mentoring opportunities yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => MentorshipDetails(
                            title: data['title'] ?? 'Mentoring',
                            description: data['description'] ?? '',
                            mentor: data['mentor'] ?? '',
                            meetLink: data['meetLink'] ?? '',
                            time: data['time'] ?? '',
                          ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['title'] ?? 'Mentoring',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mentor: ${data['mentor'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              data['time'] ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
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
