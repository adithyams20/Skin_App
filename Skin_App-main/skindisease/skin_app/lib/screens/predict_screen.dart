// lib/screens/predict_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skin_app/l10n/app_localizations.dart';

import '../colors.dart';
import '../services/api_service.dart';
import '../session.dart';
import 'result_screen.dart';

class PredictScreen extends StatefulWidget {
  final File image;

  const PredictScreen({super.key, required this.image});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen>
    with SingleTickerProviderStateMixin {

  double progress = 0.0;
  bool _apiDone = false;
  bool _predictionStarted = false; // guard so API is called only once
  late AnimationController _controller;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startProgress();
    // ✅ DO NOT call AppLocalizations.of(context) in initState — it crashes.
    // Prediction is started from didChangeDependencies instead.
  }

  // ✅ didChangeDependencies is called after initState and is safe for
  // context-dependent calls like AppLocalizations.of(context).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_predictionStarted) {
      _predictionStarted = true;
      _runPrediction();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_apiDone) {
          progress = (progress + 0.1).clamp(0.0, 1.0);
          if (progress >= 1.0) timer.cancel();
        } else if (progress < 0.85) {
          progress += 0.05;
        } else if (progress < 0.97) {
          // slow crawl while waiting for server — no more stuck at 90%
          progress += 0.005;
        }
      });
    });
  }

  Future<void> _runPrediction() async {
    final l10n = AppLocalizations.of(context)!; // ✅ safe here

    try {
      final res = await ApiService.predictImage(
        widget.image,
        UserSession.username,
      );

      _apiDone = true;
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            data: {
              ...res,
              'image': widget.image.path,
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.predictionFailed)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.aquaGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: const Icon(Icons.health_and_safety,
                    size: 80, color: Colors.white),
              ),

              const SizedBox(height: 25),

              Text(
                l10n.analyzingSkin,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white24,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 30),

              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(widget.image,
                    height: 120, width: 120, fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }
}