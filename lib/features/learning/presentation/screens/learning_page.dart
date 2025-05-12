import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/quiz_questions.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  int _currentQuestion = 0;
  int _score = 0;
  List<int?> _answers = List.filled(10, null);
  bool _showResult = false;
  bool _answered = false;
  int? _selectedIndex;

  void _answer(int selected) {
    if (_answered) return;
    setState(() {
      _selectedIndex = selected;
      _answers[_currentQuestion] = selected;
      _answered = true;
      if (selected == questions[_currentQuestion].correctIndex) {
        _score++;
      }
    });
    // Wait 1.2s then go to next or result
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        if (_currentQuestion == questions.length - 1) {
          _showResult = true;
        } else {
          _currentQuestion++;
          _answered = false;
          _selectedIndex = null;
        }
      });
    });
  }

  void _restart() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _showResult = false;
      _answers = List.filled(10, null);
      _answered = false;
      _selectedIndex = null;
    });
  }

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: Consumer(
        builder: (context, ref, _) {
          final theme = Theme.of(context);
          if (_showResult) {
            final isPerfect = _score == 10;
            return Scaffold(
              backgroundColor: const Color(0xFFF6F8FB),
              body: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPerfect
                            ? Icons.emoji_events
                            : Icons.check_circle_rounded,
                        color: isPerfect ? Colors.amber[700] : Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isPerfect ? 'Perfect Score!' : 'Quiz Complete',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your score:',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_score / 10',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color:
                              isPerfect ? Colors.amber[800] : Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _restart,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _logout(context, ref),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final q = questions[_currentQuestion];
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FB),
            appBar: AppBar(
              title: const Text('1xKing Quiz'),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  tooltip: 'Logout',
                  onPressed: () => _logout(context, ref),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestion + 1} of 10',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_score',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    q.question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(q.options.length, (i) {
                    final isSelected = _selectedIndex == i;
                    final isCorrect = q.correctIndex == i;
                    final isAnswered = _answered;
                    Color btnColor = Colors.white;
                    Color txtColor = Colors.black87;
                    IconData? icon;
                    BorderSide border = BorderSide(color: Colors.grey[300]!);
                    if (isAnswered) {
                      if (isSelected && isCorrect) {
                        border = const BorderSide(
                          color: Colors.green,
                          width: 2,
                        );
                        icon = Icons.check_circle_rounded;
                      } else if (isSelected && !isCorrect) {
                        border = const BorderSide(color: Colors.red, width: 2);
                        icon = Icons.cancel_rounded;
                      } else if (isCorrect) {
                        border = const BorderSide(
                          color: Colors.green,
                          width: 2,
                          style: BorderStyle.solid,
                        );
                        icon = Icons.check_circle_outline_rounded;
                      } else {
                        border = BorderSide(color: Colors.grey[300]!);
                      }
                    } else {
                      border =
                          isSelected
                              ? const BorderSide(color: Colors.indigo, width: 2)
                              : BorderSide(color: Colors.grey[300]!);
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: ElevatedButton(
                          onPressed: isAnswered ? null : () => _answer(i),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: btnColor,
                            foregroundColor: txtColor,
                            minimumSize: const Size.fromHeight(54),
                            elevation: isSelected ? 4 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: border,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (icon != null) ...[
                                Icon(icon, color: border.color),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Text(
                                  q.options[i],
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: txtColor,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  if (_answered)
                    Center(
                      child: Text(
                        _selectedIndex == q.correctIndex
                            ? 'Correct!'
                            : 'Incorrect. The correct answer is: "${q.options[q.correctIndex]}"',
                        style: TextStyle(
                          color:
                              _selectedIndex == q.correctIndex
                                  ? Colors.green[700]
                                  : Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
