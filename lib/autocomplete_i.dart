import 'package:flutter/material.dart';

class AutocompleteExampleChGpt extends StatelessWidget {
  AutocompleteExampleChGpt({super.key});

  // Daftar opsi yang akan muncul sebagai saran
  final List<String> options = [
    'Melaksanakan Monitoring terhadap fasilitas',
    'Ikut serta melaksanakan senam lansia',
    'Melaksanakan kegiatan gotong royong',
    'Mengadministrasikan surat surat',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return options.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            // Tindakan setelah opsi dipilih
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
      ),
    );
  }
}
