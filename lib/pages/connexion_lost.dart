// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'package:medilink_app/main.dart';

class OfflinePage extends StatefulWidget {
  const OfflinePage({super.key});

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage>
    with SingleTickerProviderStateMixin {
  bool _isConnected = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Animation controller pour Lottie
    _controller = AnimationController(vsync: this);

    // Écoute de la connexion en temps réel
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
              if (result != ConnectivityResult.none) {
                setState(() {
                  _isConnected = result != ConnectivityResult.none;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AuthWrapper()),
                );
              }
            })
            as StreamSubscription<ConnectivityResult>;
    // Vérif initiale
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A7BD5), Color(0xFF00d2ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation Lottie ou Image
              SizedBox(
                width: width * 0.6,
                height: width * 0.6,
                child: Lottie.asset(
                  'assets/lotties/offline.json', // ← mets ton fichier lottie
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..repeat();
                  },
                ),
              ),
              const SizedBox(height: 32),

              Text(
                _isConnected
                    ? "Vous êtes de retour en ligne !"
                    : "Pas de connexion",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isConnected
                    ? "Votre connexion Internet fonctionne à nouveau."
                    : "Vérifiez votre Wi-Fi ou vos données mobiles et réessayez.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.045,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),

              // Bouton Réessayer
              ElevatedButton(
                onPressed: _checkConnection,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3A7BD5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  "Réessayer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Petit footer
              Text(
                "MediLink App",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: width * 0.035,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
