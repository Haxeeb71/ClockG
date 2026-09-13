import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/world_clock_provider.dart';
import '../models/world_city.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WorldClockProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wc = context.watch<WorldClockProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.public, color: AppTheme.cyberYellow, size: 24),
            SizedBox(width: 10),
            Text('World Clock'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.cyberYellow, size: 28),
            tooltip: 'Add City',
            onPressed: () => _openAddCitySheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Hero Local Clock
          SliverToBoxAdapter(
            child: _LocalClockHero(now: wc.now),
          ),
          // Section header for world cities
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SAVED CITIES (${wc.cities.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                    ),
                  ),
                  if (wc.cities.isNotEmpty)
                    Text(
                      'Swipe left to remove',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.textMuted.withValues(alpha: 0.7) : Colors.black45,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (wc.cities.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFF1F5F9),
                        ),
                        child: Icon(
                          Icons.language_rounded,
                          size: 48,
                          color: isDark ? AppTheme.textMuted : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Cities Added',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Track local times across global timezones\nby adding cities below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.textMuted : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => _openAddCitySheet(context),
                        icon: const Icon(Icons.add, color: AppTheme.cyberYellow),
                        label: const Text('Add City', style: TextStyle(color: AppTheme.cyberYellow)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.cyberYellow),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final city = wc.cities[index];
                    DateTime cityTime;
                    try {
                      cityTime = wc.timeInCity(city);
                    } catch (_) {
                      cityTime = wc.now;
                    }
                    return _WorldCityCard(
                      city: city,
                      cityTime: cityTime,
                      localTime: wc.now,
                      onDelete: () => wc.removeCity(city.id!),
                    );
                  },
                  childCount: wc.cities.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddCitySheet(context),
        child: const Icon(Icons.add_location_alt_rounded),
      ),
    );
  }

  Future<void> _openAddCitySheet(BuildContext context) async {
    final wc = context.read<WorldClockProvider>();
    final city = await showModalBottomSheet<WorldCity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddCitySheet(),
    );
    if (city != null) {
      await wc.addCity(city);
    }
  }
}

class _LocalClockHero extends StatelessWidget {
  const _LocalClockHero({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('h:mm').format(now);
    final period = DateFormat('a').format(now);
    final dateStr = DateFormat('EEEE, MMM d').format(now);
    final offsetHours = now.timeZoneOffset.inHours;
    final offsetMins = (now.timeZoneOffset.inMinutes.abs() % 60);
    final offsetSign = offsetHours >= 0 ? '+' : '-';
    final tzString = 'GMT$offsetSign${offsetHours.abs().toString().padLeft(2, '0')}:${offsetMins.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.cyberGunmetal,
                  AppTheme.cyberSurfaceElevated,
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8FAFC),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        children: [
          // Analog dial
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: _AnalogClockPainter(
                dateTime: now,
                accentColor: AppTheme.cyberYellow,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Digital Readout
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cyberYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.cyberYellow : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dateStr.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.accentTeal,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.my_location_rounded, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                'Local Time • $tzString',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  _AnalogClockPainter({
    required this.dateTime,
    required this.accentColor,
    required this.isDark,
  });

  final DateTime dateTime;
  final Color accentColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer background circle
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Rim border
    final rimPaint = Paint()
      ..color = isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, rimPaint);

    // Hour ticks
    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = i * (math.pi / 30);
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 10.0 : 4.0;

      tickPaint.strokeWidth = isMajor ? 2.5 : 1.0;
      tickPaint.color = isMajor
          ? (i % 15 == 0 ? accentColor : (isDark ? Colors.white70 : Colors.black54))
          : (isDark ? Colors.white24 : Colors.black12);

      final startX = center.dx + (radius - 4) * math.cos(angle);
      final startY = center.dy + (radius - 4) * math.sin(angle);
      final endX = center.dx + (radius - 4 - tickLength) * math.cos(angle);
      final endY = center.dy + (radius - 4 - tickLength) * math.sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    // Time calculations
    final second = dateTime.second + (dateTime.millisecond / 1000.0);
    final minute = dateTime.minute + (second / 60.0);
    final hour = (dateTime.hour % 12) + (minute / 60.0);

    // Hour Hand
    final hourAngle = (hour * (math.pi / 6)) - (math.pi / 2);
    final hourHandLength = radius * 0.50;
    final hourPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF0F172A)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + hourHandLength * math.cos(hourAngle),
          center.dy + hourHandLength * math.sin(hourAngle)),
      hourPaint,
    );

    // Minute Hand
    final minAngle = (minute * (math.pi / 30)) - (math.pi / 2);
    final minHandLength = radius * 0.70;
    final minPaint = Paint()
      ..color = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + minHandLength * math.cos(minAngle),
          center.dy + minHandLength * math.sin(minAngle)),
      minPaint,
    );

    // Second Hand
    final secAngle = (second * (math.pi / 30)) - (math.pi / 2);
    final secHandLength = radius * 0.80;
    final secPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Tail
    canvas.drawLine(
      Offset(center.dx - 12 * math.cos(secAngle), center.dy - 12 * math.sin(secAngle)),
      Offset(center.dx + secHandLength * math.cos(secAngle),
          center.dy + secHandLength * math.sin(secAngle)),
      secPaint,
    );

    // Center pin
    final pinPaint = Paint()..color = accentColor;
    canvas.drawCircle(center, 4, pinPaint);
    final innerPin = Paint()..color = Colors.black;
    canvas.drawCircle(center, 1.5, innerPin);
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) {
    return oldDelegate.dateTime != dateTime;
  }
}

