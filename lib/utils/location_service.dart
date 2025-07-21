import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static LocationService? _instance;
  LocationService._internal();
  
  static LocationService get instance {
    _instance ??= LocationService._internal();
    return _instance!;
  }

  /// Get current location data including GPS and WiFi information
  Future<LocationData> getCurrentLocationData() async {
    try {
      // Check location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get GPS coordinates
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Location request timed out');
        },
      );

      // Get address from coordinates
      String address = '';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = '${place.street ?? ''} ${place.subThoroughfare ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}'.trim();
        }
      } catch (e) {
        print('Error getting address: $e');
        address = 'Address not available';
      }

      // Get WiFi information
      String? wifiSSID;
      String? wifiBSSID;
      
      try {
        final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
        
        if (connectivityResult.contains(ConnectivityResult.wifi)) {
          final info = NetworkInfo();
          wifiSSID = await info.getWifiName();
          wifiBSSID = await info.getWifiBSSID();
          
          // Clean up WiFi SSID (remove quotes if present)
          if (wifiSSID != null && wifiSSID.startsWith('"') && wifiSSID.endsWith('"')) {
            wifiSSID = wifiSSID.substring(1, wifiSSID.length - 1);
          }
        }
      } catch (e) {
        print('Error getting WiFi info: $e');
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address: address,
        wifiSSID: wifiSSID,
        wifiBSSID: wifiBSSID,
        timestamp: DateTime.now(),
      );

    } catch (e) {
      print('Error getting location data: $e');
      rethrow;
    }
  }

  /// Quick location check without full data
  Future<bool> isLocationAvailable() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String address;
  final String? wifiSSID;
  final String? wifiBSSID;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.address,
    this.wifiSSID,
    this.wifiBSSID,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'address': address,
      'wifi_ssid': wifiSSID,
      'wifi_bssid': wifiBSSID,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address, wifi: $wifiSSID)';
  }
}