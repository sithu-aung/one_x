import 'package:flutter/material.dart';
import 'package:one_x/core/theme/app_theme.dart';

class QuickSelectScreen extends StatefulWidget {
  final List<String>? previouslySelectedNumbers;

  const QuickSelectScreen({super.key, this.previouslySelectedNumbers});

  @override
  State<QuickSelectScreen> createState() => _QuickSelectScreenState();
}

class _QuickSelectScreenState extends State<QuickSelectScreen> {
  // Selection type: regular or reversed
  bool _isRegular = true;
  bool _hasTwin = false; // Added for အပူးပါ (twin) option
  String _enteredNumber = '';
  List<String> _selectedNumbers = [];

  // Instead of single selections, use sets to track multiple selections
  Set<String> _selectedFormulas = {};
  Set<String> _selectedLoopNumbers = {};
  Set<String> _selectedTailNumbers = {};
  Set<String> _selectedBreakNumbers = {};

  // Map to track which numbers came from which selection
  Map<String, Set<String>> _selectionToNumbers = {};

  // Controller for the text field
  final TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize with previously selected numbers if provided
    if (widget.previouslySelectedNumbers != null &&
        widget.previouslySelectedNumbers!.isNotEmpty) {
      _selectedNumbers = List.from(widget.previouslySelectedNumbers!);

      // Try to determine which options were previously selected
      _detectPreviousSelections();
    } else {
      // Default initialization with empty selection
      _selectedFormulas = {};
      _selectedLoopNumbers = {};
      _selectedTailNumbers = {};
      _selectedBreakNumbers = {};
      _selectedNumbers = [];
      _selectionToNumbers = {};
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Row(
          children: [
            Text(
              'အမြန် ရွေးရန်',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pyidaungsu',
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Radio buttons for selection type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ခွေပူး',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pyidaungsu',
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _hasTwin,
                              onChanged: (value) {
                                setState(() {
                                  _hasTwin = value ?? false;
                                });
                              },
                              activeColor: AppTheme.primaryColor,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _hasTwin = !_hasTwin;
                                });
                              },
                              child: Text(
                                'အပူးပါ',
                                style: TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 14,
                                  fontFamily: 'Pyidaungsu',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Number input field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'ဂဏန်းရိုက်ထည့်ပါ(eg. 1-12345)',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                                fontFamily: 'Pyidaungsu',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 4, 4),
                            child: TextField(
                              controller: _numberController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '43569',
                                hintStyle: TextStyle(
                                  color: AppTheme.textSecondaryColor
                                      .withOpacity(0.5),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _enteredNumber = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Single and Double Size section
                    Text(
                      'Single and Double Size',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // First row of size buttons
                    Row(
                      children: [
                        _buildSizeButton('ညီနောင် 20'),
                        const SizedBox(width: 6),
                        _buildSizeButton('အပူး 10'),
                        const SizedBox(width: 6),
                        _buildSizeButton('စုံပူး 5'),
                        const SizedBox(width: 6),
                        _buildSizeButton('မ,ပူး 5'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Second row of size buttons
                    Row(
                      children: [
                        _buildSizeButton('မ,စုံ 25'),
                        const SizedBox(width: 6),
                        _buildSizeButton('စုံမ 25'),
                        const SizedBox(width: 6),
                        _buildSizeButton('မ,မ 25'),
                        const SizedBox(width: 6),
                        _buildSizeButton('စုံစုံ 25'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Third row of size buttons
                    Row(
                      children: [
                        _buildSizeButton('မထိပ် 50'),
                        const SizedBox(width: 6),
                        _buildSizeButton('မပိတ် 50'),
                        const SizedBox(width: 6),
                        _buildSizeButton('စုံထိပ် 50'),
                        const SizedBox(width: 6),
                        _buildSizeButton('စုံပိတ် 50'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Fourth row of size buttons
                    Row(
                      children: [
                        _buildSizeButton('နက္ခတ်'),
                        const SizedBox(width: 6),
                        _buildSizeButton('ပါဝါ'),
                        const Spacer(flex: 2),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ပတ်သီး (Numbers) section
                    Text(
                      'ပတ်သီး',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pyidaungsu',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Row of selectable digit buttons (first row: 0-7)
                    Row(
                      children: [
                        _buildLoopNumberButton('0'),
                        _buildLoopNumberButton('1'),
                        _buildLoopNumberButton('2'),
                        _buildLoopNumberButton('3'),
                        _buildLoopNumberButton('4'),
                        _buildLoopNumberButton('5'),
                        _buildLoopNumberButton('6'),
                        _buildLoopNumberButton('7'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row of selectable digit buttons (second row: 8-9)
                    Row(
                      children: [
                        _buildLoopNumberButton('8'),
                        _buildLoopNumberButton('9'),
                        Spacer(flex: 6), // Fill the remaining space
                      ],
                    ),
                    const SizedBox(height: 16),

                    // နောက်ပိတ် (Numbers) section
                    Text(
                      'နောက်ပိတ်',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pyidaungsu',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Row of selectable digit buttons (first row: 0-7)
                    Row(
                      children: [
                        _buildTailNumberButton('0'),
                        _buildTailNumberButton('1'),
                        _buildTailNumberButton('2'),
                        _buildTailNumberButton('3'),
                        _buildTailNumberButton('4'),
                        _buildTailNumberButton('5'),
                        _buildTailNumberButton('6'),
                        _buildTailNumberButton('7'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row of selectable digit buttons (second row: 8-9)
                    Row(
                      children: [
                        _buildTailNumberButton('8'),
                        _buildTailNumberButton('9'),
                        Spacer(flex: 6), // Fill the remaining space
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ဘရိတ် (Numbers) section
                    Text(
                      'ဘရိတ်',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pyidaungsu',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Row of selectable digit buttons (first row: 0-7)
                    Row(
                      children: [
                        _buildBreakNumberButton('0'),
                        _buildBreakNumberButton('1'),
                        _buildBreakNumberButton('2'),
                        _buildBreakNumberButton('3'),
                        _buildBreakNumberButton('4'),
                        _buildBreakNumberButton('5'),
                        _buildBreakNumberButton('6'),
                        _buildBreakNumberButton('7'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row of selectable digit buttons (second row: 8-9)
                    Row(
                      children: [
                        _buildBreakNumberButton('8'),
                        _buildBreakNumberButton('9'),
                        Spacer(flex: 6), // Fill the remaining space
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Bottom status bar and buttons - match the two_d_screen bottom bar style
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final bottomPadding = isIOS ? MediaQuery.of(context).padding.bottom : 0;
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8 + bottomPadding.toDouble(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedNumbers.length} ကွက်',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pyidaungsu',
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              // Back button (grey)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLightTheme ? Colors.grey.shade200 : Color(0xFF3A3A3A),
                    minimumSize: const Size(double.infinity, 45),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pyidaungsu',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // OK button (primary color)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _applySelection();
                    if (_enteredNumber.isNotEmpty) {
                      _processInputText();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 45),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: Text(
                    'Ok',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pyidaungsu',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required bool value,
    required bool groupValue,
    required String label,
  }) {
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isRegular = value;
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    value == groupValue
                        ? AppTheme.primaryColor
                        : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Center(
              child:
                  value == groupValue
                      ? Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor,
                        ),
                      )
                      : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: 14,
            fontFamily: 'Pyidaungsu',
          ),
        ),
      ],
    );
  }

  Widget _buildSizeButton(String text, {bool isSelected = false}) {
    final labels = text.split(' ');
    final mainLabel = labels[0];
    final quantity = labels.length > 1 ? labels[1] : '';
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Check if this button should be selected based on the selected formulas
    final isThisSelected = _selectedFormulas.contains(mainLabel);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isThisSelected) {
              // Deselect this formula and remove its numbers
              _selectedFormulas.remove(mainLabel);
              _removeNumbersFromSelection(mainLabel);
            } else {
              // Select this formula and add its numbers
              _selectedFormulas.add(mainLabel);
              _applyFormula(mainLabel);
            }
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color:
                isThisSelected
                    ? AppTheme.primaryColor
                    : isLightTheme
                    ? Colors.white
                    : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isLightTheme
                      ? Colors.grey.shade300
                      : Colors.grey.shade800.withOpacity(0.5),
            ),
            boxShadow:
                isLightTheme
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: Text(
              quantity.isNotEmpty ? '$mainLabel $quantity' : mainLabel,
              style: TextStyle(
                color: isThisSelected ? Colors.white : AppTheme.textColor,
                fontSize: 13,
                fontFamily: 'Pyidaungsu',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoopNumberButton(String number) {
    final isSelected = _selectedLoopNumbers.contains(number);
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              // Deselect and remove its numbers
              _selectedLoopNumbers.remove(number);
              _removeNumbersFromSelection('loop_$number');
            } else {
              // Select this number and apply loop formula
              _selectedLoopNumbers.add(number);
              _applyLoopFormula(number);
            }
          });
        },
        child: Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppTheme.primaryColor
                    : isLightTheme
                    ? Colors.white
                    : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  isLightTheme
                      ? Colors.grey.shade300
                      : Colors.grey.shade800.withOpacity(0.5),
            ),
            boxShadow:
                isLightTheme
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTailNumberButton(String number) {
    final isSelected = _selectedTailNumbers.contains(number);
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              // Deselect and remove its numbers
              _selectedTailNumbers.remove(number);
              _removeNumbersFromSelection('tail_$number');
            } else {
              // Select this number and apply tail formula
              _selectedTailNumbers.add(number);
              _applyTailFormula(number);
            }
          });
        },
        child: Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppTheme.primaryColor
                    : isLightTheme
                    ? Colors.white
                    : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  isLightTheme
                      ? Colors.grey.shade300
                      : Colors.grey.shade800.withOpacity(0.5),
            ),
            boxShadow:
                isLightTheme
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakNumberButton(String number) {
    final isSelected = _selectedBreakNumbers.contains(number);
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              // Deselect and remove its numbers
              _selectedBreakNumbers.remove(number);
              _removeNumbersFromSelection('break_$number');
            } else {
              // Select this number and apply break formula
              _selectedBreakNumbers.add(number);
              _applyBreakFormula(number);
            }
          });
        },
        child: Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppTheme.primaryColor
                    : isLightTheme
                    ? Colors.white
                    : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  isLightTheme
                      ? Colors.grey.shade300
                      : Colors.grey.shade800.withOpacity(0.5),
            ),
            boxShadow:
                isLightTheme
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _applyFormula(String formula) {
    List<String> numbers = [];

    // Apply the selected formula to generate numbers
    switch (formula) {
      // Range-Based Formulas
      case 'ZeroZero':
        // Includes numbers from 0 to 19
        for (int i = 0; i <= 19; i++) {
          numbers.add(i < 10 ? '0$i' : '$i');
        }
        break;
      case 'TwoZero':
        // Includes numbers from 20 to 39
        for (int i = 20; i <= 39; i++) {
          numbers.add('$i');
        }
        break;
      case 'FourNine':
        // Includes numbers from 40 to 59
        for (int i = 40; i <= 59; i++) {
          numbers.add('$i');
        }
        break;
      case 'SixNine':
        // Includes numbers from 60 to 79
        for (int i = 60; i <= 79; i++) {
          numbers.add('$i');
        }
        break;
      case 'EightNine':
        // Includes numbers from 80 to 99
        for (int i = 80; i <= 99; i++) {
          numbers.add('$i');
        }
        break;

      // Odd and Even Formulas
      case 'မစုံ':
        // OddEvenFormula - Odd first digit, even last digit
        numbers = [
          '10',
          '12',
          '14',
          '16',
          '18',
          '30',
          '32',
          '34',
          '36',
          '38',
          '50',
          '52',
          '54',
          '56',
          '58',
          '70',
          '72',
          '74',
          '76',
          '78',
          '90',
          '92',
          '94',
          '96',
          '98',
        ];
        break;
      case 'စုံမ':
        // EvenOddFormula - Even first digit, odd last digit
        numbers = [
          '01',
          '03',
          '05',
          '07',
          '09',
          '21',
          '23',
          '25',
          '27',
          '29',
          '41',
          '43',
          '45',
          '47',
          '49',
          '61',
          '63',
          '65',
          '67',
          '69',
          '81',
          '83',
          '85',
          '87',
          '89',
        ];
        break;
      case 'မမ':
        // MMFormula - Odd first digit, odd last digit
        numbers = [
          '11',
          '13',
          '15',
          '17',
          '19',
          '31',
          '33',
          '35',
          '37',
          '39',
          '51',
          '53',
          '55',
          '57',
          '59',
          '71',
          '73',
          '75',
          '77',
          '79',
          '91',
          '93',
          '95',
          '97',
          '99',
        ];
        break;
      case 'စုံစုံ':
        // SSFormula - Even first digit, even last digit
        numbers = [
          '00',
          '02',
          '04',
          '06',
          '08',
          '20',
          '22',
          '24',
          '26',
          '28',
          '40',
          '42',
          '44',
          '46',
          '48',
          '60',
          '62',
          '64',
          '66',
          '68',
          '80',
          '82',
          '84',
          '86',
          '88',
        ];
        break;

      // Special Category Formulas
      case 'ညီနောင်':
        // NKFormula
        numbers = [
          '10',
          '21',
          '32',
          '43',
          '54',
          '65',
          '76',
          '87',
          '98',
          '90',
          '01',
          '12',
          '23',
          '34',
          '45',
          '56',
          '67',
          '78',
          '89',
          '09',
        ];
        break;
      case 'အပူး':
        // SameFormula
        numbers = ['00', '11', '22', '33', '44', '55', '66', '77', '88', '99'];
        break;
      case 'စုံပူး':
        // SPFormula
        numbers = ['00', '22', '44', '66', '88'];
        break;
      case 'မပူး':
        // MPFormula
        numbers = ['11', '33', '55', '77', '99'];
        break;
      case 'နက္ခတ်':
        // Zodiac
        numbers = ['07', '18', '24', '35', '69', '70', '81', '42', '53', '96'];
        break;
      case 'ပါဝါ':
        // Power
        numbers = ['05', '16', '27', '38', '49', '50', '61', '72', '83', '94'];
        break;
      case 'မထိပ်':
        // MTFormula - Odd first digit
        numbers = [
          '10',
          '11',
          '12',
          '13',
          '14',
          '15',
          '16',
          '17',
          '18',
          '19',
          '30',
          '31',
          '32',
          '33',
          '34',
          '35',
          '36',
          '37',
          '38',
          '39',
          '50',
          '51',
          '52',
          '53',
          '54',
          '55',
          '56',
          '57',
          '58',
          '59',
          '70',
          '71',
          '72',
          '73',
          '74',
          '75',
          '76',
          '77',
          '78',
          '79',
          '90',
          '91',
          '92',
          '93',
          '94',
          '95',
          '96',
          '97',
          '98',
          '99',
        ];
        break;
      case 'စုံထိပ်':
        // STFormula - Even first digit
        numbers = [
          '00',
          '01',
          '02',
          '03',
          '04',
          '05',
          '06',
          '07',
          '08',
          '09',
          '20',
          '21',
          '22',
          '23',
          '24',
          '25',
          '26',
          '27',
          '28',
          '29',
          '40',
          '41',
          '42',
          '43',
          '44',
          '45',
          '46',
          '47',
          '48',
          '49',
          '60',
          '61',
          '62',
          '63',
          '64',
          '65',
          '66',
          '67',
          '68',
          '69',
          '80',
          '81',
          '82',
          '83',
          '84',
          '85',
          '86',
          '87',
          '88',
          '89',
        ];
        break;
      case 'မပိတ်':
        // MFormula - Odd last digit
        numbers = [
          '01',
          '11',
          '21',
          '31',
          '41',
          '51',
          '61',
          '71',
          '81',
          '91',
          '03',
          '13',
          '23',
          '33',
          '43',
          '53',
          '63',
          '73',
          '83',
          '93',
          '05',
          '15',
          '25',
          '35',
          '45',
          '55',
          '65',
          '75',
          '85',
          '95',
          '07',
          '17',
          '27',
          '37',
          '47',
          '57',
          '67',
          '77',
          '87',
          '97',
          '09',
          '19',
          '29',
          '39',
          '49',
          '59',
          '69',
          '79',
          '89',
          '99',
        ];
        break;
      case 'စုံပိတ်':
        // SFormula - Even last digit
        numbers = [
          '00',
          '10',
          '20',
          '30',
          '40',
          '50',
          '60',
          '70',
          '80',
          '90',
          '02',
          '12',
          '22',
          '32',
          '42',
          '52',
          '62',
          '72',
          '82',
          '92',
          '04',
          '14',
          '24',
          '34',
          '44',
          '54',
          '64',
          '74',
          '84',
          '94',
          '06',
          '16',
          '26',
          '36',
          '46',
          '56',
          '66',
          '76',
          '86',
          '96',
          '08',
          '18',
          '28',
          '38',
          '48',
          '58',
          '68',
          '78',
          '88',
          '98',
        ];
        break;

      // Number Loop Formulas
      case '0ပတ်':
        // ZeroPerFormula
        numbers = [
          '00',
          '10',
          '20',
          '30',
          '40',
          '50',
          '60',
          '70',
          '80',
          '90',
          '01',
          '02',
          '03',
          '04',
          '05',
          '06',
          '07',
          '08',
          '09',
        ];
        break;
      case '1ပတ်':
        // OnePerFormula
        numbers = [
          '01',
          '11',
          '21',
          '31',
          '41',
          '51',
          '61',
          '71',
          '81',
          '91',
          '10',
          '12',
          '13',
          '14',
          '15',
          '16',
          '17',
          '18',
          '19',
        ];
        break;
      case '2ပတ်':
        // TwoPerFormula
        numbers = [
          '02',
          '12',
          '22',
          '32',
          '42',
          '52',
          '62',
          '72',
          '82',
          '92',
          '20',
          '21',
          '23',
          '24',
          '25',
          '26',
          '27',
          '28',
          '29',
        ];
        break;
      case '3ပတ်':
        // ThreePerFormula
        numbers = [
          '03',
          '13',
          '23',
          '33',
          '43',
          '53',
          '63',
          '73',
          '83',
          '93',
          '30',
          '31',
          '32',
          '34',
          '35',
          '36',
          '37',
          '38',
          '39',
        ];
        break;
      case '4ပတ်':
        // FourPerFormula
        numbers = [
          '04',
          '14',
          '24',
          '34',
          '44',
          '54',
          '64',
          '74',
          '84',
          '94',
          '40',
          '41',
          '42',
          '43',
          '45',
          '46',
          '47',
          '48',
          '49',
        ];
        break;
      case '5ပတ်':
        // FivePerFormula
        numbers = [
          '05',
          '15',
          '25',
          '35',
          '45',
          '55',
          '65',
          '75',
          '85',
          '95',
          '50',
          '51',
          '52',
          '53',
          '54',
          '56',
          '57',
          '58',
          '59',
        ];
        break;
      case '6ပတ်':
        // SixPerFormula
        numbers = [
          '06',
          '16',
          '26',
          '36',
          '46',
          '56',
          '66',
          '76',
          '86',
          '96',
          '60',
          '61',
          '62',
          '63',
          '64',
          '65',
          '67',
          '68',
          '69',
        ];
        break;
      case '7ပတ်':
        // SevenPerFormula
        numbers = [
          '07',
          '17',
          '27',
          '37',
          '47',
          '57',
          '67',
          '77',
          '87',
          '97',
          '70',
          '71',
          '72',
          '73',
          '74',
          '75',
          '76',
          '78',
          '79',
        ];
        break;
      case '8ပတ်':
        // EightPerFormula
        numbers = [
          '08',
          '18',
          '28',
          '38',
          '48',
          '58',
          '68',
          '78',
          '88',
          '98',
          '80',
          '81',
          '82',
          '83',
          '84',
          '85',
          '86',
          '87',
          '89',
        ];
        break;
      case '9ပတ်':
        // NinePerFormula
        numbers = [
          '09',
          '19',
          '29',
          '39',
          '49',
          '59',
          '69',
          '79',
          '89',
          '99',
          '90',
          '91',
          '92',
          '93',
          '94',
          '95',
          '96',
          '97',
          '98',
        ];
        break;

      // Break Formulas (ဘရိတ်)
      case '0ဘရိတ်':
        // ZeroBreakFormula
        numbers = ['00', '19', '91', '28', '82', '37', '73', '46', '64', '55'];
        break;
      case '1ဘရိတ်':
        // OneBreakFormula
        numbers = ['01', '10', '29', '92', '38', '83', '47', '74', '56', '65'];
        break;
      case '2ဘရိတ်':
        // TwoBreakFormula
        numbers = ['02', '20', '11', '39', '93', '48', '84', '57', '76', '66'];
        break;
      case '3ဘရိတ်':
        // ThreeBreakFormula
        numbers = ['03', '30', '12', '21', '49', '94', '58', '85', '67', '76'];
        break;
      case '4ဘရိတ်':
        // FourBreakFormula
        numbers = ['04', '40', '13', '31', '22', '59', '95', '68', '86', '77'];
        break;
      case '5ဘရိတ်':
        // FiveBreakFormula
        numbers = ['05', '50', '14', '41', '23', '32', '69', '96', '78', '87'];
        break;
      case '6ဘရိတ်':
        // SixBreakFormula
        numbers = ['06', '60', '15', '51', '24', '42', '33', '97', '79', '88'];
        break;
      case '7ဘရိတ်':
        // SevenBreakFormula
        numbers = ['07', '70', '16', '61', '25', '52', '34', '43', '89', '98'];
        break;
      case '8ဘရိတ်':
        // EightBreakFormula
        numbers = ['08', '80', '17', '71', '26', '62', '35', '53', '44', '99'];
        break;
      case '9ဘရိတ်':
        // NineBreakFormula
        numbers = ['09', '90', '18', '81', '27', '72', '36', '63', '45', '54'];
        break;

      // Head Formulas (ထိပ်)
      case '0ထိပ်':
        // ZeroHeadFormula
        numbers = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09'];
        break;
      case '1ထိပ်':
        // OneHeadFormula
        numbers = ['10', '11', '12', '13', '14', '15', '16', '17', '18', '19'];
        break;
      case '2ထိပ်':
        // TwoHeadFormula
        numbers = ['20', '21', '22', '23', '24', '25', '26', '27', '28', '29'];
        break;
      case '3ထိပ်':
        // ThreeHeadFormula
        numbers = ['30', '31', '32', '33', '34', '35', '36', '37', '38', '39'];
        break;
      case '4ထိပ်':
        // FourHeadFormula
        numbers = ['40', '41', '42', '43', '44', '45', '46', '47', '48', '49'];
        break;
      case '5ထိပ်':
        // FiveHeadFormula
        numbers = ['50', '51', '52', '53', '54', '55', '56', '57', '58', '59'];
        break;
      case '6ထိပ်':
        // SixHeadFormula
        numbers = ['60', '61', '62', '63', '64', '65', '66', '67', '68', '69'];
        break;
      case '7ထိပ်':
        // SevenHeadFormula
        numbers = ['70', '71', '72', '73', '74', '75', '76', '77', '78', '79'];
        break;
      case '8ထိပ်':
        // EightHeadFormula
        numbers = ['80', '81', '82', '83', '84', '85', '86', '87', '88', '89'];
        break;
      case '9ထိပ်':
        // NineHeadFormula
        numbers = ['90', '91', '92', '93', '94', '95', '96', '97', '98', '99'];
        break;

      // Tail Formulas (ပိတ်)
      case '0ပိတ်':
        // ZeroTailFormula
        numbers = ['00', '10', '20', '30', '40', '50', '60', '70', '80', '90'];
        break;
      case '1ပိတ်':
        // OneTailFormula
        numbers = ['01', '11', '21', '31', '41', '51', '61', '71', '81', '91'];
        break;
      case '2ပိတ်':
        // TwoTailFormula
        numbers = ['02', '12', '22', '32', '42', '52', '62', '72', '82', '92'];
        break;
      case '3ပိတ်':
        // ThreeTailFormula
        numbers = ['03', '13', '23', '33', '43', '53', '63', '73', '83', '93'];
        break;
      case '4ပိတ်':
        // FourTailFormula
        numbers = ['04', '14', '24', '34', '44', '54', '64', '74', '84', '94'];
        break;
      case '5ပိတ်':
        // FiveTailFormula
        numbers = ['05', '15', '25', '35', '45', '55', '65', '75', '85', '95'];
        break;
      case '6ပိတ်':
        // SixTailFormula
        numbers = ['06', '16', '26', '36', '46', '56', '66', '76', '86', '96'];
        break;
      case '7ပိတ်':
        // SevenTailFormula
        numbers = ['07', '17', '27', '37', '47', '57', '67', '77', '87', '97'];
        break;
      case '8ပိတ်':
        // EightTailFormula
        numbers = ['08', '18', '28', '38', '48', '58', '68', '78', '88', '98'];
        break;
      case '9ပိတ်':
        // NineTailFormula
        numbers = ['09', '19', '29', '39', '49', '59', '69', '79', '89', '99'];
        break;

      default:
        // No formula selected
        break;
    }

    // Store these numbers as coming from this formula
    _selectionToNumbers[formula] = numbers.toSet();

    // Add to the selected numbers instead of replacing
    setState(() {
      // Add all numbers from this selection
      _selectedNumbers.addAll(numbers);

      // Remove duplicates
      _selectedNumbers = _selectedNumbers.toSet().toList();
    });
  }

  void _applyLoopFormula(String digit) {
    List<String> numbers = [];

    // Find all numbers that include the selected digit
    for (int i = 0; i <= 99; i++) {
      String numStr = i.toString().padLeft(2, '0');
      if (numStr.contains(digit)) {
        numbers.add(numStr);
      }
    }

    // Store these numbers as coming from this loop selection
    _selectionToNumbers['loop_$digit'] = numbers.toSet();

    // Add to the selected numbers instead of replacing
    setState(() {
      // Add all numbers from this selection
      _selectedNumbers.addAll(numbers);

      // Remove duplicates
      _selectedNumbers = _selectedNumbers.toSet().toList();
    });
  }

  void _applyTailFormula(String digit) {
    List<String> numbers = [];

    // Find all numbers that end with the selected digit
    for (int i = 0; i <= 9; i++) {
      numbers.add('${i.toString()}$digit');
    }

    // Store these numbers as coming from this tail selection
    _selectionToNumbers['tail_$digit'] = numbers.toSet();

    // Add to the selected numbers instead of replacing
    setState(() {
      // Add all numbers from this selection
      _selectedNumbers.addAll(numbers);

      // Remove duplicates
      _selectedNumbers = _selectedNumbers.toSet().toList();
    });
  }

  void _applyBreakFormula(String digit) {
    List<String> numbers = [];

    // Get the digit value
    int? sumDigit = int.tryParse(digit);

    if (sumDigit != null && sumDigit >= 0 && sumDigit <= 9) {
      // Generate all pairs of digits that sum to this digit
      for (int i = 0; i <= 9; i++) {
        final j = sumDigit - i;
        if (j >= 0 && j <= 9) {
          // Format with leading zeros as needed
          final formattedNumber = '$i$j';
          numbers.add(formattedNumber);
        }
      }
    } else {
      // Fallback to hardcoded lists if parsing fails
      switch (digit) {
        case '0':
          numbers = [
            '00',
            '19',
            '91',
            '28',
            '82',
            '37',
            '73',
            '46',
            '64',
            '55',
          ];
          break;
        case '1':
          numbers = [
            '01',
            '10',
            '29',
            '92',
            '38',
            '83',
            '47',
            '74',
            '56',
            '65',
          ];
          break;
        case '2':
          numbers = [
            '02',
            '20',
            '11',
            '39',
            '93',
            '48',
            '84',
            '57',
            '76',
            '66',
          ];
          break;
        case '3':
          numbers = [
            '03',
            '30',
            '12',
            '21',
            '49',
            '94',
            '58',
            '85',
            '67',
            '76',
          ];
          break;
        case '4':
          numbers = [
            '04',
            '40',
            '13',
            '31',
            '22',
            '59',
            '95',
            '68',
            '86',
            '77',
          ];
          break;
        case '5':
          numbers = [
            '05',
            '50',
            '14',
            '41',
            '23',
            '32',
            '69',
            '96',
            '78',
            '87',
          ];
          break;
        case '6':
          numbers = [
            '06',
            '60',
            '15',
            '51',
            '24',
            '42',
            '33',
            '97',
            '79',
            '88',
          ];
          break;
        case '7':
          numbers = [
            '07',
            '70',
            '16',
            '61',
            '25',
            '52',
            '34',
            '43',
            '89',
            '98',
          ];
          break;
        case '8':
          numbers = [
            '08',
            '80',
            '17',
            '71',
            '26',
            '62',
            '35',
            '53',
            '44',
            '99',
          ];
          break;
        case '9':
          numbers = [
            '09',
            '90',
            '18',
            '81',
            '27',
            '72',
            '36',
            '63',
            '45',
            '54',
          ];
          break;
      }
    }

    // Store these numbers as coming from this break selection
    _selectionToNumbers['break_$digit'] = numbers.toSet();

    // Add to the selected numbers instead of replacing
    setState(() {
      // Add all numbers from this selection
      _selectedNumbers.addAll(numbers);

      // Remove duplicates
      _selectedNumbers = _selectedNumbers.toSet().toList();
    });
  }

  // Remove numbers associated with a specific selection
  void _removeNumbersFromSelection(String selectionKey) {
    if (_selectionToNumbers.containsKey(selectionKey)) {
      setState(() {
        // Get numbers associated with this selection
        final numbersToRemove = _selectionToNumbers[selectionKey]!;

        // Create a new list without these numbers
        List<String> updatedNumbers = List.from(_selectedNumbers);
        updatedNumbers.removeWhere((number) {
          // Only remove if this number is unique to this selection
          if (numbersToRemove.contains(number)) {
            // Check if this number is also from another selection
            bool isFromOtherSelection = false;
            for (final entry in _selectionToNumbers.entries) {
              if (entry.key != selectionKey && entry.value.contains(number)) {
                isFromOtherSelection = true;
                break;
              }
            }
            // Remove only if not from another selection
            return !isFromOtherSelection;
          }
          return false;
        });

        // Update selected numbers
        _selectedNumbers = updatedNumbers;

        // Remove this selection from tracking
        _selectionToNumbers.remove(selectionKey);
      });
    }
  }

  void _applySelection() {
    // Return the selected numbers to the caller
    Navigator.of(context).pop(_selectedNumbers);
  }

  // Detect which formulas or selections were previously used
  void _detectPreviousSelections() {
    if (_selectedNumbers.isEmpty) return;

    // Create a set of all selected numbers for easier checking
    final selectedNumbersSet = _selectedNumbers.toSet();

    // Clear any previous selections
    _selectedFormulas = {};
    _selectedLoopNumbers = {};
    _selectedTailNumbers = {};
    _selectedBreakNumbers = {};
    _selectionToNumbers = {};

    // Define expected pattern counts to help determine the most likely pattern type
    final Map<String, Map<String, int>> patternCounts = {
      'loop': {
        '0': 19,
        '1': 19,
        '2': 19,
        '3': 19,
        '4': 19,
        '5': 19,
        '6': 19,
        '7': 19,
        '8': 19,
        '9': 19,
      },
      'tail': {
        '0': 10,
        '1': 10,
        '2': 10,
        '3': 10,
        '4': 10,
        '5': 10,
        '6': 10,
        '7': 10,
        '8': 10,
        '9': 10,
      },
      'break': {
        '0': 10,
        '1': 10,
        '2': 10,
        '3': 10,
        '4': 10,
        '5': 10,
        '6': 10,
        '7': 10,
        '8': 10,
        '9': 10,
      },
    };

    // Analyze the selected numbers to determine the most likely pattern type
    // First, check exact matches for specific predefined patterns (break and formulas)

    // Check for break patterns
    for (var digit in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      // Generate the expected numbers for this digit's break pattern
      List<String> breakNumbers = [];
      int sumDigit = int.parse(digit);

      // Generate all pairs of digits that sum to this digit
      for (int i = 0; i <= 9; i++) {
        final j = sumDigit - i;
        if (j >= 0 && j <= 9) {
          breakNumbers.add('$i$j');
        }
      }

      // If all generated numbers are selected, mark this break as selected
      final breakNumbersSet = breakNumbers.toSet();

      // If the selected numbers contain all numbers from this break pattern
      // and the counts match or are proportional, consider it a match
      if (breakNumbersSet.isNotEmpty &&
          selectedNumbersSet.containsAll(breakNumbersSet) &&
          (selectedNumbersSet.length == breakNumbersSet.length ||
              selectedNumbersSet.length % breakNumbersSet.length == 0)) {
        _selectedBreakNumbers.add(digit);
        _selectionToNumbers['break_$digit'] = breakNumbersSet;

        // If exact match, return immediately; otherwise continue checking
        if (selectedNumbersSet.length == breakNumbersSet.length) {
          return;
        }
      }
    }

    // Continue with the rest of the pattern detection
    // Fallback to hardcoded break patterns if the dynamic detection fails
    final breakFormulas = {
      '0': ['00', '19', '91', '28', '82', '37', '73', '46', '64', '55'],
      '1': ['01', '10', '29', '92', '38', '83', '47', '74', '56', '65'],
      '2': ['02', '20', '11', '39', '93', '48', '84', '57', '76', '66'],
      '3': ['03', '30', '12', '21', '49', '94', '58', '85', '67', '76'],
      '4': ['04', '40', '13', '31', '22', '59', '95', '68', '86', '77'],
      '5': ['05', '50', '14', '41', '23', '32', '69', '96', '78', '87'],
      '6': ['06', '60', '15', '51', '24', '42', '33', '97', '79', '88'],
      '7': ['07', '70', '16', '61', '25', '52', '34', '43', '89', '98'],
      '8': ['08', '80', '17', '71', '26', '62', '35', '53', '44', '99'],
      '9': ['09', '90', '18', '81', '27', '72', '36', '63', '45', '54'],
    };

    // Check hardcoded break patterns for backward compatibility
    for (var entry in breakFormulas.entries) {
      final breakNumbersSet = entry.value.toSet();
      if (selectedNumbersSet.length == breakNumbersSet.length &&
          selectedNumbersSet.containsAll(breakNumbersSet)) {
        _selectedBreakNumbers.add(entry.key);
        _selectionToNumbers['break_${entry.key}'] = breakNumbersSet;
        return; // If this is an exact match, no need to check other patterns
      }
    }

    // Check for common formula patterns
    final commonFormulas = {
      'ညီနောင်': [
        '10',
        '21',
        '32',
        '43',
        '54',
        '65',
        '76',
        '87',
        '98',
        '90',
        '01',
        '12',
        '23',
        '34',
        '45',
        '56',
        '67',
        '78',
        '89',
        '09',
      ],
      'အပူး': ['00', '11', '22', '33', '44', '55', '66', '77', '88', '99'],
      'စုံပူး': ['00', '22', '44', '66', '88'],
      'မပူး': ['11', '33', '55', '77', '99'],
      // Add more formulas as needed
    };

    for (var entry in commonFormulas.entries) {
      final formulaNumbersSet = entry.value.toSet();
      if (selectedNumbersSet.length == formulaNumbersSet.length &&
          selectedNumbersSet.containsAll(formulaNumbersSet)) {
        _selectedFormulas.add(entry.key);
        _selectionToNumbers[entry.key] = formulaNumbersSet;
        return; // If this is an exact match, no need to check other patterns
      }
    }

    // Next, check for loop and tail patterns
    // The key insight is that if we have exact match to a pattern (same number of digits),
    // we should prefer that over a partial match to another pattern

    // Check for exact loop pattern matches (19 numbers for each digit)
    for (String digit in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      List<String> loopNumbers = [];
      for (int i = 0; i <= 99; i++) {
        String numStr = i.toString().padLeft(2, '0');
        if (numStr.contains(digit)) {
          loopNumbers.add(numStr);
        }
      }

      final loopNumbersSet = loopNumbers.toSet();
      if (selectedNumbersSet.length == loopNumbersSet.length &&
          selectedNumbersSet.containsAll(loopNumbersSet)) {
        _selectedLoopNumbers.add(digit);
        _selectionToNumbers['loop_$digit'] = loopNumbersSet;
        return; // If this is an exact match, no need to check other patterns
      }
    }

    // Check for exact tail pattern matches (10 numbers for each digit)
    for (String digit in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      List<String> tailNumbers = [];
      for (int i = 0; i <= 9; i++) {
        tailNumbers.add('${i.toString()}$digit');
      }

      final tailNumbersSet = tailNumbers.toSet();
      if (selectedNumbersSet.length == tailNumbersSet.length &&
          selectedNumbersSet.containsAll(tailNumbersSet)) {
        _selectedTailNumbers.add(digit);
        _selectionToNumbers['tail_$digit'] = tailNumbersSet;
        return; // If this is an exact match, no need to check other patterns
      }
    }

    // If no exact match is found, then we can check for partial matches
    // For partial matches, we prioritize by checking if the set contains all numbers
    // from a specific pattern and is close to the expected count

    // Fallback to checking for loop patterns (since they are more general)
    for (String digit in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      List<String> loopNumbers = [];
      for (int i = 0; i <= 99; i++) {
        String numStr = i.toString().padLeft(2, '0');
        if (numStr.contains(digit)) {
          loopNumbers.add(numStr);
        }
      }

      final loopNumbersSet = loopNumbers.toSet();
      if (selectedNumbersSet.containsAll(loopNumbersSet)) {
        _selectedLoopNumbers.add(digit);
        _selectionToNumbers['loop_$digit'] = loopNumbersSet;
      }
    }

    // Finally check for tail patterns
    for (String digit in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      List<String> tailNumbers = [];
      for (int i = 0; i <= 9; i++) {
        tailNumbers.add('${i.toString()}$digit');
      }

      final tailNumbersSet = tailNumbers.toSet();
      // For tail patterns, only select if we don't already have a loop pattern for this digit
      if (selectedNumbersSet.containsAll(tailNumbersSet) &&
          !_selectedLoopNumbers.contains(digit)) {
        _selectedTailNumbers.add(digit);
        _selectionToNumbers['tail_$digit'] = tailNumbersSet;
      }
    }
  }

  // Add new method to process input text for ခွေ or ခွေပူး formula
  void _processInputText() {
    if (_enteredNumber.isEmpty) return;

    // Clear current selection
    setState(() {
      _selectedNumbers.clear();
      _selectedFormulas.clear();
      _selectedLoopNumbers.clear();
      _selectedTailNumbers.clear();
      _selectedBreakNumbers.clear();
      _selectionToNumbers.clear();
    });

    // Normalize and clean the input
    String input = _normalizeDigits(_enteredNumber.trim());

    // Remove any non-digit characters
    input = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (input.isEmpty) return;

    // Apply the appropriate formula based on _hasTwin state
    if (_hasTwin) {
      // Apply ခွေပူး formula (with pairs)
      _applyKPFormula(input);
    } else {
      // Apply ခွေ formula (without pairs)
      _applyKFormula(input);
    }
  }

  // Apply ခွေပူး formula (with pairs)
  void _applyKPFormula(String digits) {
    digits = _normalizeDigits(digits);
    List<String> numbers = [];

    // Generate all combinations including pairs
    for (int i = 0; i < digits.length; i++) {
      for (int j = 0; j < digits.length; j++) {
        String number = '${digits[i]}${digits[j]}';
        numbers.add(number);
      }
    }

    // Store these numbers
    _selectionToNumbers['KP_formula'] = numbers.toSet();

    // Add to the selected numbers
    setState(() {
      _selectedNumbers.addAll(numbers);
      _selectedNumbers = _selectedNumbers.toSet().toList();
    });
  }

  // Apply ခွေ formula (without pairs)
  void _applyKFormula(String digits) {
    digits = _normalizeDigits(digits);
    List<String> numbers = [];

    // Generate combinations excluding pairs
    for (int i = 0; i < digits.length; i++) {
      for (int j = 0; j < digits.length; j++) {
        if (i != j) {
          // Skip pairs (digits that are the same)
          String number = '${digits[i]}${digits[j]}';
          numbers.add(number);
        }
      }
    }

    // Store these numbers
    _selectionToNumbers['K_formula'] = numbers.toSet();

    // Add to the selected numbers
    setState(() {
      _selectedNumbers.addAll(numbers);
      _selectedNumbers = _selectedNumbers.toSet().toList();
    });
  }

  // Helper method to normalize Myanmar digits to Arabic digits
  String _normalizeDigits(String input) {
    if (input.isEmpty) return input;

    // Convert Myanmar digits to Arabic digits
    const myanmarDigits = '၀၁၂၃၄၅၆၇၈၉';
    const arabicDigits = '0123456789';

    String result = input;
    for (int i = 0; i < myanmarDigits.length; i++) {
      result = result.replaceAll(myanmarDigits[i], arabicDigits[i]);
    }

    return result;
  }
}
