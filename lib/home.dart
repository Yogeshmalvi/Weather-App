import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

// API key - Replace with your actual API key if needed for testing
const String apiKey = 'ada3e4551fd24e6aa63150110252304'; // KEEP YOUR API KEY SECRET
const String loadingLottieUrl = 'https://lottie.host/8be2d669-b332-43c5-a1e9-344f0423be91/JObcVoSx0J.json'; // Generic Loading Lottie

// --- Lottie URL Helper ---
String _getLottieForWeatherCondition(String conditionCodeStr, String conditionText, int isDay) {
  int? conditionCode = int.tryParse(conditionCodeStr);
  String text = conditionText.toLowerCase();

  // Prioritize condition codes
  if (conditionCode != null) {
    switch (conditionCode) {
      case 1000: // Sunny/Clear
        return isDay == 1
            ? 'https://lottie.host/e8109571-b69d-4b72-9e62-aa30d5c21ea3/jYwHjoIm9U.json' // Clear Day
            : 'https://lottie.host/ad2c3bf8-c5f5-4c84-9778-fdd2bc063c76/WdiCd3Lbgm.json'; // Clear Night
      case 1003: // Partly cloudy
        return isDay == 1
            ? 'https://lottie.host/04757a99-6344-48a2-93e2-3e6cb7039d02/tI2L1MiDKe.json' // Partly Cloudy Day
            : 'https://lottie.host/6289b634-1852-45a1-876e-344f917b92de/VLBNOc7qmQ.json'; // Partly Cloudy Night
      case 1006: // Cloudy
        return 'https://lottie.host/272adf84-a5ec-4769-b50d-079cb401eaa5/66RSNzHGHB.json'; // Cloudy
      case 1009: // Overcast
        return 'https://lottie.host/f31140ca-d2ce-4a42-a741-31cdf3f8a17d/XUQgVDBiMj.json'; // Very Cloudy/Overcast

      case 1030: // Mist
      case 1135: // Fog
      case 1147: // Freezing fog
        return 'https://lottie.host/a1288562-c13a-4e1a-b8d8-948281c4fdd1/C5DtSK6Sfm.json'; // Fog

    // Light Rain types
      case 1063: case 1150: case 1153: case 1180: case 1183: case 1240:
      return 'https://lottie.host/b3cf960d-0767-4f4d-ace1-b360c3cfea27/J4pIBcb9wx.json'; // Light Rain

    // Moderate/Heavy Rain types
      case 1186: case 1189: case 1192: case 1195: case 1243: case 1246:
      return 'https://lottie.host/fec9f978-6a78-4c3f-b11f-62523ae6600e/smvWo2oCZo.json'; // Heavy Rain

    // Light Snow types
      case 1066: case 1114: case 1210: case 1213: case 1255:
      return 'https://lottie.host/c3d12d7c-26ca-4fcf-9c6b-74e3980f3b39/puX9ZdEHUT.json'; // Light Snow

    // Moderate/Heavy Snow types (including blizzard aspects if primarily snow)
      case 1117: case 1216: case 1219: case 1222: case 1225: case 1258: case 1279: case 1282:
      return 'https://lottie.host/7142f962-4daa-404e-a9ae-d4bd0bce6b3e/WGLhuTIhEx.json'; // Heavy Snow

    // Sleet / Freezing Rain / Ice Pellets
      case 1069: case 1072: case 1168: case 1171: case 1198: case 1201:
      case 1204: case 1207: case 1237: case 1249: case 1252: case 1261: case 1264:
      return 'https://lottie.host/394008d4-e6e0-4872-8090-b3040f8b98dd/BHMeDHMzyE.json'; // Sleet

    // Thunderstorm
      case 1087: // Thundery outbreaks possible
      case 1273: // Patchy light rain with thunder
      case 1276: // Moderate or heavy rain with thunder
        return 'https://lottie.host/ab6aae1e-fe76-4107-a5ee-d1a065a2f392/bXoLaoZi4S.json'; // Thunderstorm
    }
  }


  // Fallback to text-based matching if code didn't precisely match or was null
  if (text.contains('thunder')) return 'https://lottie.host/e24f101d-5e9e-448e-9271-37d69dec3a9e/m5sKoNQPxY.json';
  if (text.contains('snow') || text.contains('blizzard')) return 'https://lottie.host/78579439-5456-4755-8e83-653bd7144771/J858z2zf8c.json';
  if (text.contains('rain') || text.contains('drizzle')) return 'https://lottie.host/87266792-b887-4b07-9b98-5368a192392e/g9y8sL5mAp.json';
  if (text.contains('sleet') || text.contains('ice pellets') || text.contains('freezing')) return 'https://lottie.host/93043ac9-a4b0-4d43-90f4-e89a75c12730/BkJk3g5KUM.json';
  if (text.contains('partly cloudy')) return isDay == 1 ? 'https://lottie.host/04757a99-6344-48a2-93e2-3e6cb7039d02/tI2L1MiDKe.json' : 'https://lottie.host/93693334-95a8-436e-8553-53291208377a/6gY8zC3x9s.json';
  if (text.contains('cloudy')) return 'https://lottie.host/2a874324-1174-4a35-a075-9cbc91a9787c/dGgD2F1m2w.json';
  if (text.contains('overcast')) return 'https://lottie.host/99e70aa0-de20-4801-a291-1922f9985302/TgnzXbT7HL.json';
  if (text.contains('clear') || text.contains('sunny')) return isDay == 1 ? 'https://lottie.host/cf43a899-83ae-4809-82f9-71887f44098c/yyp5PZ2kPE.json' : 'https://lottie.host/91267699-1192-4909-85a5-81f84831d271/NKaDBxsmX7.json';
  if (text.contains('mist') || text.contains('fog') || text.contains('haze')) return 'https://lottie.host/e92d02f6-62b5-4495-a50b-5c92a1f8d7e2/X5TLOW7rA8.json';

  print("Unknown weather condition for Lottie: Code '$conditionCodeStr', Text '$conditionText'. Using default.");
  return 'https://lottie.host/038a7d19-b2bd-4c84-9ed5-3c81ef224dcb/uQxp85f7I8.json'; // Weather Unknown
}


// --- Unit Enums & Extensions ---
enum TemperatureUnit { celsius, fahrenheit }
enum SpeedUnit { kph, mph }
enum PrecipitationUnit { mm, inches }
enum PressureUnit { mb, inHg }
enum VisibilityUnit { km, miles }

extension TemperatureUnitExtension on TemperatureUnit {
  String get display => this == TemperatureUnit.celsius ? '°C' : '°F';
  String get longDisplay => this == TemperatureUnit.celsius ? 'Celsius' : 'Fahrenheit';
}
extension SpeedUnitExtension on SpeedUnit {
  String get display => this == SpeedUnit.kph ? 'kph' : 'mph';
  String get longDisplay => this == SpeedUnit.kph ? 'km/h' : 'mph';
}
extension PrecipitationUnitExtension on PrecipitationUnit {
  String get display => this == PrecipitationUnit.mm ? 'mm' : 'in';
  String get longDisplay => this == PrecipitationUnit.mm ? 'Millimeters' : 'Inches';
}
extension PressureUnitExtension on PressureUnit {
  String get display => this == PressureUnit.mb ? 'mb' : 'inHg';
  String get longDisplay => this == PressureUnit.mb ? 'Millibars' : 'Inches of Mercury';
}
extension VisibilityUnitExtension on VisibilityUnit {
  String get display => this == VisibilityUnit.km ? 'km' : 'mi';
  String get longDisplay => this == VisibilityUnit.km ? 'Kilometers' : 'Miles';
}

