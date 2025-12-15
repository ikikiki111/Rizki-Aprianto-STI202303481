import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart';
import '../models/destination_model.dart';
import '../services/database_service.dart';
import 'add_destination_screen.dart';
import 'detail_destination_screen.dart';

class PetaPage extends StatefulWidget {
 final Position? selectedLocation;

  const PetaPage({
    Key? key,
    this.selectedLocation,
  }) : super(key: key);
  @override
  State<PetaPage> createState() => _PetaPageState();
}

class _PetaPageState extends State<PetaPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<Destination> _destinations = [];
  Destination? _selectedDestination;
  bool _isLoading = true;
  LatLng? _currentPosition;
  LatLng? _tempSelectedLocation; // Lokasi yang diklik untuk tambah destinasi

  @override
  void initState() {
    super.initState();
    _loadDestinations();
    _getCurrentLocation();
  }

  // Dapatkan lokasi user saat ini
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        // Pindah kamera ke lokasi user
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 15),
        );

        // Tambah marker lokasi user
        _addCurrentLocationMarker();
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: 'Lokasi Anda',
            snippet: 'Posisi saat ini',
          ),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _loadDestinations() async {
    setState(() => _isLoading = true);
    final destinations = await DatabaseService.instance.getAllDestinations();
    setState(() {
      _destinations = destinations;
      _isLoading = false;
    });
    _createMarkers();
  }

  void _createMarkers() {
    _markers.clear();

    // Tambah marker lokasi user jika ada
    if (_currentPosition != null) {
      _addCurrentLocationMarker();
    }

    // Tambah marker destinasi
    for (var destination in _destinations) {
      _markers.add(
        Marker(
          markerId: MarkerId(destination.id.toString()),
          position: LatLng(destination.latitude, destination.longitude),
          infoWindow: InfoWindow(
            title: destination.name,
            snippet: destination.location,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () {
            setState(() => _selectedDestination = destination);
          },
        ),
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_destinations.isNotEmpty) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_destinations.first.latitude, _destinations.first.longitude),
          12,
        ),
      );
    }
  }

  // Ketika peta diklik, tampilkan dialog konfirmasi
  void _onMapTapped(LatLng position) {
    setState(() {
      _tempSelectedLocation = position;
      _selectedDestination = null; // Clear selected destination
    });

    // Tampilkan dialog konfirmasi
    _showAddDestinationDialog(position);
  }

  void _showAddDestinationDialog(LatLng position) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add_location_alt,
                  size: 48,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tambah Destinasi Baru',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dari lokasi yang Anda pilih di peta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Koordinat Otomatis:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${position.latitude.toStringAsFixed(6)}°',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            'Long: ${position.longitude.toStringAsFixed(6)}°',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _tempSelectedLocation = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigasi ke halaman tambah destinasi dengan koordinat
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddDestinationScreen(
                              selectedLocation: position,
                            ),
                          ),
                        ).then((_) {
                          _loadDestinations();
                          setState(() {
                            _tempSelectedLocation = null;
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lanjutkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _centerOnDestination(Destination destination) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(destination.latitude, destination.longitude),
        15,
      ),
    );
    setState(() => _selectedDestination = destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  onTap: _onMapTapped,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition ??
                        (_destinations.isNotEmpty
                            ? LatLng(_destinations.first.latitude,
                                _destinations.first.longitude)
                            : const LatLng(-6.2088, 106.8456)),
                    zoom: 12,
                  ),
                  markers: _markers,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                ),
          _buildTopBar(),
          if (_selectedDestination != null) _buildDestinationCard(),
          _buildFloatingButtons(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.map, color: Color(0xFF2196F3)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Peta Destinasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      '${_destinations.length} Lokasi • Tap untuk tambah',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_location,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (_selectedDestination!.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedDestination!.imagePath!),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDestination!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF2196F3),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _selectedDestination!.location,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _selectedDestination = null);
                  },
                  icon: const Icon(Icons.close, color: Color(0xFF666666)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _selectedDestination!.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Buka Google Maps untuk navigasi
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membuka Google Maps...')),
                      );
                    },
                    icon: const Icon(Icons.directions, size: 20),
                    label: const Text('Rute'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailDestinationScreen(
                            destination: _selectedDestination!,
                            onUpdate: _loadDestinations,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 20),
                    label: const Text('Detail'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2196F3),
                      side: const BorderSide(color: Color(0xFF2196F3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.35,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            mini: true,
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Color(0xFF2196F3)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            mini: true,
            backgroundColor: Colors.white,
            child: const Icon(Icons.remove, color: Color(0xFF2196F3)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'my_location',
            onPressed: () {
              if (_currentPosition != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentPosition!, 15),
                );
              } else {
                _getCurrentLocation();
              }
            },
            mini: true,
            backgroundColor: const Color(0xFF2196F3),
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: _loadDestinations,
            mini: true,
            backgroundColor: const Color(0xFF4CAF50),
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
