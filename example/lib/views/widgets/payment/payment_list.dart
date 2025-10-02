import 'package:example/views/widgets/payment/payment_list_item.dart';
import 'package:flutter/material.dart';
import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';

class PaymentList extends StatefulWidget {
  final List<Payment> payments;
  final Stream<PaymentStatus> Function(int transactionId) statusStreamGetter;

  const PaymentList({
    super.key,
    required this.payments,
    required this.statusStreamGetter,
  });

  @override
  State<PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  @override
  Widget build(BuildContext context) {
    if (widget.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Aucun paiement',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.payments.length,
      itemBuilder: (context, index) {
        return PaymentListItem(payment: widget.payments[index]);
      },
    );
  }
}
