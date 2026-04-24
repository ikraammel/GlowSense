import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../constants/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ));
          } else if (state is AuthAuthenticated) {
            // Success: Close the signup screen to let the router show onboarding
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text("Start your personalized skincare journey",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: _field(_firstCtrl, "First Name", Icons.person_outline,
                          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null)),
                      const SizedBox(width: 12),
                      Expanded(child: _field(_lastCtrl, "Last Name", Icons.person_outline,
                          validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _field(_emailCtrl, "Email", Icons.email_outlined,
                      type: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Required';
                        if (!(v!.contains('@'))) return 'Invalid email';
                        return null;
                      }),
                  const SizedBox(height: 16),
                  _field(_passCtrl, "Password", Icons.lock_outline,
                      obscure: !_showPass,
                      suffix: IconButton(
                        icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                      validator: (v) => (v?.length ?? 0) < 8 ? 'At least 8 characters' : null),
                  const SizedBox(height: 16),
                  _field(_confirmCtrl, "Confirm Password", Icons.lock_outline,
                      obscure: true,
                      validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null),
                  const SizedBox(height: 30),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading ? null : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(RegisterRequested(
                              firstName: _firstCtrl.text.trim(),
                              lastName: _lastCtrl.text.trim(),
                              email: _emailCtrl.text.trim(),
                              password: _passCtrl.text.trim(),
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
