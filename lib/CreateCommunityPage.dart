import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _inviteController = TextEditingController();
  File? _imageFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _createCommunity() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      String imageUrl = '';

      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref(
          'community_logos/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      final docRef = await FirebaseFirestore.instance
          .collection('communities')
          .add({
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim(),
            'logoURL': imageUrl,
            'creatorId': user.uid,
            'createdAt': Timestamp.now(),
            'members': [user.uid],
            'admins': [user.uid],
          });

      // Add invited users (by email)
      final inviteEmail = _inviteController.text.trim();
      if (inviteEmail.isNotEmpty) {
        final query =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: inviteEmail)
                .get();
        if (query.docs.isNotEmpty) {
          await docRef.update({
            'members': FieldValue.arrayUnion([query.docs.first.id]),
          });
        }
      }

      // Add to current user's joinedCommunities
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'joinedCommunities': FieldValue.arrayUnion([docRef.id]),
        },
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Community created!")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Community')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child:
                  _imageFile != null
                      ? CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(_imageFile!),
                      )
                      : const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.camera_alt),
                      ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Community Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inviteController,
              decoration: const InputDecoration(
                labelText: 'Invite Member (email)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _createCommunity,
                  icon: const Icon(Icons.check),
                  label: const Text('Create Community'),
                ),
          ],
        ),
      ),
    );
  }
}
