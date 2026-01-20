import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/goal_provider.dart';
import '../../models/goal_model.dart';
import '../../utils/validators.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();

  String _selectedType = 'weekly_workouts';
  String _selectedUnit = 'workouts';
  DateTime _startDate = DateTime.now();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  final Map<String, String> _goalTypes = {
    'weekly_workouts': 'Weekly Workouts',
    'total_workouts': 'Total Workouts',
    'duration': 'Total Duration',
    'calories': 'Calories Burned',
    'weight_loss': 'Weight Loss',
    'custom': 'Custom Goal',
  };

  final Map<String, String> _units = {
    'weekly_workouts': 'workouts/week',
    'total_workouts': 'workouts',
    'duration': 'minutes',
    'calories': 'calories',
    'weight_loss': 'kg',
    'custom': 'units',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _updateUnit();
  }

  void _updateUnit() {
    setState(() {
      _selectedUnit = _units[_selectedType]!;
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_targetDate.isBefore(_startDate)) {
          _targetDate = _startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _handleSaveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    final goal = GoalModel(
      userId: authProvider.user!.uid,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      targetValue: double.parse(_targetValueController.text),
      unit: _selectedUnit,
      startDate: _startDate,
      targetDate: _targetDate,
      createdAt: DateTime.now(),
    );

    final success = await goalProvider.addGoal(goal);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            goalProvider.errorMessage ?? 'Failed to add goal',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Goal Type',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _goalTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    _updateUnit();
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Value ($_selectedUnit)',
                  prefixIcon: const Icon(Icons.flag),
                ),
                validator: Validators.validatePositiveNumber,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Start Date'),
                subtitle: Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectStartDate,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Target Date'),
                subtitle: Text(
                  '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectTargetDate,
              ),
              const SizedBox(height: 32),
              Consumer<GoalProvider>(
                builder: (context, goalProvider, child) {
                  return ElevatedButton(
                    onPressed: goalProvider.isLoading ? null : _handleSaveGoal,
                    child: goalProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Save Goal'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