// --- Animated Unit Display Widget ---
class AnimatedUnitTextDisplay<T extends Enum> extends StatelessWidget {
  final T currentValue;
  final String Function(T) toLongDisplay;
  final TextStyle? textStyle;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;

  const AnimatedUnitTextDisplay({
    super.key,
    required this.currentValue,
    required this.toLongDisplay,
    this.textStyle,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
    this.beginScale = 0.85,
    this.endScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: beginScale, end: endScale).animate(
              CurvedAnimation(parent: animation, curve: curve),
            ),
            child: child,
          ),
        );
      },
      child: Text(
        toLongDisplay(currentValue),
        key: ValueKey<T>(currentValue),
        style: textStyle,
        textAlign: TextAlign.end,
      ),
    );
  }
}

// --- Animated Weather Icon Widget ---
class AnimatedWeatherIcon extends StatelessWidget {
  final String iconUrl;
  final double width;
  final double height;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;

  const AnimatedWeatherIcon({
    super.key,
    required this.iconUrl,
    required this.width,
    required this.height,
    this.fit,
    this.errorBuilder,
    this.loadingBuilder,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOut,
    this.beginScale = 0.75,
    this.endScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: beginScale, end: endScale).animate(
              CurvedAnimation(parent: animation, curve: curve),
            ),
            child: child,
          ),
        );
      },
      child: iconUrl.isEmpty || !(iconUrl.startsWith("http:") || iconUrl.startsWith("https:"))
          ? SizedBox(
        key: ValueKey<String>('empty_icon_${DateTime.now().millisecondsSinceEpoch}_${iconUrl.hashCode}'),
        width: width,
        height: height,
        child: errorBuilder?.call(context, 'empty_or_invalid_url', StackTrace.current) ??
            Icon(Icons.broken_image_outlined, size: width * 0.7, color: Theme.of(context).hintColor),
      )
          : Image.network(
        iconUrl,
        key: ValueKey<String>(iconUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ??
                (ctx, err, st) => SizedBox(
              width: width,
              height: height,
              child: Center(
                child: Icon(Icons.cloud_off_outlined,
                    size: width * 0.7,
                    color: Theme.of(ctx).hintColor),
              ),
            ),
        loadingBuilder: loadingBuilder ??
                (ctx, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                width: width,
                height: height,
                child: Center(
                  child: Lottie.network(
                    loadingLottieUrl,
                    key: const ValueKey('animated_icon_loading_lottie'),
                    width: width * 0.8,
                    height: height * 0.8,
                  ),
                ),
              );
            },
      ),
    );
  }
}


// --- Data Model for Alerts ---
class AlertItem {
  final String headline;
  final String msgtype;
  final String severity;
  final String urgency;
  final String areas;
  final String category;
  final String certainty;
  final String event;
  final String note;
  final String effective;
  final String expires;
  final String desc;
  final String instruction;

  AlertItem({
    required this.headline,
    required this.msgtype,
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
      msgtype: json['msgtype'] ?? 'N/A',
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

// --- Data Model for List View Item ---
class WeatherLocation {
  final String city;
  final String country;
  final String temperatureC;
  final String temperatureF;
  final String highTempC;
  final String highTempF;
  final String lowTempC;
  final String lowTempF;
  final String condition;
  final String iconUrl;
  final String conditionCode;
  final List<AlertItem> alerts;
  final int isDay;
  final String airQualityText; // ADDED
  final List<HourlyForecast> hourlyForecasts; // ADDED

  WeatherLocation({
    required this.city,
    required this.country,
    required this.temperatureC,
    required this.temperatureF,
    required this.highTempC,
    required this.highTempF,
    required this.lowTempC,
    required this.lowTempF,
    required this.condition,
    required this.iconUrl,
    required this.conditionCode,
    required this.alerts,
    required this.isDay,
    required this.airQualityText, // ADDED
    required this.hourlyForecasts, // ADDED
  });

  static String _getAirQualityText(int? index) {
    if (index == null) return 'N/A';
    switch (index) {
      case 1: return 'Good';
      case 2: return 'Moderate';
      case 3: return 'Unhealthy for sensitive groups';
      case 4: return 'Unhealthy';
      case 5: return 'Very Unhealthy';
      case 6: return 'Hazardous';
      default: return 'Unknown';
    }
  }

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final forecastDay = json['forecast']['forecastday'][0];
    final conditionData = current['condition'];
    final alertData = json['alerts']?['alert'] as List<dynamic>?;
    final hourData = forecastDay['hour'] as List<dynamic>?;


    return WeatherLocation(
      city: location['name'] ?? 'Unknown City',
      country: location['country'] ?? 'Unknown Country',
      temperatureC: current['temp_c']?.round().toString() ?? 'N/A',
      temperatureF: current['temp_f']?.round().toString() ?? 'N/A',
      highTempC: forecastDay['day']['maxtemp_c']?.round().toString() ?? 'N/A',
      highTempF: forecastDay['day']['maxtemp_f']?.round().toString() ?? 'N/A',
      lowTempC: forecastDay['day']['mintemp_c']?.round().toString() ?? 'N/A',
      lowTempF: forecastDay['day']['mintemp_f']?.round().toString() ?? 'N/A',
      condition: conditionData['text'] ?? 'N/A',
      iconUrl: conditionData['icon'] != null ? 'https:${conditionData['icon']}' : '',
      conditionCode: conditionData['code']?.toString() ?? '',
      alerts: alertData?.map((a) => AlertItem.fromJson(a)).toList() ?? [],
      isDay: current['is_day'] as int? ?? 1,
      airQualityText: _getAirQualityText(current['air_quality']?['us-epa-index']), // ADDED
      hourlyForecasts: hourData?.map((h) => HourlyForecast.fromJson(h)).toList() ?? [], // ADDED
    );
  }
}

// --- Data Model for Detail Page ---
class FullWeatherInfo {
  final String cityName;
  final String countryName;
  final String localTime;
  final String tempC;
  final String tempF;
  final String feelsLikeC;
  final String feelsLikeF;
  final String conditionText;
  final String conditionIconUrl;
  final String windKph;
  final String windMph;
  final String windDir;
  final String pressureMb;
  final String pressureIn;
  final String precipMm;
  final String precipIn;
  final String humidity;
  final String cloud;
  final String visKm;
  final String visMiles;
  final String uv;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String moonPhase;
  final List<HourlyForecast> hourlyForecasts;
  final List<AlertItem> alerts;
  final int isDay;

  FullWeatherInfo({
    required this.cityName,
    required this.countryName,
    required this.localTime,
    required this.tempC,
    required this.tempF,
    required this.feelsLikeC,
    required this.feelsLikeF,
    required this.conditionText,
    required this.conditionIconUrl,
    required this.windKph,
    required this.windMph,
    required this.windDir,
    required this.pressureMb,
    required this.pressureIn,
    required this.precipMm,
    required this.precipIn,
    required this.humidity,
    required this.cloud,
    required this.visKm,
    required this.visMiles,
    required this.uv,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.hourlyForecasts,
    required this.alerts,
    required this.isDay,
  });

  factory FullWeatherInfo.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final forecast = json['forecast']['forecastday'][0];
    final astro = forecast['astro'];
    final List<dynamic> hourData = forecast['hour'] ?? [];
    final alertData = json['alerts']?['alert'] as List<dynamic>?;

    return FullWeatherInfo(
      cityName: location['name'] ?? 'N/A',
      countryName: location['country'] ?? 'N/A',
      localTime: location['localtime'] ?? 'N/A',
      tempC: current['temp_c']?.toStringAsFixed(1) ?? 'N/A',
      tempF: current['temp_f']?.toStringAsFixed(1) ?? 'N/A',
      feelsLikeC: current['feelslike_c']?.toStringAsFixed(1) ?? 'N/A',
      feelsLikeF: current['feelslike_f']?.toStringAsFixed(1) ?? 'N/A',
      conditionText: current['condition']['text'] ?? 'N/A',
      conditionIconUrl: current['condition']['icon'] != null ? 'https:${current['condition']['icon']}' : '',
      windKph: current['wind_kph']?.toString() ?? 'N/A',
      windMph: current['wind_mph']?.toString() ?? 'N/A',
      windDir: current['wind_dir'] ?? 'N/A',
      pressureMb: current['pressure_mb']?.toString() ?? 'N/A',
      pressureIn: current['pressure_in']?.toString() ?? 'N/A',
      precipMm: current['precip_mm']?.toString() ?? 'N/A',
      precipIn: current['precip_in']?.toString() ?? 'N/A',
      humidity: current['humidity']?.toString() ?? 'N/A',
      cloud: current['cloud']?.toString() ?? 'N/A',
      visKm: current['vis_km']?.toString() ?? 'N/A',
      visMiles: current['vis_miles']?.toString() ?? 'N/A',
      uv: current['uv']?.toString() ?? 'N/A',
      sunrise: astro['sunrise'] ?? 'N/A',
      sunset: astro['sunset'] ?? 'N/A',
      moonrise: astro['moonrise'] ?? 'N/A',
      moonset: astro['moonset'] ?? 'N/A',
      moonPhase: astro['moon_phase'] ?? 'N/A',
      hourlyForecasts: hourData
          .map((h) => HourlyForecast.fromJson(h))
          .toList(),
      alerts: alertData?.map((a) => AlertItem.fromJson(a)).toList() ?? [],
      isDay: current['is_day'] as int? ?? 1,
    );
  }
}

class HourlyForecast {
  final String time;
  final String tempC;
  final String tempF;
  final String conditionIconUrl;

