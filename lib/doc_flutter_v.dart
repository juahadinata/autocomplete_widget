import 'dart:async';

import 'package:flutter/material.dart';

///? Contoh ini menunjukkan cara membuat widget [Autocomplete] yang opsinya diambil melalui jaringan.
///? Ini mencakup debouncing dan penanganan kesalahan,
///? sehingga permintaan jaringan yang gagal menunjukkan kesalahan kepada pengguna
///? dan dapat dipulihkan. Coba alihkan widget Pengalih jaringan untuk menyimulasikan offline.

/// Flutter code sample for [Autocomplete] that demonstrates fetching the
/// options asynchronously and debouncing the network calls, including handling
/// network errors.

const Duration fakeAPIDuration = Duration(seconds: 1);
const Duration debounceDuration = Duration(milliseconds: 500);

class AutocompleteExampleAppV extends StatelessWidget {
  const AutocompleteExampleAppV({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Autocomplete - async, debouncing, and network errors'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Type below to autocomplete the following possible results: ${_FakeAPI._kOptions}.'),
            const SizedBox(height: 32.0),
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
  /// menyimpan query pencarian saat ini
  String? _currentQuery;

  /// Menyimpan opsi terakhir yang ditampilkan di autocomplete.
  late Iterable<String> _lastOptions = <String>[];

  /// Fungsi pencarian yang telah di-debounce untuk mencegah panggilan berulang.
  late final _Debounceable<Iterable<String>?, String> _debouncedSearch;

  /// Menandai apakah jaringan diaktifkan atau tidak.
  bool _networkEnabled = true;

  /// Menandai apakah ada kesalahan jaringan.
  bool _networkError = false;

  ///? Melakukan pencarian dengan query tertentu melalui API simulasi.
  Future<Iterable<String>?> _search(String query) async {
    /// menyimpan query saat ini
    _currentQuery = query;

    late final Iterable<String> options;
    try {
      ///* Memanggil API simulasi dengan query dan status jaringan.
      options = await _FakeAPI.search(_currentQuery!, _networkEnabled);
    } on _NetworkException {
      ///* Jika terjadi kesalahan jaringan, perbarui status error.
      if (mounted) {
        setState(() {
          _networkError = true;
        });
      }

      /// Kembalikan daftar kosong jika ada kesalahan.
      return <String>[];
    }

    /// Periksa apakah query berubah selama pencarian.
    if (_currentQuery != query) {
      /// Kembalikan null jika query tidak cocok lagi.
      return null;
    }
    // reset query
    _currentQuery = null;

    // kembalikan hasil pencarian
    return options;
  }

  @override
  void initState() {
    super.initState();

    /// Inisialisasi fungsi pencarian dengan debounce.
    _debouncedSearch = _debounce<Iterable<String>?, String>(_search);
  }

  ///? UI
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ///* Menampilkan status jaringan.
        Text(
          _networkEnabled
              ? 'Network is on, toggle to induce network errors.'
              : 'Network is off, toggle to allow requests to go through.',
        ),

        ///* Switch untuk mengaktifkan/mematikan jaringan.
        switchAktifkanNetwork(),

        ///* memberi jarak vertical
        const SizedBox(
          height: 32.0,
        ),

        ///* Widget autocomplete untuk masukan teks dan saran.
        autocompleteSearch(),
      ],
    );
  }

  ///? widget widget pada UI
  Autocomplete<String> autocompleteSearch() {
    return Autocomplete<String>(
      fieldViewBuilder: (BuildContext context, TextEditingController controller,
          FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            decoration: InputDecoration(
              /// Menampilkan pesan kesalahan jika ada masalah jaringan.
              errorText:
                  _networkError ? 'Kesalahan jaringan, coba lagi.' : null,
            ),
            controller: controller, // menghubungkan controller text
            focusNode: focusNode, // mengelola fokus untuk input field
            onFieldSubmitted: (String value) {
              onFieldSubmitted(); // memproses input saat di submit
            },
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) async {
        // Reset status kesalahan jaringan.
        setState(() {
          _networkError = false;
        });
        // Melakukan pencarian dengan debounce.
        final Iterable<String>? options =
            await _debouncedSearch(textEditingValue.text);
        if (options == null) {
          return _lastOptions; // Gunakan opsi terakhir jika null.
        }
        _lastOptions = options; // Perbarui opsi terakhir.
        return options; // Kembalikan hasil pencarian.
      },
      onSelected: (String selection) {
        // Menampilkan opsi yang dipilih ke konsol.
        debugPrint('You just selected $selection');
      },
    );
  }

  Switch switchAktifkanNetwork() {
    return Switch(
      value: _networkEnabled,
      onChanged: (bool? value) {
        setState(() {
          _networkEnabled = !_networkEnabled;
        });
      },
    );
  }
}

///? Mimics a remote API.
class _FakeAPI {
  static const List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  static Future<Iterable<String>> search(
      String query, bool networkEnabled) async {
    await Future<void>.delayed(fakeAPIDuration); // Fake 1 second delay.
    if (!networkEnabled) {
      throw const _NetworkException();
    }
    if (query == '') {
      return const Iterable<String>.empty();
    }
    return _kOptions.where((String option) {
      return option.contains(query.toLowerCase());
    });
  }
}

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } on _CancelException {
      return null;
    }
    return function(parameter);
  };
}

class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

class _CancelException implements Exception {
  const _CancelException();
}

class _NetworkException implements Exception {
  const _NetworkException();
}
