import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReplyPage extends StatefulWidget {
  final String postId;
  final String content;
  final String createdBy;
  final Timestamp? timestamp;

  const ReplyPage({
    super.key,
    required this.postId,
    required this.content,
    required this.createdBy,
    required this.timestamp,
  });

  @override
  State<ReplyPage> createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {
  final TextEditingController _replyController = TextEditingController();

  Future<void> _addReply() async {
    final replyText = _replyController.text.trim();
    if (replyText.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('replies')
        .add({
          'replyText': replyText,
          'repliedBy': user.displayName ?? 'Anonymous',
          'timestamp': FieldValue.serverTimestamp(),
        });

    _replyController.clear();
  }

  Future<void> _likePost() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .doc(userId);

    final doc = await likeRef.get();
    if (doc.exists) {
      await likeRef.delete(); // Unlike
    } else {
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    return DateFormat('MMM d, h:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post & Replies")),
      body: Column(
        children: [
          // Post Display
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 40,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.content,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'By ${widget.createdBy} • ${_formatTimestamp(widget.timestamp)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  onPressed: _likePost,
                ),
              ],
            ),
          ),

          // Replies List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('replies')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final replies = snapshot.data?.docs ?? [];

                if (replies.isEmpty) {
                  return const Center(
                    child: Text(
                      "No replies yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = replies[index].data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply['replyText'] ?? '',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '- ${reply['repliedBy'] ?? 'Unknown'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Reply Input
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _replyController,
                        decoration: const InputDecoration(
                          hintText: "Write a reply...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _addReply,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
