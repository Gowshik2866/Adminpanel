// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/providers/auth_provider.dart';
import 'package:sample_app/providers/theme_provider.dart';
import 'package:sample_app/screen/signup_screen.dart';
import 'package:sample_app/widgets/app_shell.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Typography — Inter · spec-exact sizes
//   Brand Title : 42 px
//   Card Title  : 28 px
//   Input text  : 17 px
//   Hint text   : 16 px
//   Form label  : 15 px
//   Button      : 18 px
//   Footer      : 15 px
// ═══════════════════════════════════════════════════════════════════════════════
const _kFont = 'Inter';

/// Base factory — every TextStyle in the app goes through this.
TextStyle _ts({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double lh = 1.5,
  double ls = 0,
}) => TextStyle(
  fontFamily: _kFont,
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: lh,
  letterSpacing: ls,
);

// ── Named styles (colour always passed at call-site) ──────────────────────────

/// Left-panel brand title
TextStyle _tsBrand({Color? c}) =>
    _ts(size: 42, weight: FontWeight.w800, lh: 1.2, ls: -0.4, color: c);

/// Card heading
TextStyle _tsHeading({Color? c}) =>
    _ts(size: 28, weight: FontWeight.w700, lh: 1.25, ls: -0.2, color: c);

/// Subtitle / descriptive text
TextStyle _tsSub({Color? c}) =>
    _ts(size: 16, weight: FontWeight.w400, lh: 1.6, color: c);

/// Form field label
TextStyle _tsLabel({Color? c}) =>
    _ts(size: 15, weight: FontWeight.w600, lh: 1.4, color: c);

/// Input text
TextStyle _tsInput({Color? c}) =>
    _ts(size: 17, weight: FontWeight.w400, lh: 1.5, color: c);

/// Hint text
TextStyle _tsHint({Color? c}) =>
    _ts(size: 16, weight: FontWeight.w400, lh: 1.5, color: c);

/// Button text
TextStyle _tsBtn() => _ts(size: 18, weight: FontWeight.w500, lh: 1.0, ls: 0.1);

/// Small footer / link
TextStyle _tsFooter({Color? c, FontWeight w = FontWeight.w400}) =>
    _ts(size: 15, weight: w, color: c);

/// Theme-pill label
TextStyle _tsPill({Color? c}) =>
    _ts(size: 14, weight: FontWeight.w600, color: c);

/// Error/banner body
TextStyle _tsBanner({Color? c}) =>
    _ts(size: 15, weight: FontWeight.w500, color: c);

/// Validation error
TextStyle _tsError({Color? c}) => _ts(size: 13, color: c);

