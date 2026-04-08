import 'package:medilink_app/pages/choose_ur_role.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _logoSlide;
  late Animation<double> _logoFade;
  late Animation<Offset> _imageSlide;
  late Animation<double> _imageFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoSlide = _makeSlide(0.0, 0.2);
    _logoFade = _makeFade(0.0, 0.2);
    _imageSlide = _makeSlide(0.2, 0.4);
    _imageFade = _makeFade(0.2, 0.4);
    _titleSlide = _makeSlide(0.4, 0.6);
    _titleFade = _makeFade(0.4, 0.6);
    _textSlide = _makeSlide(0.6, 0.8);
    _textFade = _makeFade(0.6, 0.8);
    _buttonSlide = _makeSlide(0.8, 1.0);
    _buttonFade = _makeFade(0.8, 1.0);

    _controller.forward();
  }

  Animation<Offset> _makeSlide(double start, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

  Animation<double> _makeFade(double start, double end) =>
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeIn),
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
  ) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Responsive helpers ──────────────────────────────────────────────────
    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;
    final double h = screen.height;

    // Breakpoints
    final bool isSmall = w < 360;
    final bool isMedium = w >= 360 && w < 600;
    final bool isTablet = w >= 600 && w < 900;
    // large / desktop: w >= 900

    // Responsive values
    final double hPad = isSmall
        ? 16
        : isMedium
        ? 24
        : isTablet
        ? 48
        : 80;
    final double logoMaxWidth = isSmall
        ? 90
        : isMedium
        ? 120
        : isTablet
        ? 160
        : 200;
    final double illustrationHeight =
        (h *
                (isSmall
                    ? 0.22
                    : isMedium
                    ? 0.26
                    : isTablet
                    ? 0.30
                    : 0.32))
            .clamp(120.0, 340.0);
    final double titleFontSize = isSmall
        ? 20
        : isMedium
        ? 24
        : isTablet
        ? 28
        : 32;
    final double bodyFontSize = isSmall
        ? 13
        : isMedium
        ? 15
        : isTablet
        ? 17
        : 18;
    final double buttonHPad = isSmall
        ? 32
        : isMedium
        ? 60
        : isTablet
        ? 100
        : 130;
    final double buttonVPad = isSmall ? 12 : 16;
    final double buttonFontSize = isSmall ? 14 : 17;
    final double spacingUnit = h * 0.018; // ~1.8 % of screen height

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: spacingUnit,
              ),
              child: ConstrainedBox(
                // Ensure content fills at least the visible area so it looks
                // centred on large screens / landscape orientation.
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Logo ISPM ──────────────────────────────────────
                      _animated(
                        _logoSlide,
                        _logoFade,
                        Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: logoMaxWidth),
                            child: Image.asset('assets/images/logoIspm.png'),
                          ),
                        ),
                      ),

                      SizedBox(height: spacingUnit * 1.5),

                      // ── Illustration principale ────────────────────────
                      _animated(
                        _imageSlide,
                        _imageFade,
                        SizedBox(
                          width: double.infinity,
                          height: illustrationHeight,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: spacingUnit * 2),

                      // ── Titre ──────────────────────────────────────────
                      _animated(
                        _titleSlide,
                        _titleFade,
                        Text(
                          "Parce que votre santé mérite une connexion directe.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),
                      ),

                      SizedBox(height: spacingUnit),

                      // ── Description ────────────────────────────────────
                      _animated(
                        _textSlide,
                        _textFade,
                        Text(
                          "Nous vous aidons à choisir le meilleur médecin pour vous et à établir une communication simple et efficace.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: bodyFontSize,
                            height: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: spacingUnit * 2.5),

                      // ── Bouton ─────────────────────────────────────────
                      _animated(
                        _buttonSlide,
                        _buttonFade,
                        SizedBox(
                          // Full width on small screens, auto on larger ones
                          width: isSmall || isMedium ? double.infinity : null,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChooseUrRole(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmall || isMedium
                                    ? 0
                                    : buttonHPad,
                                vertical: buttonVPad,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              "Commencer  →",
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: spacingUnit),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