class _WorldCityCard extends StatelessWidget {
  const _WorldCityCard({
    required this.city,
    required this.cityTime,
    required this.localTime,
    required this.onDelete,
  });

  final WorldCity city;
  final DateTime cityTime;
  final DateTime localTime;
  final VoidCallback onDelete;

  String _getTimeDifference() {
    final diffMinutes = cityTime.difference(localTime).inMinutes;
    final diffHours = (diffMinutes / 60).round();

    if (diffHours == 0) return 'Same time';
    final sign = diffHours > 0 ? '+' : '';
    final dayDiff = cityTime.day - localTime.day;
    String dayLabel = '';
    if (dayDiff > 0) dayLabel = ', tomorrow';
    if (dayDiff < 0) dayLabel = ', yesterday';

    return '$sign$diffHours hrs$dayLabel';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('h:mm').format(cityTime);
    final period = DateFormat('a').format(cityTime);
    final isDaytime = cityTime.hour >= 6 && cityTime.hour < 18;
    final diffText = _getTimeDifference();

    return Dismissible(
      key: ValueKey(city.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.accentRed.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'REMOVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cyberGunmetal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Day/Night indicator icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDaytime
                    ? const Color(0xFFFFF7ED)
                    : (isDark ? AppTheme.cyberSurfaceElevated : const Color(0xFFF1F5F9)),
                border: Border.all(
                  color: isDaytime
                      ? const Color(0xFFFDBA74)
                      : (isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1)),
                ),
              ),
              child: Icon(
                isDaytime ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: isDaytime ? const Color(0xFFF59E0B) : const Color(0xFF38BDF8),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // City details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        diffText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentTeal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${city.timezone.split('/').last.replaceAll('_', ' ')}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Time display
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.cyberYellow : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCitySheet extends StatefulWidget {
  const _AddCitySheet();

  @override
  State<_AddCitySheet> createState() => _AddCitySheetState();
}

class _AddCitySheetState extends State<_AddCitySheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  static const List<Map<String, String>> _popularCities = [
    {'name': 'London', 'country': 'United Kingdom', 'tz': 'Europe/London'},
    {'name': 'New York', 'country': 'United States', 'tz': 'America/New_York'},
    {'name': 'Tokyo', 'country': 'Japan', 'tz': 'Asia/Tokyo'},
    {'name': 'Paris', 'country': 'France', 'tz': 'Europe/Paris'},
    {'name': 'Sydney', 'country': 'Australia', 'tz': 'Australia/Sydney'},
    {'name': 'Dubai', 'country': 'United Arab Emirates', 'tz': 'Asia/Dubai'},
    {'name': 'Singapore', 'country': 'Singapore', 'tz': 'Asia/Singapore'},
    {'name': 'Los Angeles', 'country': 'United States', 'tz': 'America/Los_Angeles'},
    {'name': 'Hong Kong', 'country': 'Hong Kong', 'tz': 'Asia/Hong_Kong'},
    {'name': 'Berlin', 'country': 'Germany', 'tz': 'Europe/Berlin'},
    {'name': 'Cairo', 'country': 'Egypt', 'tz': 'Africa/Cairo'},
    {'name': 'Mumbai', 'country': 'India', 'tz': 'Asia/Kolkata'},
    {'name': 'Toronto', 'country': 'Canada', 'tz': 'America/Toronto'},
    {'name': 'Seoul', 'country': 'South Korea', 'tz': 'Asia/Seoul'},
    {'name': 'Sao Paulo', 'country': 'Brazil', 'tz': 'America/Sao_Paulo'},
    {'name': 'Bangkok', 'country': 'Thailand', 'tz': 'Asia/Bangkok'},
    {'name': 'Rome', 'country': 'Italy', 'tz': 'Europe/Rome'},
    {'name': 'Auckland', 'country': 'New Zealand', 'tz': 'Pacific/Auckland'},
    {'name': 'San Francisco', 'country': 'United States', 'tz': 'America/Los_Angeles'},
    {'name': 'Chicago', 'country': 'United States', 'tz': 'America/Chicago'},
    {'name': 'Amsterdam', 'country': 'Netherlands', 'tz': 'Europe/Amsterdam'},
    {'name': 'Madrid', 'country': 'Spain', 'tz': 'Europe/Madrid'},
    {'name': 'Zurich', 'country': 'Switzerland', 'tz': 'Europe/Zurich'},
    {'name': 'Istanbul', 'country': 'Turkey', 'tz': 'Europe/Istanbul'},
    {'name': 'Beijing', 'country': 'China', 'tz': 'Asia/Shanghai'},
    {'name': 'Mexico City', 'country': 'Mexico', 'tz': 'America/Mexico_City'},
    {'name': 'Buenos Aires', 'country': 'Argentina', 'tz': 'America/Argentina/Buenos_Aires'},
    {'name': 'Johannesburg', 'country': 'South Africa', 'tz': 'Africa/Johannesburg'},
    {'name': 'Jakarta', 'country': 'Indonesia', 'tz': 'Asia/Jakarta'},
    {'name': 'Kuala Lumpur', 'country': 'Malaysia', 'tz': 'Asia/Kuala_Lumpur'},
    {'name': 'Honolulu', 'country': 'United States', 'tz': 'Pacific/Honolulu'},
    {'name': 'Vancouver', 'country': 'Canada', 'tz': 'America/Vancouver'},
    {'name': 'Stockholm', 'country': 'Sweden', 'tz': 'Europe/Stockholm'},
    {'name': 'Vienna', 'country': 'Austria', 'tz': 'Europe/Vienna'},
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _popularCities.where((c) {
      final name = c['name']!.toLowerCase();
      final country = c['country']!.toLowerCase();
      final q = _query.toLowerCase();
      return name.contains(q) || country.contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberGunmetal : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppTheme.cyberBorder : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cyberBorder : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add World City',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            onChanged: (val) => setState(() => _query = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search city or country...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(
                color: isDark ? AppTheme.cyberBorder : const Color(0xFFF1F5F9),
                height: 1,
              ),
              itemBuilder: (context, i) {
                final item = filtered[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cyberYellow.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.location_city_rounded, color: AppTheme.cyberYellow, size: 20),
                  ),
                  title: Text(
                    item['name']!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${item['country']} • ${item['tz']}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentTeal),
                  onTap: () {
                    Navigator.pop(
                      context,
                      WorldCity(name: item['name']!, timezone: item['tz']!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
