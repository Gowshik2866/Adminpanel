import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController(text: 'admin@engg.edu');
  final _passwordCtrl = TextEditingController(text: 'admin123');
  final _nameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPasswordCtrl = TextEditingController();
  final _signupConfirmCtrl = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureSignup = true;
  bool _obscureConfirm = true;
  bool _remember = true;
  bool _loading = false;
  bool _isSignUp = false;
  String? _error;

  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        setState(() {
          _isSignUp = _tabs.index == 1;
          _error = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPasswordCtrl.dispose();
    _signupConfirmCtrl.dispose();
    super.dispose();
  }

  /// Maps a [fb.FirebaseAuthException] code to a friendly message.
  String _friendlyError(Object e) {
    if (e is fb.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found for that email address.';
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-password':
          return 'Incorrect email or password. Please try again.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This account has been disabled. Contact your administrator.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please wait a moment and try again.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'email-already-in-use':
          return 'An account with this email already exists. Please login instead.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled. Contact your administrator.';
        default:
          return e.message ?? 'Authentication failed. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _login() async {
    setState(() => _error = null);
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final authRepo = ref.read(authRepositoryProvider);

    try {
      await authRepo.login(email, password);
      // Login succeeded — AuthGate handles navigation
    } on fb.FirebaseAuthException catch (loginErr) {
      // Newer Firebase SDK returns 'invalid-credential' for BOTH wrong password
      // AND account-not-found (security change to prevent email enumeration).
      // We resolve the ambiguity by attempting signup:
      //   • signup succeeds           → account was missing, now created ✅
      //   • signup fails email-in-use → account exists, password is wrong ❌
      //   • signup fails other reason → surface that error ❌
      if (loginErr.code == 'user-not-found' ||
          loginErr.code == 'invalid-credential') {
        try {
          await authRepo.signUp(
            email: email,
            password: password,
            name: 'Super Admin',
          );
          return; // signup + auto-login succeeded
        } on fb.FirebaseAuthException catch (signupErr) {
          if (!mounted) return;
          if (signupErr.code == 'email-already-in-use') {
            // Account exists → original credentials were wrong
            setState(() => _error = 'Incorrect password. Please try again.');
          } else {
            setState(() => _error = _friendlyError(signupErr));
          }
        }
      } else {
        if (!mounted) return;
        setState(() => _error = _friendlyError(loginErr));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    setState(() => _error = null);
    if (!_signupFormKey.currentState!.validate()) return;
    if (_signupPasswordCtrl.text != _signupConfirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() => _loading = true);

    try {
      await ref.read(authRepositoryProvider).signUp(
        email: _signupEmailCtrl.text.trim(),
        password: _signupPasswordCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
      );
    } on fb.FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 860;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // ══════════════════════════════════════════════════════════════
          // LEFT PANEL — Illustration (desktop only)
          // ══════════════════════════════════════════════════════════════
          if (isDesktop)
            SizedBox(
              width: size.width * 0.42,
              height: size.height,
              child: Container(
                color: const Color(0xFFEDF2F7),
                padding: const EdgeInsets.fromLTRB(56, 56, 48, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: Color(0xFF2563EB),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 36),

                    const Text(
                      'StaffAdmin\nDashboard',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.5,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Manage staff, leaves, attendance\nand reports efficiently.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    // Illustration fills remaining space
                    Expanded(
                      child: LayoutBuilder(
                        builder: (ctx, constraints) => CustomPaint(
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          painter: _OfficeScenePainter(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ══════════════════════════════════════════════════════════════
          // RIGHT PANEL — Auth Card (full height, no overflow)
          // ══════════════════════════════════════════════════════════════
          Expanded(
            child: SizedBox(
              height: size.height,
              child: Center(
                child: SizedBox(
                  width: isDesktop ? 520 : double.infinity,
                  height: size.height,
                  child: _AuthCard(
                    tabs: _tabs,
                    isSignUp: _isSignUp,
                    error: _error,
                    loading: _loading,
                    // Login form
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscureLogin: _obscureLogin,
                    onToggleLoginObscure: () =>
                        setState(() => _obscureLogin = !_obscureLogin),
                    remember: _remember,
                    onRememberChanged: (v) =>
                        setState(() => _remember = v ?? false),
                    loginFormKey: _loginFormKey,
                    onLogin: _login,
                    // Signup form
                    nameCtrl: _nameCtrl,
                    signupEmailCtrl: _signupEmailCtrl,
                    signupPasswordCtrl: _signupPasswordCtrl,
                    signupConfirmCtrl: _signupConfirmCtrl,
                    obscureSignup: _obscureSignup,
                    obscureConfirm: _obscureConfirm,
                    onToggleSignupObscure: () =>
                        setState(() => _obscureSignup = !_obscureSignup),
                    onToggleConfirmObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    signupFormKey: _signupFormKey,
                    onSignup: _signup,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Card — self-contained, full height, no overflow
// ─────────────────────────────────────────────────────────────────────────────
class _AuthCard extends StatelessWidget {
  final TabController tabs;
  final bool isSignUp;
  final String? error;
  final bool loading;

  final GlobalKey<FormState> loginFormKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscureLogin;
  final VoidCallback onToggleLoginObscure;
  final bool remember;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onLogin;

  final GlobalKey<FormState> signupFormKey;
  final TextEditingController nameCtrl;
  final TextEditingController signupEmailCtrl;
  final TextEditingController signupPasswordCtrl;
  final TextEditingController signupConfirmCtrl;
  final bool obscureSignup;
  final bool obscureConfirm;
  final VoidCallback onToggleSignupObscure;
  final VoidCallback onToggleConfirmObscure;
  final VoidCallback onSignup;

  const _AuthCard({
    required this.tabs,
    required this.isSignUp,
    required this.error,
    required this.loading,
    required this.loginFormKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscureLogin,
    required this.onToggleLoginObscure,
    required this.remember,
    required this.onRememberChanged,
    required this.onLogin,
    required this.signupFormKey,
    required this.nameCtrl,
    required this.signupEmailCtrl,
    required this.signupPasswordCtrl,
    required this.signupConfirmCtrl,
    required this.obscureSignup,
    required this.obscureConfirm,
    required this.onToggleSignupObscure,
    required this.onToggleConfirmObscure,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2563EB);
    const dark = Color(0xFF1E293B);
    const sub = Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Fixed header section ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 40, 48, 0),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: blue,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'StaffAdmin Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: dark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isSignUp
                      ? 'Create your account to get started.'
                      : 'Welcome back! Please sign in to continue.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: sub),
                ),
                const SizedBox(height: 22),

                // Tab bar
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: tabs,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: blue,
                    unselectedLabelColor: sub,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(text: 'Login'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                ),

                // Error banner
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFDC2626),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error!,
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Scrollable tab content fills remaining space ──────────────
          Expanded(
            child: TabBarView(
              controller: tabs,
              children: [
                // LOGIN
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(48, 24, 48, 32),
                  child: Form(
                    key: loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Label('Email / Username'),
                        const SizedBox(height: 8),
                        _Field(
                          controller: emailCtrl,
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 18),
                        const _Label('Password'),
                        const SizedBox(height: 8),
                        _Field(
                          controller: passwordCtrl,
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          obscure: obscureLogin,
                          onToggleObscure: onToggleLoginObscure,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
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
                                    onChanged: onRememberChanged,
                                    activeColor: blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember Me',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _PrimaryButton(
                          label: 'Login',
                          loading: loading,
                          onPressed: onLogin,
                        ),
                      ],
                    ),
                  ),
                ),

                // SIGN UP
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(48, 24, 48, 32),
                  child: Form(
                    key: signupFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Label('Full Name'),
                        const SizedBox(height: 8),
                        _Field(
                          controller: nameCtrl,
                          hint: 'Enter your full name',
                          icon: Icons.person_outline,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        const _Label('Email Address'),
                        const SizedBox(height: 8),
                        _Field(
                          controller: signupEmailCtrl,
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const _Label('Password'),
                        const SizedBox(height: 8),
                        _Field(
                          controller: signupPasswordCtrl,
                          hint: 'Create a password',
                          icon: Icons.lock_outline,
                          obscure: obscureSignup,
                          onToggleObscure: onToggleSignupObscure,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (v.length < 6) return 'Min. 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const _Label('Confirm Password'),
                        const SizedBox(height: 8),
                        _Field(
                          controller: signupConfirmCtrl,
                          hint: 'Re-enter your password',
                          icon: Icons.lock_outline,
                          obscure: obscureConfirm,
                          onToggleObscure: onToggleConfirmObscure,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),
                        _PrimaryButton(
                          label: 'Create Account',
                          loading: loading,
                          onPressed: onSignup,
                        ),
                      ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Office Scene Painter
// ─────────────────────────────────────────────────────────────────────────────
class _OfficeScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final glassPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final framePaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final cityPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final deskPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.fill;

    final bluePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    final darkBluePaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;

    final lightBluePaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = const Color(0xFFFED7AA)
      ..style = PaintingStyle.fill;

    final leafPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    // Window background
    canvas.drawRect(Rect.fromLTWH(10, 10, w - 20, h - 70), glassPaint);
    canvas.drawRect(Rect.fromLTWH(10, 10, w - 20, h - 70), framePaint);
    canvas.drawLine(Offset(w * 0.48, 10), Offset(w * 0.48, h - 70), framePaint);

    // City silhouette
    canvas.drawRect(Rect.fromLTWH(20, h - 155, 38, 85), cityPaint);
    canvas.drawRect(Rect.fromLTWH(63, h - 175, 48, 105), cityPaint);
    canvas.drawRect(Rect.fromLTWH(116, h - 140, 32, 70), cityPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.55, h - 170, 42, 100), cityPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.55 + 46, h - 148, 36, 78), cityPaint);

    // Ceiling lamp
    final lampStroke = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(w * 0.64, 0), Offset(w * 0.64, 38), lampStroke);
    final lamp = Path()
      ..moveTo(w * 0.64 - 11, 50)
      ..lineTo(w * 0.64 + 11, 50)
      ..lineTo(w * 0.64 + 7, 38)
      ..lineTo(w * 0.64 - 7, 38)
      ..close();
    canvas.drawPath(lamp, darkPaint);

    // Whiteboard
    final bx = w * 0.38;
    final by = h * 0.32;
    canvas.drawLine(
      Offset(bx + 8, by + 92),
      Offset(bx - 12, h - 38),
      framePaint,
    );
    canvas.drawLine(
      Offset(bx + 108, by + 92),
      Offset(bx + 128, h - 38),
      framePaint,
    );
    final boardRect = Rect.fromLTWH(bx, by, 116, 88);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(4)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(4)),
      framePaint,
    );

    // Line chart on board
    final chartLine = Path()
      ..moveTo(bx + 14, by + 42)
      ..lineTo(bx + 30, by + 26)
      ..lineTo(bx + 46, by + 36)
      ..lineTo(bx + 62, by + 14);
    canvas.drawPath(
      chartLine,
      Paint()
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Bar chart on board
    canvas.drawRect(Rect.fromLTWH(bx + 14, by + 54, 9, 22), bluePaint);
    canvas.drawRect(Rect.fromLTWH(bx + 28, by + 48, 9, 28), bluePaint);
    canvas.drawRect(Rect.fromLTWH(bx + 42, by + 60, 9, 16), bluePaint);

    // Pie chart on board
    canvas.drawCircle(Offset(bx + 90, by + 32), 16, darkBluePaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(bx + 90, by + 32), radius: 16),
      0,
      1.6,
      true,
      lightBluePaint,
    );

    // Presenter figure
    final px = bx + 132;
    final py = h * 0.42;
    canvas.drawCircle(Offset(px + 10, py - 10), 8, darkPaint);
    canvas.drawCircle(Offset(px + 10, py - 8), 7, skinPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px, py, 20, 44),
        const Radius.circular(4),
      ),
      bluePaint,
    );
    canvas.drawRect(Rect.fromLTWH(px + 2, py + 44, 7, 44), darkBluePaint);
    canvas.drawRect(Rect.fromLTWH(px + 11, py + 44, 7, 44), darkBluePaint);
    canvas.drawLine(
      Offset(px, py + 12),
      Offset(bx + 110, by + 52),
      Paint()
        ..color = const Color(0xFF1E293B)
        ..strokeWidth = 2,
    );

    // Left desk + person + laptop
    const d1x = 48.0;
    final d1y = h - 78.0;
    canvas.drawRect(Rect.fromLTWH(d1x, d1y, 108, 6), deskPaint);
    canvas.drawRect(Rect.fromLTWH(d1x + 8, d1y + 6, 5, 38), deskPaint);
    canvas.drawRect(Rect.fromLTWH(d1x + 94, d1y + 6, 5, 38), deskPaint);
    canvas.drawRect(Rect.fromLTWH(d1x + 62, d1y - 18, 22, 15), bluePaint);
    canvas.drawRect(Rect.fromLTWH(d1x + 57, d1y - 3, 32, 3), darkPaint);
    canvas.drawCircle(Offset(d1x + 34, d1y - 46), 10, darkPaint);
    canvas.drawCircle(Offset(d1x + 34, d1y - 44), 8, skinPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(d1x + 24, d1y - 33, 20, 33),
        const Radius.circular(4),
      ),
      darkBluePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(d1x + 13, d1y - 49, 8, 49),
        const Radius.circular(4),
      ),
      darkPaint,
    );

    // Potted plant
    const plx = 12.0;
    final ply = h - 58.0;
    canvas.drawRect(Rect.fromLTWH(plx, ply, 20, 24), deskPaint);
    canvas.drawOval(Rect.fromLTWH(plx - 8, ply - 44, 18, 44), leafPaint);
    canvas.drawOval(Rect.fromLTWH(plx + 4, ply - 58, 20, 52), leafPaint);
    canvas.drawOval(Rect.fromLTWH(plx + 15, ply - 32, 16, 32), leafPaint);

    // Right desk + person + monitor
    final d2x = w - 158.0;
    final d2y = h - 78.0;
    canvas.drawRect(Rect.fromLTWH(d2x, d2y, 108, 6), deskPaint);
    canvas.drawRect(Rect.fromLTWH(d2x + 8, d2y + 6, 5, 38), deskPaint);
    canvas.drawRect(Rect.fromLTWH(d2x + 94, d2y + 6, 5, 38), deskPaint);
    canvas.drawRect(
      Rect.fromLTWH(d2x + 18, d2y - 26, 28, 22),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawRect(Rect.fromLTWH(d2x + 30, d2y - 4, 4, 4), darkPaint);
    canvas.drawCircle(Offset(d2x + 75, d2y - 46), 10, darkPaint);
    canvas.drawCircle(Offset(d2x + 75, d2y - 44), 8, skinPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(d2x + 65, d2y - 33, 20, 33),
        const Radius.circular(4),
      ),
      darkBluePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(d2x + 87, d2y - 49, 8, 49),
        const Radius.circular(4),
      ),
      darkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
