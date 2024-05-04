import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as Geo;
import 'package:geolocator/geolocator.dart';
import 'package:weather_app_with_bloc/bloc/weather_bloc.dart';
import 'package:weather_app_with_bloc/bloc/weather_event.dart';
import 'package:weather_app_with_bloc/bloc/weather_state.dart';
import 'package:weather_app_with_bloc/model/forecast_weather_model.dart';

import '../model/current_weather_model.dart';
import '../utils/constants.dart';
import '../utils/helper_function.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({Key? key}) : super(key: key);

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final TextEditingController _cityController = TextEditingController();
  // final weatherBloc = BlocProvider.of<WeatherBloc>(context);

  @override
  void initState() {

    final weatherBloc = BlocProvider.of<WeatherBloc>(context);
    _isInit();
    super.initState();
  }

  void _isInit() async{
    determinePosition().then((position) {
      BlocProvider.of<WeatherBloc>(context).add(GetWeatherEvent(position.latitude, position.longitude));
    });
    // BlocProvider.of<WeatherBloc>(context).add(GetWeatherEvent(latitude, longitude)));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text("Weather App",),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: (){
              _isInit();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async{
              final city = await showSearch(context: context, delegate: _CitySearchDelegate());
              if(city != null && city.isNotEmpty) {

                try{
                  final locationList = await Geo.locationFromAddress(city);
                  if(locationList.isNotEmpty) {
                    final location = locationList.first;
                    BlocProvider.of<WeatherBloc>(context).add(GetWeatherEvent(location.latitude, location.longitude));
                  }
                }catch(error) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: const Text("Could not find any result for the supplied address"),
                    // duration: const Duration(seconds: 5),
                  ));
                }
              }
            },
          ),

        ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomLeft,
              colors: [
                Colors.blue,
                Colors.red,
              ],
            )
          ),
          child: Stack(
            children: [
              BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state){
                  // if(state is WeatherInitialState){
                  //   return buildInitialInput();
                  // }else
                    if(state is WeatherLoadingState){
                    return buildLoading();
                  }else if(state is WeatherLoadedState){
                    return buildColumnWithData(state.currentWeatherModel, state.forecastWeatherModel);
                  }else if(state is WeatherErrorState){
                    return buildError(state.message);
                  }else
                    // return buildInitialInput();
                    return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildLoading(){
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildColumnWithData(CurrentWeatherModel currentWeatherModel,ForecastWeatherModel forecastWeatherModel){
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomLeft,
              colors: [
                Colors.blue,
                Colors.red,
              ],
            )
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 80,),
              Text(getFormattedDate(currentWeatherModel.dt!, 'EEE MMM, YYYY'), style: TextStyle(fontSize: 16),),
              Text('${currentWeatherModel.name}, ${currentWeatherModel.sys!.country}', style:  TextStyle(fontSize: 22),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('${currentWeatherModel.main!.temp!.toStringAsFixed(2)}\u00B0' + 'C',style:  TextStyle(fontSize: 80),),
                ],
              ),
              Text('feels like ${currentWeatherModel.main!.feelsLike!.round()}\u00B0', style: TextStyle(fontSize: 20),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network('$icon_prefix${currentWeatherModel.weather![0].icon}$icon_suffix', width: 50, height: 50, fit: BoxFit.cover,),
                  Text('${currentWeatherModel.weather![0].description}')
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Sunrise: ${formattedTime(currentWeatherModel.sys!.sunrise!)}',style: const TextStyle(fontSize: 20),),
                  Text('Sunset: ${formattedTime(currentWeatherModel.sys!.sunset!)}',style: const TextStyle(fontSize: 20),),
                ],
              ),

              SizedBox(height: 20,),
              Row(
                children: [
                  Text(
                    'Forecast:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: forecastWeatherModel.list!.length,
                      itemBuilder: (context, index){
                       final forecast = forecastWeatherModel.list![index];
                       final forecastDate = forecastWeatherModel.list![0].dt!.toInt();
                       return Card(
                         color: Colors.black12.withOpacity(0.3),
                         margin: EdgeInsets.all(4),
                         child: Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Center(
                             child: Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Text(formattedDate(forecastDate),style: TextStyle(color: Colors.white),),
                                 Image.network('$icon_prefix${forecast.weather![0].icon}$icon_suffix', width: 50, height: 50, fit: BoxFit.cover,),
                                 Text('${forecast.main!.tempMax!.round()}/${forecast.main!.tempMin!.round()}\u00B0',style: TextStyle(color: Colors.white)),
                                 Text(forecast.weather![0].description!, style: TextStyle(color: Colors.white))
                               ],
                             ),
                           ),
                         ),
                       );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildError(String message){
    return Center(
      child: Text(message, style: TextStyle(color: Colors.red, fontSize: 20),),
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String>{
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      leading: const Icon(Icons.search),
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty ? cities : cities.where((element) => element.toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        ListTile(
          onTap: () {
            query = filteredList[index];
            close(context, query);
          },
          title: Text(filteredList[index]),
        );
      },
    );
  }

}


