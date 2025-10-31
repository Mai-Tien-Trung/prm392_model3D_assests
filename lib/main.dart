import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
void main() {
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: 'Login Register UI',
			theme: ThemeData(primarySwatch: Colors.indigo),
			initialRoute: '/login',
			routes: {
				'/login': (context) => const LoginPage(),
				'/register': (context) => const RegisterPage(),
				'/home': (context) => const HomePage(),
			},
		);
	}
}
