import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trips/app/app.dart';
import 'package:trips/services/services.dart';

void main() async {
  Bloc.observer = AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authenticationService = AuthenticationService();
  await authenticationService.authUser.first;
  runApp(App(authenticationService: authenticationService));
}