  HourlyForecast({
    required this.time,
    required this.tempC,
    required this.tempF,
    required this.conditionIconUrl,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: (json['time'] ?? '').split(' ').last,
      tempC: json['temp_c']?.round().toString() ?? 'N/A',
      tempF: json['temp_f']?.round().toString() ?? 'N/A',
      conditionIconUrl: json['condition']?['icon'] != null ? '${json['condition']['icon']}' : '',
    );
  }
}

// --- Real Time Clock Widget ---
class RealTimeClock extends StatefulWidget {
  const RealTimeClock({super.key});

  @override
  State<RealTimeClock> createState() => _RealTimeClockState();
}

class _RealTimeClockState extends State<RealTimeClock> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer t) => _getTime(),
    );
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _currentTime = formattedDateTime;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTextStyle = Theme.of(context).appBarTheme.titleTextStyle;
    final fallbackColor = Theme.of(context).appBarTheme.foregroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Center(
        child: Text(
          _currentTime,
          style: TextStyle(
            fontSize: appBarTextStyle?.fontSize ?? 16,
            fontWeight: appBarTextStyle?.fontWeight ?? FontWeight.w500,
            color: appBarTextStyle?.color ?? fallbackColor,
          ),
        ),
      ),
    );
  }
}

// --- App Setup (MyApp) ---
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  SpeedUnit _speedUnit = SpeedUnit.kph;
  PrecipitationUnit _precipitationUnit = PrecipitationUnit.mm;
  PressureUnit _pressureUnit = PressureUnit.mb;
  VisibilityUnit _visibilityUnit = VisibilityUnit.km;

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _updateTemperatureUnit(TemperatureUnit unit) {
    setState(() { _temperatureUnit = unit; });
  }
  void _updateSpeedUnit(SpeedUnit unit) {
    setState(() { _speedUnit = unit; });
  }
  void _updatePrecipitationUnit(PrecipitationUnit unit) {
    setState(() { _precipitationUnit = unit; });
  }
  void _updatePressureUnit(PressureUnit unit) {
    setState(() { _pressureUnit = unit; });
  }
  void _updateVisibilityUnit(VisibilityUnit unit) {
    setState(() { _visibilityUnit = unit; });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.deepPurpleAccent[100] ?? Colors.white,
                width: 3.0,
              ),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey[500]),
          labelStyle: TextStyle(color: Colors.grey[700]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepPurpleAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[800]),
          bodyMedium: TextStyle(color: Colors.grey[600]),
          titleMedium: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          titleLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
        hintColor: Colors.grey[500],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.grey[50],
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        hintColor: Colors.white70,
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.deepPurpleAccent[100] ?? Colors.white,
                width: 3.0,
              ),
            ),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey[400]),
          titleMedium: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          titleLarge: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            color: Colors.deepPurpleAccent[100],
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: Colors.deepPurpleAccent[100],
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey[500]),
          labelStyle: TextStyle(color: Colors.grey[400]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepPurpleAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.25),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2C2A4A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1D36),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.deepPurpleAccent[100],
            foregroundColor: Colors.black87
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1F1D36),
        ),
      ),
      themeMode: _themeMode,
      home: const WeatherPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Main Weather List Page (WeatherPage) ---
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<WeatherLocation> _weatherLocations = [];
  bool _isLoading = false;
  String? _errorMessage;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final List<String> _initialCities = [
    'Ahmedabad',
    'Toronto',
    'Tokyo',
    'London',
    'Paris',
  ];

  final List<String> _tabs = [
    'Search',
    'Alerts',
    'Astronomy',
    'Marine',
    'Sports'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadWeatherForCities(_initialCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherForCities(List<String> cities) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    List<WeatherLocation> loadedLocations = [];
    try {
      for (String city in cities) {
        if (!mounted) return;
        try {
          // MODIFIED: aqi=yes
          final url = Uri.parse(
            'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=1&aqi=yes&alerts=yes',
          );
          final response =
          await http.get(url).timeout(const Duration(seconds: 10));
          if (!mounted) return;
          if (response.statusCode == 200) {
            loadedLocations.add(
              WeatherLocation.fromJson(json.decode(response.body)),
            );
          } else {
            print('Error for $city: ${response.statusCode}');
            if (loadedLocations.isEmpty && cities.length == 1) {
              _errorMessage =
              'City "$city" not found or API error (Code: ${response.statusCode}).';
            }
          }
        } catch (e) {
          print('Exception for $city: $e');
          if (loadedLocations.isEmpty && cities.length == 1) {
            _errorMessage = 'Failed to fetch data for $city. Check connection.';
          }
        }
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _weatherLocations = loadedLocations;
        _isLoading = false;
        if (_weatherLocations.isEmpty &&
            _errorMessage == null &&
            cities.isNotEmpty) {
          _errorMessage =
          'No data found for initial cities or connection error.';
        }
      });
    }
  }

  Future<void> _searchAndFetchWeather(String city) async {
    if (city.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // MODIFIED: aqi=yes
      final url = Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=1&aqi=yes&alerts=yes',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final newLocation = WeatherLocation.fromJson(
          json.decode(response.body),
        );
        setState(() {
          _weatherLocations.removeWhere(
                (loc) => loc.city.toLowerCase() == newLocation.city.toLowerCase(),
          );
          _weatherLocations.insert(0, newLocation);
          _searchController.clear();
        });
      } else {
        _errorMessage =
        'City "$city" not found or API error (Code: ${response.statusCode}).';
      }
    } catch (e) {
      _errorMessage =
      'Failed to fetch weather data for $city. Check your internet connection.';
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }


  Widget _buildCurrentLocationCard(WeatherLocation location, ThemeData theme, _MyAppState? myAppState) {
    if (myAppState == null) return const SizedBox.shrink();

    // Determine temperature units
    String displayTemp, displayHigh, displayLow;
    if (myAppState._temperatureUnit == TemperatureUnit.fahrenheit) {
      displayTemp = location.temperatureF;
      displayHigh = location.highTempF;
      displayLow = location.lowTempF;
    } else {
      displayTemp = location.temperatureC;
      displayHigh = location.highTempC;
      displayLow = location.lowTempC;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherDetailPage(
              cityName: location.city,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF4A4E69), const Color(0xFF22223B)]
                : [Colors.deepPurple.shade300, Colors.deepPurple.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.city,
              style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTemp,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 72,
                    height: 1.1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    myAppState._temperatureUnit.display,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const Spacer(),
                Lottie.network(
                  _getLottieForWeatherCondition(location.conditionCode, location.condition, location.isDay),
                  width: 80,
                  height: 80,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${location.condition}  ${displayLow}° / ${displayHigh}°  •  AQI: ${location.airQualityText}',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.9), fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Hourly Forecast
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: location.hourlyForecasts.length > 8 ? 8 : location.hourlyForecasts.length, // Show up to 8 hours
                itemBuilder: (context, index) {
                  final hourly = location.hourlyForecasts[index];
                  String hourlyTemp = myAppState._temperatureUnit == TemperatureUnit.fahrenheit
                      ? hourly.tempF
                      : hourly.tempC;

                  return Container(
                    width: 65,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(hourly.time, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(height: 4),
                        Image.network(
                          'https:${hourly.conditionIconUrl}',
                          width: 40,
                          height: 40,
                          errorBuilder: (c, e, s) => const Icon(Icons.cloud_off, color: Colors.white70, size: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$hourlyTemp°',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTabContent(ThemeData theme) {
    Widget content;
    final myAppState = context.findAncestorStateOfType<_MyAppState>();

    if (_isLoading) {
      content = Center(
        child: Lottie.network(
          loadingLottieUrl,
          key: const ValueKey('search_tab_loading_lottie'),
          width: 150,
          height: 150,
        ),
      );
    } else if (_errorMessage != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _errorMessage!,
            style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_weatherLocations.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Search for a city to see weather information.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      content = ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // Primary location card
          _buildCurrentLocationCard(_weatherLocations.first, theme, myAppState),

          // "Other Locations" section
          if (_weatherLocations.length > 1) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
              child: Text('Other Locations', style: theme.textTheme.titleLarge),
            ),
            // The rest of the locations
            ..._weatherLocations.skip(1).map((location) {
              return WeatherCard(
                location: location,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherDetailPage(
                        cityName: location.city,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ]
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Search Location',
              prefixIcon: Icon(Icons.search, color: theme.hintColor),
            ),
            onSubmitted: _searchAndFetchWeather,
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: content,
          ),
        ),
      ],
    );
  }


  Widget _buildUnitDropdown<T extends Enum>(
      BuildContext context,
      ThemeData theme,
      String title,
      IconData icon,
      T currentValue,
      List<T> allValues,
      String Function(T) toLongDisplay,
      void Function(T?) onChanged,
      ) {
    final defaultTextStyle = TextStyle(
      color: theme.textTheme.bodyLarge?.color ??
          (theme.brightness == Brightness.dark ? Colors.white : Colors.black),
    );

    return ListTile(
      leading: Icon(icon, color: theme.textTheme.bodyLarge?.color),
      title: Text(title, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
      trailing: DropdownButton<T>(
        value: currentValue,
        dropdownColor: theme.drawerTheme.backgroundColor ?? theme.cardColor,
        iconEnabledColor: theme.textTheme.bodyLarge?.color,
        underline: Container(),
        items: allValues.map((T itemValueInMenu) {
          return DropdownMenuItem<T>(
            value: itemValueInMenu,
            child: Text(
              toLongDisplay(itemValueInMenu),
              style: defaultTextStyle,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        selectedItemBuilder: (BuildContext context) {
          return allValues.map<Widget>((T item) {
            return Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AnimatedUnitTextDisplay<T>(
                currentValue: currentValue,
                toLongDisplay: toLongDisplay,
                textStyle: defaultTextStyle,
              ),
            );
          }).toList();
        },
      ),
    );
  }


  Widget _buildAppDrawer(BuildContext context, ThemeData theme, _MyAppState? myAppState) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Lottie.network('https://lottie.host/ed0850b6-1f4c-4f25-831e-def7536a0dbf/L0vW7YbD0M.json', // Default cloudy for drawer
                  width: 100,
                  height: 60,
                ),
                const SizedBox(height: 5),
                Text(
                  'Weather',
                  style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 20),
                ),
                Text(
                  'Quick actions & locations',
                  style: TextStyle(color: theme.appBarTheme.foregroundColor?.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.refresh, color: theme.textTheme.bodyLarge?.color),
            title: Text('Refresh Initial Cities', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              _loadWeatherForCities(_initialCities);
            },
          ),
          ListTile(
            leading: Icon(
              myAppState?._themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: theme.textTheme.bodyLarge?.color,
            ),
            title: Text(
              myAppState?._themeMode == ThemeMode.light ? 'Switch to Dark Mode' : 'Switch to Light Mode',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            onTap: () {
              myAppState?._toggleTheme();
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Unit Preferences',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildUnitDropdown<TemperatureUnit>( context, theme,
            'Temperature', Icons.thermostat_outlined,
            myAppState?._temperatureUnit ?? TemperatureUnit.celsius,
            TemperatureUnit.values, (u) => u.longDisplay,
                (TemperatureUnit? newValue) {
              if (newValue != null && myAppState != null) myAppState._updateTemperatureUnit(newValue);
            },
          ),
          _buildUnitDropdown<SpeedUnit>( context, theme,
            'Wind Speed', Icons.air_outlined,
            myAppState?._speedUnit ?? SpeedUnit.kph,
            SpeedUnit.values, (u) => u.longDisplay,
                (SpeedUnit? newValue) {
              if (newValue != null && myAppState != null) myAppState._updateSpeedUnit(newValue);
            },
          ),
          _buildUnitDropdown<PrecipitationUnit>( context, theme,
            'Precipitation', Icons.water_drop_outlined,
            myAppState?._precipitationUnit ?? PrecipitationUnit.mm,
            PrecipitationUnit.values, (u) => u.longDisplay,
                (PrecipitationUnit? newValue) {
              if (newValue != null && myAppState != null) myAppState._updatePrecipitationUnit(newValue);
            },
          ),
          _buildUnitDropdown<PressureUnit>( context, theme,
            'Pressure', Icons.speed_outlined,
            myAppState?._pressureUnit ?? PressureUnit.mb,
            PressureUnit.values, (u) => u.longDisplay,
                (PressureUnit? newValue) {
              if (newValue != null && myAppState != null) myAppState._updatePressureUnit(newValue);
            },
          ),
          _buildUnitDropdown<VisibilityUnit>( context, theme,
            'Visibility', Icons.visibility_outlined,
            myAppState?._visibilityUnit ?? VisibilityUnit.km,
            VisibilityUnit.values, (u) => u.longDisplay,
                (VisibilityUnit? newValue) {
              if (newValue != null && myAppState != null) myAppState._updateVisibilityUnit(newValue);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Current Locations',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_weatherLocations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'No locations loaded. Search or refresh.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            )
          else
            ..._weatherLocations.map((location) {
              String displayTemp;
              String tempUnitString;
              if (myAppState?._temperatureUnit == TemperatureUnit.fahrenheit) {
                displayTemp = location.temperatureF;
                tempUnitString = TemperatureUnit.fahrenheit.display;
              } else {
                displayTemp = location.temperatureC;
                tempUnitString = TemperatureUnit.celsius.display;
              }
              // Using AnimatedWeatherIcon here as it's the drawer, not the search card
              return ListTile(
                leading: AnimatedWeatherIcon(
                  key: ValueKey<String>('drawer_loc_icon_${location.city}_${location.iconUrl}'),
                  iconUrl: location.iconUrl,
                  width: 32,
                  height: 32,
                  errorBuilder: (c,e,s) => Icon(Icons.location_city, color: Theme.of(c).hintColor, size: 24),
                ),
                title: Text('${location.city}, ${location.country}', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                trailing: Text('$displayTemp$tempUnitString', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherDetailPage(
                        cityName: location.city,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.textTheme.bodyLarge?.color),
            title: Text('About', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
            onTap: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (context) => AlertDialog(
                title: const Text('About Weather App'),
                content: const Text('A simple weather application.\nVersion 1.1.0\nNew design with AQI support.'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
              ));
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myAppState = context.findAncestorStateOfType<_MyAppState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.cloud_queue),
          tooltip: 'Open Menu',
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text('Weather'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              myAppState?._themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              myAppState?._toggleTheme();
            },
          ),
          const RealTimeClock(),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((String name) => Tab(text: name)).toList(),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          indicatorWeight: 3.0,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        ),
      ),
      drawer: _buildAppDrawer(context, theme, myAppState),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.scaffoldBackgroundColor,
              theme.brightness == Brightness.dark
                  ? const Color(0xFF101020)
                  : Colors.deepPurple.shade200,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: _tabs.map((String name) {
            switch (name) {
              case 'Search':
                return _buildSearchTabContent(theme);
              case 'Alerts':
                return AlertsTabPage(weatherLocations: _weatherLocations);
              case 'Astronomy':
                return AstronomyTabPage(weatherLocations: _weatherLocations);
              case 'Marine':
                return MarineTabPage(weatherLocations: _weatherLocations);
              case 'Sports':
                return SportsTabPage(weatherLocations: _weatherLocations);
              default:
                return Center(
                  child: Text(
                    '$name Content Coming Soon',
                    style: theme.textTheme.titleLarge,
                  ),
                );
            }
          }).toList(),
        ),
      ),
    );
  }
}

// --- Weather Card Widget (WeatherCard) ---
class WeatherCard extends StatelessWidget {
  final WeatherLocation location;
  final VoidCallback onTap;

  const WeatherCard({super.key, required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myAppState = context.findAncestorStateOfType<_MyAppState>();

    String displayTemp, displayHigh, displayLow, tempUnitString;
    if (myAppState?._temperatureUnit == TemperatureUnit.fahrenheit) {
      displayTemp = location.temperatureF;
      displayHigh = location.highTempF;
      displayLow = location.lowTempF;
      tempUnitString = TemperatureUnit.fahrenheit.display;
    } else {
      displayTemp = location.temperatureC;
      displayHigh = location.highTempC;
      displayLow = location.lowTempC;
      tempUnitString = TemperatureUnit.celsius.display;
    }

    final tempStyle = theme.textTheme.displaySmall ??
        TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor);

    final String lottieUrl = _getLottieForWeatherCondition(location.conditionCode, location.condition, location.isDay);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$displayTemp$tempUnitString',
                      style: tempStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'H:$displayHigh$tempUnitString L:$displayLow$tempUnitString',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      location.city,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      location.country,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Lottie.network(
                      lottieUrl,
                      key: ValueKey<String>('lottie_${location.city}_${location.conditionCode}_${location.isDay}'), // More specific key
                      width: 64,
                      height: 64,
                      errorBuilder: (context, error, stackTrace) {
                        print("Lottie Error for $lottieUrl: $error"); // Log the error
                        // Fallback to a default "unknown" Lottie animation
                        return Lottie.network(
                            'https://lottie.host/a11964bb-f183-4b28-a8ab-56b98214e788/WyO7DrGPVH.json', // Unknown weather Lottie
                            key: ValueKey<String>('lottie_unknown_fallback_${location.city}'),
                            width: 64, height: 64,
                            errorBuilder: (ctx, err, st) {
                              // Final fallback to a static icon if even the default Lottie fails
                              return Icon(Icons.ac_unit, size: 50, color: theme.hintColor);
                            }
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location.condition,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Weather Detail Page (WeatherDetailPage) ---
class WeatherDetailPage extends StatefulWidget {
  final String cityName;

  const WeatherDetailPage({super.key, required this.cityName});

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  FullWeatherInfo? _weatherInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetailedWeather();
  }

  Future<void> _fetchDetailedWeather() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final url = Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=${widget.cityName}&days=1&aqi=yes&alerts=yes',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _weatherInfo = FullWeatherInfo.fromJson(json.decode(response.body));
        });
      } else {
        setState(() {
          _errorMessage =
          'Failed to load details for ${widget.cityName}: Server error ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching details: $e. Check connection.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon, bool isExpandable = false}) {
    final theme = Theme.of(context);
    Widget valueWidget = Text(
      value,
      style: theme.textTheme.bodyMedium,
      textAlign: TextAlign.end,
      softWrap: true,
    );

    if (isExpandable) {
      valueWidget = Expanded(child: valueWidget);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: theme.hintColor, size: 20),
          if (icon != null) const SizedBox(width: 10),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          isExpandable ? valueWidget : Flexible(child: valueWidget),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myAppState = context.findAncestorStateOfType<_MyAppState>();

    final bool isLightMode = myAppState?._themeMode == ThemeMode.light;

    final currentAppBarTheme = Theme.of(context).appBarTheme;
    const TextStyle defaultTitleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
    final TextStyle baseTitleStyle = currentAppBarTheme.titleTextStyle ?? defaultTitleStyle;
    final Color baseIconColor = currentAppBarTheme.iconTheme?.color ?? currentAppBarTheme.foregroundColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) ;


    TextStyle finalTitleTextStyle;
    Color finalIconColor;

    if (isLightMode) {
      finalTitleTextStyle = baseTitleStyle.copyWith(color: Colors.deepPurple);
      finalIconColor = Colors.deepPurple;
    } else {
      finalTitleTextStyle = baseTitleStyle;
      finalIconColor = baseIconColor;
    }

    final largeTempStyle =
        theme.textTheme.displaySmall?.copyWith(fontSize: 48) ??
            TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color);

    if (_isLoading) {
      return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient( colors: [ theme.scaffoldBackgroundColor, theme.brightness == Brightness.dark ? const Color(0xFF101020) : Colors.deepPurple.shade200, ], begin: Alignment.topCenter, end: Alignment.bottomCenter,),
            ),
            child: Center(
              child: Lottie.network(
                loadingLottieUrl,
                key: const ValueKey('detail_page_loading_lottie'),
                width: 180,
                height: 180,
              ),
            )
        ),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.cityName),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: finalIconColor),
          titleTextStyle: finalTitleTextStyle,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient( colors: [ theme.scaffoldBackgroundColor, theme.brightness == Brightness.dark ? const Color(0xFF101020) : Colors.deepPurple.shade200, ], begin: Alignment.topCenter, end: Alignment.bottomCenter,),
            ),
            child: Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error, fontSize: 16), textAlign: TextAlign.center)))
        ),
      );
    }
    if (_weatherInfo == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.cityName),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: finalIconColor),
            titleTextStyle: finalTitleTextStyle,
          ),
          extendBodyBehindAppBar: true,
          body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient( colors: [ theme.scaffoldBackgroundColor, theme.brightness == Brightness.dark ? const Color(0xFF101020) : Colors.deepPurple.shade200, ], begin: Alignment.topCenter, end: Alignment.bottomCenter,),
              ),
              child: Center(child: Text('No weather data available.', style: theme.textTheme.bodyMedium))
          )
      );
    }

    String mainTemp, feelsLikeTemp, currentTempUnitDisplay;
    if (myAppState?._temperatureUnit == TemperatureUnit.fahrenheit) {
      mainTemp = _weatherInfo!.tempF;
      feelsLikeTemp = _weatherInfo!.feelsLikeF;
      currentTempUnitDisplay = TemperatureUnit.fahrenheit.display;
    } else {
      mainTemp = _weatherInfo!.tempC;
      feelsLikeTemp = _weatherInfo!.feelsLikeC;
      currentTempUnitDisplay = TemperatureUnit.celsius.display;
    }

    String windSpeed, windUnitDisplay;
    if (myAppState?._speedUnit == SpeedUnit.mph) {
      windSpeed = _weatherInfo!.windMph;
      windUnitDisplay = SpeedUnit.mph.display;
    } else {
      windSpeed = _weatherInfo!.windKph;
      windUnitDisplay = SpeedUnit.kph.display;
    }

    String pressureVal, pressureUnitDisplay;
    if (myAppState?._pressureUnit == PressureUnit.inHg) {
      pressureVal = _weatherInfo!.pressureIn;
      pressureUnitDisplay = PressureUnit.inHg.display;
    } else {
      pressureVal = _weatherInfo!.pressureMb;
      pressureUnitDisplay = PressureUnit.mb.display;
    }

    String precipVal, precipUnitDisplay;
    if (myAppState?._precipitationUnit == PrecipitationUnit.inches) {
      precipVal = _weatherInfo!.precipIn;
      precipUnitDisplay = PrecipitationUnit.inches.display;
    } else {
      precipVal = _weatherInfo!.precipMm;
      precipUnitDisplay = PrecipitationUnit.mm.display;
    }

    String visVal, visUnitDisplay;
    if (myAppState?._visibilityUnit == VisibilityUnit.miles) {
      visVal = _weatherInfo!.visMiles;
      visUnitDisplay = VisibilityUnit.miles.display;
    } else {
      visVal = _weatherInfo!.visKm;
      visUnitDisplay = VisibilityUnit.km.display;
    }

    Widget mainWeatherVisual;
    if (_weatherInfo!.conditionIconUrl.isNotEmpty) {
      mainWeatherVisual = AnimatedWeatherIcon(
        key: ValueKey<String>('detail_main_icon_${_weatherInfo!.cityName}_${_weatherInfo!.conditionIconUrl}'),
        iconUrl: _weatherInfo!.conditionIconUrl.replaceFirst("64x64", "128x128"), // Larger image
        width: 100,
        height: 100,
        errorBuilder: (c, e, s) => Icon(
            Icons.error_outline,
            size: 64,
            color: theme.hintColor),
      );
    } else {
      String detailLottie = _getLottieForWeatherCondition(
          (_weatherInfo!.hourlyForecasts.isNotEmpty ? _weatherInfo!.hourlyForecasts.first.conditionIconUrl.split('/').last.split('.').first : "1000"),
          _weatherInfo!.conditionText,
          _weatherInfo!.isDay
      );
      mainWeatherVisual = Lottie.network(
          detailLottie,
          key: ValueKey<String>('detail_lottie_${_weatherInfo!.cityName}'),
          width: 100, height: 100,
          errorBuilder: (ctx, err, st) => Icon(Icons.cloud_queue, size:64, color: theme.hintColor)
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(_weatherInfo!.cityName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: finalIconColor),
        titleTextStyle: finalTitleTextStyle,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.scaffoldBackgroundColor,
              theme.brightness == Brightness.dark
                  ? const Color(0xFF101020)
                  : Colors.deepPurple.shade200,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              8.0,
              kToolbarHeight +
                  MediaQuery.of(context).padding.top +
                  8.0,
              8.0,
              8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                mainWeatherVisual,
                Text(
                  '$mainTemp$currentTempUnitDisplay',
                  style: largeTempStyle,
                ),
                Text(
                  _weatherInfo!.conditionText,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  'Feels like: $feelsLikeTemp$currentTempUnitDisplay',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Local Time: ${_weatherInfo!.localTime.split(" ").last}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Humidity', '${_weatherInfo!.humidity}%', icon: Icons.water_drop_outlined),
                        _buildDetailRow('Wind', '$windSpeed $windUnitDisplay ${_weatherInfo!.windDir}', icon: Icons.air),
                        _buildDetailRow('Pressure', '$pressureVal $pressureUnitDisplay', icon: Icons.speed_outlined),
                        _buildDetailRow('Precipitation', '$precipVal $precipUnitDisplay', icon: Icons.umbrella_outlined),
                        _buildDetailRow('Cloud Cover', '${_weatherInfo!.cloud}%', icon: Icons.cloud_outlined),
                        _buildDetailRow('Visibility', '$visVal $visUnitDisplay', icon: Icons.visibility_outlined),
                        _buildDetailRow('UV Index', _weatherInfo!.uv, icon: Icons.wb_sunny_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Celestial', style: theme.textTheme.titleLarge),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0),
                    child: Column(
                      children: [
                        _buildDetailRow('Sunrise', _weatherInfo!.sunrise, icon: Icons.wb_twilight_outlined),
                        _buildDetailRow('Sunset', _weatherInfo!.sunset, icon: Icons.brightness_4_outlined),
                        _buildDetailRow('Moonrise', _weatherInfo!.moonrise, icon: Icons.nightlight_round),
                        _buildDetailRow('Moonset', _weatherInfo!.moonset, icon: Icons.night_shelter_outlined),
                        _buildDetailRow('Moon Phase', _weatherInfo!.moonPhase, icon: Icons.brightness_2_outlined, isExpandable: true),
                      ],
                    ),
                  ),
                ),
                if (_weatherInfo!.alerts.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Active Alerts', style: theme.textTheme.titleLarge),
                  ..._weatherInfo!.alerts.map((alert) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert.headline, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Event: ${alert.event}", style: theme.textTheme.bodyMedium),
                          Text("Effective: ${alert.effective}", style: theme.textTheme.bodySmall),
                          Text("Expires: ${alert.expires}", style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Text(alert.desc, style: theme.textTheme.bodyMedium),
                          if (alert.instruction.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text("Instruction: ${alert.instruction}", style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                          ]
                        ],
                      ),
                    ),
                  )).toList(),
                ],
                const SizedBox(height: 20),
                if (_weatherInfo!.hourlyForecasts.isNotEmpty) ...[
                  Text('Hourly Forecast (Today)', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _weatherInfo!.hourlyForecasts.length,
                      itemBuilder: (context, index) {
                        final hourly = _weatherInfo!.hourlyForecasts[index];
                        String hourlyTemp;
                        if (myAppState?._temperatureUnit == TemperatureUnit.fahrenheit) {
                          hourlyTemp = hourly.tempF;
                        } else {
                          hourlyTemp = hourly.tempC;
                        }
                        if (index % 2 != 0 && _weatherInfo!.hourlyForecasts.length > 12 && _weatherInfo!.hourlyForecasts.length <=24) return const SizedBox.shrink();
                        if (index % 3 != 0 && _weatherInfo!.hourlyForecasts.length > 24) return const SizedBox.shrink();

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(hourly.time, style: theme.textTheme.bodySmall),
                                AnimatedWeatherIcon(
                                  key: ValueKey<String>('hourly_icon_${hourly.time}_${_weatherInfo!.cityName}_${hourly.conditionIconUrl}'),
                                  iconUrl: 'https:${hourly.conditionIconUrl}',
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (c, e, s) => Icon(Icons.thermostat, size: 24, color: Theme.of(c).hintColor),
                                ),
                                Text(
                                  '$hourlyTemp$currentTempUnitDisplay',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- Alerts Tab Page ---
class AlertsTabPage extends StatelessWidget {
  final List<WeatherLocation> weatherLocations;

  const AlertsTabPage({super.key, required this.weatherLocations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> allAlertWidgets = [];

    if (weatherLocations.isEmpty && ! _isLoadingFromParent(context) && _getErrorMessageFromParent(context) == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No locations loaded. Please search for a city on the "Search" tab.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }


    for (var location in weatherLocations) {
      if (location.alerts.isNotEmpty) {
        allAlertWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Alerts for ${location.city}, ${location.country}',
              style: theme.textTheme.titleLarge,
            ),
          ),
        );
        for (var alert in location.alerts) {
          allAlertWidgets.add(
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.headline, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Event: ${alert.event}", style: theme.textTheme.bodyMedium),
                    Text("Severity: ${alert.severity} (${alert.msgtype})", style: theme.textTheme.bodyMedium),
                    Text("Effective: ${alert.effective}", style: theme.textTheme.bodySmall),
                    Text("Expires: ${alert.expires}", style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text("Description: ${alert.desc}", style: theme.textTheme.bodyMedium),
                    if (alert.instruction.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text("Instruction: ${alert.instruction}", style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                    ]
                  ],
                ),
              ),
            ),
          );
        }
        allAlertWidgets.add(const SizedBox(height: 16));
      }
    }

    if (allAlertWidgets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            weatherLocations.isNotEmpty
                ? 'No active alerts for the current location(s).'
                : 'No locations loaded. Please search for a city on the "Search" tab.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top:8.0, bottom: 8.0),
      children: allAlertWidgets,
    );
  }
  bool _isLoadingFromParent(BuildContext context) {
    final weatherPageState = context.findAncestorStateOfType<_WeatherPageState>();
    return weatherPageState?._isLoading ?? false;
  }

  String? _getErrorMessageFromParent(BuildContext context) {
    final weatherPageState = context.findAncestorStateOfType<_WeatherPageState>();
    return weatherPageState?._errorMessage;
  }
}

