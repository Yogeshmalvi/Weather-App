// marine_tab_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'marine_data.dart'; // Import your Marine models

class MarineTabPage extends StatefulWidget {
  final String apiKey;
  final String cityName;

  const MarineTabPage({
    Key? key,
    required this.apiKey,
    required this.cityName,
  }) : super(key: key);

  @override
  State<MarineTabPage> createState() => _MarineTabPageState();
}
// marine_data.dart
class MarineHour {
  final String time;
  final double tempC;
  final String conditionText;
  final String conditionIcon;
  final double windKph;
  final String windDir;
  final double pressureMb;
  final double precipMm;
  final int humidity;
  final int cloud;
  final double feelslikeC;
  final double windchillC;
  final double heatindexC;
  final double dewpointC;
  final double visKm;
  final double gustKph;
  final double sigHm0; // Significant wave height
  final double swellHm0; // Swell wave height
  final String swellDir16Point;
  final double swellPeriodSecs;

  MarineHour({
    required this.time,
    required this.tempC,
    required this.conditionText,
    required this.conditionIcon,
    required this.windKph,
    required this.windDir,
    required this.pressureMb,
    required this.precipMm,
    required this.humidity,
    required this.cloud,
    required this.feelslikeC,
    required this.windchillC,
    required this.heatindexC,
    required this.dewpointC,
    required this.visKm,
    required this.gustKph,
    required this.sigHm0,
    required this.swellHm0,
    required this.swellDir16Point,
    required this.swellPeriodSecs,
  });

  factory MarineHour.fromJson(Map<String, dynamic> json) {
    return MarineHour(
      time: (json['time'] ?? '').split(' ').last, // HH:MM
      tempC: (json['temp_c'] as num?)?.toDouble() ?? 0.0,
      conditionText: json['condition']?['text'] ?? 'N/A',
      conditionIcon: 'https:${json['condition']?['icon'] ?? ''}',
      windKph: (json['wind_kph'] as num?)?.toDouble() ?? 0.0,
      windDir: json['wind_dir'] ?? 'N/A',
      pressureMb: (json['pressure_mb'] as num?)?.toDouble() ?? 0.0,
      precipMm: (json['precip_mm'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      cloud: (json['cloud'] as num?)?.toInt() ?? 0,
      feelslikeC: (json['feelslike_c'] as num?)?.toDouble() ?? 0.0,
      windchillC: (json['windchill_c'] as num?)?.toDouble() ?? 0.0,
      heatindexC: (json['heatindex_c'] as num?)?.toDouble() ?? 0.0,
      dewpointC: (json['dewpoint_c'] as num?)?.toDouble() ?? 0.0,
      visKm: (json['vis_km'] as num?)?.toDouble() ?? 0.0,
      gustKph: (json['gust_kph'] as num?)?.toDouble() ?? 0.0,
      sigHm0: (json['sig_hm0'] as num?)?.toDouble() ?? 0.0,
      swellHm0: (json['swell_hm0'] as num?)?.toDouble() ?? 0.0,
      swellDir16Point: json['swell_dir_16_point'] ?? 'N/A',
      swellPeriodSecs: (json['swell_period_secs'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MarineDayForecast {
  final String date;
  final List<MarineHour> hourly;
  // Add other daily marine data if available at this level

  MarineDayForecast({required this.date, required this.hourly});

  factory MarineDayForecast.fromJson(Map<String, dynamic> json) {
    List<MarineHour> hours = [];
    if (json['hour'] != null && json['hour'] is List) {
      hours = (json['hour'] as List)
          .map((h) => MarineHour.fromJson(h))
          .toList();
    }
    return MarineDayForecast(
      date: json['date'] ?? 'N/A',
      hourly: hours,
    );
  }
}

class MarineData {
  final String cityName;
  final String countryName;
  final List<MarineDayForecast> forecastDays;

  MarineData({required this.cityName, required this.countryName, required this.forecastDays});

  factory MarineData.fromJson(Map<String, dynamic> json) {
    List<MarineDayForecast> days = [];
    if (json['forecast']?['forecastday'] != null && json['forecast']['forecastday'] is List) {
      days = (json['forecast']['forecastday'] as List)
          .map((d) => MarineDayForecast.fromJson(d))
          .toList();
    }
    return MarineData(
      cityName: json['location']?['name'] ?? 'N/A',
      countryName: json['location']?['country'] ?? 'N/A',
      forecastDays: days,
    );
  }
}

class _MarineTabPageState extends State<MarineTabPage> {
  MarineData? _marineData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMarineData();
  }

  @override
  void didUpdateWidget(covariant MarineTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName) {
      _fetchMarineData();
    }
  }

  Future<void> _fetchMarineData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _marineData = null;
    });

    // API fetches 1 day by default with this URL structure
    final String apiUrl =
        'http://api.weatherapi.com/v1/marine.json?key=${widget.apiKey}&q=${widget.cityName}&days=1';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 15)); // Marine data can be larger
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _marineData = MarineData.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load marine data for ${widget.cityName}. Server error: ${response.statusCode}\n${response.body}'; // Include body for debugging
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching marine data: $e. Check connection.';
        _isLoading = false;
      });
    }
  }

  Widget _buildHourlyMarineCard(BuildContext context, MarineHour hour) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hour.time, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            Row(
              children: [
                if (hour.conditionIcon.isNotEmpty && hour.conditionIcon.startsWith("https:"))
                  Image.network(hour.conditionIcon, width: 32, height: 32, errorBuilder: (c,e,s) => Icon(Icons.error, size: 24)),
                const SizedBox(width: 8),
                Expanded(child: Text(hour.conditionText, style: theme.textTheme.bodySmall)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Temp: ${hour.tempC}°C, Feels: ${hour.feelslikeC}°C', style: theme.textTheme.bodySmall),
            Text('Wind: ${hour.windKph} kph ${hour.windDir}', style: theme.textTheme.bodySmall),
            Text('Swell: ${hour.swellHm0.toStringAsFixed(1)}m, ${hour.swellDir16Point}, ${hour.swellPeriodSecs.toStringAsFixed(0)}s', style: theme.textTheme.bodySmall),
            Text('Sig. Wave: ${hour.sigHm0.toStringAsFixed(1)}m', style: theme.textTheme.bodySmall),
            Text('Visibility: ${hour.visKm} km, Precip: ${hour.precipMm} mm', style: theme.textTheme.bodySmall),
          ],
        ),
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
    if (_marineData == null || _marineData!.forecastDays.isEmpty || _marineData!.forecastDays[0].hourly.isEmpty) {
      return Center(child: Text('No marine data available for ${widget.cityName}.', style: theme.textTheme.bodyMedium));
    }

    final todayMarineForecast = _marineData!.forecastDays[0];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Marine Forecast for ${_marineData!.cityName}, ${_marineData!.countryName} (${todayMarineForecast.date})',
              style: theme.textTheme.titleLarge,
            ),
          ),
          ListView.builder(
            shrinkWrap: true, // Important for ListView inside SingleChildScrollView
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
            itemCount: todayMarineForecast.hourly.length,
            itemBuilder: (context, index) {
              // Optionally show fewer items e.g. every 2 or 3 hours
              // if (index % 2 != 0) return const SizedBox.shrink();
              final hourData = todayMarineForecast.hourly[index];
              return _buildHourlyMarineCard(context, hourData);
            },
          ),
          const SizedBox(height: 20), // Padding at the bottom
        ],
      ),
    );
  }
}