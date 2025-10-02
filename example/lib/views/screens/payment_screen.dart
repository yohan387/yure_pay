import 'dart:async';

import 'package:example/controllers/payment_controller.dart';
import 'package:example/core/constants.dart';
import 'package:example/core/snackbar.dart';
import 'package:example/models/product.dart';
import 'package:example/views/widgets/payment/summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_tips/yure_tips.dart';

class PaymentScreen extends StatefulWidget {
  final Product product;
  final int quantity;
  final int totalPrice;

  const PaymentScreen({
    super.key,
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentController _paymentController = PaymentController();

  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<PaymentStatus>? _paymentStatusSubscription;
  int? _currentTransactionId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _paymentStatusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      await _paymentController.loadProviders();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processPayment() async {
    if (_paymentController.selectedProvider == null) {
      AppSnackBar.warning(context, 'Veuillez sélectionner un mode de paiement');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final mainPaymentResult = await _paymentController.processMainPayment(
        amount: widget.totalPrice,
        providerName: _paymentController.selectedProvider!.name,
      );

      _currentTransactionId = mainPaymentResult.transactionId;

      // Démarrer l'écoute du statut en arrière-plan
      _listenToPaymentStatus(_currentTransactionId!);

      // Suggérer les tips IMMÉDIATEMENT sans attendre le résultat
      await _handleTipSuggestion(mainPaymentResult);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _listenToPaymentStatus(int transactionId) {
    _paymentStatusSubscription?.cancel();

    _paymentStatusSubscription = _paymentController
        .getPaymentStatus(transactionId)
        .listen(
          (status) {
            if (status != PaymentStatus.inProgress) {
              setState(() => _isLoading = false);
            }

            if (status == PaymentStatus.succeeded) {
              _handleFinalSuccess();
            } else if (status == PaymentStatus.failed ||
                status == PaymentStatus.canceled) {
              if (mounted) {
                AppSnackBar.error(context, 'Le paiement a échoué');
              }
              _paymentStatusSubscription?.cancel();
            }
          },
          onError: (error) {
            if (mounted) {
              AppSnackBar.error(context, 'Erreur lors du suivi du paiement');
            }
          },
        );
  }

  Future<void> _handleTipSuggestion(PaymentResult result) async {
    if (!mounted) return;
    if (result.request == null) {
      AppSnackBar.error(
        context,
        "Impossible d'accéder aux infos pour le pourboire",
      );
      return;
    }
    try {
      YureTips.instance.suggestTip(context: context, result: result);

      // Ne pas naviguer ici, attendre le résultat final du paiement
      // La navigation se fera dans _handleFinalSuccess()
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, e.toString());
      }
    }
  }

  void _handleFinalSuccess() {
    if (mounted) {
      _paymentStatusSubscription?.cancel();
      Navigator.popUntil(context, (route) => route.isFirst);
      AppSnackBar.success(context, 'Paiement réussi !');
    }
  }

  /// Construit la carte d'un provider
  Widget _buildProviderCard(ProviderInfo provider) {
    final isSelected = _paymentController.selectedProvider?.id == provider.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isSelected ? AppColors.mainLight : Colors.white,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Text(provider.logo, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          provider.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.main)
            : const Icon(Icons.radio_button_unchecked),
        onTap: () {
          setState(() {
            _paymentController.selectProvider(provider);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Traitement du paiement...'),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé de commande
                SummaryWidget(
                  product: widget.product,
                  quantity: widget.quantity,
                  totalPrice: widget.totalPrice,
                ),

                // Message d'erreur
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Sélection du provider
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Sélectionnez un moyen de paiement',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                // Liste des providers
                Expanded(
                  child: _paymentController.availableProviders.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun mode de paiement disponible',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              _paymentController.availableProviders.length,
                          itemBuilder: (context, index) {
                            final provider =
                                _paymentController.availableProviders[index];
                            return _buildProviderCard(provider);
                          },
                        ),
                ),
              ],
            ),

      // Bouton de paiement
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _processPayment,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Valider le paiement',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
