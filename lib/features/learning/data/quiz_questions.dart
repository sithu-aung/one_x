class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

final List<QuizQuestion> questions = [
  QuizQuestion(
    question: 'Which sentence is correct?',
    options: [
      'She go to school every day.',
      'She goes to school every day.',
      'She going to school every day.',
      'She gone to school every day.',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'Choose the correct form: "I ____ a book now."',
    options: ['reads', 'am reading', 'read', 'reading'],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'Which is the past tense of "go"?',
    options: ['goed', 'goes', 'went', 'gone'],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Select the correct sentence.',
    options: [
      'He don\'t like apples.',
      'He doesn\'t likes apples.',
      'He doesn\'t like apples.',
      'He don\'t likes apples.',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Fill in the blank: "They ____ playing football."',
    options: ['is', 'are', 'am', 'be'],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'Which is correct?',
    options: [
      'She have a car.',
      'She has a car.',
      'She haves a car.',
      'She having a car.',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    question: 'Choose the correct word: "There ____ some milk in the fridge."',
    options: ['is', 'are', 'am', 'be'],
    correctIndex: 0,
  ),
  QuizQuestion(
    question: 'Which is the plural form of "child"?',
    options: ['childs', 'childes', 'children', 'childrens'],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Select the correct sentence.',
    options: [
      'I can to swim.',
      'I can swimming.',
      'I can swim.',
      'I can swam.',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    question: 'Fill in the blank: "He ____ TV every night."',
    options: ['watch', 'watches', 'watching', 'watched'],
    correctIndex: 1,
  ),
];
