import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/products/product_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Product Management',
            theme: ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.themeMode, // <-- follows provider
            debugShowCheckedModeBanner: false,
            home: ProductListScreen(),
          );
        },
      ),
    );
  }
}
