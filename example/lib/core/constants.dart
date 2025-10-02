import 'package:example/models/product.dart';
import 'package:flutter/widgets.dart';
import 'package:yure_payment_core/core/models.dart';

const PaymentConfig kPaymentConfig = PaymentConfig(
  merchantId: "M001",
  merchantName: "SmartBye",
);

const List<Product> kProducts = [
  Product(name: 'Ordinateur portable', price: 150000, icon: '💻'),
  Product(name: 'Smartphone', price: 75000, icon: '📱'),
  Product(name: 'Ecouteurs', price: 15000, icon: '🎧'),
  Product(name: 'Tablette', price: 300000, icon: '📟'),
  Product(name: 'Smartwatch', price: 120000, icon: '⌚'),
];

abstract class AppColors {
  static const Color main = Color.fromARGB(255, 44, 8, 102);
  static const Color mainLight = Color.fromARGB(255, 232, 226, 241);
}
