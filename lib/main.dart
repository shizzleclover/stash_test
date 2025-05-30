import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/stash_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_stash_screen.dart';
import 'screens/stash_detail_screen.dart';
import 'services/storage_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await StorageService.init();
  
  runApp(const MyStashApp());
}

class MyStashApp extends StatelessWidget {
  const MyStashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StashProvider()),
      ],
      child: MaterialApp(
        title: 'myStash',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.inter(
              color: AppConstants.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(
              color: AppConstants.textPrimary,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            ),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: BorderSide(
                color: AppConstants.textSecondary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              borderSide: const BorderSide(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingMedium,
            ),
          ),
        ),
        home: const AppWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/create-stash': (context) => const CreateStashScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/stash-detail') {
            final stashId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => StashDetailScreen(stashId: stashId),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.initializeAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (authProvider.authState == AuthState.unknown) {
          return Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.savings,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'myStash',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Smart savings made simple',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppConstants.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                  ),
                ],
              ),
            ),
          );
        }

        // Navigate based on auth state
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
  