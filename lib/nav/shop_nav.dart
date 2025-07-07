import 'package:flutter/material.dart';
import '../screens/shop_page.dart';

/// Navigator for Shop tab with internal routing
class ShopNavigator extends StatelessWidget {
  const ShopNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const ShopPage(),
            );
          case '/itemDetail':
            final itemId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => _ItemDetailPage(itemId: itemId),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const ShopPage(),
            );
        }
      },
    );
  }
}

/// Placeholder item detail page
class _ItemDetailPage extends StatelessWidget {
  final String? itemId;
  
  const _ItemDetailPage({this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: Center(
        child: Text('Item ID: ${itemId ?? 'Unknown'}'),
      ),
    );
  }
}