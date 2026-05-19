import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../constants/constants.dart';

class ProductRecommendationWidget extends StatefulWidget {
  final String skinType;
  final Map<String, double> detectedProblems;

  const ProductRecommendationWidget({
    super.key,
    required this.skinType,
    required this.detectedProblems,
  });

  @override
  State<ProductRecommendationWidget> createState() =>
      _ProductRecommendationWidgetState();
}

class _ProductRecommendationWidgetState
    extends State<ProductRecommendationWidget> {
  List<Map<String, dynamic>> pharmaProducts = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPharmaRecommendations();
  }

  Future<void> fetchPharmaRecommendations() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await Dio().get(
        AppConstants.pharmaRecommendationsUrl,
        queryParameters: {
          'skin_type': _toHfSkinType(widget.skinType),
          'problem': _toHfProblem(_topProblem()),
        },
      );

      final data = response.data;
      final products = data is List
          ? data
          : data is Map
              ? (data['recommendations'] ??
                  data['products'] ??
                  data['data'] ??
                  data['result'])
              : null;

      if (!mounted) return;
      setState(() {
        pharmaProducts = products is List
            ? products
                .whereType<Map>()
                .map((item) => item.map(
                      (key, value) => MapEntry(key.toString(), value),
                    ))
                .toList()
            : [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _topProblem() {
    if (widget.detectedProblems.isEmpty) return 'Acné';
    return widget.detectedProblems.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  String _toHfSkinType(String skinType) {
    final normalized = skinType.toLowerCase().trim();
    if (normalized.contains('gras') || normalized.contains('oily')) {
      return 'Grasse';
    }
    if (normalized.contains('sec') || normalized.contains('dry')) {
      return 'S\u00E8che';
    }
    if (normalized.contains('mix') || normalized.contains('combination')) {
      return 'Mixte';
    }
    if (normalized.contains('sensible') || normalized.contains('sensitive')) {
      return 'Sensible';
    }
    if (normalized.contains('mature') ||
        normalized.contains('ride') ||
        normalized.contains('wrinkle')) {
      return 'Mature';
    }
    return 'Sensible';
  }

  String _toHfProblem(String problem) {
    final normalized = problem.toLowerCase().trim();
    if (normalized.contains('acne') ||
        normalized.contains('acn\u00E9') ||
        normalized.contains('bouton') ||
        normalized.contains('imperfection')) {
      return 'Acn\u00E9';
    }
    if (normalized.contains('blackhead') ||
        normalized.contains('comedon') ||
        normalized.contains('com\u00E9don') ||
        normalized.contains('point noir')) {
      return 'Points Noirs';
    }
    if (normalized.contains('pore')) {
      return 'Pores';
    }
    if (normalized.contains('dark') ||
        normalized.contains('spot') ||
        normalized.contains('tache') ||
        normalized.contains('pigment')) {
      return 'Hyperpigmentation';
    }
    if (normalized.contains('wrinkle') ||
        normalized.contains('ride') ||
        normalized.contains('age') ||
        normalized.contains('\u00E2ge')) {
      return 'Rides';
    }
    if (normalized.contains('hydrat') ||
        normalized.contains('dry') ||
        normalized.contains('sec')) {
      return 'D\u00E9shydratation';
    }
    if (normalized.contains('red') ||
        normalized.contains('rouge') ||
        normalized.contains('rosace')) {
      return 'Rougeurs';
    }
    if (normalized.contains('cerne') ||
        normalized.contains('poche') ||
        normalized.contains('eye')) {
      return 'Cernes/Poches';
    }
    return 'Acn\u00E9';
  }

  String _toPharmaSkinType(String skinType) {
    final normalized = skinType.toLowerCase().trim();
    if (normalized.contains('gras') || normalized.contains('oily')) {
      return 'Grasse';
    }
    if (normalized.contains('sec') || normalized.contains('dry')) {
      return 'Sèche';
    }
    if (normalized.contains('mix') || normalized.contains('combination')) {
      return 'Mixte';
    }
    if (normalized.contains('sensible') || normalized.contains('sensitive')) {
      return 'Sensible';
    }
    if (normalized.contains('mature') ||
        normalized.contains('ride') ||
        normalized.contains('wrinkle')) {
      return 'Mature';
    }
    return 'Sensible';
  }

  String _toPharmaProblem(String problem) {
    final normalized = problem.toLowerCase().trim();
    if (normalized.contains('acne') ||
        normalized.contains('acné') ||
        normalized.contains('bouton') ||
        normalized.contains('imperfection')) {
      return 'Acné';
    }
    if (normalized.contains('blackhead') ||
        normalized.contains('comedon') ||
        normalized.contains('comédon') ||
        normalized.contains('point noir')) {
      return 'Points Noirs';
    }
    if (normalized.contains('pore')) return 'Pores';
    if (normalized.contains('dark') ||
        normalized.contains('spot') ||
        normalized.contains('tache') ||
        normalized.contains('pigment')) {
      return 'Hyperpigmentation';
    }
    if (normalized.contains('wrinkle') ||
        normalized.contains('ride') ||
        normalized.contains('age') ||
        normalized.contains('âge')) {
      return 'Rides';
    }
    if (normalized.contains('hydrat') ||
        normalized.contains('dry') ||
        normalized.contains('sec')) {
      return 'Déshydratation';
    }
    if (normalized.contains('red') ||
        normalized.contains('rouge') ||
        normalized.contains('rosace')) {
      return 'Rougeurs';
    }
    if (normalized.contains('cerne') ||
        normalized.contains('poche') ||
        normalized.contains('eye')) {
      return 'Cernes/Poches';
    }
    return 'Acné';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Erreur: $error'));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produits pharmaceutiques recommandés',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...pharmaProducts.map((product) => ProductCard(product: product)),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final image =
        product['image'] ?? product['image_url'] ?? product['imageUrl'];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: image != null
            ? Image.network(image.toString(),
                width: 56, height: 56, fit: BoxFit.cover)
            : const Icon(Icons.medical_services),
        title: Text(
          (product['name'] ??
                  product['product_name'] ??
                  product['productName'] ??
                  product['title'] ??
                  'Produit')
              .toString(),
        ),
        subtitle: Text(
          (product['description'] ?? product['desc'] ?? product['summary'] ?? '')
              .toString(),
        ),
      ),
    );
  }
}
