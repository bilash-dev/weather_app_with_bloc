import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app_with_bloc/bloc/weather_event.dart';
import 'package:weather_app_with_bloc/bloc/weather_state.dart';
import 'package:weather_app_with_bloc/repo/weather_repo.dart';
import 'package:weather_app_with_bloc/utils/helper_function.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState>{
  final WeatherRepo weatherRepo;

  WeatherBloc(this.weatherRepo): super(WeatherInitialState()){
    on<WeatherEvent>((event, emit) async{
      if(event is GetWeatherEvent){
        emit(WeatherLoadingState());
        try{
          final currentWeather = await weatherRepo.getCurrentWeatherData(event.latitude, event.longitude);
          final forecastWeather = await weatherRepo.getForecastWeather(event.latitude, event.longitude);
          emit(WeatherLoadedState(currentWeatherModel: currentWeather!, forecastWeatherModel: forecastWeather!));
        }catch(e){
          emit(WeatherErrorState("Failed to fetch weather"));
        }
      }
    });
  }
}