import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silverskin/controllers/getDataController.dart';
import 'package:silverskin/pages/ADMIN/adminHomePage.dart';
import 'package:silverskin/pages/login.dart';
import 'package:silverskin/pages/splashScreen/splash1.dart';
import 'package:silverskin/pages/users/allProduct.dart';
import 'package:silverskin/pages/users/home.dart';
import 'package:silverskin/pages/vendor/vendorHomePage.dart';
import 'package:silverskin/providers/cartProvider.dart';

late final SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    print("Error initializing SharedPreferences: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Initialize GetX Controller
    Get.put(GetDataController());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Cartprovider()..loadCartItems()),
      ],
      child: KhaltiScope(
        publicKey: "test_public_key_f3ba0f172418472e98f0fae65788f366",
        builder: (context, navigatorKey) {
          return GetMaterialApp(
            navigatorKey: navigatorKey,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ne', 'NP'),
            ],
            localizationsDelegates: const [
              KhaltiLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            theme: _buildAppTheme(),
            
            home: _getInitialScreen(),
            onGenerateRoute: (settings) {
              
              return null; // Let GetPage handle the routing
            },
            getPages: _buildAppRoutes(),
          );
        },
      ),
    );
  }

  Widget _getInitialScreen() {
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String role = prefs.getString('role') ?? "user";

    if (!isLoggedIn) {
      return const SplashScreen1();
    } else {
      switch (role) {
        case "admin":
          return const AdminHomePage();
        case "vendor":
          return const VendorHomePage(); 
        default:
          return const HomePage();
      }
    }
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: false,
      primaryColor: const Color(0xFF4E342E),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: const Color(0xFFD84315),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4E342E),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<GetPage> _buildAppRoutes() {
    return [
      GetPage(name: '/splash1', page: () => const SplashScreen1()),
      GetPage(name: '/login', page: () =>  LoginPage()),
      GetPage(name: '/home', page: () => const HomePage()),
      GetPage(name: '/adminHome', page: () => const AdminHomePage()),
      GetPage(
        name: '/allProductPage',
        page: () => const AllProductPage(),
        transition: Transition.rightToLeft,
      ),
    ];
  }
}