import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyAppDua());
// }

class MyAppDua extends StatelessWidget {
  const MyAppDua({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AutocompleteDialogExample(),
    );
  }
}

class AutocompleteDialogExample extends StatelessWidget {
  AutocompleteDialogExample({super.key});

  final List<String> options = [
    'Melaksanakan Monitoring terhadap fasilitas',
    'Ikut serta melaksanakan pemberian tambahan makanan',
    'Melaksanakan kegiatan gotong royong',
    'Mengadministrasikan surat surat',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete in AlertDialog'),
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
