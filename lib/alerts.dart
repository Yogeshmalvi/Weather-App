// alerts_tab_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'alerts_data.dart'; // Import your Alert models

class AlertsTabPage extends StatefulWidget {
  final String apiKey;
  final String cityName;


  const AlertsTabPage({
    Key? key,
    required this.apiKey,
    required this.cityName,
  }) : super(key: key);

  @override
  State<AlertsTabPage> createState() => _AlertsTabPageState();
}
// alerts_data.dart
class AlertItem {
  final String headline;
  final String msgType; // e.g., "Alert", "Warning"
  final String severity; // e.g., "Moderate", "Severe"
  final String urgency; // e.g., "Immediate", "Expected"
  final String areas;
  final String category; // e.g., "Met"
  final String certainty; // e.g., "Observed", "Likely"
  final String event;
  final String note;
  final String effective; // DateTime
  final String expires;   // DateTime
  final String desc;
  final String instruction;

  AlertItem({
    required this.headline,
    required this.msgType,
    required this.severity,
    required this.urgency,
    required this.areas,
    required this.category,
    required this.certainty,
    required this.event,
    required this.note,
    required this.effective,
    required this.expires,
    required this.desc,
    required this.instruction,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      headline: json['headline'] ?? 'N/A',
      msgType: json['msgtype'] ?? 'N/A',
      severity: json['severity'] ?? 'N/A',
      urgency: json['urgency'] ?? 'N/A',
      areas: json['areas'] ?? 'N/A',
      category: json['category'] ?? 'N/A',
      certainty: json['certainty'] ?? 'N/A',
      event: json['event'] ?? 'N/A',
      note: json['note'] ?? 'N/A',
      effective: json['effective'] ?? 'N/A',
      expires: json['expires'] ?? 'N/A',
      desc: json['desc'] ?? 'N/A',
      instruction: json['instruction'] ?? 'N/A',
    );
  }
}

class AlertsData {
  final List<AlertItem> alerts;

  AlertsData({required this.alerts});

  factory AlertsData.fromJson(Map<String, dynamic> json) {
    List<AlertItem> alertItems = [];
    if (json['alert'] != null && json['alert'] is List) {
      alertItems = (json['alert'] as List)
          .map((item) => AlertItem.fromJson(item))
          .toList();
    }
    return AlertsData(alerts: alertItems);
  }
}

class _AlertsTabPageState extends State<AlertsTabPage> {
  AlertsData? _alertsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAlertsData();
  }

  @override
  void didUpdateWidget(covariant AlertsTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName) {
      _fetchAlertsData();
    }
  }

  Future<void> _fetchAlertsData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _alertsData = null;
    });

    final String apiUrl =
        'http://api.weatherapi.com/v1/alerts.json?key=${widget.apiKey}&q=${widget.cityName}';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _alertsData = AlertsData.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load alerts for ${widget.cityName}. Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching alerts: $e. Check connection.';
        _isLoading = false;
      });
    }
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
    if (_alertsData == null || _alertsData!.alerts.isEmpty) {
      return Center(child: Text('No active alerts for ${widget.cityName}.', style: theme.textTheme.bodyMedium));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _alertsData!.alerts.length,
      itemBuilder: (context, index) {
        final alert = _alertsData!.alerts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.headline, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Event: ${alert.event}', style: theme.textTheme.bodyMedium),
                Text('Severity: ${alert.severity} | Urgency: ${alert.urgency}', style: theme.textTheme.bodyMedium),
                Text('Effective: ${alert.effective} | Expires: ${alert.expires}', style: theme.textTheme.bodySmall),
                if (alert.desc.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Description: ${alert.desc}', style: theme.textTheme.bodySmall),
                ],
                if (alert.instruction.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Instruction: ${alert.instruction}', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                ],
                if (alert.areas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Areas: ${alert.areas}', style: theme.textTheme.bodySmall),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}