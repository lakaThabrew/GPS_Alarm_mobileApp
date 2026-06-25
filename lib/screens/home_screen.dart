import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../services/location_service.dart';
import '../providers/history_provider.dart';
import '../providers/location_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import 'tracking_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final MapController _mapController = MapController();
  Timer? _debounce;
  List<Destination> _suggestions = [];
  bool _isSearching = false;
  LatLng? _currentLocation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initLocation();
  }

  Future<void> _initLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentLocation!, 15.0);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _suggestions = [];
        });
        return;
      }
      setState(() => _isSearching = true);
      final results = await LocationService.searchDestinations(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      }
    });
  }

  void _startTracking(Destination dest) {
    FocusScope.of(context).unfocus(); // Close keyboard
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);

    historyProvider.addHistory(dest);
    locationProvider.startTracking(dest);

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrackingScreen()));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.95),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.satellite_alt, size: 48, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text('GPS Alarm', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: const Icon(Icons.history, color: AppColors.accent, size: 28),
                title: const Text('Search History', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: const Icon(Icons.person, color: AppColors.primary, size: 28),
                title: const Text('Profile', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Premium Dark Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(7.8731, 80.7718),
              initialZoom: 7.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lakathabrew.gps_alarm',
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 80,
                      height: 80,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 40 + (_pulseController.value * 40),
                                height: 40 + (_pulseController.value * 40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(alpha: 0.3 * (1 - _pulseController.value)),
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top UI Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Unified Search Bar & Menu Button
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    borderRadius: 30,
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: AppColors.textLight),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Container(width: 1, height: 24, color: AppColors.glassBorder),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: const TextStyle(color: AppColors.textLight, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Where to?',
                              hintStyle: const TextStyle(color: AppColors.textMuted),
                              border: InputBorder.none,
                              suffixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                      ),
                                    )
                                  : _searchController.text.isNotEmpty ? IconButton(
                                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _suggestions = [];
                                        });
                                      },
                                    ) : const Icon(Icons.search, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Search Results or History Dropdown
                  if (_suggestions.isNotEmpty || (_searchController.text.isEmpty && historyProvider.history.isNotEmpty))
                    Flexible(
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 20,
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _suggestions.isNotEmpty ? _suggestions.length : (historyProvider.history.length > 5 ? 5 : historyProvider.history.length),
                          separatorBuilder: (context, index) => Divider(color: AppColors.glassBorder, height: 1),
                          itemBuilder: (context, index) {
                            if (_suggestions.isNotEmpty) {
                              final dest = _suggestions[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                leading: const Icon(Icons.place, color: AppColors.accent),
                                title: Text(dest.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textLight, fontSize: 15)),
                                onTap: () {
                                  _searchController.clear();
                                  setState(() => _suggestions = []);
                                  _startTracking(dest);
                                },
                              );
                            } else {
                              final item = historyProvider.history[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                leading: const Icon(Icons.history, color: AppColors.textMuted),
                                title: Text(item.destination.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textLight, fontSize: 15)),
                                onTap: () => _startTracking(item.destination),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 8,
        onPressed: _initLocation,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
