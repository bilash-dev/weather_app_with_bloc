abstract class WeatherEvent{}

class GetWeatherEvent extends WeatherEvent{

  double latitude;
  double longitude;
  GetWeatherEvent(this.latitude, this.longitude);
}

