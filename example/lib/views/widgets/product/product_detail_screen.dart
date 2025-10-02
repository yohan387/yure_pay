import 'package:example/core/constants.dart';
import 'package:example/core/extensions.dart';
import 'package:example/models/product.dart';
import 'package:example/views/screens/payment_screen.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void proceedToPayment() {
    final totalPrice = widget.product.price * quantity;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          product: widget.product,
          quantity: quantity,
          totalPrice: totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.product.price * quantity;

    return Scaffold(
      appBar: AppBar(title: Text('Détails Produit')),
      body: SafeArea(
        child: Card(
          margin: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Information
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Hero(
                        tag: "ImgProduit-${widget.product.name}",
                        child: Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 244, 239, 253),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.product.icon,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.product.price.formatAsAmount(),
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.main,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Selector
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quantité:', style: TextStyle(fontSize: 18)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: decrementQuantity,
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: incrementQuantity,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Total Price
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      totalPrice.formatAsAmount(),
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.main,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Proceed to Payment Button
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: proceedToPayment,
          child: Text(
            'Payer',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
