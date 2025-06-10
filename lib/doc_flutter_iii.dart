import 'package:flutter/material.dart';

///? Contoh ini menunjukkan cara membuat widget Autocomplete
///? yang opsinya diambil melalui jaringan.

/// Flutter code sample for [Autocomplete] that shows how to fetch the options
/// from a remote API.

const Duration fakeAPIDuration = Duration(seconds: 1);

class AutocompleteExampleApp3 extends StatelessWidget {
  const AutocompleteExampleApp3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete - async'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Type below to autocomplete the following possible results: ${_FakeAPI._kOptions}.'),
            const _AsyncAutocomplete(),
          ],
        ),
      ),
    );
  }
}

class _AsyncAutocomplete extends StatefulWidget {
  const _AsyncAutocomplete();

  @override
  State<_AsyncAutocomplete> createState() => _AsyncAutocompleteState();
}

class _AsyncAutocompleteState extends State<_AsyncAutocomplete> {
  String? _searchingWithQuery;
  // Variabel untuk menyimpan query pencarian saat ini.
  // Digunakan untuk membandingkan apakah query telah berubah
  // selama operasi asinkron berlangsung.

  late Iterable<String> _lastOptions = <String>[];
  // Variabel untuk menyimpan opsi terakhir yang berhasil dimuat.
  // Inisialisasi awal sebagai daftar kosong.

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      // Widget Autocomplete dengan tipe data String.

      optionsBuilder: (TextEditingValue textEditingValue) async {
        // Fungsi untuk membangun daftar opsi berdasarkan input pengguna.
        // Mengembalikan Future yang berisi Iterable<String>.

        _searchingWithQuery = textEditingValue.text;
        // Menyimpan query pencarian dari input pengguna.

        final Iterable<String> options =
            await _FakeAPI.search(_searchingWithQuery!);
        // Melakukan pencarian ke API (_FakeAPI) secara asinkron
        // berdasarkan query yang dimasukkan pengguna.

        if (_searchingWithQuery != textEditingValue.text) {
          // Jika query pencarian telah berubah selama proses pencarian,
          // kembalikan opsi terakhir yang berhasil dimuat untuk mencegah inkonsistensi.
          return _lastOptions;
        }

        _lastOptions = options;
        // Memperbarui daftar opsi terakhir dengan hasil pencarian baru.

        return options;
        // Mengembalikan hasil pencarian ke widget Autocomplete untuk ditampilkan.
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
      },
    );
  }
}

class _FakeAPI {
  // Kelas statis yang mensimulasikan API untuk pencarian.
  static const List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];
  // Daftar opsi statis yang tersedia untuk simulasi pencarian.

  static Future<Iterable<String>> search(String kataKunci) async {
    // Metode pencarian asinkron untuk mensimulasikan pemanggilan API.

    await Future<void>.delayed(fakeAPIDuration);
    // Mensimulasikan penundaan 1 detik untuk meniru respons API nyata.

    if (kataKunci == '') {
      // jika katakunci kosong kembalikan iterabel kosong
      return const Iterable<String>.empty();
    }
    return _kOptions.where((String pilihan) {
      // Filter daftar opsi berdasarkan kecocokan dengan kata kunci.
      return pilihan.contains(kataKunci.toLowerCase());
    });
  }
}
