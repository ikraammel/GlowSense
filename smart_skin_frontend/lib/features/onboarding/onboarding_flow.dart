import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../constants/colors.dart';
import '../../data/services/api_service.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});
  @override State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Collected data
  String? _skinType;
  final List<String> _concerns = [];
  String? _routinePreference;
  String? _effortLevel;
  String? _sunExposure;

  final _skinTypes = [
    {'value': 'NORMAL', 'label': 'Normal', 'icon': '✨'},
    {'value': 'SEC', 'label': 'Dry', 'icon': '🏜️'},
    {'value': 'GRAS', 'label': 'Oily', 'icon': '💧'},
    {'value': 'MIXTE', 'label': 'Combination', 'icon': '🌗'},
    {'value': 'SENSIBLE', 'label': 'Sensitive', 'icon': '🌸'},
    {'value': 'ACNEIQUE', 'label': 'Acne-prone', 'icon': '🔴'},
  ];

  final _concernsList = ['acne', 'taches', 'rougeurs', 'pores', 'cernes', 'rides', 'hydratation'];

  void _nextPage() {
    if (_currentPage < 3) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    } else {
      _submitOnboarding();
    }
  }

  Future<void> _submitOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      await api.completeOnboarding({
        'skinType': _skinType ?? 'NORMAL',
        'skinConcerns': _concerns.join(','),
        'routinePreference': _routinePreference ?? 'moderate',
        'effortLevel': _effortLevel ?? 'medium',
        'sunExposure': _sunExposure ?? 'moderate',
      });
      if (mounted) context.read<AuthBloc>().add(const CheckAuthStatus());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSkinTypePage(),
                  _buildConcernsPage(),
                  _buildRoutinePage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(4, (i) => Expanded(
          child: Container(
            height: 6, margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: i <= _currentPage ? AppColors.primaryPink : Colors.grey.shade200,
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildSkinTypePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's your skin type?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("This helps us personalize your routine.", style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.3, crossAxisSpacing: 12, mainAxisSpacing: 12,
              ),
              itemCount: _skinTypes.length,
              itemBuilder: (context, i) {
                final skin = _skinTypes[i];
                final selected = _skinType == skin['value'];
                return GestureDetector(
                  onTap: () => setState(() => _skinType = skin['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryPink.withOpacity(0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.primaryPink : Colors.grey.shade200,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(skin['icon']!, style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 8),
                        Text(skin['label']!, style: TextStyle(
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          color: selected ? AppColors.deepPink : AppColors.textDark,
                          fontSize: 15,
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConcernsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Main concerns?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Select all that apply.", style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
          const SizedBox(height: 30),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _concernsList.map((c) {
              final selected = _concerns.contains(c);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) _concerns.remove(c); else _concerns.add(c);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryPink : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: selected ? AppColors.primaryPink : Colors.grey.shade300),
                  ),
                  child: Text(c, style: TextStyle(
                    color: selected ? Colors.white : AppColors.textDark,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  )),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your routine preference?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _radioGroup("Routine", ['minimal', 'moderate', 'complete'], _routinePreference,
              (v) => setState(() => _routinePreference = v)),
          const SizedBox(height: 20),
          _radioGroup("Effort level", ['low', 'medium', 'high'], _effortLevel,
              (v) => setState(() => _effortLevel = v)),
          const SizedBox(height: 20),
          _radioGroup("Sun exposure", ['rare', 'moderate', 'frequent'], _sunExposure,
              (v) => setState(() => _sunExposure = v)),
        ],
      ),
    );
  }

  Widget _radioGroup(String title, List<String> options, String? selected, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final isSelected = selected == opt;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(opt),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryPink : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? AppColors.primaryPink : Colors.grey.shade300),
                  ),
                  child: Text(opt, textAlign: TextAlign.center,
                    style: TextStyle(color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Profile", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Here's a summary of your skin profile.", style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
          const SizedBox(height: 30),
          _summaryCard("Skin Type", _skinType ?? 'Not selected'),
          _summaryCard("Concerns", _concerns.isEmpty ? 'None' : _concerns.join(', ')),
          _summaryCard("Routine", _routinePreference ?? 'Not selected'),
          _summaryCard("Effort", _effortLevel ?? 'Not selected'),
          _summaryCard("Sun Exposure", _sunExposure ?? 'Not selected'),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  setState(() => _currentPage--);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryPink),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Back", style: TextStyle(color: AppColors.primaryPink)),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_currentPage < 3 ? "Continue" : "Get Started",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