// --- Base Class for Detail Tabs (Astronomy, Marine) ---
abstract class DetailFetchingTabPage extends StatefulWidget {
  final List<WeatherLocation> weatherLocations;
  const DetailFetchingTabPage({super.key, required this.weatherLocations});
}

abstract class _DetailFetchingTabPageState<T extends DetailFetchingTabPage> extends State<T> {
  String? _selectedCity;
  FullWeatherInfo? _weatherInfo;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.weatherLocations.isNotEmpty) {
      _selectedCity = widget.weatherLocations.first.city;
      _fetchDetailedWeatherForCity(_selectedCity!);
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weatherLocations.isNotEmpty) {
      final currentSelectedCityStillExists = widget.weatherLocations.any((loc) => loc.city == _selectedCity);

      if (_selectedCity == null || !currentSelectedCityStillExists) {
        _selectedCity = widget.weatherLocations.first.city;
        _fetchDetailedWeatherForCity(_selectedCity!);
      } else if (oldWidget.weatherLocations != widget.weatherLocations && _selectedCity != null) {
        if(widget.weatherLocations.any((loc) => loc.city == _selectedCity)) {
          _fetchDetailedWeatherForCity(_selectedCity!);
        } else {
          _selectedCity = widget.weatherLocations.first.city;
          _fetchDetailedWeatherForCity(_selectedCity!);
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _selectedCity = null;
          _weatherInfo = null;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    }
  }


  Future<void> _fetchDetailedWeatherForCity(String cityName) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherInfo = null;
    });
    try {
      final url = Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=1&aqi=yes&alerts=yes',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final newInfo = FullWeatherInfo.fromJson(json.decode(response.body));
        if (mounted && newInfo.cityName == _selectedCity) {
          setState(() {
            _weatherInfo = newInfo;
          });
        }
      } else {
        if (mounted && cityName == _selectedCity) {
          setState(() {
            _errorMessage =
            'Failed to load details for $cityName: Server error ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (!mounted && cityName == _selectedCity) return;
      setState(() {
        _errorMessage = 'Error fetching details for $cityName: $e. Check connection.';
      });
    } finally {
      if (mounted && cityName == _selectedCity) {
        setState(() {
          _isLoading = false;
        });
      } else if (mounted && _isLoading) { // Ensure loading stops if city changes mid-load
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildCitySelector(ThemeData theme) {
    if (widget.weatherLocations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Please search for a location on the "Search" tab first.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select City',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          labelStyle: TextStyle(color: theme.hintColor),
        ),
        value: _selectedCity,
        items: widget.weatherLocations
            .map((location) => DropdownMenuItem(
          value: location.city,
          child: Text(location.city, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        ))
            .toList(),
        onChanged: (value) {
          if (value != null && value != _selectedCity) {
            setState(() {
              _selectedCity = value;
              _weatherInfo = null;
              _errorMessage = null;
            });
            _fetchDetailedWeatherForCity(value);
          }
        },
        dropdownColor: theme.cardColor,
        iconEnabledColor: theme.hintColor,
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {IconData? icon}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: theme.hintColor, size: 18),
          if (icon != null) const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context, ThemeData theme, _MyAppState? myAppState);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myAppState = context.findAncestorStateOfType<_MyAppState>();

    Widget bodyContent;

    if (widget.weatherLocations.isEmpty) {
      bodyContent = Container();
    } else if (_isLoading) {
      bodyContent = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Lottie.network(
            loadingLottieUrl,
            key: const ValueKey('detail_tab_loading_lottie'),
            width: 120,
            height: 120,
          ),
        ),
      );
    } else if (_errorMessage != null && _weatherInfo == null) {
      bodyContent = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
        ),
      );
    } else if (_weatherInfo != null && _selectedCity != null && _weatherInfo!.cityName == _selectedCity) {
      bodyContent = buildContent(context, theme, myAppState);
    } else if (_selectedCity != null) {
      bodyContent = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('Loading data for $_selectedCity...', style: theme.textTheme.bodyMedium)),
      );
    }
    else {
      bodyContent = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('Please select a city to view details.', style: theme.textTheme.bodyMedium)),
      );
    }


    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCitySelector(theme),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: SizedBox( // Ensure the key changes when loading state or selected city changes
                key: ValueKey<String>(_selectedCity ?? 'no_city_selected' + (_isLoading ? '_loading' : (_errorMessage ?? (_weatherInfo?.cityName ?? 'no_info'))) ),
                child: bodyContent
            ),
          ),
        ],
      ),
    );
  }
}


