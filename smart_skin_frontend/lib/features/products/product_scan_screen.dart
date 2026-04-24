import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/colors.dart';
import '../../data/models/product_scan_model.dart';
import '../../data/services/api_service.dart';

class ProductScanScreen extends StatefulWidget {
  const ProductScanScreen({super.key});
  @override State<ProductScanScreen> createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends State<ProductScanScreen> {
  final _ctrl = TextEditingController();
  bool _isLoading = false;
  ProductScanModel? _result;
  
  List<ProductScanModel> _history = [];
  bool _loadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final result = await context.read<ApiService>().getProductHistory();
      setState(() => _history = result);
    } catch (e) {
      debugPrint("History Error: $e");
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _scan() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() { _isLoading = true; _result = null; });
    try {
      final result = await context.read<ApiService>().scanProduct(
        ProductScanRequestModel(
          productName: "Manual Analysis",
          ingredients: _ctrl.text.trim(),
        ),
      );
      setState(() => _result = result);
      _loadHistory(); // Refresh history after new scan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Product Scanner", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: AppColors.primaryPink,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.science_outlined, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Ingredient Analyzer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Paste ingredients list from any product label",
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Ingredients List", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: TextField(
                  controller: _ctrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: "e.g. Water, Glycerin, Niacinamide, Hyaluronic Acid...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _scan,
                  icon: _isLoading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.analytics_outlined),
                  label: Text(_isLoading ? "Analyzing..." : "Analyze Ingredients",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                  ),
                ),
              ),
              
              if (_result != null) ...[
                const SizedBox(height: 24),
                _buildResult(_result!),
              ],

              const SizedBox(height: 32),
              const Text("Scan History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 16),
              
              if (_loadingHistory)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.primaryPink),
                ))
              else if (_history.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("No history available yet.", style: TextStyle(color: Colors.grey.shade600)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder: (context, index) => _buildHistoryItem(_history[index]),
                ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ProductScanModel item) {
    final DateTime? dateParsed = item.scannedAt != null ? DateTime.tryParse(item.scannedAt!) : null;
    final String dateStr = dateParsed != null 
        ? "${dateParsed.day}/${dateParsed.month}/${dateParsed.year}" 
        : "Unknown date";
    final int score = item.compatibilityScore ?? 0;
    final String percentage = "$score%";
    final bool isGood = score >= 70;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: Colors.pink.shade300, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName ?? "Product Analysis", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(percentage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              Row(
                children: [
                  Icon(isGood ? Icons.trending_up : Icons.trending_down, 
                      color: isGood ? Colors.green : Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(isGood ? "Good" : "Risk", 
                      style: TextStyle(color: isGood ? Colors.green : Colors.red, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult(ProductScanModel r) {
    final score = r.compatibilityScore ?? 0;
    final scoreColor = score >= 70 ? AppColors.success : score >= 40 ? AppColors.warning : AppColors.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Column(children: [
              Text(score.toString(), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: scoreColor)),
              const Text("/100", style: TextStyle(color: Colors.grey)),
              const Text("Compatibility", style: TextStyle(fontWeight: FontWeight.w500)),
            ]),
          )),
          const SizedBox(width: 12),
          Expanded(child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Column(children: [
              Text(r.safetyRating ?? 'N/A', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text("Safety Rating", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              const Text("Overall", style: TextStyle(fontWeight: FontWeight.w500)),
            ]),
          )),
        ]),
        if (r.summary != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Summary", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(r.summary!, style: const TextStyle(color: AppColors.textDark, height: 1.4)),
            ]),
          ),
        ],
        if (r.beneficialIngredients.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ingredientGroup("Beneficial Ingredients", r.beneficialIngredients, AppColors.success),
        ],
        if (r.harmfulIngredients.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ingredientGroup("Ingredients to Avoid", r.harmfulIngredients, AppColors.error),
        ],
      ],
    );
  }

  Widget _ingredientGroup(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: items.map((ing) => Chip(
              label: Text(ing, style: const TextStyle(fontSize: 12)),
              backgroundColor: color.withOpacity(0.1),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
        ],
      ),
    );
  }
}
