import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'CommunitiesPage.dart'; // 👈 Import this

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({super.key});

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  User? _user;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      setState(() {
        _user = userCredential.user;
      });

      // Navigate to CommunitiesPage after sign in
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CommunitiesPage()),
        );
      }
    } catch (e) {
      print('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Sign-In")),
      body: Center(
        child:
            _user == null
                ? ElevatedButton(
                  onPressed: signInWithGoogle,
                  child: const Text("Sign in with Google"),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(_user!.photoURL ?? ''),
                      radius: 40,
                    ),
                    const SizedBox(height: 10),
                    Text("Hello, ${_user!.displayName}"),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: signOut,
                      child: const Text("Sign out"),
                    ),
                  ],
                ),
      ),
    );
  }
}
