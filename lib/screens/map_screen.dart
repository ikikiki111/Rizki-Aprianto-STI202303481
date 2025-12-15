import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/destination_model.dart';

class MapScreen extends StatefulWidget {
  final List<Destination> destinations;

  const MapScreen({Key? key, required this.destinations}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  Destination? _selectedDestination;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    for (var destination in widget.destinations) {
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
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (widget.destinations.isNotEmpty) {
      final firstDestination = widget.destinations.first;
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(firstDestination.latitude, firstDestination.longitude),
          12,
        ),
      );
    }
  }

  void _centerOnDestination(Destination destination) {
    _mapController.animateCamera(
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
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.destinations.isNotEmpty
                  ? LatLng(
                      widget.destinations.first.latitude,
                      widget.destinations.first.longitude,
                    )
                  : const LatLng(-6.2088, 106.8456),
              zoom: 12,
            ),
            markers: _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          _buildAppBar(),
          if (_selectedDestination != null) _buildDestinationCard(),
          _buildDestinationsList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
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
            borderRadius: BorderRadius.circular(16),
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
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new),
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Peta Destinasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      '${widget.destinations.length} Lokasi',
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
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.map, color: Color(0xFF2196F3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
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
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF666666),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _selectedDestination!.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.my_location,
                    size: 16,
                    color: Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDestination!.latitude.toStringAsFixed(4)}, ${_selectedDestination!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationsList() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.destinations.length,
          itemBuilder: (context, index) {
            final destination = widget.destinations[index];
            final isSelected = _selectedDestination?.id == destination.id;

            return GestureDetector(
              onTap: () => _centerOnDestination(destination),
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            destination.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destination.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white70
                                  : const Color(0xFF666666),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
