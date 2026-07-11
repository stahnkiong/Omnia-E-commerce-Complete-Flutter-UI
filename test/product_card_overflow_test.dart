import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasar_now/components/product/product_card.dart';
import 'package:pasar_now/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test ProductCard with 2-line title and 240 height style', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    // Set screen size to a standard phone size
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<WishlistProvider>(
            create: (_) => WishlistProvider(),
            child: Row(
              children: [
                Expanded(
                  child: ProductCard(
                    productId: "1",
                    image: "",
                    brandName: "Brand",
                    title: "This is a long product title that spans two lines",
                    price: 10.0,
                    priceAfetDiscount: 8.0,
                    dicountpercent: 20,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 250),
                      maximumSize: const Size(double.infinity, 250),
                      padding: const EdgeInsets.all(8),
                    ),
                    press: () {},
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
      ),
    );

    // Let any pending microtasks run
    await tester.pump();
  });
}
