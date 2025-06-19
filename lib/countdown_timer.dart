import 'dart:async';
import 'package:flutter/material.dart';

/// 倒计时类
class CountdownTimer {
  // 剩余时间（毫秒）
  int _remainingTime;
  // 总时间（毫秒）
  final int totalTime;
  // 计时器
  Timer? _timer;
  // 倒计时结束回调
  final VoidCallback? onFinished;
  // 倒计时变化回调（剩余毫秒数）
  late final ValueChanged<int>? onTick;
  // 是否正在运行
  bool _isRunning = false;

  /// 构造函数
  /// [totalTime] 总时间（毫秒）
  /// [onFinished] 倒计时结束回调
  /// [onTick] 倒计时变化回调（每秒钟回调一次，传递剩余毫秒数）
  CountdownTimer({
    required this.totalTime,
    this.onFinished,
    this.onTick,
  }) : _remainingTime = totalTime;

  /// 获取剩余时间（毫秒）
  int get remainingTime => _remainingTime;

  /// 是否正在运行
  bool get isRunning => _isRunning;

  /// 开始倒计时
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _remainingTime -= 100;

      // 通知时间变化
      onTick?.call(_remainingTime);

      // 检查是否结束
      if (_remainingTime <= 0) {
        _remainingTime = 0;
        _timer?.cancel();
        _isRunning = false;
        onFinished?.call();
      }
    });
  }

  /// 暂停倒计时
  void pause() {
    _timer?.cancel();
    _isRunning = false;
  }

  /// 重置倒计时
  void reset() {
    pause();
    _remainingTime = totalTime;
    onTick?.call(_remainingTime);
  }

  /// 重新开始倒计时
  void restart() {
    reset();
    start();
  }

  /// 销毁倒计时（释放资源）
  void dispose() {
    _timer?.cancel();
    _isRunning = false;
  }
}
