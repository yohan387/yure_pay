import 'package:example/core/constants.dart';
import 'package:example/views/screens/product_list_screen.dart';
import 'package:example/views/screens/payment_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:yure_payment_core/yure_payment_core.dart';
import 'package:yure_tips/yure_tips.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YurePay Demo',
      theme: ThemeData(
        colorSchemeSeed: AppColors.main,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor: AppColors.main,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      home: const MyHomePage(title: 'YurePay Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initSdk();
  }

  void initSdk() async {
    await YurePayment.init(kPaymentConfig);
    await YureTips.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildFeatureCard(
              icon: Text("📱", style: TextStyle(fontSize: 48)),
              title: "Boutique en ligne",
              subtitle: "Parcourir les produits",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductListScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Text("🕒", style: TextStyle(fontSize: 48)),
              title: "Historique des paiements",
              subtitle: "Voir mes transactions",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentListScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Text("🎁", style: TextStyle(fontSize: 48)),
              title: "Les tips",
              subtitle: "Gérer les pourboires",
              onTap: () => YureTips.instance.showTips(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
