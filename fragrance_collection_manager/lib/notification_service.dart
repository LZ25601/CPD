import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';
import '../database/database_helper.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fragrance_reminders',
      'Fragrance Reminders',
      description: 'Daily reminders to wear your fragrances',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleDailyNotification() async {
    // Schedule for 6:00 AM daily
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 6, 0);
    
    // If 6 AM has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Get a random fragrance from database
    final fragrances = await DatabaseHelper.instance.readAllFragrances();
    String notificationBody = 'Open the app to see your collection!';
    
    if (fragrances.isNotEmpty) {
      final random = Random();
      final randomFragrance = fragrances[random.nextInt(fragrances.length)];
      notificationBody = 'How about ${randomFragrance.name} by ${randomFragrance.brand} today?';
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Fragrance of the Day',
      notificationBody,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fragrance_reminders',
          'Fragrance Reminders',
          channelDescription: 'Daily reminders to wear your fragrances',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showRandomFragranceNotification() async {
    final fragrances = await DatabaseHelper.instance.readAllFragrances();
    String notificationBody = 'Open the app to see your collection!';
    
    if (fragrances.isNotEmpty) {
      final random = Random();
      final randomFragrance = fragrances[random.nextInt(fragrances.length)];
      notificationBody = 'Random fragrance: ${randomFragrance.name} by ${randomFragrance.brand}';
    }

    await flutterLocalNotificationsPlugin.show(
      1, // Different ID from the scheduled one
      'Fragrance Suggestion',
      notificationBody,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fragrance_reminders',
          'Fragrance Reminders',
          channelDescription: 'Daily reminders to wear your fragrances',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}