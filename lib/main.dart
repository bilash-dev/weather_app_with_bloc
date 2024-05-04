import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app_with_bloc/bloc/weather_bloc.dart';
import 'package:weather_app_with_bloc/repo/weather_repo.dart';
import 'package:weather_app_with_bloc/screens/weather_view.dart';
import 'package:weather_app_with_bloc/utils/helper_function.dart';

void main() {
  runApp(RepositoryProvider(
    create: ((context) => WeatherRepo()),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WeatherBloc(
                WeatherRepo(),
            ),
          ),
        ],
        child: const WeatherView(),
      )

    );
  }
}

