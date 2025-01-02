import 'package:custom_fields/custom_fields.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(backgroundColor: Colors.black12, body: HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = WordFieldController(word: 'hadisharifzade');

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        Future.delayed(Duration(seconds: 5)).then(
          (value) {
            // _controller.fillCharacters({1: 'U'});
            // print(_controller.getFullWord());
            _controller.fillRandomCharacters();
            print('---------------');
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: CharacterInputFields(
              wordModel: _controller,
              fillColor: Colors.white12,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white),
              border: (valid) => OutlineInputBorder(
                  borderSide: BorderSide(
                    color: valid ? Colors.greenAccent : Colors.white60,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