// --- Astronomy Tab Page ---
class AstronomyTabPage extends DetailFetchingTabPage {
  const AstronomyTabPage({super.key, required super.weatherLocations});

  @override
  State<AstronomyTabPage> createState() => _AstronomyTabPageState();
}

class _AstronomyTabPageState extends _DetailFetchingTabPageState<AstronomyTabPage> {
  @override
  Widget buildContent(BuildContext context, ThemeData theme, _MyAppState? myAppState) {
    if (super._weatherInfo == null) {
      return Center(child: Text("No astronomy data available.", style: theme.textTheme.bodyMedium));
    }
    final astro = super._weatherInfo!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Celestial Information for ${astro.cityName}', style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              _buildDetailRow(context, 'Sunrise', astro.sunrise, icon: Icons.wb_twilight_outlined),
              _buildDetailRow(context, 'Sunset', astro.sunset, icon: Icons.brightness_4_outlined),
              _buildDetailRow(context, 'Moonrise', astro.moonrise, icon: Icons.nightlight_round),
              _buildDetailRow(context, 'Moonset', astro.moonset, icon: Icons.night_shelter_outlined),
              _buildDetailRow(context, 'Moon Phase', astro.moonPhase, icon: Icons.brightness_2_outlined),
              const SizedBox(height: 10),
              Text('Local Time: ${astro.localTime.split(" ").last}', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ],
          ),
        ),
      ),
    );
  }
}


