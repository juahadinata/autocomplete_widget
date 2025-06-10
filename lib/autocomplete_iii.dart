import 'package:flutter/material.dart';

// Model class
class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});
}

class AutocompleteDialogExample extends StatelessWidget {
  AutocompleteDialogExample({super.key});

  // Daftar objek model
  final List<Item> items = [
    Item(id: 1, name: 'Flutter'),
    Item(id: 2, name: 'Dart'),
    Item(id: 3, name: 'React'),
    Item(id: 4, name: 'Vue'),
    Item(id: 5, name: 'Angular'),
    Item(id: 6, name: 'JavaScript'),
    Item(id: 7, name: 'Python'),
    Item(id: 8, name: 'Java'),
    Item(id: 9, name: 'C++'),
    Item(id: 10, name: 'C#'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete with Model'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Input Data'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            // Mengambil daftar nama dari model
                            final List<String> options =
                                items.map((item) => item.name).toList();

                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            return options.where((String option) {
                              return option.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            debugPrint('Anda memilih: $selection');
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Masukkan teks',
                                border: OutlineInputBorder(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Tambahkan logika penyimpanan data di sini
                        Navigator.of(context).pop();
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Buka Dialog'),
        ),
      ),
    );
  }
}
