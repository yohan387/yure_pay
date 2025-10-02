import 'package:example/views/widgets/payment/payment_list.dart';
import 'package:flutter/material.dart';
import 'package:yure_payment_core/yure_payment_core.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final YurePayment _yurePaymentSdk = YurePayment.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historique des Paiements')),
      body: FutureBuilder(
        future: _yurePaymentSdk.getPayments(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
            return PaymentList(
              payments: asyncSnapshot.data!,
              statusStreamGetter: _yurePaymentSdk.getPaymentStatus,
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
