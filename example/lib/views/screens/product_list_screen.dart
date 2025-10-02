import 'package:example/core/constants.dart';
import 'package:example/models/product.dart';
import 'package:example/views/widgets/product/product_detail_screen.dart';
import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> products = kProducts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ma Boutique')),
      body: ListView.builder(
        padding: EdgeInsets.only(top: 8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Hero(
                tag: "ImgProduit-${products[index].name}",
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 244, 239, 253),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      products[index].icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
              title: Text(products[index].name),
              subtitle: Text('${products[index].price} F'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
