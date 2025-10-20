import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaGuard Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE3F2FD),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2196F3),
          secondary: const Color(0xFF64B5F6),
          surface: const Color(0xFFBBDEFB),
        ),
        fontFamily: 'Roboto',
      ),
      home: const WaterLeakMonitor(),
    );
  }
}

class WaterLeakMonitor extends StatefulWidget {
  const WaterLeakMonitor({super.key});

  @override
  State<WaterLeakMonitor> createState() => _WaterLeakMonitorState();
}

class _WaterLeakMonitorState extends State<WaterLeakMonitor>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _rotationController;
  Timer? _flowTimer;
  
  double flowRate = 45.8; // L/min
  double totalVolume = 1245.6; // Liters
  int leaksDetected = 0;
  bool isLeaking = false;
  String systemStatus = 'OPTIMAL';

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    // Simulate real-time data updates
    Future.delayed(const Duration(seconds: 2), () {
      _simulateFlowChanges();
    });
  }

  void _simulateFlowChanges() {
    _flowTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          flowRate = 40 + math.Random().nextDouble() * 15;
          totalVolume += flowRate / 30;
        });
      }
    });
  }

  void _toggleLeakSimulation() {
    setState(() {
      isLeaking = !isLeaking;
      if (isLeaking) {
        leaksDetected++;
        systemStatus = 'LEAK DETECTED';
        flowRate = 75.5;
      } else {
        systemStatus = 'OPTIMAL';
        flowRate = 45.8;
      }
    });
  }

  @override
  void dispose() {
    _flowTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE3F2FD),
              const Color(0xFFBBDEFB),
              const Color(0xFF90CAF9),
              isLeaking ? const Color(0xFFFFCDD2) : const Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildMainMonitor(),
                        const SizedBox(height: 24),
                        _buildSensorStatus(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2196F3),
                  const Color(0xFF64B5F6),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AQUAGUARD',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Flow Monitoring System',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2196F3),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isLeaking ? Colors.red : Colors.green)
                      .withOpacity(0.2 + _pulseController.value * 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLeaking ? Colors.red : Colors.green,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isLeaking ? Colors.red : Colors.green)
                          .withOpacity(_pulseController.value * 0.5),
                      blurRadius: 10 + _pulseController.value * 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(
                    color: isLeaking ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainMonitor() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'SYSTEM STATUS',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF2196F3),
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Text(
                systemStatus,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isLeaking ? Colors.red : Colors.green,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: (isLeaking ? Colors.red : Colors.green)
                          .withOpacity(_pulseController.value),
                      blurRadius: 20,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              // Rotating background circles
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF64B5F6).withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Central flow indicator
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      isLeaking
                          ? Colors.red.withOpacity(0.3)
                          : const Color(0xFF2196F3).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1 + _waveController.value * 0.1,
                            child: Icon(
                              Icons.water_drop,
                              size: 50,
                              color: isLeaking
                                  ? Colors.red
                                  : const Color(0xFF2196F3),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${flowRate.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const Text(
                        'L/min',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2196F3),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorStatus() {
    final sensors = [
      {'name': 'Flow Sensor', 'status': isLeaking ? 'Warning' : 'Active', 'value': '${flowRate.toStringAsFixed(1)} L/min'},
      {'name': 'IR Sensor', 'status': isLeaking ? 'Warning' : 'Active', 'value': isLeaking ? 'Detected' : 'Not Detected'},
      {'name': 'Solenoid Valve', 'status': isLeaking ? 'Warning' : 'Active', 'value': isLeaking ? 'Opened' : 'Closed'},
      {'name': 'Leakage', 'status': isLeaking ? 'Warning' : 'Active', 'value': isLeaking ? 'Yes' : 'No'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sensors,
                color: const Color(0xFF2196F3),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'SENSOR STATUS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sensors.map((sensor) => _buildSensorRow(
                sensor['name']!,
                sensor['status']!,
                sensor['value']!,
              )),
        ],
      ),
    );
  }

  Widget _buildSensorRow(String name, String status, String value) {
    final isWarning = status == 'Warning';
    final color = isWarning ? Colors.orange : Colors.green;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(_pulseController.value),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF1565C0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
