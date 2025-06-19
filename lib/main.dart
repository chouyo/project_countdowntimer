import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';
import '../countdown_timer.dart'; // 确保路径正确

class CountdownData {
  final int totalTime;
  final String name;

  CountdownData({required this.totalTime, required this.name});

  Map<String, dynamic> toJson() => {
        'totalTime': totalTime,
        'name': name,
      };

  factory CountdownData.fromJson(Map<String, dynamic> json) {
    return CountdownData(
      totalTime: json['totalTime'],
      name: json['name'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '倒计时应用',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CountdownHomePage(),
    );
  }
}

class CountdownHomePage extends StatefulWidget {
  const CountdownHomePage({super.key});

  @override
  _CountdownHomePageState createState() => _CountdownHomePageState();
}

class _CountdownHomePageState extends State<CountdownHomePage> {
  late List<CountdownTimer> countdownTimers;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
    _loadTimers();
    _initializeNotifications();

    // 创建3个倒计时实例
    countdownTimers = [
      CountdownTimer(
        totalTime: 10 * 1000, // 10 秒
        onTick: (remainingTime) {
          setState(() {}); // 触发 rebuild
        },
        onFinished: () {
          print('Countdown 1 finished!');
          setState(() {}); // 触发 rebuild
        },
      ),
      CountdownTimer(
        totalTime: 15 * 1000, // 15 秒
        onTick: (remainingTime) {
          setState(() {}); // 触发 rebuild
        },
        onFinished: () {
          print('Countdown 2 finished!');
          setState(() {}); // 触发 rebuild
        },
      ),
      CountdownTimer(
        totalTime: 20 * 1000, // 20 秒
        onTick: (remainingTime) {
          setState(() {}); // 触发 rebuild
        },
        onFinished: () {
          print('Countdown 3 finished!');
          setState(() {}); // 触发 rebuild
        },
      ),
    ];

    // 启动所有倒计时
    for (var timer in countdownTimers) {
      timer.start();
    }
  }

