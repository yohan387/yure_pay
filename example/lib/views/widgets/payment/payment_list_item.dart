import 'package:example/controllers/payment_controller.dart';
import 'package:example/core/constants.dart';
import 'package:example/core/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';

class PaymentListItem extends StatefulWidget {
  final Payment payment;
  final VoidCallback? onPaymentUpdated;

  const PaymentListItem({
    super.key,
    required this.payment,

    this.onPaymentUpdated,
  });

  @override
  State<PaymentListItem> createState() => _PaymentListItemState();
}

class _PaymentListItemState extends State<PaymentListItem> {
  late Stream<PaymentStatus> _statusStream;
  PaymentStatus _currentStatus = PaymentStatus.inProgress;
  bool _isCancelling = false;
  final PaymentController _paymentController = PaymentController();

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.payment.status;
    _initializeStatusStream();
  }

  /// Initialise le stream de statut
  void _initializeStatusStream() {
    try {
      _statusStream = _paymentController.getPaymentStatus(widget.payment.id);
      _listenToStatus();
    } catch (e) {
      debugPrint('Erreur initialisation stream: $e');
    }
  }

  void _listenToStatus() {
    _statusStream.listen(
      (status) {
        debugPrint('🔄 [STREAM] Nouveau statut reçu: $status');

        if (mounted) {
          setState(() {
            _currentStatus = status;
          });
        }

        // Notifier le parent si le statut a changé
        widget.onPaymentUpdated?.call();
      },
      onError: (error) {
        debugPrint('🔴 [STREAM] Erreur: $error');
      },
      onDone: () {
        debugPrint('🏁 [STREAM] Stream terminé pour la transaction');
      },
      cancelOnError: false,
    );
  }

  /// Tente d'annuler le paiement
  Future<void> _cancelPayment() async {
    if (!_canCancelPayment) {
      return;
    }

    setState(() => _isCancelling = true);

    try {
      final success = await _paymentController.cancelPayment(widget.payment.id);

      if (mounted) {
        if (success) {
          AppSnackBar.success(context, '');
        } else {
          AppSnackBar.warning(context, 'Impossible d\'annuler ce paiement');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.success(context, 'Erreur: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  /// Affiche la dialog de confirmation d'annulation
  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Annuler le paiement'),
        content: const Text('Êtes-vous sûr de vouloir annuler ce paiement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelPayment();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.main),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  /// Vérifie si le paiement peut être annulé
  bool get _canCancelPayment {
    return _currentStatus == PaymentStatus.inProgress;
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.inProgress:
        return Icons.hourglass_empty;
      case PaymentStatus.succeeded:
        return Icons.check_circle;
      case PaymentStatus.canceled:
        return Icons.cancel;
      case PaymentStatus.failed:
        return Icons.error;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.inProgress:
        return Colors.orange;
      case PaymentStatus.succeeded:
        return Colors.green;
      case PaymentStatus.canceled:
        return Colors.grey;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.inProgress:
        return 'En cours';
      case PaymentStatus.succeeded:
        return 'Réussi';
      case PaymentStatus.canceled:
        return 'Annulé';
      case PaymentStatus.failed:
        return 'Échec';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(_currentStatus).withAlpha(50),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(_currentStatus),
            color: _getStatusColor(_currentStatus),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              'ID: ${widget.payment.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(_currentStatus).withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(_currentStatus),
                style: TextStyle(
                  color: _getStatusColor(_currentStatus),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Montant: \$${widget.payment.amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 2),
            Text(
              'Provider: ${widget.payment.providerName}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: _buildTrailingWidget(),
      ),
    );
  }

  /// Construit le widget trailing selon l'état
  Widget _buildTrailingWidget() {
    if (_isCancelling) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_currentStatus == PaymentStatus.inProgress) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicateur de progression
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),

          // Bouton d'annulation
          if (_canCancelPayment)
            IconButton(
              icon: const Icon(Icons.cancel, size: 20),
              color: AppColors.main,
              onPressed: _showCancelConfirmation,
              tooltip: 'Annuler le paiement',
            ),
        ],
      );
    }

    return Icon(
      _getStatusIcon(_currentStatus),
      color: _getStatusColor(_currentStatus),
      size: 20,
    );
  }
}
