import 'package:flutter/material.dart';
import 'package:yure_tips/yure_tips.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  late final YureTips _sdk;

  @override
  void initState() {
    super.initState();
    YureTips.init().then((_) {
      _sdk = YureTips.instance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _sdk.tipsUI.addTipForms(context);
              },
              child: Text("Add Tip"),
            ),

            ElevatedButton(
              onPressed: () {
                _sdk.tipsUI.showTips(context);
              },
              child: Text("List Tips"),
            ),
          ],
        ),
      ),
    );
  }
}
