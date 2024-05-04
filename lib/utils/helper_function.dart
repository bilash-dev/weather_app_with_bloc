import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';


String formattedDate(int timestamp){
  var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';

}

String getFormattedDate(num dt, String format){
  return DateFormat().format(DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000));

}

String formattedTime(num timestamp){
  var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
  return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';

}

//Current Position determine

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}