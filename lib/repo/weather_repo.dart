import 'dart:convert';
import '../model/current_weather_model.dart';
import '../model/forecast_weather_model.dart';
import '../utils/constants.dart';
import 'package:http/http.dart'as http;

class WeatherRepo{

   String tempUnit = 'metric';

  Future<CurrentWeatherModel?> getCurrentWeatherData(double latitude, double longitude)async{
    final url  = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$tempUnit&appid=$weatherApiKey';
    try{
      final response = await http.get(Uri.parse(url));
      final map = json.decode(response.body);
      // print(map.runtimeType);
      // print(map);
      if(response.statusCode ==200){
        return CurrentWeatherModel.fromJson(map);
      }else{
        print(map['message']);
      }
    }catch(e){
      throw Exception('Failed to load current weather data');
    }
  }

  Future<ForecastWeatherModel?> getForecastWeather(double latitude, double longitude)async{
    final url  = 'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$tempUnit&appid=$weatherApiKey';
    try{
      final response = await http.get(Uri.parse(url));
      final map = json.decode(response.body);
      if(response.statusCode ==200){
        return ForecastWeatherModel.fromJson(map);
      }else{
        print(map['message']);
      }
    }catch(e){
      throw Exception('Failed to load forecast data');
    }
  }
}