import 'package:flutter/material.dart';
import '../countdown_timer.dart'; // 确保路径正确

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  @override
  _CountdownHomePageState createState() => _CountdownHomePageState();
}

class _CountdownHomePageState extends State<CountdownHomePage> {
  late List<CountdownTimer> countdownTimers;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('倒计时'),
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
                  Text(
                    '倒计时 ${index + 1}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
