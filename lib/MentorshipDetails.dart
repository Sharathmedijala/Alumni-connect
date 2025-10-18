import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MentorshipDetails extends StatelessWidget {
  final String title;
  final String description;
  final String mentor;
  final String meetLink;
  final String time;

  const MentorshipDetails({
    super.key,
    required this.title,
    required this.description,
    required this.mentor,
    required this.meetLink,
    required this.time,
  });

  void _launchURL(BuildContext context) async {
    final uri = Uri.parse(meetLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the meet link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mentorship Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼️ Top Image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/mentring.jpg',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 📚 Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 👤 Mentor
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        mentor,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 30, thickness: 1),

                  // 📝 Description
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // 🔗 Meet Link
                  Text(
                    "Meet Link",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _launchURL(context),
                    child: Text(
                      meetLink,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ⏰ Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      Text(time, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
