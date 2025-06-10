import 'dart:async';

import 'package:flutter/material.dart';

///? Contoh ini menunjukkan cara membuat widget Autocomplete
///? yang opsinya diambil melalui jaringan.
///
///? Ini menggunakan debouncing untuk menunggu untuk melakukan permintaan jaringan
///? hingga pengguna selesai mengetik.

/// Flutter code sample for [Autocomplete] that demonstrates fetching the
/// options asynchronously and debouncing the network calls.

const Duration fakeAPIDuration = Duration(seconds: 1);
const Duration debounceDuration = Duration(milliseconds: 500);

// void main() => runApp(const AutocompleteExampleApp());

class AutocompleteExampleApp extends StatelessWidget {
  const AutocompleteExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete - async and debouncing'),
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
  // Kueri yang sedang dicari. Jika null, tidak ada permintaan yang tertunda.
  String? _kataKunciTerbaru;

  // Pilihan terbaru yang diterima dari API.
  late Iterable<String> _pilihanTerbaru = <String>[];

  late final _Debounceable<Iterable<String>?, String> _debouncedSearch;

  // Memanggil API "jarak jauh" untuk mencari dengan kueri yang diberikan.
  // Mengembalikan null ketika panggilan sudah tidak berlaku lagi.
  Future<Iterable<String>?> _search(String kataKunci) async {
    _kataKunciTerbaru = kataKunci;

    // Dalam aplikasi nyata, seharusnya ada penanganan kesalahan di sini.
    final Iterable<String> pilihanKata =
        await _FakeAPI.search(_kataKunciTerbaru!);

    // If another search happened after this one, throw away these options.
    if (_kataKunciTerbaru != kataKunci) {
      return null;
    }
    _kataKunciTerbaru = null;

    return pilihanKata;
  }

  @override
  void initState() {
    super.initState();
    _debouncedSearch = _debounce<Iterable<String>?, String>(_search);
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        final Iterable<String>? pilihanKataa =
            await _debouncedSearch(textEditingValue.text);
        if (pilihanKataa == null) {
          return _pilihanTerbaru;
        }
        _pilihanTerbaru = pilihanKataa;
        return pilihanKataa;
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

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);
// Membuat alias untuk sebuah fungsi yang menerima parameter bertipe T dan
// mengembalikan nilai bertipe Future<S?>. Ini mempermudah penulisan tipe fungsi
// yang digunakan dalam mekanisme debounce.

_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  // Fungsi `_debounce` yang menerima fungsi bertipe `_Debounceable<S?, T>`
  // dan mengembalikan fungsi bertipe `_Debounceable<S, T>` dengan logika debounce.
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      // Jika timer debounce sedang berjalan, batalkan timer sebelumnya.
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    // Membuat instance baru dari `_DebounceTimer` untuk memulai timer baru.
    try {
      await debounceTimer!.future;
      // Menunggu hingga timer selesai tanpa pembatalan.
    } on _CancelException {
      // Jika timer dibatalkan, hentikan proses dan kembalikan null.
      return null;
    }
    return function(parameter);
    // Jika timer selesai tanpa gangguan, jalankan fungsi yang diberikan
    // dengan parameter yang diteruskan.
  };
}

class _DebounceTimer {
  // Kelas untuk mengelola logika timer debounce.

  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
    // Membuat timer dengan durasi yang ditentukan, menjalankan `_onComplete`
    // saat waktu habis.
  }

  late final Timer _timer;
  // Instance dari `Timer` untuk mengatur waktu debounce.

  final Completer<void> _completer = Completer<void>();
  // `Completer` digunakan untuk menunggu hingga timer selesai atau dibatalkan.

  void _onComplete() {
    _completer.complete();
    // Menandakan bahwa timer telah selesai dengan menyelesaikan `Completer`.
  }

  Future<void> get future => _completer.future;
  // Properti untuk mendapatkan Future yang akan selesai ketika timer selesai
  // atau dibatalkan.

  bool get isCompleted => _completer.isCompleted;
  // Properti untuk memeriksa apakah `Completer` telah selesai atau belum.

  void cancel() {
    _timer.cancel();
    // Membatalkan timer yang sedang berjalan.

    _completer.completeError(const _CancelException());
    // Menyelesaikan Future dengan kesalahan `CancelException` untuk
    // menunjukkan pembatalan.
  }
}

class _CancelException implements Exception {
  // Kelas exception khusus untuk menandakan bahwa timer telah dibatalkan.
  const _CancelException();
  // Konstruktor konstanta untuk instance exception ini.
}

/*

  Pemahaman debounce dapat diilustrasikan sebagai mekanisme untuk mengatur 
  seberapa sering sebuah fungsi dipanggil, dengan memastikan bahwa fungsi 
  tersebut hanya dieksekusi setelah serangkaian pemanggilan berhenti dalam durasi 
  tertentu. Hal ini berguna untuk menghindari panggilan fungsi yang terlalu 
  sering atau tidak perlu, terutama pada kasus yang melibatkan input pengguna 
  atau event-driven actions.

    Analogi Debounce :
      Bayangkan Anda mengetik sesuatu di mesin pencarian. Setiap kali Anda menekan 
      tombol, aplikasi akan mengirim permintaan untuk mendapatkan hasil pencarian. 
      Jika Anda mengetik cepat, aplikasi akan mengirim terlalu banyak permintaan, 
      yang membebani sistem dan memperlambat pengalaman pengguna.

      Dengan debounce, aplikasi hanya akan mengirim permintaan ketika Anda berhenti 
      mengetik selama beberapa waktu tertentu. Jika Anda terus mengetik tanpa 
      berhenti, tidak ada permintaan yang dikirim hingga Anda selesai. 

    Karakteristik Debounce : 
      Menunda eksekusi: Fungsi tidak akan langsung dipanggil saat pertama kali dipicu, 
      tetapi akan menunggu hingga tidak ada pemanggilan baru dalam periode tertentu 
      (disebut durasi debounce).

      Mengurangi pemanggilan berlebihan: Fungsi hanya akan dipanggil satu kali setelah 
      aktivitas berulang selesai dalam periode debounce.

      Umum digunakan pada:

        - Autocomplete: Menghindari permintaan API untuk setiap huruf yang diketik.
        - Event Listener: Membatasi event seperti resize, scroll, 
          atau keypress agar tidak dipanggil terlalu sering.
        - Form Validation: Menunda validasi hingga pengguna selesai mengetik.


 */
