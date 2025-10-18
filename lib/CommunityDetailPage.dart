import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityDetailPage extends StatefulWidget {
  final String communityId;

  const CommunityDetailPage({Key? key, required this.communityId})
    : super(key: key);

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  late String userId;
  bool isJoined = false;
  bool loading = true;
  Map<String, dynamic>? communityData;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    loadCommunityData();
  }

  Future<void> loadCommunityData() async {
    var communitySnap =
        await FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId)
            .get();

    var userSnap =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    var joined = List<String>.from(userSnap.data()?['joinedCommunities'] ?? []);
    setState(() {
      communityData = communitySnap.data();
      isJoined = joined.contains(widget.communityId);
      loading = false;
    });
  }

  Future<void> joinCommunity() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'joinedCommunities': FieldValue.arrayUnion([widget.communityId]),
    });

    setState(() {
      isJoined = true;
      loading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Joined community!')));

    // Optional: navigate back to CommunitiesPage after joining
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(communityData?['name'] ?? 'Community')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (communityData?['logoURL'] != null)
              Image.network(
                communityData!['logoURL'],
                height: 100,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(Icons.image),
              ),
            const SizedBox(height: 16),
            Text(
              communityData?['name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              communityData?['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(isJoined ? Icons.check : Icons.group_add),
              label: Text(isJoined ? 'Joined' : 'Join Community'),
              onPressed: isJoined ? null : joinCommunity,
            ),
          ],
        ),
      ),
    );
  }
}
