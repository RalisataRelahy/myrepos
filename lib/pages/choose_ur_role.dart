// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:medilink_app/pages/public/login_page.dart';

class ChooseUrRole extends StatefulWidget {
  const ChooseUrRole({super.key});

  @override
  State<ChooseUrRole> createState() => _ChooseUrRoleState();
}

class _ChooseUrRoleState extends State<ChooseUrRole>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _card1Slide;
  late Animation<double> _card1Fade;
  late Animation<Offset> _card2Slide;
  late Animation<double> _card2Fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleSlide = _makeSlide(0.0, 0.4);
    _titleFade = _makeFade(0.0, 0.4);
    _card1Slide = _makeSlide(0.2, 0.6);
    _card1Fade = _makeFade(0.2, 0.6);
    _card2Slide = _makeSlide(0.4, 0.8);
    _card2Fade = _makeFade(0.4, 0.8);

    _controller.forward();
  }

  Animation<Offset> _makeSlide(double start, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );

  Animation<double> _makeFade(double start, double end) =>
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animated(
    Animation<Offset> slide,
    Animation<double> fade,
    Widget child,
  ) => FadeTransition(
    opacity: fade,
    child: SlideTransition(position: slide, child: child),
  );

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;
    final double h = screen.height;

    final bool isSmall = w < 360;
    final bool isMedium = w >= 360 && w < 600;
    final bool isTablet = w >= 600 && w < 900;
    final bool isDesktop = w >= 900;

    final double hPad = isSmall
        ? 20
        : isMedium
        ? 32
        : isTablet
        ? 80
        : 160;
    final double cardMaxWidth = isDesktop ? 500 : double.infinity;
    final double titleFontSize = isSmall
        ? 28
        : isMedium
        ? 32
        : isTablet
        ? 40
        : 48;
    final double subtitleFontSize = isSmall
        ? 14
        : isMedium
        ? 16
        : 18;
    final double cardSpacing = isSmall ? 16 : 20;
    final double sectionSpacing = h * 0.05;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.6),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: sectionSpacing,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - sectionSpacing * 2,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: cardMaxWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Logo & Header ─────────────────────────────────────────
                          _animated(
                            _titleSlide,
                            _titleFade,
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade600,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.shade200,
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.health_and_safety_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  "MediLink",
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader =
                                          LinearGradient(
                                            colors: [
                                              Colors.blue.shade700,
                                              Colors.blue.shade500,
                                              Colors.cyan.shade600,
                                            ],
                                          ).createShader(
                                            Rect.fromLTWH(0, 0, 200, 50),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Choisissez votre profil",
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 60,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade300,
                                        Colors.blue.shade600,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: sectionSpacing * 1.2),

                          // ── Patient Card ───────────────────────────────────
                          _animated(
                            _card1Slide,
                            _card1Fade,
                            _ModernRoleCard(
                              label: "Patient",
                              subtitle:
                                  "Accédez à vos soins, consultez des médecins, gérez votre santé",
                              icon: Icons.person_rounded,
                              gradientColors: [
                                Colors.blue.shade50,
                                Colors.blue.shade100,
                              ],
                              iconGradient: const [
                                Color(0xFF2196F3),
                                Color(0xFF1976D2),
                              ],
                              onTap: () => _navigateToLogin(context, "Patient"),
                            ),
                          ),

                          SizedBox(height: cardSpacing),

                          // ── Doctor Card ────────────────────────────────────
                          _animated(
                            _card2Slide,
                            _card2Fade,
                            _ModernRoleCard(
                              label: "Docteur",
                              subtitle:
                                  "Gérez vos patients, vos consultations, votre agenda médical",
                              icon: Icons.medical_services_rounded,
                              gradientColors: [
                                Colors.green.shade50,
                                Colors.green.shade100,
                              ],
                              iconGradient: const [
                                Color(0xFF4CAF50),
                                Color(0xFF2E7D32),
                              ],
                              onTap: () => _navigateToLogin(context, "Docteur"),
                            ),
                          ),

                          SizedBox(height: sectionSpacing),

                          // ── Footer ─────────────────────────────────────────
                          Column(
                            children: [
                              Text(
                                "Votre santé, notre priorité",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFooterIcon(
                                    Icons.shield_rounded,
                                    Colors.blue.shade400,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFooterIcon(
                                    Icons.support_agent_rounded,
                                    Colors.green.shade400,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFooterIcon(
                                    Icons.verified_rounded,
                                    Colors.orange.shade400,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  void _navigateToLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            Login(role: role),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.3, 0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }
}

// ── Modern Role Card Widget ──────────────────────────────────────────
class _ModernRoleCard extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Color> iconGradient;
  final VoidCallback onTap;

  const _ModernRoleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.iconGradient,
    required this.onTap,
  });

  @override
  State<_ModernRoleCard> createState() => _ModernRoleCardState();
}

class _ModernRoleCardState extends State<_ModernRoleCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.98 : (_isHovered && isDesktop ? 1.02 : 1.0)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isHovered
                    ? [
                        widget.gradientColors[0],
                        widget.gradientColors[1].withOpacity(0.8),
                      ]
                    : widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color:
                      (_isHovered
                              ? widget.gradientColors[1]
                              : Colors.grey.shade300)
                          .withOpacity(_isHovered ? 0.3 : 0.2),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: Offset(0, _isHovered ? 8 : 4),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Icon Container with Gradient
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.iconGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.iconGradient.first.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.label,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..translate(_isHovered ? 4.0 : 0.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: widget.iconGradient.first,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
