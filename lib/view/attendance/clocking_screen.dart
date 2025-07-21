import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:geocoding/geocoding.dart'; // Add this import
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'clocking_controller.dart';
import '../../repository/attendancerepository.dart';
import '../../data/remote/response/attendance_status_response.dart';
import '../../services/theme_service.dart';

class ClockingScreen extends StatefulWidget {
  const ClockingScreen({super.key});

  @override
  State<ClockingScreen> createState() => _ClockingScreenState();
}

class _ClockingScreenState extends State<ClockingScreen> {
  late Timer _timer;
  DateTime now = DateTime.now();
  bool isClockedIn = false;
  String clockInTime = "--:--";
  
  // Face ID Controller
  late ClockingController clockingController;
  
  // Attendance Repository
  final AttendanceRepository _attendanceRepository = AttendanceRepository();
  
  // Attendance Status
  AttendanceStatusData? _attendanceStatus;
  bool _isLoadingAttendanceStatus = false;
  String? _attendanceStatusError;

  // Map and Location variables
  MapController? mapController;
  LatLng? currentLocation;
  List<Marker> markers = [];
  double? _currentLat;
  double? _currentLng;
  String? _wifiSSID;
  String? _wifiBSSID;
  String _locationStatus = "Getting location data...";
  bool _isLocationLoading = true;
  bool _hasLocationPermission = false;
  bool _isConnectedToWifi = false;
  bool _isMapReady = false;

