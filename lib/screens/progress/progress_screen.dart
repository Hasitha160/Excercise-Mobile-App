import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/workout_provider.dart';
import '../../providers/goal_provider.dart';
import '../../utils/date_helper.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Theme.of(context).colorScheme.primary,
              underline: Container(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticsCards(),
            const SizedBox(height: 24),
            _buildWorkoutChart(),
            const SizedBox(height: 24),
            _buildCaloriesChart(),
            const SizedBox(height: 24),
            _buildGoalsProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final now = DateTime.now();
        DateTime startDate;

        switch (_selectedPeriod) {
          case 'Week':
            startDate = DateHelper.getStartOfWeek(now);
            break;
          case 'Month':
            startDate = DateTime(now.year, now.month, 1);
            break;
          case 'Year':
            startDate = DateTime(now.year, 1, 1);
            break;
          default:
            startDate = DateHelper.getStartOfWeek(now);
        }

        final workouts = workoutProvider.workouts.where((workout) {
          return workout.date.isAfter(startDate) &&
              workout.date.isBefore(now.add(const Duration(days: 1)));
        }).toList();

        final totalWorkouts = workouts.length;
        final totalDuration = workouts.fold<int>(
          0,
          (sum, workout) => sum + workout.durationMinutes,
        );
        final totalCalories = workouts.fold<double>(
          0,
          (sum, workout) => sum + workout.caloriesBurned,
        );

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Workouts',
                totalWorkouts.toString(),
                Icons.fitness_center,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Duration',
                '$totalDuration min',
                Icons.timer,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Calories',
                '${totalCalories.toInt()}',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutChart() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final now = DateTime.now();
        final data = _getChartData(workoutProvider, now);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout Frequency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (data.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2)
                          .toDouble(),
                      barGroups: data
                          .asMap()
                          .entries
                          .map(
                            (entry) => BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.y,
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < data.length) {
                                return Text(
                                  data[value.toInt()].label,
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCaloriesChart() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final now = DateTime.now();
        final data = _getCaloriesData(workoutProvider, now);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calories Burned',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < data.length) {
                                return Text(
                                  data[value.toInt()].label,
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.y))
                              .toList(),
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalsProgress() {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        final activeGoals = goalProvider.activeGoals;

        if (activeGoals.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...activeGoals.take(3).map((goal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                goal.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${goal.progressPercentage.toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: goal.progressPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ChartData> _getChartData(WorkoutProvider provider, DateTime now) {
    switch (_selectedPeriod) {
      case 'Week':
        return _getWeeklyData(provider, now);
      case 'Month':
        return _getMonthlyData(provider, now);
      case 'Year':
        return _getYearlyData(provider, now);
      default:
        return [];
    }
  }

  List<ChartData> _getCaloriesData(WorkoutProvider provider, DateTime now) {
    switch (_selectedPeriod) {
      case 'Week':
        return _getWeeklyCalories(provider, now);
      case 'Month':
        return _getMonthlyCalories(provider, now);
      case 'Year':
        return _getYearlyCalories(provider, now);
      default:
        return [];
    }
  }

  List<ChartData> _getWeeklyData(WorkoutProvider provider, DateTime now) {
    final startOfWeek = DateHelper.getStartOfWeek(now);
    final data = <ChartData>[];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final count = provider.workouts
          .where((w) => DateHelper.isSameDay(w.date, date))
          .length;
      data.add(ChartData(DateHelper.getWeekday(date).substring(0, 3), count.toDouble()));
    }

    return data;
  }

  List<ChartData> _getMonthlyData(WorkoutProvider provider, DateTime now) {
    final data = <ChartData>[];
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final interval = (daysInMonth / 7).ceil();

    for (int i = 0; i < 7; i++) {
      final startDay = i * interval + 1;
      final endDay = ((i + 1) * interval).clamp(1, daysInMonth);
      
      int count = 0;
      for (int day = startDay; day <= endDay; day++) {
        final date = DateTime(now.year, now.month, day);
        count += provider.workouts
            .where((w) => DateHelper.isSameDay(w.date, date))
            .length;
      }
      
      data.add(ChartData('$startDay-$endDay', count.toDouble()));
    }

    return data;
  }

  List<ChartData> _getYearlyData(WorkoutProvider provider, DateTime now) {
    final data = <ChartData>[];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (int i = 0; i < 12; i++) {
      final count = provider.workouts
          .where((w) => w.date.year == now.year && w.date.month == i + 1)
          .length;
      data.add(ChartData(months[i], count.toDouble()));
    }

    return data;
  }

  List<ChartData> _getWeeklyCalories(WorkoutProvider provider, DateTime now) {
    final startOfWeek = DateHelper.getStartOfWeek(now);
    final data = <ChartData>[];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final calories = provider.workouts
          .where((w) => DateHelper.isSameDay(w.date, date))
          .fold<double>(0, (sum, w) => sum + w.caloriesBurned);
      data.add(ChartData(DateHelper.getWeekday(date).substring(0, 3), calories));
    }

    return data;
  }

  List<ChartData> _getMonthlyCalories(WorkoutProvider provider, DateTime now) {
    final data = <ChartData>[];
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final interval = (daysInMonth / 7).ceil();

    for (int i = 0; i < 7; i++) {
      final startDay = i * interval + 1;
      final endDay = ((i + 1) * interval).clamp(1, daysInMonth);
      
      double calories = 0;
      for (int day = startDay; day <= endDay; day++) {
        final date = DateTime(now.year, now.month, day);
        calories += provider.workouts
            .where((w) => DateHelper.isSameDay(w.date, date))
            .fold<double>(0, (sum, w) => sum + w.caloriesBurned);
      }
      
      data.add(ChartData('$startDay-$endDay', calories));
    }

    return data;
  }

  List<ChartData> _getYearlyCalories(WorkoutProvider provider, DateTime now) {
    final data = <ChartData>[];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (int i = 0; i < 12; i++) {
      final calories = provider.workouts
          .where((w) => w.date.year == now.year && w.date.month == i + 1)
          .fold<double>(0, (sum, w) => sum + w.caloriesBurned);
      data.add(ChartData(months[i], calories));
    }

    return data;
  }
}

class ChartData {
  final String label;
  final double y;

  ChartData(this.label, this.y);
}
