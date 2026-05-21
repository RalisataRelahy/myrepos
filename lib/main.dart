import 'package:flutter/material.dart';
import 'package:medilink_app/pages/get_started_page.dart';
import 'package:medilink_app/pages/public/main_screen.dart';
import 'package:medilink_app/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://efhhcmtwdshrgsltgzqg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVmaGhjbXR3ZHNocmdzbHRnenFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxMTA4NzYsImV4cCI6MjA5NDY4Njg3Nn0.OB7yyDyJPXPWTq8pRLeGIQzVrCRYofwf7xR-JHF0CS4',
  );
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
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {

        // ⏳ loading
        if (!snapshot.hasData) {
          return const SplashPage();
        }

        final session = snapshot.data!.session;
        final user = session?.user;

        // ❌ pas connecté
        if (user == null) {
          return const IntroPage();
        }

        // ✅ connecté → check rôle
        return FutureBuilder<Widget>(
          future: _getRoleBasedHome(user.id),
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
}

  Future<Widget> _getRoleBasedHome(String uid) async {
    final role= await UserService.getRole(uid);
    if (role == 'patient') {
      return MainNavigation(uid: uid);
    }

    if (role == 'doctor') {
      return MainNavigation(uid: uid);
    }

    final supabase=Supabase.instance.client;
    await supabase.auth.signOut();
    return const IntroPage();
  }

