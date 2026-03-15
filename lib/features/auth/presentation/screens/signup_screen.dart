// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/features/auth/presentation/auth_notifier.dart';
import 'package:sample_app/features/settings/presentation/providers/theme_provider.dart';
import 'package:sample_app/features/auth/presentation/screens/login_screen.dart';
import 'package:sample_app/widgets/app_shell.dart';
import 'package:sample_app/core/enums.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Design Tokens
// ═══════════════════════════════════════════════════════════════════════════════

const _kBlue        = Color(0xFF4B73C4); // primary brand blue

// Light palette
const _kLightBg     = Color(0xFFF1F5F9); 
const _kLightPanel  = Color(0xFFF1F5F9); 
const _kLightCard   = Color(0xFFFFFFFF);
const _kLightInput  = Color(0xFFFFFFFF);
const _kLightInputB = Color(0xFFE2E8F0);
const _kLightText   = Color(0xFF1E293B);
const _kLightSub    = Color(0xFF64748B);

// Dark palette
const _kDarkBg      = Color(0xFF0F172A);
const _kDarkPanel   = Color(0xFF0F172A);
const _kDarkCard    = Color(0xFF283648);
const _kDarkInput   = Color(0xFF324056);
const _kDarkInputB  = Color(0xFF475569);
const _kDarkText    = Color(0xFFF8FAFC);
const _kDarkSub     = Color(0xFF94A3B8);

// Typography factory
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
// SignUpScreen
// ═══════════════════════════════════════════════════════════════════════════════

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});
  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure   = true;
  bool _remember  = false;
  bool _loading   = false;
  String? _error;

  late final AnimationController _anim;
  late final Animation<double>   _cardFade;
  late final Animation<Offset>   _cardSlide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 560));
    _cardFade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, .035), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await ref.read(authProvider.notifier).signUp(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      name: _nameCtrl.text,
      department: 'General',
      role: Role.other,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err == null) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppShell(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeIn),
          child: c,
        ),
        transitionDuration: const Duration(milliseconds: 380),
      ));
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final rightBg = isDark ? _kDarkBg : _kLightBg;

    return Scaffold(
      backgroundColor: rightBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LEFT PANEL
              Expanded(
                flex: 55,
                child: _LeftPanel(isDark: isDark),
              ),
              // RIGHT PANEL
              Expanded(
                flex: 45,
                child: _RightPanel(
                  isDark: isDark,
                  cardFade: _cardFade,
                  cardSlide: _cardSlide,
                  formKey: _formKey,
                  nameCtrl: _nameCtrl,
                  emailCtrl: _emailCtrl,
                  passwordCtrl: _passwordCtrl,
                  obscure: _obscure,
                  remember: _remember,
                  loading: _loading,
                  error: _error,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onRemember: (v) => setState(() => _remember = v ?? false),
                  onSubmit: _submit,
                  onSignIn: () => Navigator.of(context).pushReplacement(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const LoginScreen(),
                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                    transitionDuration: const Duration(milliseconds: 280),
                  )),
                ),
              ),
            ],
          ),
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
    final bgCol = isDark ? _kDarkPanel : _kLightPanel;
    final titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF526075);
    return Container(
      color: bgCol,
      child: Stack(
        children: [
          // Illustration Blob
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: CustomPaint(
              painter: _BlobPainter(isDark: isDark),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BrandLogo(size: 44, color: isDark ? const Color(0xFF536E99) : const Color(0xFF334A72)),
                const SizedBox(height: 18),
                Text(
                  'StaffAdmin Dashboard',
                  style: _t(
                    size: 34,
                    weight: FontWeight.w800,
                    color: titleColor,
                    lh: 1.15,
                    ls: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Manage staff, leaves, attendance\nand reports efficiently.',
                  style: _t(
                    size: 15,
                    weight: FontWeight.w400,
                    color: subtitleColor,
                    lh: 1.4,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        child: Image.asset(
                          isDark
                              ? 'assets/images/office_illustration_dark.png'
                              : 'assets/images/office_illustration.png',
                          key: ValueKey<bool>(isDark),
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

class _BlobPainter extends CustomPainter {
  final bool isDark;
  _BlobPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;
      
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.1, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.7, 0, size.height * 0.5);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) => oldDelegate.isDark != isDark;
}

class _BrandLogo extends StatelessWidget {
  final double size;
  final Color color;
  const _BrandLogo({this.size = 48, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Wrap(
          spacing: size * 0.08,
          runSpacing: size * 0.08,
          children: List.generate(4, (i) => Container(
            width: size * 0.2, height: size * 0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.04),
            ),
          )),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RIGHT PANEL
// ═══════════════════════════════════════════════════════════════════════════════

class _RightPanel extends StatelessWidget {
  final bool isDark;
  final Animation<double> cardFade;
  final Animation<Offset> cardSlide;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, passwordCtrl;
  final bool obscure, remember, loading;
  final String? error;
  final VoidCallback onToggleObscure, onSubmit;
  final ValueChanged<bool?> onRemember;
  final VoidCallback onSignIn;

  const _RightPanel({
    required this.isDark,
    required this.cardFade,
    required this.cardSlide,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.remember,
    required this.loading,
    required this.error,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onRemember,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _kDarkCard : _kLightCard;
    final txtCol = isDark ? _kDarkText : _kLightText;
    final subCol = isDark ? _kDarkSub : _kLightSub;
    final inputBg = isDark ? _kDarkInput : _kLightInput;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: FadeTransition(
          opacity: cardFade,
          child: SlideTransition(
            position: cardSlide,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? .20 : .08),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: _BrandLogo(size: 42, color: const Color(0xFF4C6BAD)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'StaffAdmin Dashboard',
                    textAlign: TextAlign.center,
                    style: _t(size: 20, weight: FontWeight.w700, color: txtCol, ls: -0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new account.',
                    textAlign: TextAlign.center,
                    style: _t(size: 13, color: subCol),
                  ),
                  const SizedBox(height: 36),

                  if (error != null) ...[
                    _ErrorBanner(message: error!, isDark: isDark),
                    const SizedBox(height: 20),
                  ],

                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        _FieldLabel(label: 'Full Name', txtCol: txtCol),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: nameCtrl,
                          hint: 'Enter your name',
                          icon: Icons.person_outline_rounded,
                          inputBg: inputBg,
                          txtCol: txtCol,
                          subCol: subCol,
                          isDark: isDark,
                          validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
                          onSubmitted: (_) => onSubmit(),
                        ),
                        const SizedBox(height: 20),
                        
                        _FieldLabel(label: 'Email / Username',  txtCol: txtCol),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: emailCtrl,
                          hint: 'Enter your email',
                          icon: Icons.mail_outline_rounded,
                          inputBg: inputBg,
                          txtCol: txtCol,
                          subCol: subCol,
                          isDark: isDark,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || v.isEmpty) ? 'Email required' : null,
                          onSubmitted: (_) => onSubmit(),
                        ),
                        const SizedBox(height: 20),
                        
                        _FieldLabel(label: 'Password', txtCol: txtCol),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: passwordCtrl,
                          hint: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          inputBg: inputBg,
                          txtCol: txtCol,
                          subCol: subCol,
                          isDark: isDark,
                          obscureText: obscure,
                          onToggleObscure: onToggleObscure,
                          validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
                          onSubmitted: (_) => onSubmit(),
                        ),
                        const SizedBox(height: 18),

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
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    side: BorderSide(color: subCol.withValues(alpha: .5), width: 1.2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Remember Me', style: _t(size: 12.5, color: subCol, weight: FontWeight.w500)),
                              ],
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {},
                                child: Text('Forgot Password?', style: _t(size: 12.5, color: _kBlue, weight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        _SubmitButton(loading: loading, onPressed: onSubmit, text: 'Sign Up'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: _t(size: 13, color: subCol)),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: onSignIn,
                            child: Text(
                              'Sign In',
                              style: _t(size: 13, color: txtCol, weight: FontWeight.w700),
                            ),
                          ),
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
    );
  }
}

// ── Shared UI Widgets ────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final Color txtCol;
  const _FieldLabel({required this.label, required this.txtCol});
  @override
  Widget build(BuildContext context) => Text(
        label,
        style: _t(size: 12, weight: FontWeight.w700, color: txtCol),
      );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color inputBg, txtCol, subCol;
  final bool isDark;
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
    required this.txtCol,
    required this.subCol,
    required this.isDark,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
    this.onSubmitted,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final borderCol = isDark ? _kDarkInputB : _kLightInputB;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: _t(size: 14, color: txtCol, weight: FontWeight.w400),
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: _t(size: 13, color: subCol),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 18, color: subCol),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 46),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                iconSize: 18,
                icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: subCol),
                onPressed: onToggleObscure,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 46),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: borderCol, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _kBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        errorStyle: _t(size: 11, color: const Color(0xFFEF4444)),
      ),
      validator: validator,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: isDark ? .15 : .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: .35), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFEF4444)),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: _t(size: 12.5, color: const Color(0xFFEF4444), weight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final bool loading;
  final VoidCallback onPressed;
  final String text;
  const _SubmitButton({required this.loading, required this.onPressed, required this.text});
  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}
