// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/features/auth/presentation/auth_notifier.dart';
import 'package:sample_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:sample_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:sample_app/widgets/app_shell.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Design Tokens
// ═══════════════════════════════════════════════════════════════════════════════

const _kBlue = Color(0xFF2563EB); // primary brand blue
// Light palette
const _kLightBg = Color(0xFFF8FAFC); // clean white/soft gray
const _kLightPanel = Color(0xFFF1F5F9);
const _kLightCard = Color(0xFFFFFFFF);
const _kLightInput = Color(0xFFFFFFFF);
const _kLightInputB = Color(0xFFE2E8F0);
const _kLightText = Color(0xFF0F172A);
const _kLightSub = Color(0xFF64748B);

// Dark palette
const _kDarkBg = Color(0xFF0B1120); // deep navy
const _kDarkCard = Color(0xFF1E293B); // lighter card surface
const _kDarkInput = Color(0xFF0F172A);
const _kDarkInputB = Color(0xFF334155);
const _kDarkText = Color(0xFFF8FAFC);
const _kDarkSub = Color(0xFF94A3B8);

// ── Typography factory ────────────────────────────────────────────────────────

TextStyle _t({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? lh,
  double ls = 0,
}) => TextStyle(
  fontFamily: 'Inter',
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: lh,
  letterSpacing: ls,
);

