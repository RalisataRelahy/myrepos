// ignore_for_file: prefer_typing_uninitialized_variables, strict_top_level_inference, deprecated_member_use

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIBanner extends StatefulWidget {
  final currentUser;
  final bool isSmall;
  final bool isTablet;
  const AIBanner({
    super.key,
    required this.currentUser,
    required this.isSmall,
    required this.isTablet,
  });

  @override
  State<AIBanner> createState() => _AIBannerState();
}

class _AIBannerState extends State<AIBanner> {
  String? _risk;
  double? _proba;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _callAiApi();
  }

  Future<void> _callAiApi() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Non connecté';
          _loading = false;
        });
        return;
      }

      final idToken = await user.getIdToken();
      final url = Uri.parse('https://moduleia-production-56.up.railway.app/AI');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK') {
          setState(() {
            _risk = json['level']?.toString();
            _proba = double.tryParse(json['probability']?.toString() ?? '');
            _loading = false;
          });
        } else {
          setState(() {
            _error = 'Résultat indisponible';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Erreur serveur (${response.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur de connexion';
        _loading = false;
      });
    }
  }

  // ── Risk color ──────────────────────────────────────────────────────────

  Color _riskColor(String? risk) {
    switch (risk?.toLowerCase()) {
      case 'low':
      case 'faible':
        return Colors.green.shade400;
      case 'medium':
      case 'moyen':
        return Colors.orange.shade400;
      case 'high':
      case 'élevé':
      case 'eleve':
        return Colors.red.shade400;
      default:
        return Colors.white70;
    }
  }

  String _riskLabel(String? risk) {
    switch (risk?.toLowerCase()) {
      case 'low':
        return 'Faible';
      case 'medium':
        return 'Moyen';
      case 'high':
        return 'Élevé';
      default:
        return risk ?? '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmall = widget.isSmall;
    final bool isTablet = widget.isTablet;

    final double bannerHeight = isSmall
        ? 110
        : isTablet
        ? 160
        : 130;
    final double titleSize = isSmall
        ? 13
        : isTablet
        ? 18
        : 16;
    final double bodySize = isSmall
        ? 11
        : isTablet
        ? 14
        : 12;
    final double badgeSize = isSmall
        ? 58
        : isTablet
        ? 84
        : 70;

    return Container(
      height: bannerHeight,
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A7BFF), Color(0xFF6FA4FF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // ── Left: text ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Votre risque santé",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize,
                  ),
                ),
                SizedBox(height: isSmall ? 4 : 6),
                Text(
                  "Analyse IA personnalisée\nde votre état de santé.",
                  style: TextStyle(
                    color: Colors.grey[100],
                    fontSize: bodySize,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: isSmall ? 8 : 12),

          // ── Right: risk badge ───────────────────────────────────────
          _loading
              ? SizedBox(
                  width: badgeSize,
                  height: badgeSize,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : _error != null
              ? _ErrorBadge(
                  message: _error!,
                  size: badgeSize,
                  fontSize: bodySize - 1,
                  onRetry: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _callAiApi();
                  },
                )
              : _RiskBadge(
                  risk: _riskLabel(_risk),
                  proba: _proba,
                  color: _riskColor(_risk),
                  size: badgeSize,
                  fontSize: bodySize,
                ),
        ],
      ),
    );
  }
}

// ─── Risk badge ───────────────────────────────────────────────────────────────

class _RiskBadge extends StatelessWidget {
  final String risk;
  final double? proba;
  final Color color;
  final double size;
  final double fontSize;

  const _RiskBadge({
    required this.risk,
    required this.proba,
    required this.color,
    required this.size,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final String probaStr = proba != null
        ? '${(proba!).toStringAsFixed(0)}%'
        : '—';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            probaStr,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize + 2,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              risk,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize - 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error badge ──────────────────────────────────────────────────────────────

class _ErrorBadge extends StatelessWidget {
  final String message;
  final double size;
  final double fontSize;
  final VoidCallback onRetry;

  const _ErrorBadge({
    required this.message,
    required this.size,
    required this.fontSize,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, color: Colors.white70, size: 18),
            const SizedBox(height: 2),
            Text(
              'Réessayer',
              style: TextStyle(color: Colors.white70, fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
