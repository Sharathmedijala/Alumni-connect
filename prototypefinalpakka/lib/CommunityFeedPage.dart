import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommunityFeedPage extends StatefulWidget {
  final String communityName;
  final String communityId;

  const CommunityFeedPage({
    super.key,
    required this.communityName,
    required this.communityId,
  });

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  final TextEditingController _postController = TextEditingController();

  Future<void> _addPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('posts').add({
      'content': content,
      'createdBy': user.displayName ?? 'Anonymous',
      'communityId': widget.communityId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _postController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.communityName} Feed')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: const InputDecoration(
                      hintText: 'Write a post...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.send), onPressed: _addPost),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .where('communityId', isEqualTo: widget.communityId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;

                if (posts.isEmpty) {
                  return const Center(child: Text("No posts yet."));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final content = post['content'] ?? '';
                    final createdBy = post['createdBy'] ?? 'Unknown';
                    final timestamp =
                        post['timestamp'] != null
                            ? (post['timestamp'] as Timestamp).toDate()
                            : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(content),
                        subtitle: Text(
                          'By $createdBy • ${timestamp != null ? timestamp.toLocal().toString().split('.')[0] : 'Just now'}',
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
    );
  }
}