  // Address variables
  String? _street;
  String? _city;
  String? _state;
  String? _country;
  String? _postalCode;
  bool _isGeocodingLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize Face ID controller
    clockingController = Get.put(ClockingController());
    _startTimer();
    // Initialize MapController and start location fetching
    _initializeLocationServices();
    // Load attendance status
    _loadAttendanceStatus();
  }

  Future<void> _initializeLocationServices() async {
    // Initialize MapController
    mapController = MapController();

    // Start location services
    await _checkConnectivity();
    await _requestLocationPermission();
  }

  Future<void> _loadAttendanceStatus() async {
    setState(() {
      _isLoadingAttendanceStatus = true;
      _attendanceStatusError = null;
    });

    try {
      final response = await _attendanceRepository.getAttendanceStatus();
      final attendanceStatusResponse = AttendanceStatusResponse.fromJson(response);
      
      if (!attendanceStatusResponse.error && attendanceStatusResponse.data != null) {
        setState(() {
          _attendanceStatus = attendanceStatusResponse.data;
          _isLoadingAttendanceStatus = false;
          
          // Update local state based on attendance status
          if (_attendanceStatus!.attendanceData.clockIn != null && 
              _attendanceStatus!.attendanceData.clockOut == null) {
            isClockedIn = true;
            clockInTime = _formatTimeFromString(_attendanceStatus!.attendanceData.clockIn!);
          }
        });
      } else {
        setState(() {
          _attendanceStatusError = attendanceStatusResponse.message;
          _isLoadingAttendanceStatus = false;
        });
      }
    } catch (e) {
      setState(() {
        _attendanceStatusError = 'Failed to load attendance status: ${e.toString()}';
        _isLoadingAttendanceStatus = false;
      });
      print('Error loading attendance status: $e');
    }
  }

  String _formatTimeFromString(String timeString) {
    try {
      // Handle both full datetime strings and time-only strings
      DateTime dateTime;
      if (timeString.contains('T') || timeString.contains(' ')) {
        dateTime = DateTime.parse(timeString);
      } else {
        // Assume it's a time string like "07:00:00"
        final now = DateTime.now();
        final timeParts = timeString.split(':');
        dateTime = DateTime(now.year, now.month, now.day, 
            int.parse(timeParts[0]), int.parse(timeParts[1]), 
            timeParts.length > 2 ? int.parse(timeParts[2]) : 0);
      }
      return _formatTime(dateTime);
    } catch (e) {
      return timeString; // Return original if parsing fails
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();

      setState(() {
        _isConnectedToWifi = connectivityResult.contains(ConnectivityResult.wifi);
      });

      if (_isConnectedToWifi) {
        // Get real WiFi information using network_info_plus
        final info = NetworkInfo();
        final wifiName = await info.getWifiName();       // SSID
        final wifiBSSID = await info.getWifiBSSID();     // BSSID
        final wifiIP = await info.getWifiIP();           // IP Address
        final wifiGatewayIP = await info.getWifiGatewayIP();

        print('WiFi Name (SSID): $wifiName');
        print('BSSID: $wifiBSSID');
        print('IP Address: $wifiIP');
        print('Gateway IP: $wifiGatewayIP');

        setState(() {
          _wifiSSID = wifiName ?? "Connected to WiFi";
          _wifiBSSID = wifiBSSID ?? "Unknown BSSID";
        });
      } else {
        setState(() {
          _wifiSSID = null;
          _wifiBSSID = null;
        });
      }
    } catch (e) {
      print('Connectivity check error: $e');
      setState(() {
        _isConnectedToWifi = false;
        _wifiSSID = null;
        _wifiBSSID = null;
      });
    }
  }

  // New method to get address from coordinates
  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    setState(() {
      _isGeocodingLoading = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          _street = '${place.street ?? ''} ${place.subThoroughfare ?? ''}'.trim();
          if (_street!.isEmpty) _street = place.thoroughfare ?? 'Unknown Street';

          _city = place.locality ?? place.subAdministrativeArea ?? 'Unknown City';
          _state = place.administrativeArea ?? 'Unknown State';
          _country = place.country ?? 'Unknown Country';
          _postalCode = place.postalCode ?? 'Unknown Postal Code';
          _isGeocodingLoading = false;
        });

        print('Address Details:');
        print('Street: $_street');
        print('City: $_city');
        print('State: $_state');
        print('Country: $_country');
        print('Postal Code: $_postalCode');
      }
    } catch (e) {
      print('Geocoding error: $e');
      setState(() {
        _street = 'Address not available';
        _city = 'City not available';
        _state = 'State not available';
        _country = 'Country not available';
        _postalCode = 'Postal code not available';
        _isGeocodingLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        setState(() {
          _hasLocationPermission = true;
        });
        await _getCurrentLocation();
      } else {
        setState(() {
          _isLocationLoading = false;
          _hasLocationPermission = false;
          _locationStatus = "Location permission denied";
        });
      }
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
        _locationStatus = "Error requesting location permission: $e";
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_hasLocationPermission) {
      await _requestLocationPermission();
      return;
    }

    try {
      setState(() {
        _isLocationLoading = true;
        _locationStatus = "Getting location...";
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocationLoading = false;
          _locationStatus = "Location services are disabled. Please enable GPS.";
        });
        return;
      }

      // Get current position with high accuracy for real location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, // Use high accuracy for real GPS
          distanceFilter: 0, // Get updates for any movement
        ),
      ).timeout(
        const Duration(seconds: 30), // Increased timeout for better GPS fix
        onTimeout: () {
          throw TimeoutException('Location request timed out');
        },
      );

      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
        currentLocation = LatLng(position.latitude, position.longitude);
        _isLocationLoading = false;
        _locationStatus = _buildLocationStatus();

        // Update markers with real location
        markers = [
          Marker(
            width: 120.0,
            height: 120.0,
            point: currentLocation!,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeService.instance.getCardColor(),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeService.instance.getTextPrimaryColor().withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Current Location\n${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: ThemeService.instance.getTextPrimaryColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.location_pin,
                  color: ThemeService.instance.getPrimaryColor(),
                  size: 40,
                ),
              ],
            ),
          ),
        ];
      });

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      // Move map to current location only if map is ready
      if (_isMapReady && mapController != null) {
        mapController!.move(currentLocation!, 16.0);
      }

    } on TimeoutException catch (e) {
      setState(() {
        _isLocationLoading = false;
        _locationStatus = "Location request timed out. Please try again.";
      });
    } on LocationServiceDisabledException catch (e) {
      setState(() {
        _isLocationLoading = false;
        _locationStatus = "Location services are disabled. Please enable GPS.";
      });
    } on PermissionDeniedException catch (e) {
      setState(() {
        _isLocationLoading = false;
        _hasLocationPermission = false;
        _locationStatus = "Location permission denied.";
      });
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
        _locationStatus = "Failed to get location: ${e.toString()}";
      });
    }
  }

  String _buildLocationStatus() {
    List<String> statusParts = [];

    if (_currentLat != null && _currentLng != null) {
      statusParts.add("Latitude: ${_currentLat!.toStringAsFixed(6)}");
      statusParts.add("Longitude: ${_currentLng!.toStringAsFixed(6)}");

      // Add accuracy information if available
      statusParts.add("GPS Location Retrieved");
    }

    // Add WiFi status if connected
    if (_wifiSSID != null && _wifiSSID!.isNotEmpty) {
      statusParts.add("WiFi: $_wifiSSID");
    }

    // Add BSSID if available
    if (_wifiBSSID != null && _wifiBSSID!.isNotEmpty) {
      statusParts.add("BSSID: $_wifiBSSID");
    }

    return statusParts.isEmpty ? "Location data not available" : statusParts.join("\n");
  }

  Future<bool> _isValidWorkLocation() async {
    if (_currentLat == null || _currentLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to determine current location'),
          backgroundColor: ThemeService.instance.getErrorColor(),
        ),
      );
      return false;
    }

    try {
      // Show debug information
      print('Current location: $_currentLat, $_currentLng');
      print('WiFi SSID: $_wifiSSID');
      print('WiFi BSSID: $_wifiBSSID');
      print('Address: $_street, $_city, $_state');

      // Allow clocking from anywhere - always return true
      return true;
    } catch (e) {
      print('Error validating work location: $e');
      return true; // Still allow clocking even if there's an error
    }
  }

  String _formatTime(DateTime dateTime) {
    String hour = dateTime.hour > 12
        ? (dateTime.hour - 12).toString().padLeft(2, '0')
        : dateTime.hour == 0
        ? '12'
        : dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute:$second $period';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;
    
    return Scaffold(
      backgroundColor: themeService.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Clocking',
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: themeService.getTextSecondaryColor()),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Map Section
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: themeService.getCardColor(),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _isLocationLoading
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: themeService.getPrimaryColor(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Getting your GPS location...',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeService.getTextSecondaryColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This may take a few moments',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeService.getTextSecondaryColor(),
                          ),
                        ),
                      ],
                    ),
                  )
                      : !_hasLocationPermission
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          color: themeService.getTextSecondaryColor(),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Location Permission Required',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeService.getTextPrimaryColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please enable location permission to view the map',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeService.getTextSecondaryColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _requestLocationPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeService.getPrimaryColor(),
                            foregroundColor: themeService.getSilver(),
                          ),
                          child: const Text('Enable Location'),
                        ),
                      ],
                    ),
                  )
                      : currentLocation == null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_searching,
                          color: themeService.getTextSecondaryColor(),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _locationStatus,
                          style: TextStyle(
                            fontSize: 14,
                            color: themeService.getTextSecondaryColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _getCurrentLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeService.getPrimaryColor(),
                            foregroundColor: themeService.getSilver(),
                          ),
                          child: const Text('Retry GPS'),
                        ),
                      ],
                    ),
                  )
                      : FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: currentLocation!,
                      initialZoom: 16.0,
                      maxZoom: 18.0,
                      minZoom: 10.0,
                      onMapReady: () {
                        setState(() {
                          _isMapReady = true;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.clocking_app',
                        maxZoom: 18,
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Location Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeService.getCardColor(),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeService.getPrimaryColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.gps_fixed,
                            color: themeService.getPrimaryColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'GPS Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeService.getTextPrimaryColor(),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            _checkConnectivity();
                            _getCurrentLocation();
                          },
                          icon: Icon(
                            Icons.refresh,
                            color: themeService.getPrimaryColor(),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeService.getBackgroundColor(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isLocationLoading ? 'Getting GPS location...' : _locationStatus,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeService.getTextSecondaryColor(),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Address Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeService.getCardColor(),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeService.getSuccessColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_city,
                            color: themeService.getSuccessColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Address Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeService.getTextPrimaryColor(),
                          ),
                        ),
                        const Spacer(),
                        if (_isGeocodingLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: themeService.getSuccessColor(),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address Information
                    _buildAddressRow('Street', _street ?? 'Loading...', Icons.route),
                    const SizedBox(height: 12),
                    _buildAddressRow('City', _city ?? 'Loading...', Icons.location_city),
                    const SizedBox(height: 12),
                    _buildAddressRow('State', _state ?? 'Loading...', Icons.map),
                    const SizedBox(height: 12),
                    _buildAddressRow('Latitude', _currentLat?.toStringAsFixed(6) ?? 'Loading...', Icons.my_location),
                    const SizedBox(height: 12),
                    _buildAddressRow('Longitude', _currentLng?.toStringAsFixed(6) ?? 'Loading...', Icons.place),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Face ID Status Card
              Obx(() => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeService.getCardColor(),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: clockingController.hasEmbedding.value 
                                ? themeService.getSuccessColor().withValues(alpha: 0.1)
                                : themeService.getWarningColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            clockingController.hasEmbedding.value 
                                ? Icons.face 
                                : Icons.face_retouching_off,
                            color: clockingController.hasEmbedding.value 
                                ? themeService.getSuccessColor() 
                                : themeService.getWarningColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Face Recognition Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeService.getTextPrimaryColor(),
                          ),
                        ),
                        const Spacer(),
                        if (clockingController.isLoading.value)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: themeService.getWarningColor(),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: clockingController.hasEmbedding.value 
                            ? themeService.getSuccessColor().withValues(alpha: 0.1)
                            : themeService.getWarningColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        clockingController.getEmbeddingMessage(),
                        style: TextStyle(
                          fontSize: 14,
                          color: clockingController.hasEmbedding.value 
                              ? themeService.getSuccessColor() 
                              : themeService.getWarningColor(),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (!clockingController.hasEmbedding.value && !clockingController.isLoading.value) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await clockingController.navigateToScanScreen();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeService.getPrimaryColor(),
                            foregroundColor: themeService.getSilver(),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Register Face Recognition',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )),

              const SizedBox(height: 30),

              // Time and Date Section
              Column(
                children: [
                  // Drag indicator
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: themeService.getTextSecondaryColor().withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date
                  Text(
                    _formatDate(now),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: themeService.getTextPrimaryColor(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Current Time
                  Text(
                    _formatTime(now),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: themeService.getTextPrimaryColor(),
                      height: 1.0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Action Buttons Section
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 2.2,
                children: [
                  // Clock-in Button (Active)
                  Obx(() => _buildActionButton(
                    title: 'Clock-in',
                    time: _getClockInTime(),
                    isActive: _isClockInActive(),
                    isDisabled: !_canClockIn(),
                    onTap: () async {
                      if (!isClockedIn) {
                        // Check Face ID first
                        if (!clockingController.canClockIn()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Face recognition required to clock in. Please register face recognition first.'),
                              backgroundColor: ThemeService.instance.getWarningColor(),
                            ),
                          );
                          return;
                        }
                        
                        // Verify face for clock-in
                        final result = await clockingController.verifyFaceForClockIn(
                          attendanceType: 'clock_in',
                          locationData: getLocationData(),
                        );
                        
                        // Always reload attendance status after returning from face recognition screen
                        await _loadAttendanceStatus();
                        
                        if (result is Map<String, dynamic>) {
                          if (result['success'] == true) {
                            // Parse the timestamp from the result
                            String? timeString = result['time'];
                            DateTime attendanceTime = timeString != null 
                                ? DateTime.parse(timeString)
                                : DateTime.now();
                            
                            setState(() {
                              isClockedIn = true;
                              clockInTime = _formatTime(attendanceTime);
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Face verified and clocked in successfully at ${_formatTime(attendanceTime)}!'),
                                backgroundColor: ThemeService.instance.getSuccessColor(),
                              ),
                            );
                          } else if (result['warning'] == true && result['message'] != null) {
                            // Handle validation message from API
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor: ThemeService.instance.getWarningColor(),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          } else {
                            // Handle error message
                            String errorMessage = result['message'] ?? 'Face verification failed. Please try again.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: ThemeService.instance.getErrorColor(),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Face verification failed. Please try again.'),
                              backgroundColor: ThemeService.instance.getErrorColor(),
                            ),
                          );
                        }
                      }
                    },
                  )),

                  // Break start
                  Obx(() => _buildActionButton(
                    title: 'Break Start',
                    time: _getBreakTime(false),
                    isActive: _attendanceStatus?.attendanceData.breakIn != null && _attendanceStatus?.attendanceData.breakOut == null,
                    isDisabled: !_canBreakIn(),
                    onTap: () async {
                      if (!clockingController.canClockIn()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Face recognition required for break. Please register face recognition first.'),
                            backgroundColor: ThemeService.instance.getWarningColor(),
                          ),
                        );
                        return;
                      }

                      final result = await clockingController.verifyFaceForClockIn(
                        attendanceType: 'break_in',
                        locationData: getLocationData(),
                      );
                      
                      // Always reload attendance status after returning from face recognition screen
                      await _loadAttendanceStatus();
                      
                      if (result is Map<String, dynamic>) {
                        if (result['success'] == true) {
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Break started successfully!'),
                              backgroundColor: ThemeService.instance.getSuccessColor(),
                            ),
                          );
                        } else if (result['warning'] == true && result['message'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: ThemeService.instance.getWarningColor(),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        } else {
                          String errorMessage = result['message'] ?? 'Break start failed. Please try again.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: ThemeService.instance.getErrorColor(),
                            ),
                          );
                        }
                      }
                    },
                  )),

                  // Break end
                  Obx(() => _buildActionButton(
                    title: 'Break End',
                    time: _getBreakTime(true),
                    isActive: _attendanceStatus?.attendanceData.breakIn != null && _attendanceStatus?.attendanceData.breakOut != null,
                    isDisabled: !_canBreakOut(),
                    onTap: () async {
                      if (!clockingController.canClockIn()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Face recognition required for break. Please register face recognition first.'),
                            backgroundColor: ThemeService.instance.getWarningColor(),
                          ),
                        );
                        return;
                      }

                      final result = await clockingController.verifyFaceForClockIn(
                        attendanceType: 'break_out',
                        locationData: getLocationData(),
                      );
                      
                      // Always reload attendance status after returning from face recognition screen
                      await _loadAttendanceStatus();
                      
                      if (result is Map<String, dynamic>) {
                        if (result['success'] == true) {
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Break ended successfully!'),
                              backgroundColor: ThemeService.instance.getSuccessColor(),
                            ),
                          );
                        } else if (result['warning'] == true && result['message'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: ThemeService.instance.getWarningColor(),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        } else {
                          String errorMessage = result['message'] ?? 'Break end failed. Please try again.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: ThemeService.instance.getErrorColor(),
                            ),
                          );
                        }
                      }
                    },
                  )),

                  // Clock-out
                  Obx(() => _buildActionButton(
                    title: 'Clock-out',
                    time: _getClockOutTime(),
                    isActive: _attendanceStatus?.attendanceData.clockOut != null,
                    isDisabled: !_canClockOut(),
                    onTap: () async {
                      if (!clockingController.canClockIn()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Face recognition required to clock out. Please register face recognition first.'),
                            backgroundColor: ThemeService.instance.getWarningColor(),
                          ),
                        );
                        return;
                      }

                      final result = await clockingController.verifyFaceForClockIn(
                        attendanceType: 'clock_out',
                        locationData: getLocationData(),
                      );
                      
                      // Always reload attendance status after returning from face recognition screen
                      await _loadAttendanceStatus();
                      
                      if (result is Map<String, dynamic>) {
                        if (result['success'] == true) {
                          setState(() {
                            isClockedIn = false;
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Clocked out successfully!'),
                              backgroundColor: ThemeService.instance.getWarningColor(),
                            ),
                          );
                        } else if (result['warning'] == true && result['message'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: ThemeService.instance.getWarningColor(),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        } else {
                          String errorMessage = result['message'] ?? 'Clock out failed. Please try again.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: ThemeService.instance.getErrorColor(),
                            ),
                          );
                        }
                      }
                    },
                  )),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(String label, String value, IconData icon) {
    final themeService = ThemeService.instance;
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: themeService.getTextSecondaryColor(),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: themeService.getTextSecondaryColor(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: themeService.getTextPrimaryColor(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String time,
    required bool isActive,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    final themeService = ThemeService.instance;
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled 
              ? themeService.getTextSecondaryColor().withValues(alpha: 0.3)
              : (isActive ? themeService.getPrimaryColor() : themeService.getCardColor()),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled 
                    ? themeService.getTextSecondaryColor()
                    : (isActive ? themeService.getSilver() : themeService.getTextPrimaryColor()),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDisabled 
                    ? themeService.getTextSecondaryColor()
                    : (isActive ? themeService.getSilver() : themeService.getTextSecondaryColor()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for attendance status
  String _getClockInTime() {
    if (_attendanceStatus != null && _attendanceStatus!.attendanceData.clockIn != null) {
      return _formatTimeFromString(_attendanceStatus!.attendanceData.clockIn!);
    }
    return clockInTime; // Fallback to local state
  }

  bool _isClockInActive() {
    if (_attendanceStatus != null) {
      return _attendanceStatus!.attendanceData.clockIn != null && 
             _attendanceStatus!.attendanceData.clockOut == null;
    }
    return isClockedIn; // Fallback to local state
  }

  bool _canClockIn() {
    if (_attendanceStatus != null && _attendanceStatus!.attendanceEnabled) {
      return _attendanceStatus!.canClockIn && clockingController.canClockIn();
    }
    return clockingController.canClockIn(); // Fallback to face recognition check
  }

  bool _canClockOut() {
    if (_attendanceStatus != null && _attendanceStatus!.attendanceEnabled) {
      return _attendanceStatus!.canClockOut && clockingController.canClockIn();
    }
    return clockingController.canClockIn(); // Fallback
  }

  bool _canBreakIn() {
    if (_attendanceStatus != null && _attendanceStatus!.attendanceEnabled) {
      return _attendanceStatus!.canBreakIn && clockingController.canClockIn();
    }
    return clockingController.canClockIn(); // Fallback
  }

  bool _canBreakOut() {
    if (_attendanceStatus != null && _attendanceStatus!.attendanceEnabled) {
      return _attendanceStatus!.canBreakOut && clockingController.canClockIn();
    }
    return clockingController.canClockIn(); // Fallback
  }

  String _getBreakTime(bool isBreakOut) {
    if (_attendanceStatus != null) {
      if (isBreakOut && _attendanceStatus!.attendanceData.breakOut != null) {
        return _formatTimeFromString(_attendanceStatus!.attendanceData.breakOut!);
      } else if (!isBreakOut && _attendanceStatus!.attendanceData.breakIn != null) {
        return _formatTimeFromString(_attendanceStatus!.attendanceData.breakIn!);
      }
    }
    return '--:--';
  }

  String _getClockOutTime() {
    if (_attendanceStatus != null && _attendanceStatus!.attendanceData.clockOut != null) {
      return _formatTimeFromString(_attendanceStatus!.attendanceData.clockOut!);
    }
    return '--:--';
  }

  // Helper method to get location data as a Map (useful for storing/sending to server)
  Map<String, dynamic> getLocationData() {
    return {
      'street': _street,
      'city': _city,
      'state': _state,
      'country': _country,
      'postalCode': _postalCode,
      'latitude': _currentLat,
      'longitude': _currentLng,
      'wifiSSID': _wifiSSID,
      'wifiBSSID': _wifiBSSID,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}