import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class Calculator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _CalculatorState();
  }
}

class _CalculatorState extends State<Calculator> {
  var _textController = new TextEditingController();
  String _display = "Tap a number to Start";
  double _result = 0;
  var _buttons = [
    "1",
    "2",
    "3",
    "+",
    "4",
    "5",
    "6",
    "-",
    "7",
    "8",
    "9",
    "*",
    "",
    "Clear",
    "/",
    "="
  ];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Material Calculator'),
        ),
        body: new Column(children: [
          new Row(children: [
            new Expanded(
              child: new TextField(
                readOnly: true,
                textAlign: TextAlign.end,
                controller: _textController,
                decoration: InputDecoration(labelText: _display),
              ),
            ),
          ]),
          new Expanded(child: _buildButtons())
        ]));
  }

  Widget _buildButtons() {
    return new GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
        ),
        itemCount: _buttons.length,
        itemBuilder: (context, i) {
          switch (_buttons[i]) {
            case ("="):
              {
                return (new TextButton(
                  child: new Text(_buttons[i]),
                  onPressed: () => _textController.text = _calculateResult(),
                ));
              }
            case ("Clear"):
              {
                return (new TextButton(
                  child: new Text(_buttons[i]),
                  onPressed: () => _clearResult(),
                ));
              }
          }

          return (new TextButton(
            child: new Text(_buttons[i]),
            onPressed: () => _result == 0
                ? _textController.text += _buttons[i]
                : _clearResult(_buttons[i]),
          ));
        });
  }

  String _calculateResult() {
    Parser p = Parser();
    ContextModel cm = ContextModel();
    Expression exp = p.parse(_textController.text);
    double result = exp.evaluate(EvaluationType.REAL, cm);
    _result = result;
    return result.toString();
  }

  void _clearResult([String set = ""]) {
    _result = 0;
    _textController.text = set;
  }
}
