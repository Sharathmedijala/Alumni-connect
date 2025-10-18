import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'reply.dart';

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
  bool _isPosting = false;

  Future<void> _addPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'content': content,
        'createdBy': user.displayName ?? 'Anonymous',
        'userId': user.uid,
        'communityId': widget.communityId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _postController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    return DateFormat('MMM d, h:mm a').format(timestamp.toDate());
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
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Share something...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isPosting
                    ? const CircularProgressIndicator()
                    : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _addPost,
                    ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .where('communityId', isEqualTo: widget.communityId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong."));
                }

                final posts = snapshot.data?.docs ?? [];

                if (posts.isEmpty) {
                  return const Center(child: Text("No posts yet."));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final postData =
                        posts[index].data() as Map<String, dynamic>;
                    final content = postData['content'] ?? '';
                    final createdBy = postData['createdBy'] ?? 'Unknown';
                    final timestamp = postData['timestamp'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ReplyPage(
                                    postId: posts[index].id,
                                    content: content,
                                    createdBy: createdBy,
                                    timestamp: timestamp,
                                  ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  createdBy.isNotEmpty
                                      ? createdBy[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      createdBy,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      content,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
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
            ),
          ),
        ],
      ),
    );
  }
}
