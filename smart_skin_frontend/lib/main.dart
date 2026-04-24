import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
import 'bloc/analysis/analysis_bloc.dart';
import 'bloc/coach/coach_bloc.dart';
import 'bloc/notification/notification_bloc.dart';
import 'constants/colors.dart';
import 'data/services/api_service.dart';
import 'data/services/local_storage_service.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_flow.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = LocalStorageService(prefs: prefs);
  final api = ApiService(storage);
  runApp(SmartSkinApp(api: api, storage: storage));
}

class SmartSkinApp extends StatelessWidget {
  final ApiService api;
  final LocalStorageService storage;

  const SmartSkinApp({super.key, required this.api, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>.value(value: api),
        RepositoryProvider<LocalStorageService>.value(value: storage),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(api: api, storage: storage)..add(const CheckAuthStatus())),
          BlocProvider(create: (_) => DashboardBloc(api: api)),
          BlocProvider(create: (_) => AnalysisBloc(api: api)),
          BlocProvider(create: (_) => CoachBloc(api: api)),
          BlocProvider(create: (_) => NotificationBloc(api: api)),
        ],
        child: MaterialApp(
          title: 'Smart Skin',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: messengerKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryPink),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: AppColors.backgroundLight,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textDark,
              elevation: 0,
            ),
          ),
          home: const _AppRouter(),
        ),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        if (state is AuthInitial) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryPink,
                  child: Icon(Icons.auto_awesome, size: 40, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text("Smart Skin", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                CircularProgressIndicator(color: AppColors.primaryPink),
              ]),
            ),
          );
        }
        
        if (state is AuthAuthenticated) {
          if (state.needsOnboarding) return const OnboardingFlow();
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}