// ═══════════════════════════════════════════════════════════════════════════════
// LoginScreen
// ═══════════════════════════════════════════════════════════════════════════════

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
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    _cardFade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, .035),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
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
        .login(_emailCtrl.text, _passwordCtrl.text);
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
    final isDark = ref.watch(themeProvider);

    final rightBg = isDark ? _kDarkBg : _kLightBg;
    final cardBg = isDark ? _kDarkCard : _kLightCard;
    final inputBg = isDark ? _kDarkInput : _kLightInput;
    final inputB = isDark ? _kDarkInputB : _kLightInputB;
    final txtCol = isDark ? _kDarkText : _kLightText;
    final subCol = isDark ? _kDarkSub : _kLightSub;

    return Scaffold(
      backgroundColor: rightBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Two-panel layout (55% / 45%) ───────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══════════════════════════════════════════════════════════
              // LEFT PANEL (55%) — Branding & Illustration
              // ═══════════════════════════════════════════════════════════
              Expanded(flex: 55, child: _LeftPanel(isDark: isDark)),

              // ═══════════════════════════════════════════════════════════
              // RIGHT PANEL (45%) — Login Card
              // ═══════════════════════════════════════════════════════════
              Expanded(
                flex: 45,
                child: _RightPanel(
                  isDark: isDark,
                  rightBg: rightBg,
                  cardBg: cardBg,
                  inputBg: inputBg,
                  inputB: inputB,
                  txtCol: txtCol,
                  subCol: subCol,
                  cardFade: _cardFade,
                  cardSlide: _cardSlide,
                  formKey: _formKey,
                  emailCtrl: _emailCtrl,
                  passwordCtrl: _passwordCtrl,
                  obscure: _obscure,
                  remember: _remember,
                  loading: _loading,
                  error: _error,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onRemember: (v) => setState(() => _remember = v ?? false),
                  onSubmit: _submit,
                  onSignUp: () => Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const SignUpScreen(),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                      transitionDuration: const Duration(milliseconds: 280),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Theme Switch ──────────────────────────────────────────────
          Positioned(
            top: 24,
            right: 28,
            child: _ThemeToggle(isDark: isDark, ref: ref),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEFT PANEL
// ═══════════════════════════════════════════════════════════════════════════════

class _LeftPanel extends StatelessWidget {
  final bool isDark;
  const _LeftPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF080F1A) : _kLightPanel,
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF080F1A),
                  Color(0xFF131D33),
                ],
                stops: [0.0, 0.5, 1.0],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2563EB).withValues(alpha: .03),
                  const Color(0xFF3B82F6).withValues(alpha: .06),
                ],
              ),
      ),
      child: Stack(
        children: [
          // Background soft shapes
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kBlue.withValues(alpha: isDark ? 0.05 : 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kBlue.withValues(alpha: isDark ? 0.04 : 0.04),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branding
                _LogoBadge(isDark: isDark),
                const SizedBox(height: 32),
                Text(
                  'StaffAdmin\nDashboard',
                  style: _t(
                    size: 44,
                    weight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    lh: 1.15,
                    ls: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Efficient Staff Management & Administration Platform.\nManage staff, leave records, attendance, and reports efficiently.',
                  style: _t(
                    size: 15,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                    lh: 1.6,
                  ),
                ),
                const SizedBox(height: 48),

                // Illustration
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Transform.scale(
                        scale: 1.15,
                        child: Image.asset(
                          isDark
                              ? 'assets/images/office_illustration_dark.png'
                              : 'assets/images/office_illustration.png',
                          width: 620,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final bool isDark;
  const _LogoBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _kBlue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _kBlue.withValues(alpha: .3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.dashboard_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RIGHT PANEL (Login Card)
// ═══════════════════════════════════════════════════════════════════════════════

class _RightPanel extends StatelessWidget {
  final bool isDark;
  final Color rightBg, cardBg, inputBg, inputB, txtCol, subCol;
  final Animation<double> cardFade;
  final Animation<Offset> cardSlide;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, passwordCtrl;
  final bool obscure, remember, loading;
  final String? error;
  final VoidCallback onToggleObscure, onSubmit, onSignUp;
  final ValueChanged<bool?> onRemember;

  const _RightPanel({
    required this.isDark,
    required this.rightBg,
    required this.cardBg,
    required this.inputBg,
    required this.inputB,
    required this.txtCol,
    required this.subCol,
    required this.cardFade,
    required this.cardSlide,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.remember,
    required this.loading,
    required this.error,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onRemember,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: rightBg,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          child: FadeTransition(
            opacity: cardFade,
            child: SlideTransition(
              position: cardSlide,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 520,
                ), // 520px width as requested
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      blurRadius: 24,
                      spreadRadius: isDark ? 0 : 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: .05)
                        : Colors.black.withValues(alpha: .05),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 48,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome Back',
                      style: _t(
                        size: 28,
                        weight: FontWeight.w700,
                        color: txtCol,
                        ls: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign in to access your dashboard.',
                      style: _t(size: 15, color: subCol, lh: 1.5),
                    ),
                    const SizedBox(height: 32),

                    if (error != null) ...[
                      _ErrorBanner(message: error!, isDark: isDark),
                      const SizedBox(height: 24),
                    ],

                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _FieldLabel(
                            label: 'Email / Username',
                            txtCol: txtCol,
                          ),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: emailCtrl,
                            hint: 'Enter your email',
                            icon: Icons.alternate_email_rounded,
                            inputBg: inputBg,
                            inputB: inputB,
                            txtCol: txtCol,
                            subCol: subCol,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                            onSubmitted: (_) => onSubmit(),
                          ),
                          const SizedBox(height: 24),

                          _FieldLabel(label: 'Password', txtCol: txtCol),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: passwordCtrl,
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            inputBg: inputBg,
                            inputB: inputB,
                            txtCol: txtCol,
                            subCol: subCol,
                            obscureText: obscure,
                            onToggleObscure: onToggleObscure,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                            onSubmitted: (_) => onSubmit(),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Checkbox(
                                      value: remember,
                                      onChanged: onRemember,
                                      activeColor: _kBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: BorderSide(
                                        color: subCol.withValues(alpha: .5),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember Me',
                                    style: _t(
                                      size: 14,
                                      color: subCol,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              _HoverLink(
                                text: 'Forgot Password?',
                                color: _kBlue,
                                weight: FontWeight.w600,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          _LoginButton(loading: loading, onPressed: onSubmit),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: _t(size: 14, color: subCol),
                          ),
                          _HoverLink(
                            text: 'Sign Up',
                            color: _kBlue,
                            weight: FontWeight.w700,
                            underline: true,
                            onTap: onSignUp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared UI Widgets ─────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final Color txtCol;
  const _FieldLabel({required this.label, required this.txtCol});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: _t(size: 14, weight: FontWeight.w600, color: txtCol),
  );
}

class _HoverLink extends StatefulWidget {
  final String text;
  final Color color;
  final FontWeight weight;
  final bool underline;
  final VoidCallback onTap;
  const _HoverLink({
    required this.text,
    required this.color,
    required this.weight,
    this.underline = false,
    required this.onTap,
  });

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style:
              _t(
                size: 14,
                color: _hover
                    ? widget.color.withValues(alpha: .8)
                    : widget.color,
                weight: widget.weight,
              ).copyWith(
                decoration: widget.underline || _hover
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: widget.color,
              ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color inputBg, inputB, txtCol, subCol;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.inputBg,
    required this.inputB,
    required this.txtCol,
    required this.subCol,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
    this.onSubmitted,
    this.keyboardType,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focus = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.inputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _focus ? _kBlue : widget.inputB,
            width: _focus ? 2 : 1,
          ),
          boxShadow: _focus
              ? [
                  BoxShadow(
                    color: _kBlue.withValues(alpha: .15),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: _t(size: 15, color: widget.txtCol),
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hint,
            hintStyle: _t(size: 15, color: widget.subCol.withValues(alpha: .6)),
            prefixIcon: Icon(widget.icon, size: 20, color: widget.subCol),
            suffixIcon: widget.onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      widget.obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: widget.subCol,
                      size: 20,
                    ),
                    onPressed: widget.onToggleObscure,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: InputBorder.none,
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorBanner({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: _t(
                size: 14,
                color: const Color(0xFFEF4444),
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onPressed;
  const _LoginButton({required this.loading, required this.onPressed});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _hover && !widget.loading
                ? [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]
                : [const Color(0xFF2563EB), const Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _kBlue.withValues(alpha: _hover ? 0.4 : 0.2),
              blurRadius: _hover ? 16 : 8,
              offset: Offset(0, _hover ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.loading ? null : widget.onPressed,
            child: Center(
              child: widget.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Login',
                      style: _t(
                        size: 16,
                        weight: FontWeight.w600,
                        color: Colors.white,
                        ls: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatefulWidget {
  final bool isDark;
  final WidgetRef ref;
  const _ThemeToggle({required this.isDark, required this.ref});

  @override
  State<_ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<_ThemeToggle> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () =>
            widget.ref.read(themeProvider.notifier).toggleTheme(!widget.isDark),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: .1)
                  : Colors.black.withValues(alpha: .05),
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 18,
                color: widget.isDark
                    ? const Color(0xFF93C5FD)
                    : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              Text(
                widget.isDark ? 'Dark Mode' : 'Light Mode',
                style: _t(
                  size: 14,
                  weight: FontWeight.w500,
                  color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