// --- Marine Tab Page ---
class MarineTabPage extends DetailFetchingTabPage {
  const MarineTabPage({super.key, required super.weatherLocations});

  @override
  State<MarineTabPage> createState() => _MarineTabPageState();
}

class _MarineTabPageState extends _DetailFetchingTabPageState<MarineTabPage> {
  @override
  Widget buildContent(BuildContext context, ThemeData theme, _MyAppState? myAppState) {
    if (super._weatherInfo == null || myAppState == null) {
      return Center(child: Text("No marine data available.", style: theme.textTheme.bodyMedium));
    }
    final weather = super._weatherInfo!;
    final appState = myAppState;

    String windSpeed, windUnitDisplay;
    if (appState._speedUnit == SpeedUnit.mph) {
      windSpeed = weather.windMph;
      windUnitDisplay = SpeedUnit.mph.display;
    } else {
      windSpeed = weather.windKph;
      windUnitDisplay = SpeedUnit.kph.display;
    }

    String pressureVal, pressureUnitDisplay;
    if (appState._pressureUnit == PressureUnit.inHg) {
      pressureVal = weather.pressureIn;
      pressureUnitDisplay = PressureUnit.inHg.display;
    } else {
      pressureVal = weather.pressureMb;
      pressureUnitDisplay = PressureUnit.mb.display;
    }

    String precipVal, precipUnitDisplay;
    if (appState._precipitationUnit == PrecipitationUnit.inches) {
      precipVal = weather.precipIn;
      precipUnitDisplay = PrecipitationUnit.inches.display;
    } else {
      precipVal = weather.precipMm;
      precipUnitDisplay = PrecipitationUnit.mm.display;
    }

    String visVal, visUnitDisplay;
    if (appState._visibilityUnit == VisibilityUnit.miles) {
      visVal = weather.visMiles;
      visUnitDisplay = VisibilityUnit.miles.display;
    } else {
      visVal = weather.visKm;
      visUnitDisplay = VisibilityUnit.km.display;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Marine Conditions for ${weather.cityName}', style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              _buildDetailRow(context, 'Wind', '$windSpeed $windUnitDisplay ${weather.windDir}', icon: Icons.air),
              _buildDetailRow(context, 'Visibility', '$visVal $visUnitDisplay', icon: Icons.visibility_outlined),
              _buildDetailRow(context, 'Pressure', '$pressureVal $pressureUnitDisplay', icon: Icons.speed_outlined),
              _buildDetailRow(context, 'Precipitation', '$precipVal $precipUnitDisplay', icon: Icons.umbrella_outlined),
              _buildDetailRow(context, 'Cloud Cover', '${weather.cloud}%', icon: Icons.cloud_outlined),
              _buildDetailRow(context, 'Humidity', '${weather.humidity}%', icon: Icons.water_drop_outlined),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Note: For detailed tide and sea state information, a dedicated marine forecast is recommended.',
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: theme.hintColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Sports Tab Page ---
class SportsTabPage extends StatefulWidget {
  final List<WeatherLocation> weatherLocations;

  const SportsTabPage({super.key, required this.weatherLocations});

  @override
  State<SportsTabPage> createState() => _SportsTabPageState();
}

class _SportsTabPageState extends State<SportsTabPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myAppState = context.findAncestorStateOfType<_MyAppState>();
    String sportsAdvice = "Check local conditions for outdoor activities.";

    if (widget.weatherLocations.isNotEmpty && myAppState != null) {
      final firstLocation = widget.weatherLocations.first;
      String tempToParse;
      String currentTempUnitDisplay;

      if (myAppState._temperatureUnit == TemperatureUnit.fahrenheit) {
        tempToParse = firstLocation.temperatureF;
        currentTempUnitDisplay = TemperatureUnit.fahrenheit.display;
      } else {
        tempToParse = firstLocation.temperatureC;
        currentTempUnitDisplay = TemperatureUnit.celsius.display;
      }

      try {
        if (tempToParse != "N/A") {
          double temp = double.parse(tempToParse);
          double lowThresholdCelsius = 10;
          double highThresholdCelsius = 26;
          double lowThresholdFahrenheit = 50;
          double highThresholdFahrenheit = 79;


          double lowThreshold = myAppState._temperatureUnit == TemperatureUnit.celsius ? lowThresholdCelsius : lowThresholdFahrenheit;
          double highThreshold = myAppState._temperatureUnit == TemperatureUnit.celsius ? highThresholdCelsius : highThresholdFahrenheit;

          String conditionLower = firstLocation.condition.toLowerCase();
          bool isAdverse = conditionLower.contains("rain") ||
              conditionLower.contains("storm") ||
              conditionLower.contains("snow") ||
              conditionLower.contains("sleet") ||
              conditionLower.contains("blizzard") ||
              conditionLower.contains("thunder");


          if (isAdverse) {
            sportsAdvice = "Adverse weather (${firstLocation.condition}) in ${firstLocation.city}. Indoor sports are recommended.";
          } else if (temp >= lowThreshold && temp <= highThreshold) {
            sportsAdvice = "Weather in ${firstLocation.city} ($tempToParse$currentTempUnitDisplay, ${firstLocation.condition}) seems pleasant for outdoor sports.";
          } else if (temp < lowThreshold) {
            sportsAdvice = "It's quite cool in ${firstLocation.city} ($tempToParse$currentTempUnitDisplay, ${firstLocation.condition}). Dress warmly for outdoor activities.";
          } else {
            sportsAdvice = "It's quite warm in ${firstLocation.city} ($tempToParse$currentTempUnitDisplay, ${firstLocation.condition}). Stay hydrated and take breaks if playing sports outdoors.";
          }
        } else {
          sportsAdvice = "Temperature data not available for ${firstLocation.city}. Check detailed forecast for sports planning.";
        }
      } catch(e) {
        print("Error parsing temperature for sports advice: $e");
        sportsAdvice = "Could not determine sports advice for ${firstLocation.city} due to a data issue. Please check the detailed forecast.";
      }
    } else if (widget.weatherLocations.isEmpty) {
      sportsAdvice = 'Please search for a location on the "Search" tab to get sports weather advice.';
    }


    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_run, size: 60, color: theme.hintColor),
            const SizedBox(height: 20),
            Text(
              'Sports Weather Outlook',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              sportsAdvice,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '(This is a basic outlook based on the first loaded/searched city. For specific events, always consult detailed forecasts and local information.)',
              style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(const MyApp());
}