// ── Layout constants ──────────────────────────────────────────────────────────
const double _cardW = 620;
const double _cardH = 640;
const double _cardPH = 64; // card horizontal padding
const double _cardPV = 56; // card vertical padding
const double _fieldH = 62; // input min-height
const double _btnH = 60; // button height
const double _iconBox = 60;
const double _cardR = 24; // card radius
const double _fieldR = 12; // field radius
const double _panelPadH = 76; // left panel horizontal padding (72-80 range)
const double _panelPadV = 80; // left panel vertical padding
const double _hTargetPad = 246; // right panel spacer
const double _vTargetPad = 220; // right panel spacer
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _remember = false;
  bool _loading = false;
  String? _error;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, .04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await ref
        .read(authProvider.notifier)
        .authenticate(_emailCtrl.text, _passwordCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err == null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AppShell(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeIn),
            child: c,
          ),
          transitionDuration: const Duration(milliseconds: 380),
        ),
      );
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leftBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEDF2F7);
    final rightBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final brand = cs.primary;

    return Scaffold(
      backgroundColor: rightBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ══════════════════════════════════════════════════════════
              // LEFT PANEL — 42 %
              // ══════════════════════════════════════════════════════════
              Expanded(
                flex: 42,
                child: Container(
                  color: leftBg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: _panelPadH,
                    vertical: _panelPadV,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: brand.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.dashboard_rounded,
                          color: brand,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Brand title — 32 px Inter ExtraBold
                      Text(
                        'StaffAdmin\nDashboard',
                        style: _tsBrand(c: cs.onSurface),
                      ),
                      const SizedBox(height: 18),

                      // Brand subtitle — 16 px Inter Regular
                      Text(
                        'Manage staff, leaves, attendance\nand reports efficiently.',
                        style: _tsSub(c: cs.onSurfaceVariant),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40, bottom: 20),
                          child: Center(
                            child: _OfficeIllustration(
                              isDark: isDark,
                              brand: brand,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ══════════════════════════════════════════════════════════
              // RIGHT PANEL — 58 %
              //  panel  ≈ 1113 px  (1920 × 0.58)
              //  card   =  620 px  → h-pad ≈ 246 px ✓
              //  card h ≈  620 px  → v-pad ≈ 230 px ✓
              // ══════════════════════════════════════════════════════════
              Expanded(
                flex: 58,
                child: Container(
                  color: rightBg,
                  child: LayoutBuilder(
                    builder: (ctx, box) {
                      final vPad = ((box.maxHeight - _cardH) / 2).clamp(
                        _cardPV,
                        _vTargetPad,
                      );
                      final hPad = ((box.maxWidth - _cardW) / 2).clamp(
                        _cardPH,
                        _hTargetPad,
                      );
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: hPad,
                          vertical: vPad,
                        ),
                        child: FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _slide,
                            child: Container(
                              width: _cardW,
                              padding: const EdgeInsets.symmetric(
                                horizontal: _cardPH,
                                vertical: _cardPV,
                              ),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(_cardR),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.40 : 0.09,
                                    ),
                                    blurRadius: 52,
                                    spreadRadius: -6,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: .08)
                                      : Colors.black.withValues(alpha: .06),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Icon
                                  Center(
                                    child: Container(
                                      width: _iconBox,
                                      height: _iconBox,
                                      decoration: BoxDecoration(
                                        color: brand.withValues(alpha: .11),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        Icons.dashboard_rounded,
                                        color: brand,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),

                                  // Heading — 30 px Inter Bold
                                  Text(
                                    'StaffAdmin Dashboard',
                                    textAlign: TextAlign.center,
                                    style: _tsHeading(c: cs.onSurface),
                                  ),
                                  const SizedBox(height: 8),

                                  // Subtitle — 16 px Inter Regular
                                  Text(
                                    'Welcome back! Please sign in to continue.',
                                    textAlign: TextAlign.center,
                                    style: _tsSub(c: cs.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 32),

                                  // Error banner
                                  if (_error != null) ...[
                                    _AlertBanner(
                                      message: _error!,
                                      isError: true,
                                    ),
                                    const SizedBox(height: 22),
                                  ],

                                  // Form
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Label — 14 px Inter SemiBold
                                        _FieldLabel('Email / Username'),
                                        const SizedBox(height: 8),
                                        _AuthField(
                                          controller: _emailCtrl,
                                          hint: 'Enter your email',
                                          icon: Icons.email_outlined,
                                          inputBg: inputBg,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (v) =>
                                              v == null || v.isEmpty
                                              ? 'Required'
                                              : null,
                                          onSubmitted: (_) => _submit(),
                                        ),
                                        const SizedBox(height: 22),

                                        _FieldLabel('Password'),
                                        const SizedBox(height: 8),
                                        _AuthField(
                                          controller: _passwordCtrl,
                                          hint: 'Enter your password',
                                          icon: Icons.lock_outline_rounded,
                                          inputBg: inputBg,
                                          obscureText: _obscure,
                                          onToggleObscure: () => setState(
                                            () => _obscure = !_obscure,
                                          ),
                                          validator: (v) =>
                                              v == null || v.isEmpty
                                              ? 'Required'
                                              : null,
                                          onSubmitted: (_) => _submit(),
                                        ),
                                        const SizedBox(height: 18),

                                        // Remember + Forgot
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: Checkbox(
                                                    value: _remember,
                                                    onChanged: (v) => setState(
                                                      () => _remember =
                                                          v ?? false,
                                                    ),
                                                    activeColor: brand,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    side: BorderSide(
                                                      color: cs.onSurfaceVariant
                                                          .withValues(
                                                            alpha: .4,
                                                          ),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                // 14 px Inter Regular
                                                Text(
                                                  'Remember Me',
                                                  style: _tsFooter(
                                                    c: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () {},
                                                // 14 px Inter SemiBold
                                                child: Text(
                                                  'Forgot Password?',
                                                  style: _tsFooter(
                                                    c: brand,
                                                    w: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 28),

                                        // Button — 16 px Inter Medium
                                        _PrimaryBtn(
                                          label: 'Login',
                                          loading: _loading,
                                          brand: brand,
                                          onPressed: _submit,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Footer
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: _tsFooter(
                                          c: cs.onSurfaceVariant,
                                        ),
                                      ),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () => Navigator.of(context)
                                              .pushReplacement(
                                                PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      const SignUpScreen(),
                                                  transitionsBuilder:
                                                      (_, a, __, c) =>
                                                          FadeTransition(
                                                            opacity: a,
                                                            child: c,
                                                          ),
                                                  transitionDuration:
                                                      const Duration(
                                                        milliseconds: 280,
                                                      ),
                                                ),
                                              ),
                                          child: Text(
                                            'Sign Up',
                                            style:
                                                _tsFooter(
                                                  c: cs.onSurface,
                                                  w: FontWeight.w700,
                                                ).copyWith(
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                        ),
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
            ],
          ),

          // Theme toggle pill
          Positioned(
            top: 28,
            right: 36,
            child: _ThemeTogglePill(isDark: isDark, ref: ref),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets — ALL use _ts*() → Inter guaranteed
// ─────────────────────────────────────────────────────────────────────────────

/// Form field label — 14 px Inter SemiBold
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: _tsLabel(c: Theme.of(context).colorScheme.onSurface));
}

/// Styled TextFormField — input 16 px Inter Regular
class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color inputBg;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.inputBg,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
    this.onSubmitted,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: _tsInput(c: cs.onSurface),
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: _tsHint(c: cs.onSurface.withValues(alpha: .38)),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 18, right: 14),
          child: Icon(
            icon,
            size: 22,
            color: cs.onSurfaceVariant.withValues(alpha: .55),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 56, minHeight: _fieldH),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                iconSize: 22,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: cs.onSurfaceVariant.withValues(alpha: .55),
                ),
                onPressed: onToggleObscure,
              )
            : null,
        suffixIconConstraints: BoxConstraints(minWidth: 56, minHeight: _fieldH),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldR),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldR),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldR),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldR),
          borderSide: BorderSide(color: cs.error, width: 1.6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldR),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        errorStyle: _tsError(c: cs.error), // 13 px Inter
      ),
      validator: validator,
    );
  }
}

/// Coloured alert / info banner
class _AlertBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _AlertBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isError
        ? cs.errorContainer.withValues(alpha: .55)
        : cs.primaryContainer;
    final border = isError
        ? cs.error.withValues(alpha: .45)
        : cs.primary.withValues(alpha: .3);
    final fg = isError ? cs.error : cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.4),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 20,
            color: fg,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: _tsBanner(c: fg)),
          ), // 14 px Inter Medium
        ],
      ),
    );
  }
}