  Future<void> _requestNotificationPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _initializeNotifications() async {
    initializeTimeZones();

    setLocalLocation(getLocation('Asia/Shanghai'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // 替换为你的应用图标

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String id) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'countdown_channel', 'Countdown Notifications',
            channelDescription: 'Notifications for countdown timers',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: const DarwinNotificationDetails());

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      '$title 倒计时结束',
      '倒计时已完成!',
      notificationDetails,
    );
  }

  Future<void> _loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final timersJson = prefs.getStringList('timers');
    if (timersJson != null) {
      setState(() {
        countdownTimers = timersJson
            .map((json) => CountdownData.fromJson(jsonDecode(json)))
            .map((data) => CountdownTimer(
                  totalTime: data.totalTime,
                  onTick: (remainingTime) {
                    setState(() {});
                  },
                  onFinished: () {
                    print('${data.name} finished!');
                    _showNotification(data.name, data.hashCode.toString());
                    setState(() {});
                  },
                ))
            .toList();
        for (var timer in countdownTimers) {
          timer.start();
        }
      });
    } else {
      // 初始示例
      countdownTimers = [
        CountdownTimer(
          totalTime: 10 * 1000, // 10 秒
          onTick: (remainingTime) {
            setState(() {}); // 触发 rebuild
          },
          onFinished: () {
            print('Countdown 1 finished!');
            _showNotification('Countdown 1', '0');
            setState(() {}); // 触发 rebuild
          },
        ),
        CountdownTimer(
          totalTime: 15 * 1000, // 15 秒
          onTick: (remainingTime) {
            setState(() {}); // 触发 rebuild
          },
          onFinished: () {
            print('Countdown 2 finished!');
            _showNotification('Countdown 2', '1');
            setState(() {}); // 触发 rebuild
          },
        ),
        CountdownTimer(
          totalTime: 20 * 1000, // 20 秒
          onTick: (remainingTime) {
            setState(() {}); // 触发 rebuild
          },
          onFinished: () {
            print('Countdown 3 finished!');
            _showNotification('Countdown 3', '2');
            setState(() {}); // 触发 rebuild
          },
        ),
      ];
      for (var timer in countdownTimers) {
        timer.start();
      }
      _saveTimers();
    }
  }

  Future<void> _saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final timersJson = countdownTimers
        .map((timer) => CountdownData(
            name: 'Countdown ${countdownTimers.indexOf(timer) + 1}',
            totalTime: timer.totalTime))
        .map((data) => jsonEncode(data.toJson()))
        .toList();
    await prefs.setStringList('timers', timersJson);
  }

  @override
  void dispose() {
    // 停止所有倒计时
    for (var timer in countdownTimers) {
      timer.dispose();
    }
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hoursStr:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

// ...existing code...
  Future<void> _addNewCountdown(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('创建新的倒计时'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: '倒计时名称'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(selectedDate == null
                          ? '选择日期'
                          : '已选择: ${selectedDate!.toLocal()}'),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(selectedTime == null
                          ? '选择时间'
                          : '已选择: ${selectedTime!.format(context)}'),
                      IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('创建'),
              onPressed: () {
                if (selectedDate != null && selectedTime != null) {
                  DateTime targetDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  int totalTime =
                      targetDateTime.difference(DateTime.now()).inMilliseconds;
                  if (totalTime <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('请选择未来的时间')),
                    );
                    return;
                  }

                  setState(() {
                    countdownTimers.add(
                      CountdownTimer(
                        totalTime: totalTime,
                        onTick: (remainingTime) {
                          setState(() {});
                        },
                        onFinished: () {
                          print('${nameController.text} finished!');
                          _showNotification(nameController.text,
                              nameController.hashCode.toString()); // 显示通知
                          setState(() {});
                        },
                      ),
                    );
                    countdownTimers.last.start();
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('请选择日期和时间')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
// ...existing code...

// ...existing code...
  Future<void> _editCountdown(BuildContext context, int index) async {
    TextEditingController nameController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // 初始化编辑数据
    nameController.text = '倒计时 ${index + 1}'; // 默认名称
    int initialTotalTime = countdownTimers[index].totalTime;
    DateTime initialDateTime =
        DateTime.now().add(Duration(milliseconds: initialTotalTime));
    selectedDate = initialDateTime.toLocal();
    selectedTime = TimeOfDay.fromDateTime(initialDateTime.toLocal());

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('编辑倒计时'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: '倒计时名称'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(selectedDate == null
                          ? '选择日期'
                          : '已选择: ${selectedDate!.toLocal()}'),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(selectedTime == null
                          ? '选择时间'
                          : '已选择: ${selectedTime!.format(context)}'),
                      IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('保存'),
              onPressed: () {
                if (selectedDate != null && selectedTime != null) {
                  DateTime targetDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  int totalTime =
                      targetDateTime.difference(DateTime.now()).inMilliseconds;
                  if (totalTime <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('请选择未来的时间')),
                    );
                    return;
                  }

                  setState(() {
                    countdownTimers[index].dispose(); // Dispose old timer

                    countdownTimers[index] = CountdownTimer(
                      totalTime: totalTime,
                      onTick: (remainingTime) {
                        setState(() {});
                      },
                      onFinished: () {
                        print('${nameController.text} finished!');
                        _showNotification(nameController.text,
                            nameController.hashCode.toString()); // 显示通知
                        setState(() {});
                      },
                    );
                    countdownTimers[index].start();
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('请选择日期和时间')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
// ...existing code...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('倒计时'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _addNewCountdown(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: countdownTimers.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '倒计时 ${index + 1}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editCountdown(context, index);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    countdownTimers[index].isRunning
                        ? _formatTime(countdownTimers[index].remainingTime)
                        : '已结束',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            countdownTimers[index].start();
                          });
                        },
                        child: Text('开始'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            countdownTimers[index].pause();
                          });
                        },
                        child: Text('暂停'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            countdownTimers[index].reset();
                          });
                        },
                        child: Text('重置'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            countdownTimers[index].restart();
                          });
                        },
                        child: Text('重新开始'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
