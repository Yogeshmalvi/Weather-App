// astronomy_tab_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// You'll need to import your AstronomyInfo model
// import 'astronomy_data.dart'; // Assuming you create this file

class AstronomyTabPage extends StatefulWidget {
  final String apiKey;
  final String cityName;
  final String date;

  const AstronomyTabPage({
    Key? key,
    required this.apiKey,
    required this.cityName,
    required this.date,
  }) : super(key: key);

  @override
  State<AstronomyTabPage> createState() => _AstronomyTabPageState();
}
// astronomy_data.dart
class AstronomyInfo {
  final String cityName;
  final String countryName;
  final String localTime;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String moonPhase;
  final String moonIllumination;

  AstronomyInfo({
    required this.cityName,
    required this.countryName,
    required this.localTime,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonIllumination,
  });

  factory AstronomyInfo.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final astronomy = json['astronomy']['astro'];
    return AstronomyInfo(
      cityName: location['name'] ?? 'N/A',
      countryName: location['country'] ?? 'N/A',
      localTime: location['localtime'] ?? 'N/A',
      sunrise: astronomy['sunrise'] ?? 'N/A',
      sunset: astronomy['sunset'] ?? 'N/A',
      moonrise: astronomy['moonrise'] ?? 'N/A',
      moonset: astronomy['moonset'] ?? 'N/A',
      moonPhase: astronomy['moon_phase'] ?? 'N/A',
      moonIllumination: astronomy['moon_illumination']?.toString() ?? 'N/A',
    );
  }
}

class _AstronomyTabPageState extends State<AstronomyTabPage> {
  AstronomyInfo? _astronomyInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAstronomyData();
  }

  @override
  void didUpdateWidget(covariant AstronomyTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName || oldWidget.date != widget.date) {
      _fetchAstronomyData();
    }
  }

  Future<void> _fetchAstronomyData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _astronomyInfo = null;
    });

    final String apiUrl =
        'http://api.weatherapi.com/v1/astronomy.json?key=${widget.apiKey}&q=${widget.cityName}&dt=${widget.date}';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _astronomyInfo = AstronomyInfo.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load astronomy data for ${widget.cityName}. Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching astronomy data: $e. Check connection.';
        _isLoading = false;
      });
    }
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {IconData? icon}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: theme.hintColor, size: 20),
          if (icon != null) const SizedBox(width: 10),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error, fontSize: 16), textAlign: TextAlign.center),
        ),
      );
    }
    if (_astronomyInfo == null) {
      return Center(child: Text('No astronomy data available for ${widget.cityName} on ${widget.date}.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center,));
    }

    final astro = _astronomyInfo!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Astronomy for ${astro.cityName}, ${astro.countryName}', style: theme.textTheme.titleLarge),
              Text('Date: ${widget.date}, Local Time: ${astro.localTime.split(" ").last}', style: theme.textTheme.titleSmall),
              const SizedBox(height: 16),
              _buildDetailRow(context, 'Sunrise', astro.sunrise, icon: Icons.wb_twilight_outlined),
              _buildDetailRow(context, 'Sunset', astro.sunset, icon: Icons.brightness_4_outlined),
              _buildDetailRow(context, 'Moonrise', astro.moonrise, icon: Icons.nightlight_round),
              _buildDetailRow(context, 'Moonset', astro.moonset, icon: Icons.night_shelter_outlined),
              _buildDetailRow(context, 'Moon Phase', astro.moonPhase, icon: Icons.brightness_2_outlined),
              _buildDetailRow(context, 'Moon Illumination', '${astro.moonIllumination}%', icon: Icons.lens_blur_outlined),
            ],
          ),
        ),
      ),
    );
  }
}