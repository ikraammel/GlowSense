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
import 'app_version_screen.dart';
import 'email_preferences_screen.dart';
import 'help_support_screen.dart';
import 'notifications_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _firstCtrl, _lastCtrl, _emailCtrl;
  bool _isLoading = false;
  File? _newAvatar;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;
    _firstCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastCtrl = TextEditingController(text: user?.lastName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      if (_newAvatar != null) {
        await api.uploadAvatar(_newAvatar!.path);
      }
      await api.updateProfile({
        'firstName': _firstCtrl.text.trim(),
        'lastName': _lastCtrl.text.trim(),
      });

      if (!mounted) return;

      context.read<AuthBloc>().add(const CheckAuthStatus());
      setState(() {
        _isEditing = false;
        _newAvatar = null;
      });

      messengerKey.currentState?.showSnackBar(const SnackBar(
        content: Text("Profil mis à jour !"),
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

  Future<void> _deleteAccount() async {
    final api = context.read<ApiService>();
    try {
      await api.requestAccountDeletion();
      if (!mounted) return;
      context.read<AuthBloc>().add(const CheckAuthStatus());
      messengerKey.currentState?.showSnackBar(const SnackBar(
        content: Text("Suppression demandée. Votre compte sera supprimé dans 30 jours."),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      messengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _cancelDeletion() async {
    final api = context.read<ApiService>();
    try {
      await api.cancelAccountDeletion();
      if (!mounted) return;
      context.read<AuthBloc>().add(const CheckAuthStatus());
      messengerKey.currentState?.showSnackBar(const SnackBar(
        content: Text("Suppression annulée !"),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      messengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.error,
      ));
    }
  }

  String _deletionDate(String deletionRequestedAt) {
    final date = DateTime.parse(deletionRequestedAt).add(const Duration(days: 30));
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (user != null && user.deletionRequestedAt != null)
                          _buildDeletionNotice(user),
                        _buildHeader(user),
                        const SizedBox(height: 24),
                        _buildStatsRow(dashData),
                        const SizedBox(height: 32),
                        if (_isEditing)
                          _buildEditForm()
                        else ...[
                          _buildSectionTitle("Profil de peau"),
                          const SizedBox(height: 12),
                          _buildSkinProfileCard(user),
                          const SizedBox(height: 32),
                          _buildSectionTitle("Paramètres"),
                          const SizedBox(height: 12),
                          _buildSettingsSection(user),
                          const SizedBox(height: 32),
                          _buildSectionTitle("À propos"),
                          const SizedBox(height: 12),
                          _buildAboutSection(),
                          const SizedBox(height: 32),
                          _buildSectionTitle("Zone de danger"),
                          const SizedBox(height: 12),
                          _buildDangerZone(user),
                          const SizedBox(height: 40),
                          _buildSignOutButton(),
                        ],
                        const SizedBox(height: 24),
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

  Widget _buildDeletionNotice(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre compte sera supprimé le ${_deletionDate(user.deletionRequestedAt!)}. ',
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Reconnectez-vous avant cette date pour l\'annuler ou cliquez ci-dessous.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
                TextButton(
                  onPressed: _cancelDeletion,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                  child: const Text("Annuler la suppression", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.backgroundLight.withOpacity(0.95),
              ],
              stops: const [0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(_isEditing),
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _isEditing ? "Modifier le profil" : "Mon profil",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 17,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        centerTitle: true,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () => setState(() => _isEditing = !_isEditing),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isEditing
                      ? AppColors.error.withOpacity(0.15)
                      : AppColors.primaryPink.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isEditing
                        ? AppColors.error.withOpacity(0.3)
                        : AppColors.primaryPink.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isEditing ? Icons.close : Icons.edit_outlined,
                    key: ValueKey(_isEditing),
                    color: _isEditing ? AppColors.error : AppColors.primaryPink,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textGrey,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel? user) {
    return Column(
      children: [
        _buildAvatar(user),
        const SizedBox(height: 20),
        Text(
          user?.fullName ?? "Utilisateur",
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email, size: 14, color: AppColors.primaryPink),
              const SizedBox(width: 6),
              Text(
                user?.email ?? "email@exemple.com",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryPink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(UserModel? user) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primaryPink, AppColors.deepPink],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPink.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: _newAvatar != null
                  ? Image.file(
                _newAvatar!,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              )
                  : user?.profileImageUrl != null
                  ? Image.network(
                user!.profileImageUrl!,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 55,
                    color: AppColors.deepPink,
                  ),
                ),
              )
                  : Container(
                color: AppColors.primaryPink.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 55,
                  color: AppColors.deepPink,
                ),
              ),
            ),
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) setState(() => _newAvatar = File(picked.path));
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPink, AppColors.deepPink],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow(dynamic dashData) {
    return Row(
      children: [
        _statItem(dashData?.lastAnalysis?.overallScore?.toString() ?? "0", "%", "Score Peau"),
        _statItem(dashData?.totalAnalyses.toString() ?? "0", "", "Analyses"),
        _statItem(dashData?.currentStreak.toString() ?? "0", "", "Série"),
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
          _profileRow(Icons.cake_outlined, "Âge", "${user?.age ?? "Non défini"} ans"),
          const Divider(height: 24, thickness: 0.5),
          _profileRow(Icons.opacity, "Type de peau", user?.skinType ?? "Non défini"),
          const Divider(height: 24, thickness: 0.5),
          _profileRow(Icons.track_changes, "Préoccupations", _formatConcerns(user?.skinConcerns)),
          const Divider(height: 24, thickness: 0.5),
          _profileRow(Icons.wb_sunny_outlined, "Exposition Soleil", user?.sunExposure ?? "Non défini"),
          const Divider(height: 24, thickness: 0.5),
          _profileRow(Icons.speed, "Niveau d'effort", user?.effortLevel ?? "Non défini"),
          const Divider(height: 24, thickness: 0.5),
          _profileRow(Icons.auto_awesome, "Préférence Routine", user?.routinePreference ?? "Non défini"),
          const Divider(height: 24, thickness: 0.5),
          _profileRow(Icons.science_outlined, "Ingrédients à éviter", _formatIngredients(user?.ingredientsToAvoid)),
          const Divider(height: 24, thickness: 0.5),
          _profileRow(Icons.emoji_emotions_outlined, "Bénéfices souhaités", _formatBenefits(user?.desiredBenefits)),
        ],
      ),
    );
  }

  String _formatConcerns(String? concerns) {
    if (concerns == null || concerns.isEmpty) return "Non défini";
    final list = concerns.split(',');
    if (list.length > 3) return "${list.take(3).join(', ')}...";
    return concerns.replaceAll(',', ', ');
  }

  String _formatIngredients(String? ingredients) {
    if (ingredients == null || ingredients.isEmpty) return "Aucun";
    return ingredients.replaceAll(',', ', ');
  }

  String _formatBenefits(String? benefits) {
    if (benefits == null || benefits.isEmpty) return "Non défini";
    return benefits.replaceAll(',', ', ');
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.primaryPink),
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

  Widget _buildSettingsSection(UserModel? user) {
    final notificationsEnabled = user?.notificationsEnabled ?? true;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        children: [
          _settingTile(Icons.notifications_none_rounded, "Notifications", "Gérez vos alertes", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsSettingsScreen(initialEnabled: notificationsEnabled)));
          }),
          _settingTile(Icons.mail_outline_rounded, "Préférences e-mail", "Newsletter et mises à jour", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailPreferencesScreen()));
          }),
          _settingTile(Icons.lock_outline_rounded, "Changer le mot de passe", "Sécurité et accès", _showChangePasswordDialog),
          _settingTile(Icons.help_outline_rounded, "Aide et support", "FAQ et nous contacter", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
          }),
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
          _settingTile(Icons.description_outlined, "Conditions d'utilisation", "Accords légaux", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()));
          }),
          _settingTile(Icons.privacy_tip_outlined, "Politique de confidentialité", "Protection des données", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
          }),
          _settingTile(Icons.info_outline_rounded, "Version", "v1.0.0 (Build 42)", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AppVersionScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildDangerZone(UserModel? user) {
    final isDeleting = user?.deletionRequestedAt != null;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]),
      child: Column(
        children: [
          if (isDeleting)
            _settingTile(Icons.undo_rounded, "Annuler la suppression", "Récupérer votre compte",
              _cancelDeletion, color: Colors.orange)
          else
            _settingTile(Icons.delete_forever_rounded, "Supprimer le compte", "Suppression définitive",
              _showDeleteConfirmation, color: AppColors.error),
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

  Widget _buildSignOutButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _signOut,
        icon: const Icon(Icons.logout, size: 20),
        label: const Text("Déconnexion", style: TextStyle(fontSize: 16)),
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

  Widget _buildEditForm() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _editField(_firstCtrl, "Prénom", Icons.person_outline),
            const SizedBox(height: 16),
            _editField(_lastCtrl, "Nom", Icons.person_outline),
            const SizedBox(height: 16),
            _editField(_emailCtrl, "E-mail", Icons.email_outlined, type: TextInputType.emailAddress, readOnly: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Mettre à jour", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text, bool readOnly = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      readOnly: readOnly,
      style: TextStyle(color: readOnly ? Colors.grey : Colors.black87),
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: readOnly ? Colors.grey : AppColors.primaryPink),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
      ),
    );
  }

  void _signOut() {
    final bloc = context.read<AuthBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vous déconnecter ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              print("LOGOUT CLICKED");
              bloc.add(const LogoutRequested());
            },
            child: const Text("Quitter", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer le compte"),
        content: const Text("Cette action est irréversible. Toutes vos données seront perdues. Continuer ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAccount();
            },
            child: const Text("Supprimer", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final api = context.read<ApiService>();
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(api: api),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  final ApiService api;
  const ChangePasswordDialog({super.key, required this.api});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  bool _oldVisible = false;
  bool _newVisible = false;
  bool _loading = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Changer le mot de passe"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldCtrl, obscureText: !_oldVisible,
              decoration: InputDecoration(
                hintText: "Mot de passe actuel",
                suffixIcon: IconButton(
                  icon: Icon(_oldVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _oldVisible = !_oldVisible),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newCtrl, obscureText: !_newVisible,
              decoration: InputDecoration(
                hintText: "Nouveau (min 8 caractères)",
                suffixIcon: IconButton(
                  icon: Icon(_newVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _newVisible = !_newVisible),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(
          onPressed: _loading ? null : () async {
            final oldP = _oldCtrl.text.trim();
            final newP = _newCtrl.text.trim();

            if (oldP.isEmpty) {
              _showError("Veuillez saisir votre mot de passe actuel.");
              return;
            }

            if (newP.length < 8) {
              _showError("Le nouveau mot de passe doit faire au moins 8 caractères.");
              return;
            }

            if (oldP == newP) {
              _showError("Le nouveau mot de passe doit être différent de l'actuel.");
              return;
            }

            setState(() => _loading = true);
            try {
              await widget.api.changePassword(oldP, newP);
              if (mounted) {
                Navigator.pop(context);
                messengerKey.currentState?.showSnackBar(const SnackBar(
                  content: Text("Mot de passe changé avec succès !"),
                  backgroundColor: AppColors.success,
                ));
              }
            } catch (e) {
              if (mounted) {
                setState(() => _loading = false);
                _showError(e.toString());
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
          child: _loading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Changer", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showError(String msg) {
     messengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
     ));
  }
}
