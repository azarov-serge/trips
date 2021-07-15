import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trips/app/app.dart';
import 'package:trips/blocs/blocs.dart';
import 'package:trips/services/services.dart';

void main() async {
  Bloc.observer = SimpleBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authService = AuthService();
  final usersService = UsersService();
  await authService.authUser.first;
  runApp(
    App(
      authService: authService,
      usersService: usersService,
    ),
  );
}
