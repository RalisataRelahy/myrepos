import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:medilink_app/pages/get_started_page.dart';
import 'package:medilink_app/pages/public/main_screen.dart';
import 'package:medilink_app/pages/splash_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      navigatorObservers: [routeObserver],
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashPage();
        }
        final user = snapshot.data;

        if (user == null) {
          return const IntroPage(); // ou LoginPage()
        }
        // L'utilisateur est connecté → on vérifie le rôle (asynchrone)
        return FutureBuilder<Widget>(
          future: _getRoleBasedHome(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return roleSnapshot.data ?? const IntroPage();
          },
        );
      },
    );
  }

  Future<Widget> _getRoleBasedHome(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      await FirebaseAuth.instance.signOut();
      return const IntroPage();
    }

    final role = doc.data()?['role'];

    if (role == 'patient') {
      return MainNavigation(uid: uid);
    }

    if (role == 'doctor') {
      return MainNavigation(uid: uid);
    }

    await FirebaseAuth.instance.signOut();
    return const IntroPage();
  }
}
