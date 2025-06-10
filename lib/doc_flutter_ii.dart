import 'package:flutter/material.dart';

///? Contoh ini menunjukkan cara membuat widget Autocomplete dengan tipe khusus.
///? Coba telusuri dengan teks dari kolom nama atau email.

/// Flutter code sample for [Autocomplete].

class AutocompleteExampleApp extends StatelessWidget {
  const AutocompleteExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autocomplete Basic User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Type below to autocomplete the following possible results: ${AutocompleteBasicUserExample._userOptions}.'),
            const AutocompleteBasicUserExample(),
          ],
        ),
      ),
    );
  }
}

@immutable
// Menandakan bahwa kelas ini bersifat immutable (tidak dapat diubah setelah dibuat).
// Semua properti harus bersifat final agar sesuai dengan sifat immutable.

class User {
  // Deklarasi kelas User, mewakili entitas dengan atribut email dan name.

  const User({
    required this.email,
    required this.name,
  });
  // Konstruktor konstanta untuk memastikan bahwa objek yang dibuat bersifat immutable.
  // Parameter 'required' memastikan bahwa nilai email dan name wajib diisi saat instansiasi.

  final String email;
  // Properti final untuk menyimpan email pengguna, tidak dapat diubah setelah diinisialisasi.

  final String name;
  // Properti final untuk menyimpan nama pengguna, juga tidak dapat diubah setelah diinisialisasi.

  @override
  String toString() {
    return '$name, $email';
  }
  // Override metode toString() untuk memberikan representasi string
  // yang lebih informatif dari objek.
  // Mengembalikan string yang berisi nama dan email pengguna.

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is User && other.name == name && other.email == email;
  }
  // Override operator == untuk membandingkan dua objek User.
  // Dua objek dianggap sama jika runtimeType mereka sama dan atribut name
  // serta email memiliki nilai yang sama.

  @override
  int get hashCode => Object.hash(email, name);
  // Override getter hashCode untuk menghasilkan nilai hash unik
  // berdasarkan email dan name.
  //
  // Penting untuk memastikan bahwa objek yang sama memiliki nilai hashCode yang sama.
}

class AutocompleteBasicUserExample extends StatelessWidget {
  const AutocompleteBasicUserExample({super.key});

  static const List<User> _userOptions = <User>[
    // Daftar opsi pengguna yang tersedia untuk widget Autocomplete.
    // Bersifat static dan constant karena tidak akan berubah selama aplikasi berjalan.
    User(name: 'Alice', email: 'alice@example.com'),
    User(name: 'Bob', email: 'bob@example.com'),
    User(name: 'Charlie', email: 'charlie123@gmail.com'),
  ];

  static String _displayStringForOption(User option) => option.name;
  // Fungsi untuk menentukan string yang akan ditampilkan di UI dari setiap opsi.
  // Dalam kasus ini, hanya atribut name dari objek User yang digunakan.

  @override
  Widget build(BuildContext context) {
    return Autocomplete<User>(
      // Menggunakan widget Autocomplete yang mendukung tipe generik user
      displayStringForOption: _displayStringForOption,
      // Menentukan bagaimana setiap opsi User akan ditampilkan di Autocomplete.
      // Dalam hal ini, hanya menampilkan nama pengguna (name).
      optionsBuilder: (TextEditingValue textEditingValue) {
        // Fungsi untuk membangun daftar opsi berdasarkan input pengguna.
        if (textEditingValue.text == '') {
          // jika fungsi kosong, kembalikan iterable kosong
          return const Iterable<User>.empty();
        }
        return _userOptions.where((User option) {
          // Menyaring opsi berdasarkan kecocokan dengan input pengguna.
          // Menggunakan metode toString() dari objek User untuk pencarian.
          return option
              .toString()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (User selection) {
        // callback yang dipanggil ketika pengguna memilih salah satu opsi
        debugPrint('You just selected ${_displayStringForOption(selection)}');
      },
    );
  }
}
