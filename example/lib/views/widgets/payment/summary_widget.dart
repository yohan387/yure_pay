import 'package:example/core/constants.dart';
import 'package:example/core/extensions.dart';
import 'package:example/models/product.dart';
import 'package:flutter/material.dart';

class SummaryWidget extends StatelessWidget {
  const SummaryWidget({
    super.key,
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });

  final Product product;
  final int quantity;
  final int totalPrice;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé paiement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Produit:', product.name),
            _buildSummaryRow('Quantité:', quantity.toString()),
            _buildSummaryRow('Prix unitaire:', product.price.formatAsAmount()),
            const Divider(height: 20),
            _buildSummaryRow(
              'Total:',
              totalPrice.formatAsAmount(),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 22 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.main : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
