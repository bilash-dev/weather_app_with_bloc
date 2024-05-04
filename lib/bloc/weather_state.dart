import 'package:weather_app_with_bloc/model/current_weather_model.dart';
import 'package:weather_app_with_bloc/model/forecast_weather_model.dart';

abstract class WeatherState{}

class WeatherInitialState extends WeatherState{}
class WeatherLoadingState extends WeatherState{}
class WeatherLoadedState extends WeatherState{
  final CurrentWeatherModel currentWeatherModel;
  final ForecastWeatherModel forecastWeatherModel;
  WeatherLoadedState({required this.currentWeatherModel, required this.forecastWeatherModel});
}
class WeatherErrorState extends WeatherState{
  final String message;
  WeatherErrorState(this.message);
}