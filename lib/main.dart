
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora - Portfólio',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: const CalculatorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _expression = '';
  String _result = '';

  final List<List<String>> buttons = [
    ['C', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '⌫', '='],
  ];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
        return;
      }

      if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
        return;
      }

      if (value == '=') {
        _evaluateExpression();
        return;
      }

      if (value == '±') {
        // toggle sign of last number
        _toggleSign();
        return;
      }

      // Append other buttons
      _expression += value;
    });
  }

  void _toggleSign() {
    // Find last number in the expression and toggle its sign
    final regex = RegExp(r'([\d\.]+)$');
    final match = regex.firstMatch(_expression);
    if (match != null) {
      final numStr = match.group(0)!;
      final start = match.start;
      if (numStr.startsWith('-')) {
        _expression = _expression.replaceRange(start, _expression.length, numStr.substring(1));
      } else {
        _expression = _expression.replaceRange(start, _expression.length, '-$numStr');
      }
    } else if (_expression.isEmpty) {
      _expression = '-';
    }
  }

  void _evaluateExpression() {
    try {
      final exp = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');

      Parser p = Parser();
      Expression parsed = p.parse(exp);
      ContextModel cm = ContextModel();
      double eval = parsed.evaluate(EvaluationType.REAL, cm);

      _result = _formatResult(eval);
    } catch (e) {
      _result = 'Erro';
    }
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  Color _operatorColor() => Colors.orangeAccent;
  Color _buttonColor() => Colors.grey.shade900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: const TextStyle(fontSize: 32, color: Colors.white70),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _result,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black87,
                child: Column(
                  children: buttons.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((btn) {
                          final isOperator = ['÷', '×', '-', '+', '='].contains(btn);
                          final isWide = btn == '0';
                          return Expanded(
                            flex: isWide ? 2 : 1,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOperator ? _operatorColor() : _buttonColor(),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                ),
                                onPressed: () => _onButtonPressed(btn),
                                child: Text(
                                  btn,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: isOperator ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
