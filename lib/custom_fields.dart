import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CharacterInputFields extends StatefulWidget {
  final WordFieldController wordModel;
  final double spacing;
  final double runSpacing;
  final Color? fillColor;
  final double width;
  final double height;
  final TextStyle? style;
  final InputBorder? errorBorder;
  final InputBorder? Function(bool)? border;
  final Future<void> Function() onTypeWrong;
  final Future<void> Function() onTypeCorrect;

  const CharacterInputFields({
    super.key,
    required this.wordModel,
    this.spacing = 8,
    this.runSpacing = 8,
    this.width = 50,
    this.height = 52,
    this.fillColor,
    this.style,
    this.errorBorder,
    this.border,
    required this.onTypeWrong,
    required this.onTypeCorrect,
  });

  @override
  CharacterInputFieldsState createState() => CharacterInputFieldsState();
}

class CharacterInputFieldsState extends State<CharacterInputFields> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  late List<String?> errorsText;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
        widget.wordModel.filedCount, (_) => TextEditingController());
    focusNodes = List.generate(widget.wordModel.filedCount, (_) => FocusNode());
    errorsText = List.generate(widget.wordModel.filedCount, (_) => null);
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          controllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: controllers[i].text.length,
          );
        }
      });
    }
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) => widget.wordModel.setController(controllers),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Center(
        child: Wrap(
          spacing: widget.spacing,
          runSpacing: widget.runSpacing,
          children: List.generate(widget.wordModel.filedCount, (index) {
            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    if (controllers[index].text.isEmpty && index > 0) {
                      FocusScope.of(context)
                          .requestFocus(focusNodes[index - 1]);
                      controllers[index - 1].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: controllers[index - 1].text.length,
                      );
                    }
                  }
                },
                child: TextFormField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  style: widget.style ?? TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    counterText: '',
                    error: errorsText[index] == null
                        ? null
                        : const SizedBox.shrink(),
                    errorText: null,
                    fillColor: widget.fillColor ?? Colors.grey.shade300,
                    filled: true,
                    errorBorder: widget.errorBorder ??
                        OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.red.shade300,
                            width: 3,
                          ),
                        ),
                    enabledBorder: widget.border?.call(
                            controllers[index].text.toLowerCase() ==
                                widget.wordModel.word[index].toLowerCase()) ??
                        OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: controllers[index].text.toLowerCase() ==
                                    widget.wordModel.word[index].toLowerCase()
                                ? Colors.greenAccent
                                : Colors.black,
                            width: 3,
                          ),
                        ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) async {
                    setState(() {
                      widget.wordModel.updateCharacter(index, value);
                    });
                    if (value.toLowerCase() ==
                            widget.wordModel.word[index].toLowerCase() &&
                        value.isNotEmpty) {
                      await widget.onTypeCorrect.call();
                    } else if (value.toLowerCase() !=
                            widget.wordModel.word[index].toLowerCase() &&
                        value.isNotEmpty) {
                      await widget.onTypeWrong.call();
                    }
                    if (value.isEmpty) {
                      setState(() {
                        errorsText[index] = null;
                      });
                    } else {
                      if (value.toLowerCase() !=
                          widget.wordModel.word[index].toLowerCase()) {
                        setState(() {
                          errorsText[index] = '';
                        });
                      }
                    }
                    if (index < widget.wordModel.filedCount - 1 &&
                        value.isNotEmpty) {
                      FocusScope.of(context)
                          .requestFocus(focusNodes[index + 1]);
                    }
                  },
                  onTap: () {
                    controllers[index].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: controllers[index].text.length,
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class WordFieldController {
  Map<int, String> characterMap;
  String word;
  int filedCount;
  final List<TextEditingController>? textControllers =
      List.empty(growable: true);

  WordFieldController({required String word})
      : word = word.formatString(),
        filedCount = word.formatString().length,
        characterMap = Map.fromIterables(
          List.generate(word.formatString().length, (index) => index),
          List.generate(word.formatString().length, (_) => ''),
        );

  void updateCharacter(int index, String value) {
    if (characterMap.containsKey(index)) {
      characterMap[index] = value;
    }
  }

  Map<int, String> getControllerDetails() => characterMap;

  String getFullWord() {
    return characterMap.values.join('');
  }

  void fillCharacters(Map<int, String> characters) {
    for (var entry in characters.entries) {
      int index = entry.key;
      String value = entry.value;

      if (index >= 0 && index < filedCount && value.length == 1) {
        characterMap[index] = value;
        textControllers?[index].text = value;
      }
    }
  }

  void setController(List<TextEditingController> controllers) {
    textControllers?.addAll(controllers);
  }

  void fillRandomCharacters() {
    int maxCharactersToFill = (filedCount / 2).floor();
    List<int> availableIndices = List.generate(filedCount, (index) => index);

    availableIndices.shuffle(Random());
    List<int> selectedIndices =
        availableIndices.take(maxCharactersToFill).toList();

    for (int index in selectedIndices) {
      characterMap[index] = word[index];
      textControllers?[index].text = word[index];
    }
  }
}

extension on String {
  String formatString() => replaceAll(' ', '')
      .replaceAll('.', '')
      .replaceAll(RegExp('[{}\\[\\]()<>.,;:"\'!@#\$%^&*\\-=+_|~`?/]'), '');
}
