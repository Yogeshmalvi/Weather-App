// sports_tab_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'sports_data.dart'; // Import your Sports models

class SportsTabPage extends StatefulWidget {
  final String apiKey;
  final String cityName;

  const SportsTabPage({
    Key? key,
    required this.apiKey,
    required this.cityName,
  }) : super(key: key);

  @override
  State<SportsTabPage> createState() => _SportsTabPageState();
}
// sports_data.dart
class SportEvent {
  final String stadium;
  final String country;
  final String region;
  final String tournament;
  final String start; // DateTime string
  final String match;

  SportEvent({
    required this.stadium,
    required this.country,
    required this.region,
    required this.tournament,
    required this.start,
    required this.match,
  });

  factory SportEvent.fromJson(Map<String, dynamic> json) {
    return SportEvent(
      stadium: json['stadium'] ?? 'N/A',
      country: json['country'] ?? 'N/A',
      region: json['region'] ?? 'N/A',
      tournament: json['tournament'] ?? 'N/A',
      start: json['start'] ?? 'N/A',
      match: json['match'] ?? 'N/A',
    );
  }
}

class SportsData {
  final List<SportEvent> football;
  final List<SportEvent> cricket;
  final List<SportEvent> golf;
  // Add other sports if the API returns them under different keys

  SportsData({required this.football, required this.cricket, required this.golf});

  factory SportsData.fromJson(Map<String, dynamic> json) {
    List<SportEvent> parseEvents(dynamic eventListJson) {
      if (eventListJson != null && eventListJson is List) {
        return (eventListJson as List)
            .map((item) => SportEvent.fromJson(item))
            .toList();
      }
      return [];
    }

    return SportsData(
      football: parseEvents(json['football']),
      cricket: parseEvents(json['cricket']),
      golf: parseEvents(json['golf']),
    );
  }
}

class _SportsTabPageState extends State<SportsTabPage> {
  SportsData? _sportsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSportsData();
  }

  @override
  void didUpdateWidget(covariant SportsTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName) {
      _fetchSportsData();
    }
  }

  Future<void> _fetchSportsData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _sportsData = null;
    });

    final String apiUrl =
        'http://api.weatherapi.com/v1/sports.json?key=${widget.apiKey}&q=${widget.cityName}';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sportsData = SportsData.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load sports events for ${widget.cityName}. Server error: ${response.statusCode}\n${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching sports events: $e. Check connection.';
        _isLoading = false;
      });
    }
  }

  Widget _buildSportEventsList(BuildContext context, String title, List<SportEvent> events) {
    final theme = Theme.of(context);
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No upcoming $title events found for this location.', style: theme.textTheme.bodyMedium),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.match, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Tournament: ${event.tournament}', style: theme.textTheme.bodyMedium),
                    Text('Stadium: ${event.stadium}, ${event.region}, ${event.country}', style: theme.textTheme.bodySmall),
                    Text('Start Time: ${event.start}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
    if (_sportsData == null) {
      return Center(child: Text('No sports data available for ${widget.cityName}.', style: theme.textTheme.bodyMedium));
    }
    if(_sportsData!.football.isEmpty && _sportsData!.cricket.isEmpty && _sportsData!.golf.isEmpty){
      return Center(child: Text('No sports events found for ${widget.cityName} in Football, Cricket, or Golf.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center,));
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSportEventsList(context, 'Football', _sportsData!.football),
          _buildSportEventsList(context, 'Cricket', _sportsData!.cricket),
          _buildSportEventsList(context, 'Golf', _sportsData!.golf),
          // Add more sports if your API supports and model includes them
        ],
      ),
    );
  }
}