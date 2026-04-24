import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../constants/colors.dart';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _firstCtrl, _lastCtrl, _phoneCtrl;
  bool _isLoading = false;
  File? _newAvatar;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;
    _firstCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastCtrl = TextEditingController(text: user?.lastName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(BuildContext rootContext) async {
    setState(() => _isLoading = true);
    try {
      final api = rootContext.read<ApiService>();
      if (_newAvatar != null) {
        await api.uploadAvatar(_newAvatar!.path);
      }
      await api.updateProfile({
        'firstName': _firstCtrl.text.trim(),
        'lastName': _lastCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
      });
      
      if (!mounted) return;
      
      rootContext.read<AuthBloc>().add(const CheckAuthStatus());
      setState(() {
        _isEditing = false;
        _newAvatar = null;
      });
      
      messengerKey.currentState?.showSnackBar(const SnackBar(
        content: Text("Profile updated!"),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      messengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount(BuildContext rootContext) async {
    final api = rootContext.read<ApiService>();
    try {
      await api.deleteAccount();
      if (!mounted) return;
      rootContext.read<AuthBloc>().add(const LogoutRequested());
      messengerKey.currentState?.showSnackBar(const SnackBar(
        content: Text("Account permanently deleted."),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      messengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootContext = context;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, authState) {
          final user = authState is AuthAuthenticated ? authState.user : null;
          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (ctx, dashState) {
              final dashData = dashState is DashboardLoaded ? dashState.data : null;
              
              return CustomScrollView(
                slivers: [
                  _buildAppBar(user),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(user),
                        const SizedBox(height: 24),
                        _buildStatsRow(dashData),
                        const SizedBox(height: 32),
                        
                        if (_isEditing) 
                          _buildEditForm(rootContext)
                        else ...[
                          _buildSectionTitle("Skin Profile"),
                          const SizedBox(height: 12),
                          _buildSkinProfileCard(user),
                          
                          const SizedBox(height: 32),
                          _buildSectionTitle("Settings"),
                          const SizedBox(height: 12),
                          _buildSettingsSection(rootContext),
                          
                          const SizedBox(height: 32),
                          _buildSectionTitle("About"),
                          const SizedBox(height: 12),
                          _buildAboutSection(),

                          const SizedBox(height: 32),
                          _buildSectionTitle("Danger Zone"),
                          const SizedBox(height: 12),
                          _buildDangerZone(rootContext),
                          
                          const SizedBox(height: 40),
                          _buildSignOutButton(rootContext),
                        ],
                        
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppBar(UserModel? user) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(_isEditing ? "Edit Profile" : "Profile", 
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined, color: AppColors.primaryPink),
          onPressed: () => setState(() => _isEditing = !_isEditing),
        ),
      ],
    );
  }

  Widget _buildHeader(UserModel? user) {
    return Column(
      children: [
        _buildAvatar(user),
        const SizedBox(height: 16),
        Text(user?.fullName ?? "User", 
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        Text(user?.email ?? "email@example.com", 
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildAvatar(UserModel? user) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: _newAvatar != null
                ? ClipOval(child: Image.file(_newAvatar!, width: 100, height: 100, fit: BoxFit.cover))
                : user?.profileImageUrl != null
                    ? ClipOval(child: Image.network(user!.profileImageUrl!, 
                        width: 100, height: 100, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50, color: AppColors.deepPink)))
                    : const Icon(Icons.person, size: 50, color: AppColors.deepPink),
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) setState(() => _newAvatar = File(picked.path));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primaryPink, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow(dynamic dashData) {
    return Row(
      children: [
        _statItem(dashData?.lastAnalysis?.overallScore?.toString() ?? "0", "%", "Skin Score"),
        _statItem(dashData?.totalAnalyses.toString() ?? "0", "", "Scans"),
        _statItem(dashData?.currentStreak.toString() ?? "0", "", "Days Streak"),
      ],
    );
  }

  Widget _statItem(String value, String unit, String label) {
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryPink)),
                if (unit.isNotEmpty) TextSpan(text: unit, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryPink)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark));
  }

  Widget _buildSkinProfileCard(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          _profileRow("💧", "Skin Type", user?.skinType ?? "Not set"),
          const Divider(height: 24, thickness: 0.5),
          _profileRow("🎯", "Primary Concerns", user?.skinConcerns ?? "Not set"),
          const Divider(height: 24, thickness: 0.5),
          _profileRow("⚠️", "Allergies", "None detected"),
          const Divider(height: 24, thickness: 0.5),
          _profileRow("📅", "Age Range", "25-30 years"),
        ],
      ),
    );
  }

  Widget _profileRow(String emoji, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
          ]),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext rootContext) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        children: [
          _settingTile(Icons.notifications_none_rounded, "Notifications", "Manage your alerts", () {}),
          _settingTile(Icons.mail_outline_rounded, "Email Preferences", "Newsletter & updates", () {}),
          _settingTile(Icons.lock_outline_rounded, "Change Password", "Security and access", () => _showChangePasswordDialog(rootContext)),
          _settingTile(Icons.help_outline_rounded, "Help & Support", "FAQs and contact us", () {}),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        children: [
          _settingTile(Icons.description_outlined, "Terms of Service", "Legal agreements", () {}),
          _settingTile(Icons.privacy_tip_outlined, "Privacy Policy", "How we protect your data", () {}),
          _settingTile(Icons.info_outline_rounded, "App Version", "v1.2.0", () {}),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext rootContext) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        children: [
          _settingTile(Icons.delete_forever_rounded, "Delete Account", "Permanently remove your data", 
            () => _showDeleteConfirmation(rootContext), color: AppColors.error),
        ],
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, String subtitle, VoidCallback onTap, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.primaryPink),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color ?? AppColors.textDark)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildSignOutButton(BuildContext rootContext) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _signOut(rootContext),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text("Sign Out", style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.red.shade400,
          backgroundColor: Colors.red.shade50,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext rootContext) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _editField(_firstCtrl, "First Name", Icons.person_outline),
          const SizedBox(height: 16),
          _editField(_lastCtrl, "Last Name", Icons.person_outline),
          const SizedBox(height: 16),
          _editField(_phoneCtrl, "Phone Number", Icons.phone_outlined, type: TextInputType.phone),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _saveProfile(rootContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Update Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editField(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryPink),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primaryPink, width: 2)),
        filled: true, fillColor: Colors.grey.shade50,
      ),
    );
  }

  void _signOut(BuildContext rootContext) {
    showDialog(
      context: rootContext,
      builder: (ctx) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to exit?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              rootContext.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text("Sign Out", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext rootContext) {
    showDialog(
      context: rootContext,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("This action is irreversible. All your skin data, scans, and reports will be permanently deleted. Do you wish to continue?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAccount(rootContext);
            },
            child: const Text("Delete Permanently", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext rootContext) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final api = rootContext.read<ApiService>();

    showDialog(
      context: rootContext,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, obscureText: true, 
              decoration: InputDecoration(hintText: "Current password", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, obscureText: true,
              decoration: InputDecoration(hintText: "New password (min 8 chars)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (newCtrl.text.length < 8) return;
              try {
                await api.changePassword(oldCtrl.text, newCtrl.text);
                if (rootContext.mounted) {
                  Navigator.pop(ctx);
                  messengerKey.currentState?.showSnackBar(const SnackBar(
                    content: Text("Password changed successfully!"), backgroundColor: AppColors.success,
                  ));
                }
              } catch (e) {
                messengerKey.currentState?.showSnackBar(SnackBar(
                  content: Text(e.toString()), backgroundColor: AppColors.error,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Change", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