class _SubmitButtonState extends State<_SubmitButton> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _hovering && !widget.loading
                ? [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]
                : [const Color(0xFF2563EB), const Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: _hovering ? 0.4 : 0.2),
              blurRadius: _hovering ? 16 : 8,
              offset: Offset(0, _hovering ? 6 : 2),
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
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(widget.text, style: _t(size: 16, weight: FontWeight.w600, color: Colors.white, ls: 0.5)),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// THEME TOGGLE
// ═══════════════════════════════════════════════════════════════════════════════
class _ThemeToggle extends StatefulWidget {
  final bool isDark;
  final WidgetRef ref;
  const _ThemeToggle({required this.isDark, required this.ref});
  @override
  State<_ThemeToggle> createState() => _ThemeToggleState();
}
class _ThemeToggleState extends State<_ThemeToggle> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool get _isDark => widget.isDark;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1, end: .95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  Future<void> _tap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.ref.read(themeProvider.notifier).toggleTheme(!_isDark);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDark ? const Color(0xFF283648) : Colors.white;
    final borderColor = _isDark ? const Color(0xFF324056) : const Color(0xFFE2E8F0);
    final txtColor = _isDark ? const Color(0xFFF1F5F9) : const Color(0xFF374151);

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _tap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: _isDark ? .1 : .04), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 14,
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                Text(
                  _isDark ? 'Light' : 'Dark',
                  style: _t(size: 12, weight: FontWeight.w600, color: txtColor),
                ),
                const SizedBox(width: 8),
                Container(
                   width: 28, height: 16,
                   decoration: BoxDecoration(
                     color: const Color(0xFF4B6DA1),
                     borderRadius: BorderRadius.circular(10),
                   ),
                   child: AnimatedAlign(
                     duration: const Duration(milliseconds: 200),
                     curve: Curves.easeOut,
                     alignment: _isDark ? Alignment.centerLeft : Alignment.centerRight,
                     child: Container(
                       width: 12, height: 12,
                       margin: const EdgeInsets.symmetric(horizontal: 2),
                       decoration: const BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                       ),
                     )
                   ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
