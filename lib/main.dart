import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const AplicativoCalculadora());
}

class AplicativoCalculadora extends StatelessWidget {
  const AplicativoCalculadora({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora - Portfólio',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: const TelaCalculadora(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TelaCalculadora extends StatefulWidget {
  const TelaCalculadora({super.key});

  @override
  State<TelaCalculadora> createState() => _EstadoTelaCalculadora();
}

class _EstadoTelaCalculadora extends State<TelaCalculadora> {
  String _expressao = '';
  String _resultado = '';

  final List<List<String>> botoes = [
    ['C', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '⌫', '='],
  ];

  void _quandoBotaoPressionado(String valor) {
    setState(() {
      if (valor == 'C') {
        _expressao = '';
        _resultado = '';
        return;
      }

      if (valor == '⌫') {
        if (_expressao.isNotEmpty) {
          _expressao = _expressao.substring(0, _expressao.length - 1);
        }
        return;
      }

      if (valor == '=') {
        _avaliarExpressao();
        return;
      }

      if (valor == '±') {
        _alternarSinal();
        return;
      }

      // Adicionar outros valores
      _expressao += valor;
    });
  }

  void _alternarSinal() {
    // Encontra o último número e alterna o sinal
    final regex = RegExp(r'([\d\.]+)$');
    final match = regex.firstMatch(_expressao);
    if (match != null) {
      final numeroStr = match.group(0)!;
      final inicio = match.start;
      if (numeroStr.startsWith('-')) {
        _expressao = _expressao.replaceRange(inicio, _expressao.length, numeroStr.substring(1));
      } else {
        _expressao = _expressao.replaceRange(inicio, _expressao.length, '-$numeroStr');
      }
    } else if (_expressao.isEmpty) {
      _expressao = '-';
    }
  }

  void _avaliarExpressao() {
    try {
      final exp = _expressao
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');

      Parser p = Parser();
      Expression parsed = p.parse(exp);
      ContextModel cm = ContextModel();
      double eval = parsed.evaluate(EvaluationType.REAL, cm);

      _resultado = _formatarResultado(eval);
    } catch (e) {
      _resultado = 'Erro';
    }
  }

  String _formatarResultado(double valor) {
    if (valor == valor.roundToDouble()) {
      return valor.toInt().toString();
    }
    return valor.toString();
  }

  Color _corOperador() => Colors.orangeAccent;
  Color _corBotao() => Colors.grey.shade900;

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
                        _expressao.isEmpty ? '0' : _expressao,
                        style: const TextStyle(fontSize: 32, color: Colors.white70),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _resultado,
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
                  children: botoes.map((linha) {
                    return Expanded(
                      child: Row(
                        children: linha.map((btn) {
                          final eOperador = ['÷', '×', '-', '+', '='].contains(btn);
                          final eLargo = btn == '0';
                          return Expanded(
                            flex: eLargo ? 2 : 1,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: eOperador ? _corOperador() : _corBotao(),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                ),
                                onPressed: () => _quandoBotaoPressionado(btn),
                                child: Text(
                                  btn,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: eOperador ? Colors.black : Colors.white,
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
