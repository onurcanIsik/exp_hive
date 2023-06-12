import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('ProductBox');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> items = [];
  final boxit = Hive.box('productBox');
  TextEditingController textController = TextEditingController();
  final keyForm = GlobalKey<FormState>();

  void refreshBox() async {
    final data = boxit.keys.map((key) {
      final value = boxit.get(key);
      return {
        'key': key,
        'text': value['text'],
      };
    }).toList();

    setState(() {
      items = data.reversed.toList();
    });
  }

  Future<void> createItem(Map<String, dynamic> newItem) async {
    await boxit.add(newItem);
    refreshBox();
  }

  Future<void> deleteItem(key) async {
    await boxit.delete(key).then(
          (value) => refreshBox(),
        );
  }

  @override
  void initState() {
    super.initState();
    refreshBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: const Text("Example Hive"),
      ),
      body: Form(
        key: keyForm,
        child: Stack(
          children: [
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      items[index]['text'],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          deleteItem(items[index]['key']);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Boş bırakmayın";
                          }
                          return null;
                        },
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'Mesajınızı yazın',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (keyForm.currentState!.validate()) {
                            createItem({'text': textController.text});
                          }
                        });
                      },
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
