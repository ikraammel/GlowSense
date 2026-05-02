import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../constants/colors.dart';
import '../../data/services/api_service.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  static const int _totalPages = 10;
  bool _isLoading = false;
  bool _showWelcome = false;

  // ── Étape 1 : Nom (Pseudo Onboarding) ─────────────────────────────────────
  final _nameCtrl = TextEditingController();

  // ── Étape 2 : À propos de vous ──────────────────────────────────────────────
  final _ageCtrl = TextEditingController();
  String? _gender;
  String? _skinType;

  // ── Étape 3 : Ethnicité ───────────────────────────────────────────────────
  String? _ethnicity;

  // ── Étape 4 : Problèmes de peau ──────────────────────────────────────────────
  final List<String> _concerns = [];

  // ── Étape 5 : Votre peau aujourd'hui ──────────────────────────────────────────
  String? _sensitivity;
  String? _tiredness;
  String? _stress;

  // ── Étape 6 : Exposition au soleil ──────────────────────────────────────────
  String? _sunExposure;

  // ── Étape 7 : Préférence de routine ─────────────────────────────────────────
  String? _routinePreference;

  // ── Étape 8 : Ingrédients à éviter ─────────────────────────────────────────
  final List<String> _ingredientsToAvoid = [];

  // ── Étape 9 : Niveau d'effort ──────────────────────────────────────────────
  String? _effortLevel;

  // ── Étape 10 : Bénéfices souhaités ──────────────────────────────────────────
  final List<String> _benefits = [];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    } else {
      _submitOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  Future<void> _submitOnboarding() async {
    setState(() => _isLoading = true);
    try {
      await context.read<ApiService>().completeOnboarding({
        'onboardingName': _nameCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
        'gender': _gender ?? '',
        'skinType': _mapSkinType(_skinType),
        'ethnicity': _ethnicity ?? '',
        'skinConcerns': _concerns.join(','),
        'skinSensitivity': _sensitivity ?? '',
        'tirednessLevel': _tiredness ?? '',
        'stressLevel': _stress ?? '',
        'sunExposure': _sunExposure ?? '', // On envoie la valeur brute en français
        'routinePreference': _routinePreference ?? '', // On envoie la valeur brute en français
        'ingredientsToAvoid': _ingredientsToAvoid.join(','),
        'effortLevel': _effortLevel ?? '', // On envoie la valeur brute en français
        'desiredBenefits': _benefits.join(','),
      });
      setState(() { _isLoading = false; _showWelcome = true; });
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) context.read<AuthBloc>().add(const CheckAuthStatus());
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _mapSkinType(String? v) {
    const m = {
      'Sèche': 'SEC', 'Grasse': 'GRAS', 'Mixte': 'MIXTE',
      'Normale': 'NORMAL', 'Sensible': 'SENSIBLE', 'Pas sûr': 'NORMAL',
    };
    return m[v] ?? 'NORMAL';
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcome) return _buildWelcomeScreen();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNamePage(),
                  _buildAboutPage(),
                  _buildEthnicityPage(),
                  _buildConcernsPage(),
                  _buildSkinTodayPage(),
                  _buildSunExposurePage(),
                  _buildRoutinePrefPage(),
                  _buildIngredientsPage(),
                  _buildEffortPage(),
                  _buildBenefitsPage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          if (_currentPage > 0)
            GestureDetector(
              onTap: _prevPage,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.black87),
              ),
            )
          else
            const SizedBox(width: 38),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _totalPages,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPink,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primaryPink.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(height: 22, width: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(_currentPage < _totalPages - 1 ? 'Suivant' : 'Commencer',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Comment souhaitez-vous\nque l'on vous appelle ?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 10),
          const Text(
            "C'est ainsi que vous apparaîtrez sur votre écran d'accueil.",
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 56),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryPink, width: 2)),
              hintText: 'Votre pseudo',
              hintStyle: TextStyle(fontSize: 26, color: Colors.black26, fontWeight: FontWeight.bold),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutPage() {
    final skinTypes = ['Sèche', 'Grasse', 'Mixte', 'Normale', 'Sensible', 'Pas sûr'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Parlez-nous de vous",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Nous utilisons ces informations pour personnaliser vos recommandations de soins.",
              style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4)),
          const SizedBox(height: 22),

          _sectionCard(
            label: 'Âge',
            child: TextField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Tapez votre âge...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),

          _sectionCard(
            label: 'Genre',
            child: Row(
              children: ['Femme', 'Homme'].map((g) {
                final sel = _gender == g;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primaryPink.withOpacity(0.12) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? AppColors.primaryPink : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(g,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                            color: sel ? AppColors.deepPink : Colors.black87,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          _sectionCard(
            label: 'Type de peau',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: skinTypes.map((s) {
                final sel = _skinType == s;
                return GestureDetector(
                  onTap: () => setState(() => _skinType = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryPink.withOpacity(0.12) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? AppColors.primaryPink : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(s,
                        style: TextStyle(
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          color: sel ? AppColors.deepPink : Colors.black87,
                          fontSize: 14,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEthnicityPage() {
    final options = ['Asie de l\'Est', 'Asie du Sud', 'Noir / Origine Africaine', 'Moyen-Orient / Afrique du Nord', 'Latino / Hispanique', 'Blanc / Caucasien', 'Préfère ne pas répondre'];
    return _buildRadioListPage(title: 'Quelle est votre ethnicité ?', subtitle: 'Différents types de peau ont des attributs uniques.', options: options, selected: _ethnicity, onSelect: (v) => setState(() => _ethnicity = v));
  }

  Widget _buildConcernsPage() {
    final concerns = ['Pas sûr', 'Acné', 'Rides et ridules', 'Peau grasse', 'Pores dilatés', 'Rougeurs', 'Taches brunes', 'Cernes', 'Déshydratation', 'Sensibilité', 'Teint irrégulier'];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        children: [
          const Text("Quels sont vos\nproblèmes de peau ?", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.25)),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(width: 100, height: 300, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.face, size: 60, color: AppColors.primaryPink)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: concerns.map((c) {
                    final sel = _concerns.contains(c);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (c == 'Pas sûr') { _concerns.clear(); if (!sel) _concerns.add(c); }
                        else { _concerns.remove('Pas sûr'); if (sel) _concerns.remove(c); else _concerns.add(c); }
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(color: sel ? const Color(0xFFFFF9E6) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? const Color(0xFFE8C97A) : Colors.grey.shade200)),
                        child: Text(c, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkinTodayPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _subQuestion("À quel point votre peau est sensible ?", ['Pas du tout', 'Légèrement', 'Modérément', 'Très'], _sensitivity, (v) => setState(() => _sensitivity = v)),
          const SizedBox(height: 20),
          _subQuestion("Niveau de fatigue ?", ['Bien reposé', 'Fatigué', 'Épuisé'], _tiredness, (v) => setState(() => _tiredness = v)),
          const SizedBox(height: 20),
          _subQuestion("Niveau de stress ?", ['Calme', 'Stressé', 'Très stressé'], _stress, (v) => setState(() => _stress = v)),
        ],
      ),
    );
  }

  Widget _buildSunExposurePage() {
    return _buildRadioListPage(title: 'Exposition au soleil', subtitle: 'Combien de temps passez-vous au soleil ?', options: ['Rarement', 'Un peu', 'Souvent', 'Pas sûr'], selected: _sunExposure, onSelect: (v) => setState(() => _sunExposure = v));
  }

  Widget _buildRoutinePrefPage() {
    return _buildRadioListPage(title: 'Préférence routine', subtitle: 'Quel type de produits préférez-vous ?', options: ['Produits courants', 'Naturels', 'Qualité médicale'], selected: _routinePreference, onSelect: (v) => setState(() => _routinePreference = v));
  }

  Widget _buildIngredientsPage() {
    final options = ['Pas sûr', 'Parabènes', 'Parfums', 'Sulfates', 'Alcool'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text("Ingrédients à éviter", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: options.map((ing) {
              final sel = _ingredientsToAvoid.contains(ing);
              return FilterChip(label: Text(ing), selected: sel, onSelected: (v) => setState(() { if (v) _ingredientsToAvoid.add(ing); else _ingredientsToAvoid.remove(ing); }));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEffortPage() {
    return _buildRadioListPage(title: 'Niveau d\'effort', subtitle: 'Combien d\'étapes souhaitez-vous ?', options: ['Minimaliste', 'Modéré', 'Enthousiaste'], selected: _effortLevel, onSelect: (v) => setState(() => _effortLevel = v));
  }

  Widget _buildBenefitsPage() {
    return _buildRadioListPage(title: 'Bénéfices souhaités', subtitle: 'Que recherchez-vous en priorité ?', options: ['Éclat', 'Anti-âge', 'Hydratation', 'Fermeté'], selected: _benefits.isEmpty ? null : _benefits.first, onSelect: (v) => setState(() { if (_benefits.contains(v)) _benefits.remove(v); else _benefits.add(v); }), multiSelected: _benefits);
  }

  Widget _buildWelcomeScreen() {
    final name = _nameCtrl.text.isNotEmpty ? _nameCtrl.text.trim() : 'Ami';
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.white),
            const SizedBox(height: 30),
            Text("Salut $name 🌸", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            const Text("Bienvenue dans ton univers skincare !", style: TextStyle(fontSize: 18, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioListPage({required String title, required String subtitle, required List<String> options, required String? selected, required Function(String) onSelect, List<String>? multiSelected}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ...options.map((opt) {
            final isSelected = multiSelected != null ? multiSelected.contains(opt) : selected == opt;
            return ListTile(title: Text(opt), leading: Radio<String>(value: opt, groupValue: isSelected ? opt : '', onChanged: (v) => onSelect(opt)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), tileColor: isSelected ? AppColors.primaryPink.withOpacity(0.1) : Colors.grey.shade50);
          }),
        ],
      ),
    );
  }

  Widget _sectionCard({required String label, required Widget child}) {
    return Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), child]));
  }

  Widget _subQuestion(String question, List<String> opts, String? selected, Function(String) onSelect) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(question, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), Wrap(spacing: 8, children: opts.map((opt) => ChoiceChip(label: Text(opt), selected: selected == opt, onSelected: (v) => onSelect(opt))).toList())]);
  }
}
