import 'package:adminsneaker/presentation/comment_screen/CommentScreen.dart';
import 'package:adminsneaker/domains/Controller/Comment_provider.dart';
import 'package:adminsneaker/presentation/customer_screen/customer_Screen.dart';
import 'package:adminsneaker/domains/Controller/customer_provider.dart';
import 'package:adminsneaker/presentation/dashboard/DashboardScreen.dart';
import 'package:adminsneaker/presentation/dashboard/dashboard_provider.dart';
import 'package:adminsneaker/presentation/login/LoginScreen.dart';
import 'package:adminsneaker/presentation/login/bloc/login_cubit.dart';
import 'package:adminsneaker/presentation/orderscreen/OrderManagementScreen.dart';
import 'package:adminsneaker/domains/Controller/order_provider.dart';
import 'package:adminsneaker/presentation/product_manage/ProductManagementScreen.dart';
import 'package:adminsneaker/domains/Controller/ProductProvider.dart';
import 'package:adminsneaker/presentation/splash/SplashScreen.dart';
import 'package:adminsneaker/presentation/ultilenum/AuthenticationStatus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app/app_cubit.dart';
import 'domains/Controller/firebase_auth_service.dart';
import 'domains/datasource/remote/authentication_repository/authentication_repository.dart';
import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

  } catch (e) {
    print(" Lỗi Firebase: $e");
  }
  runApp(const App());
}
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}
class _AppState extends State<App> {
  late final AuthenticationRepository _authenticationRepository;
  late final FirebaseAuthService _firebaseAuthService;

  @override
  void initState() {
    super.initState();
    _firebaseAuthService = FirebaseAuthService();
    _authenticationRepository = AuthenticationRepositoryImpl(firebaseAuthService: _firebaseAuthService);
  }
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => _authenticationRepository),
        ],
        child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => LoginCubit(authenticationRepository: _authenticationRepository)),
              BlocProvider(create: (_)=> AppCubit(authenticationRepository: _authenticationRepository)),
              ChangeNotifierProvider(create: (context) => ProductProvider()),
              ChangeNotifierProvider(create: (context)=> OrderProvider() ),
              ChangeNotifierProvider(create: (context)=> DashboardProvider() ),
              ChangeNotifierProvider(create: (context)=> CustomerProvider() ),
              ChangeNotifierProvider(create: (context)=> CommentProvider() ),

            ],
            child: MyApp()));
  }
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: BlocProvider.of<LoginCubit>(context)),
        BlocProvider.value(value: BlocProvider.of<AppCubit>(context))
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // routes: {
        //   "/splash": (context) => SplashScreen(),
        //   "/home": (context) => OnboardingPageView(),
        // },
        // initialRoute: "/splash",
        builder: (context,child){
          return BlocListener<AppCubit,AppState>(
            listener: (context,state){
              switch (state.status){
                case AuthenticationStatus.authenticated:
                  _navigatorKey.currentState!.pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context)=>  AdminApp()
                    ),
                        (route) => false,
                  );
                case AuthenticationStatus.unauthenticated:
                  _navigatorKey.currentState!.pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context)=> const Loginscreen()
                    ),
                        (route) => false,
                  );
                case AuthenticationStatus.unknown:
                // k lam gi
                  break;
              }
            },
            child: child,
          );
        },
        onGenerateRoute: (_){
          return MaterialPageRoute(builder: (context)=> const SplashScreen());
        },
      ),
    );
  }
}
class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Admin Panel',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AdminDashboard(),
      );

  }
}


class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _buildDrawer(context, isDarkMode),
      body: _buildDashboardBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDarkMode) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.blueGrey[800]!, Colors.blueGrey[900]!]
                    : [Colors.blue[600]!, Colors.blue[800]!],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 50,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'View Statistics',
                  destination: DashboardScreen(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_bag,
                  title: 'Manage Products',
                  destination: ProductManagementScreen(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.receipt_long,
                  title: 'Manage Orders',
                  destination: OrderManagementScreen(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: 'Manage Customers',
                  destination: CustomerScreen(),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.comment,
                  title: 'Manage Comments',
                  destination: CommentScreen(),
                ),
                Divider(thickness: 1),
                // _buildDrawerItem(
                //   context,
                //   icon: Icons.settings,
                //   title: 'Settings',
                //   // destination: SettingsScreen(),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Widget destination,
      }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: GoogleFonts.poppins(),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image/admin-panel.png', // Thay bằng ảnh của bạn
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30),
              Text(
                "Welcome to Admin Dashboard",
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Manage your store efficiently with our comprehensive admin tools",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 40),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickActionCard(
                    context,
                    icon: Icons.shopping_bag,
                    title: "Products",
                    count: 125,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductManagementScreen()),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.receipt,
                    title: "Orders",
                    count: 42,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderManagementScreen()),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.people,
                    title: "Customers",
                    count: 89,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required int count,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 150,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 5),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Xóa các dữ liệu local storage nếu cần
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();
      print("Đăng xuất thành công");
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
    }
  }
}


