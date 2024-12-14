import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chosimpo_app/painters/diagonal_painter.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int minutes;
  late int concentrationTime = minutes;
  bool isRunning = false;
  int totalPomodoros = 0;
  late Timer timer;
  bool isTimerInitialized = false;
  bool basic = true;
  bool isRest = false;
  late int restTime;
  bool isSound = false;
  bool isVibrate = true;

  final audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    minutes = 1500;
  }

  void resetPomodoro(int seconds, bool basic) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.track_changes_rounded, size: 50),
          iconColor: Colors.amber,
          title: Text(
            "시간을 변경하시겠습니까?",
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: Colors.black),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "아니요",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isRunning = false;
                  minutes = seconds;
                  concentrationTime = minutes;
                  basic = basic;
                });
                if (isTimerInitialized) {
                  timer.cancel();
                }
                Navigator.of(context).pop();
              },
              child: Text(
                "네",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          ],
        );
      },
    );
  }

  void onStartPressed() {
    setState(() {
      isRunning = true;
      isTimerInitialized = true;
    });
    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );
  }

  void onTick(Timer timer) {
    if (concentrationTime == 0) {
      timer.cancel();
      setState(() {
        isRest = true;
        restTime = basic ? 300 : 600;
      });
      restTimeStart();
    } else {
      setState(() {
        concentrationTime -= 1;
      });
    }
  }

  bool _isVibrating = false;

  void vibrateContinuously() {
    const duration = 500;
    const repeatInterval = 2500;

    if (_isVibrating) return;
    _isVibrating = true;

    Future.doWhile(() async {
      if (!_isVibrating) return false;
      Vibration.vibrate(duration: duration);
      await Future.delayed(
        const Duration(milliseconds: repeatInterval),
      );
      return true;
    });
  }

  void stopVibrating() {
    _isVibrating = false;
    Vibration.cancel();
  }

  void endRest() async {
    if (isSound) {
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.play(AssetSource("sounds/click.mp3"));
    } else if (isVibrate) {
      vibrateContinuously();
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "휴식이 끝났습니다",
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: Colors.black),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () async {
                if (isSound) {
                  await audioPlayer.setReleaseMode(ReleaseMode.stop);
                } else if (isVibrate) {
                  stopVibrating();
                }
                Navigator.of(context).pop();
              },
              child: Text(
                "확인",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  void restTimeStart() async {
    if (isSound) {
      await audioPlayer.play(AssetSource("sounds/click.mp3"));
    } else if (isVibrate) {
      Vibration.vibrate(duration: 500);
    }
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (restTime > 0) {
          setState(() {
            restTime -= 1;
          });
        } else {
          timer.cancel();
          setState(() {
            isRest = false;
            totalPomodoros += 1;
            minutes = basic ? 1500 : 3000;
            concentrationTime = minutes;
            isRunning = false;
          });
          endRest();
        }
      },
    );
  }

  void onPausePressed() {
    setState(() {
      isRunning = false;
    });
    timer.cancel();
  }

  void onRefreshPressed() {
    if (concentrationTime != 1500 | 3000) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.warning_amber_rounded, size: 50),
            iconColor: Colors.amber,
            title: Text(
              "'초기화' 하시겠습니까?",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(color: Colors.black),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "아니요",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isRunning = false;
                    concentrationTime = minutes;
                  });
                  timer.cancel();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "네",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            ],
          );
        },
      );
    }
  }

  String formatSeconds(int seconds) {
    var duration = Duration(seconds: seconds);
    var result = duration.toString().split(".").first.substring(2);
    return result;
  }

  void soundAlarm() async {
    setState(() {
      isSound = true;
      isVibrate = false;
    });
    await audioPlayer.play(AssetSource("sounds/click.mp3"));
  }

  void vibrateAlarm() {
    setState(() {
      isSound = false;
      isVibrate = true;
    });
    Vibration.vibrate(duration: 500);
  }

  void noAlarm() {
    setState(() {
      isSound = false;
      isVibrate = false;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        !isRest ? Theme.of(context).scaffoldBackgroundColor : Colors.green;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: surfaceColor,
        body: Stack(
          children: [
            CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter:
                  DiagonalPainter(surfaceColor: surfaceColor, isRest: isRest),
            ),
            Positioned(
              top: 50,
              right: 25,
              child: Text(
                "History",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "ToDay",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              "$totalPomodoros",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            !isRest
                                ? IconButton(
                                    iconSize: 50,
                                    color: (concentrationTime != 1500 &&
                                            concentrationTime != 3000)
                                        ? Theme.of(context).cardColor
                                        : Color.lerp(Colors.transparent,
                                            Colors.grey, 0.3),
                                    onPressed: (concentrationTime != 1500 &&
                                            concentrationTime != 3000)
                                        ? onRefreshPressed
                                        : null,
                                    icon: const Icon(Icons.refresh_outlined),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        !isRest
                            ? formatSeconds(concentrationTime)
                            : formatSeconds(restTime),
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 90,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      !isRest
                          ? IconButton(
                              iconSize: 110,
                              color: Theme.of(context).cardColor,
                              onPressed:
                                  isRunning ? onPausePressed : onStartPressed,
                              icon: Icon(
                                isRunning
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                              ),
                            )
                          : IconButton(
                              iconSize: 110,
                              color: Theme.of(context).cardColor,
                              onPressed: () {},
                              icon: const Icon(Icons.local_cafe),
                            )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xfff5f5dc),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => !isRest
                              ? resetPomodoro(1500, basic = true)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: !isRest
                                  ? Colors.lightGreen
                                  : Colors.grey.shade400,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              "25/5",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontSize: 18,
                                      color: !isRest
                                          ? Colors.black
                                          : Colors.grey.shade300),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => !isRest
                              ? resetPomodoro(3000, basic = false)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: !isRest
                                  ? Colors.lightGreen
                                  : Colors.grey.shade400,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              "50/10",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: 18,
                                    color: !isRest
                                        ? Colors.black
                                        : Colors.grey.shade300,
                                  ),
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: soundAlarm,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.volume_up_rounded,
                                        ),
                                        isSound
                                            ? Container(
                                                width: 30,
                                                height: 5,
                                                decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(20),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(
                                                width: 30,
                                                height: 5,
                                              ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: vibrateAlarm,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.vibration_rounded,
                                        ),
                                        isVibrate
                                            ? Container(
                                                width: 30,
                                                height: 5,
                                                decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(20),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(
                                                height: 5,
                                                width: 30,
                                              ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: noAlarm,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.alarm_off_rounded,
                                        ),
                                        !isSound & !isVibrate
                                            ? Container(
                                                width: 30,
                                                height: 5,
                                                decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(20),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(
                                                height: 5,
                                                width: 30,
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
