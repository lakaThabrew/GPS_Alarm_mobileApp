import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Search History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppColors.danger),
            onPressed: () => provider.clearHistory(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Static Map Background
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(7.8731, 80.7718),
              initialZoom: 7.0,
              interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lakathabrew.gps_alarm',
                subdomains: const ['a', 'b', 'c'],
              ),
              Container(color: Colors.black.withValues(alpha: 0.6)),
            ],
          ),
          
          // Content
          SafeArea(
            child: provider.history.isEmpty
                ? const Center(
                    child: GlassCard(
                      child: Text(
                        'No search history yet.',
                        style: TextStyle(color: AppColors.textLight, fontSize: 18),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: provider.history.length,
                    itemBuilder: (context, index) {
                      final item = provider.history[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                                ),
                                child: const Icon(Icons.place, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.destination.name,
                                      style: const TextStyle(
                                        color: AppColors.textLight,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Searched on: ${item.timestamp.toLocal().toString().split('.')[0]}',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
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
        ],
      ),
    );
  }
}
