import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MentoringPage extends StatelessWidget {
  const MentoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentoring Opportunities')),
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
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['title'] ?? 'Mentoring'),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: Text(data['mentor'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
