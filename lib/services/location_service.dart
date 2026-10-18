import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
  );

  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        'Serviços de localização e GPS estão desativados. Por favor, ative-os nas configurações do dispositivo e tente novamente.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
          'Permissões de localização negadas. Por favor, configure as permissões do aplicativo nas configurações do dispositivo e tente novamente.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Permissões de localização negadas. Por favor, configure as permissões do aplicativo nas configurações do dispositivo e tente novamente.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: locationSettings.accuracy,
    );
  }

  static LatLng geolocationPositionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
}
