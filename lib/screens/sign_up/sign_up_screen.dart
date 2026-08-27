import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool hasAcceptedTerms = false;
  bool isPasswordHidden = true;
  bool showTermsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    final areFieldsValid = _formKey.currentState?.validate() ?? false;

    setState(() => showTermsError = !hasAcceptedTerms);

    if (!areFieldsValid || !hasAcceptedTerms) {
      return;
    }

    debugPrint('Name: ${_nameController.text}');
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Password: ${_passwordController.text}');
    debugPrint('Accepted terms: $hasAcceptedTerms');
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
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BackButton(),
                  const SizedBox(height: 36),
                  const _AppIcon(),
                  const SizedBox(height: 32),
                  const _TitleSection(),
                  const SizedBox(height: 38),
                  SignUpTextField(
                    label: 'FULL NAME',
                    icon: Icons.person_rounded,
                    hintText: 'Ava Chen',
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 18),
                  SignUpTextField(
                    label: 'EMAIL',
                    icon: Icons.email_rounded,
                    hintText: 'ava.chen@school.edu',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 18),
                  SignUpTextField(
                    label: 'PASSWORD',
                    icon: Icons.lock_rounded,
                    hintText: 'Enter your password',
                    obscureText: isPasswordHidden,
                    controller: _passwordController,
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
                  const SizedBox(height: 17),
                  _TermsCheckbox(
                    value: hasAcceptedTerms,
                    errorText: showTermsError ? 'Please accept the Terms of Service.' : null,
                    onChanged: (value) {
                      setState(() {
                        hasAcceptedTerms = value ?? false;
                        if (hasAcceptedTerms) {
                          showTermsError = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      onPressed: _createAccount,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8639E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Create Account'), SizedBox(width: 10), Icon(Icons.arrow_forward_rounded)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const _DividerLabel(label: 'or sign up with'),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: SocialSignUpButton(icon: Icons.apple, label: 'Apple', onPressed: () => debugPrint('apple signup'))),
                      SizedBox(width: 16),
                      Expanded(child: SocialSignUpButton(icon: Icons.g_mobiledata_rounded, label: 'Google', onPressed: () => debugPrint('google signup'))),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: Color(0xFFAFA8BE), fontSize: 16)),
                        TextButton(
                          onPressed: () {
                            context.pushReplacementNamed(AppRoutes.signIn);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Sign in', style: TextStyle(color: Color(0xFFD1B6FF), fontWeight: FontWeight.w700)),
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

String? _validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your name.';
  }
  return null;
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
  if (value == null || value.length < 8) {
    return 'Use at least 8 characters.';
  }
  return null;
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

class _AppIcon extends StatelessWidget {
  const _AppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFF8845EE),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x667E3FF2), blurRadius: 28)],
      ),
      child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 42),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(color: Colors.white, fontSize: 39, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -1.5),
            children: [
              TextSpan(text: 'Create your '),
              TextSpan(text: 'account', style: TextStyle(color: Color(0xFFE77BB7))),
            ],
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Start turning your notes into a brain-aware calendar in seconds.',
          style: TextStyle(color: Color(0xFFACA5BD), fontSize: 18, height: 1.45),
        ),
      ],
    );
  }
}

class SignUpTextField extends StatelessWidget {
  const SignUpTextField({
    super.key,
    required this.label,
    required this.icon,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.validator,
  });

  final String label;
  final IconData icon;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFABA4BB), fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        TextFormField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFAD83FA)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF26203F),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFAEA7BC), fontSize: 18),
            enabledBorder: _inputBorder,
            focusedBorder: _inputBorder.copyWith(borderSide: const BorderSide(color: Color(0xFF9A60F5))),
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

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged, this.errorText});

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF833CE8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(color: Color(0xFFAFA8BE), fontSize: 14),
                  children: [
                    TextSpan(text: "I agree to Cadence's "),
                    TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFFD1B6FF), fontWeight: FontWeight.w700)),
                    TextSpan(text: ' and '),
                    TextSpan(text: 'Privacy Policy.', style: TextStyle(color: Color(0xFFD1B6FF), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 38, top: 5),
            child: Text(errorText!, style: const TextStyle(color: Color(0xFFFF8A9B), fontSize: 12)),
          ),
      ],
    );
  }
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

class SocialSignUpButton extends StatelessWidget {
  const SocialSignUpButton({super.key, required this.icon, required this.label, required this.onPressed});

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
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
