import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'CommunitiesPage.dart';

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({super.key});

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  User? _user;

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut(); // Always show account picker

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      if (!googleUser.email.endsWith('@iiitdwd.ac.in')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only @iiitdwd.ac.in emails allowed')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final doc = await userRef.get();

        if (!doc.exists) {
          await userRef.set({
            'userId': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoUrl': user.photoURL,
            'joinedCommunities': [],
            'skills': '',
            'experience': '',
          });
        }

        setState(() => _user = user);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CommunitiesPage()),
          );
        }
      }
    } catch (e) {
      print('Sign in failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing in: $e')));
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/home.jpg', fit: BoxFit.cover),
          Container(
            color: Colors.black.withOpacity(0.3), // Optional overlay
          ),
          Center(
            child:
                _user == null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome to AlumniConnect',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black54,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'From college to career — stay connected, stay inspired.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 80), // spacing before button
                        InkWell(
                          onTap: signInWithGoogle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 30,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Colors.grey),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/google_logo.png',
                                  height: 28,
                                ),
                                const SizedBox(width: 14),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(_user!.photoURL ?? ''),
                          radius: 45,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Hello, ${_user!.displayName}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: signOut,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text("Sign out"),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
