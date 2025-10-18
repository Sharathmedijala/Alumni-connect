import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CommunityFeedPage.dart';
import 'CommunityDetailPage.dart';
import 'MentoringPage.dart';
import 'ProfilePage.dart';

class CommunitiesPage extends StatefulWidget {
  const CommunitiesPage({super.key});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on CommunitiesPage
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MentoringPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communities')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'My Communities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 140,
            child: StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var userData =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                var joined = List<String>.from(
                  userData['joinedCommunities'] ?? [],
                );

                if (joined.isEmpty) {
                  return const Center(child: Text("No communities joined."));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: joined.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('communities')
                              .doc(joined[index])
                              .get(),
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox();
                        var data =
                            snap.data!.data() as Map<String, dynamic>? ?? {};

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CommunityFeedPage(
                                      communityName:
                                          data['name'] ?? 'Community',
                                      communityId: joined[index],
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              width: 120,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      data['logoURL'] ?? '',
                                    ),
                                    radius: 30,
                                    onBackgroundImageError:
                                        (_, __) => const Icon(Icons.image),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data['name'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Explore Communities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('communities')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data =
                        docs[index].data() as Map<String, dynamic>? ?? {};

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => CommunityDetailPage(
                                  communityId: docs[index].id,
                                ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                data['logoURL'] ?? '',
                              ),
                              radius: 30,
                              onBackgroundImageError:
                                  (_, __) => const Icon(Icons.image),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                data['name'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
