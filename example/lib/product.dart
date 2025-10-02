import 'package:flutter/material.dart';
import 'package:yure_tips/yure_tips.dart';

void main() {
  runApp(MyApp());
}

class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});
}

class ProviderInfo {
  final String id;
  final String name;
  final String? logo; // Optional logo path or icon data

  ProviderInfo({required this.id, required this.name, this.logo});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> products = [
    Product(name: 'Laptop', price: 999.99),
    Product(name: 'Smartphone', price: 699.99),
    Product(name: 'Headphones', price: 149.99),
    Product(name: 'Tablet', price: 399.99),
    Product(name: 'Smartwatch', price: 199.99),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(products[index].name),
              subtitle: Text('\$${products[index].price.toStringAsFixed(2)}'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailScreen(product: products[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
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
        builder: (context) => PaymentPage(
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
      appBar: AppBar(title: Text('Product Details')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Information
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
              ],
            ),
          ),

          // Quantity Selector
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Quantity:', style: TextStyle(fontSize: 18)),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
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
                ),
              ],
            ),
          ),

          // Total Price
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Proceed to Payment Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: proceedToPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            'Proceed to Payment',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final Product product;
  final int quantity;
  final double totalPrice;

  const PaymentPage({
    Key? key,
    required this.product,
    required this.quantity,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final YureTips _sdk = YureTips.instance;

  ProviderInfo? _selectedProvider;
  final List<ProviderInfo> _paymentProviders = [
    ProviderInfo(id: 'visa', name: 'Visa/MasterCard', logo: '💳'),
    ProviderInfo(id: 'momo', name: 'Mobile Money', logo: '📱'),
    ProviderInfo(id: 'paypal', name: 'PayPal', logo: '🔵'),
    ProviderInfo(id: 'apple_pay', name: 'Apple Pay', logo: '🍎'),
    ProviderInfo(id: 'mock', name: 'Test Provider', logo: '🧪'),
  ];

  void _processPayment() {
    if (_selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a payment provider'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simulate payment processing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Processing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing payment with ${_selectedProvider!.name}...'),
          ],
        ),
      ),
    );

    // Simulate API call delay
    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);

      _sdk.tipsUI.addTipForms(context);
    });
  }

  Widget _buildProviderCard(ProviderInfo provider) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _selectedProvider?.id == provider.id
          ? Colors.blue.withOpacity(0.1)
          : Colors.white,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Text(provider.logo ?? '🏦', style: TextStyle(fontSize: 24)),
        ),
        title: Text(
          provider.name,
          style: TextStyle(
            fontWeight: _selectedProvider?.id == provider.id
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        trailing: _selectedProvider?.id == provider.id
            ? Icon(Icons.check_circle, color: Colors.blue)
            : Icon(Icons.radio_button_unchecked),
        onTap: () {
          setState(() {
            _selectedProvider = provider;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Column(
        children: [
          // Order Summary
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Product:'), Text(widget.product.name)],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quantity:'),
                      Text(widget.quantity.toString()),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Unit Price:'),
                      Text('\$${widget.product.price.toStringAsFixed(2)}'),
                    ],
                  ),
                  Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${widget.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Payment Providers
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _paymentProviders.length,
              itemBuilder: (context, index) {
                return _buildProviderCard(_paymentProviders[index]);
              },
            ),
          ),
        ],
      ),

      // Process Payment Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            'Process Payment',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
