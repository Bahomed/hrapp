import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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

  // Map and Location variables
  MapController? mapController;
  LatLng? currentLocation;
  List<Marker> markers = [];
  double? _currentLat;
  double? _currentLng;
  String? _wifiSSID;
  String? _wifiBSSID;
  String _locationStatus = "Getting location...";
  bool _isLocationLoading = true;
  bool _hasLocationPermission = false;
  bool _isConnectedToWifi = false;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Initialize MapController and start location fetching
    _initializeLocationServices();
  }

  Future<void> _initializeLocationServices() async {
    // Initialize MapController
    mapController = MapController();

    // Start location services
    await _checkConnectivity();
    await _requestLocationPermission();
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Current Location\n${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.location_pin,
                  color: Color(0xFF00BCD4),
                  size: 40,
                ),
              ],
            ),
          ),
        ];
      });

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
        const SnackBar(
          content: Text('Unable to determine current location'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      // Show debug information
      print('Current location: $_currentLat, $_currentLng');
      print('WiFi SSID: $_wifiSSID');
      print('WiFi BSSID: $_wifiBSSID');

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Clocking',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _isLocationLoading
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF00BCD4),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Getting your GPS location...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This may take a few moments',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
                        const Icon(
                          Icons.location_off,
                          color: Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Location Permission Required',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please enable location permission to view the map',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _requestLocationPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4),
                            foregroundColor: Colors.white,
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
                        const Icon(
                          Icons.location_searching,
                          color: Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _locationStatus,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _getCurrentLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4),
                            foregroundColor: Colors.white,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                            color: const Color(0xFF00BCD4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.gps_fixed,
                            color: Color(0xFF00BCD4),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'GPS Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            _checkConnectivity();
                            _getCurrentLocation();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFF00BCD4),
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
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isLocationLoading ? 'Getting GPS location...' : _locationStatus,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Time and Date Section
              Column(
                children: [
                  // Drag indicator
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date
                  Text(
                    _formatDate(now),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Current Time
                  Text(
                    _formatTime(now),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                  _buildActionButton(
                    title: 'Clock-in',
                    time: clockInTime,
                    isActive: isClockedIn,
                    onTap: () async {
                      if (!isClockedIn) {
                        bool isValid = await _isValidWorkLocation();
                        if (isValid) {
                          setState(() {
                            isClockedIn = true;
                            clockInTime = _formatTime(now);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Clocked in successfully'),
                              backgroundColor: Color(0xFF00BCD4),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You must be at the office location to clock in'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),

                  // Break start
                  _buildActionButton(
                    title: 'Break Start',
                    time: '--:--',
                    isActive: false,
                    onTap: () {},
                  ),

                  // Break end
                  _buildActionButton(
                    title: 'Break End',
                    time: '--:--',
                    isActive: false,
                    onTap: () {},
                  ),

                  // Clock-out
                  _buildActionButton(
                    title: 'Clock-out',
                    time: '--:--',
                    isActive: false,
                    onTap: () async {
                      if (isClockedIn) {
                        setState(() {
                          isClockedIn = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Clocked out successfully'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String time,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00BCD4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}