/// Primary CTA button — 16 px Inter Medium
class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final Color brand;
  final VoidCallback onPressed;
  const _PrimaryBtn({
    required this.label,
    required this.loading,
    required this.brand,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _btnH,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: brand.withValues(alpha: .55),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: _tsBtn().copyWith(color: Colors.white),
            ), // 16 px Inter Medium
    ),
  );
}

// ── Office illustration ───────────────────────────────────────────────────────

class _OfficeIllustration extends StatelessWidget {
  final bool isDark;
  final Color brand;
  const _OfficeIllustration({required this.isDark, required this.brand});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(520, 380),
    painter: _OfficePainter(
      c1: brand.withValues(alpha: .55),
      c2: brand.withValues(alpha: .30),
      c3: brand.withValues(alpha: .15),
      c4: brand.withValues(alpha: .08),
    ),
  );
}

class _OfficePainter extends CustomPainter {
  final Color c1, c2, c3, c4;
  const _OfficePainter({
    required this.c1,
    required this.c2,
    required this.c3,
    required this.c4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    final sp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;

    p.color = c3;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * .5, h * .95),
        width: w * .85,
        height: h * .07,
      ),
      p,
    );
    p.color = c2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .06, h * .72, w * .88, h * .055),
        const Radius.circular(8),
      ),
      p,
    );
    p.color = c4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .35, h * .08, w * .44, h * .60),
        const Radius.circular(12),
      ),
      p,
    );
    p.color = c3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .37, h * .10, w * .40, h * .54),
        const Radius.circular(9),
      ),
      p,
    );

    sp.color = c2;
    sp.strokeWidth = 1.5;
    for (int i = 1; i <= 5; i++) {
      canvas.drawLine(
        Offset(w * .37, h * (.10 + i * .085)),
        Offset(w * .77, h * (.10 + i * .085)),
        sp,
      );
    }
    for (int i = 1; i <= 5; i++) {
      canvas.drawLine(
        Offset(w * (.37 + i * .066), h * .10),
        Offset(w * (.37 + i * .066), h * .64),
        sp,
      );
    }

    p.color = c1;
    for (final pos in [
      Offset(w * .42, h * .27),
      Offset(w * .49, h * .35),
      Offset(w * .56, h * .27),
      Offset(w * .63, h * .35),
      Offset(w * .70, h * .27),
      Offset(w * .42, h * .44),
      Offset(w * .56, h * .44),
    ]) {
      canvas.drawCircle(pos, 6.5, p);
    }

    p.color = c3;
    canvas.drawCircle(Offset(w * .86, h * .19), 34, p);
    p.color = c2;
    canvas.drawCircle(Offset(w * .86, h * .19), 26, p);
    sp.color = c1;
    sp.strokeWidth = 3.5;
    canvas.drawLine(
      Offset(w * .86, h * .19),
      Offset(w * .86, h * .19 - 17),
      sp,
    );
    sp.strokeWidth = 3;
    canvas.drawLine(
      Offset(w * .86, h * .19),
      Offset(w * .86 + 14, h * .19 + 8),
      sp,
    );

    p.color = c2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .08, h * .52, w * .13, h * .20),
        const Radius.circular(15),
      ),
      p,
    );
    canvas.drawCircle(Offset(w * .145, h * .42), 24, p);
    p.color = c1;
    canvas.drawPath(
      Path()
        ..moveTo(w * .08, h * .41)
        ..arcTo(
          Rect.fromCenter(
            center: Offset(w * .145, h * .42),
            width: 48,
            height: 48,
          ),
          3.14,
          3.14,
          false,
        )
        ..close(),
      p,
    );
    sp.color = c2;
    sp.strokeWidth = 14;
    canvas.drawLine(Offset(w * .21, h * .59), Offset(w * .33, h * .64), sp);

    p.color = c3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .29, h * .59, w * .23, h * .13),
        const Radius.circular(8),
      ),
      p,
    );
    p.color = c2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .31, h * .61, w * .19, h * .095),
        const Radius.circular(6),
      ),
      p,
    );
    sp.color = c1;
    sp.strokeWidth = 2.2;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(w * .33, h * (.64 + i * .025)),
        Offset(w * .48, h * (.64 + i * .025)),
        sp,
      );
    }

    p.color = c2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .09, h * .72, w * .025, h * .11),
        const Radius.circular(5),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .14, h * .72, w * .025, h * .11),
        const Radius.circular(5),
      ),
      p,
    );

    p.color = c2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .70, h * .39, w * .12, h * .31),
        const Radius.circular(15),
      ),
      p,
    );
    canvas.drawCircle(Offset(w * .76, h * .30), 22, p);
    p.color = c1;
    canvas.drawPath(
      Path()
        ..moveTo(w * .70, h * .30)
        ..arcTo(
          Rect.fromCenter(
            center: Offset(w * .76, h * .30),
            width: 44,
            height: 44,
          ),
          3.14,
          3.14,
          false,
        )
        ..close(),
      p,
    );

    p.color = c3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .82, h * .45, w * .085, h * .15),
        const Radius.circular(7),
      ),
      p,
    );
    sp.color = c1;
    sp.strokeWidth = 2.2;
    canvas.drawLine(Offset(w * .84, h * .50), Offset(w * .89, h * .50), sp);
    canvas.drawLine(Offset(w * .84, h * .545), Offset(w * .885, h * .545), sp);
    canvas.drawLine(Offset(w * .84, h * .59), Offset(w * .878, h * .59), sp);

    p.color = c2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .88, h * .64, w * .07, h * .10),
        const Radius.circular(6),
      ),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * .915, h * .59), width: 40, height: 28),
      p,
    );
    p.color = c1;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * .875, h * .53), width: 30, height: 22),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * .955, h * .55), width: 28, height: 21),
      p,
    );
  }

  @override
  bool shouldRepaint(_OfficePainter o) =>
      o.c1 != c1 || o.c2 != c2 || o.c3 != c3 || o.c4 != c4;
}

// ── Theme toggle pill ─────────────────────────────────────────────────────────

class _ThemeTogglePill extends StatelessWidget {
  final bool isDark;
  final WidgetRef ref;
  const _ThemeTogglePill({required this.isDark, required this.ref});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => ref.read(themeProvider.notifier).toggleTheme(!isDark),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: .4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 18,
              color: cs.onSurface,
            ),
            const SizedBox(width: 8),
            // 14 px Inter SemiBold
            Text(isDark ? 'Dark' : 'Light', style: _tsPill(c: cs.onSurface)),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 20,
              decoration: BoxDecoration(
                color: isDark
                    ? cs.primary.withValues(alpha: .3)
                    : cs.primary.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
