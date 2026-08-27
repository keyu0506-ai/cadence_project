import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isPasswordHidden = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    debugPrint('Email: ${_emailController.text}');
    debugPrint('Password: ${_passwordController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D2D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [Color(0xFF3F207B), Color(0xFF17112F), Color(0xFF120D2D)],
            stops: [0, 0.32, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 650),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BackButton(),
                    const SizedBox(height: 28),
                    const _BrandHeader(),
                    const SizedBox(height: 44),
                    const _WelcomeMessage(),
                    const SizedBox(height: 42),
                    SignInTextField(
                      label: 'EMAIL',
                      icon: Icons.email_rounded,
                      hintText: 'ava.chen@school.edu',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 18),
                    SignInTextField(
                      label: 'PASSWORD',
                      icon: Icons.lock_rounded,
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      obscureText: isPasswordHidden,
                      validator: _validatePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => isPasswordHidden = !isPasswordHidden);
                        },
                        icon: Icon(
                          isPasswordHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: const Color(0xFF918AA4),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(color: Color(0xFFC9ACFF), fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 76,
                      child: FilledButton(
                        onPressed: _signIn,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF8639E8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text('Sign In'), SizedBox(width: 10), Icon(Icons.arrow_forward_rounded)],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    const _DividerLabel(label: 'or continue with'),
                    const SizedBox(height: 34),
                    Row(
                      children: [
                        Expanded(
                          child: SocialSignInButton(
                            icon: Icons.apple,
                            label: 'Apple',
                            onPressed: () => debugPrint('apple sign in'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SocialSignInButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google',
                            onPressed: () => debugPrint('google sign in'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('New to Cadence? ', style: TextStyle(color: Color(0xFFAFA8BE), fontSize: 16)),
                          TextButton(
                            onPressed: () {
                              context.pushReplacementNamed(AppRoutes.signUp);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Create an account', style: TextStyle(color: Color(0xFFD1B6FF), fontWeight: FontWeight.w700)),
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

String? _validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your email.';
  }
  if (!value.contains('@')) {
    return 'Please enter a valid email.';
  }
  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password.';
  }
  return null;
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFF8845EE),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0x557E3FF2), blurRadius: 24)],
          ),
          child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(width: 15),
        const Text('Cadence', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: OutlinedButton(
        onPressed: () => context.pop(),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF4A435F)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(color: Colors.white, fontSize: 45, height: 1.08, fontWeight: FontWeight.w800, letterSpacing: -1.8),
            children: [
              TextSpan(text: 'Welcome\n'),
              TextSpan(text: 'back.', style: TextStyle(color: Color(0xFFE77BB7))),
            ],
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Sign in to pick up your plan right where your brain left off.',
          style: TextStyle(color: Color(0xFFACA5BD), fontSize: 18, height: 1.45),
        ),
      ],
    );
  }
}

class SignInTextField extends StatelessWidget {
  const SignInTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.validator,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFABA4BB), fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFAD83FA)),
            suffixIcon: suffixIcon,
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFAEA7BC), fontSize: 18),
            filled: true,
            fillColor: const Color(0xFF26203F),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            enabledBorder: _inputBorder,
            focusedBorder: _inputBorder.copyWith(borderSide: const BorderSide(color: Color(0xFF9A60F5), width: 2)),
            errorBorder: _inputBorder.copyWith(borderSide: const BorderSide(color: Color(0xFFFF8A9B))),
          ),
        ),
      ],
    );
  }

  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: Color(0xFF46405D)),
  );
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF49425E))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(label, style: const TextStyle(color: Color(0xFF958DA7), fontSize: 14)),
        ),
        const Expanded(child: Divider(color: Color(0xFF49425E))),
      ],
    );
  }
}

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({super.key, required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: icon == Icons.g_mobiledata_rounded ? 28 : 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF46405D)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
