import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:agpop/models/task_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Implementar navegação para a tela de detalhes da tarefa
      },
    );
  }
  
  Future<void> showTaskNotification(TaskModel task) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Tarefas',
      channelDescription: 'Notificações de tarefas',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      task.id.hashCode,
      'Tarefa: ${task.title}',
      task.description,
      notificationDetails,
    );
  }
  
  Future<void> scheduleTaskNotification(TaskModel task) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminder_channel',
      'Lembretes de Tarefas',
      channelDescription: 'Lembretes para tarefas agendadas',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Agendar notificação para 1 hora antes do prazo
    // final scheduledTime = tz.TZDateTime.from(
    //   tz.local,
    // );

    // await _notificationsPlugin.zonedSchedule(
    //   task.id.hashCode,
    //   'Lembrete: ${task.title}',
    //   'Esta tarefa vence em 1 hora'
    //   // scheduledTime,
    //   // notificationDetails,
    //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    // );
  }
  
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
  
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
