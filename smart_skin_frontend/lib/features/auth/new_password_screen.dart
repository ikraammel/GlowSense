import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../constants/colors.dart';

class NewPasswordScreen extends StatefulWidget {
  final String token;
  const NewPasswordScreen({super.key, required this.token});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() { _passCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(ResetPasswordRequested(
            token: widget.token,
            newPassword: _passCtrl.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context))),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Password changed successfully!"), backgroundColor: AppColors.success));
            // Back to Login
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: AppColors.error));
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
                  const Text("New Password", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text("Create a strong password for your account.",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
                  const SizedBox(height: 32),
                  _label("Password"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: !_showPass,
                    decoration: _inputDec("••••••••", Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                  ),
                  const SizedBox(height: 20),
                  _label("Confirm Password"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    decoration: _inputDec("••••••••", Icons.lock_reset_outlined),
                    validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink,
                          foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Change Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
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

  Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15));
  InputDecoration _inputDec(String hint, IconData icon) => InputDecoration(
    hintText: hint, prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primaryPink, width: 2)),
    filled: true, fillColor: Colors.grey.shade50,
  );
}
