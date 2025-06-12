#### Completer class

Di Flutter (atau Dart secara umum), Completer adalah class yang digunakan untuk mengontrol sebuah Future secara manual. Ini sangat berguna ketika kita ingin menyelesaikan (menyatakan berhasil atau gagal) suatu Future dari luar fungsi async.

- **🔍 Pengertian Singkat**
    Completer adalah objek yang kita buat untuk menghasilkan dan mengendalikan sebuah Future secara eksplisit. Biasanya kita akan:

    - Membuat Completer

    - Mengakses completer.future → diberikan ke suatu bagian kode lain

    - Memanggil completer.complete(value) atau completer.completeError(error) ketika proses selesai

- **🧠 Kenapa Perlu Completer?**
    - Kadang kita tidak bisa menggunakan async/await secara langsung, misalnya:

    - kita menunggu callback dari SDK eksternal

    - kita sedang membungkus API callback lama menjadi API Future

    - kita membuat logika kompleks seperti `race`, timeout manual, event listener, dll

- **✅ Contoh Penggunaan Sederhana**
    ```dart

    Future<String> fetchDataManually() {
        final completer = Completer<String>();
        // Simulasi async operation manual
        Timer(Duration(seconds: 2), () {
            completer.complete("Data berhasil diambil");
        });
        return completer.future;
    }

    void main() {
        fetchDataManually().then((value) {
            print(value); // Output: Data berhasil diambil (setelah 2 detik)
        });
    }
    ```
- **📌 Properti & Method Penting**
    |Properti/Method	|Keterangan|
    |:------------------|:---------|
    |`completer.future`	|Mengembalikan `Future` yang akan diselesaikan nanti|
    |`completer.complete(value)`	|Menyelesaikan `Future` dengan nilai|
    |`completer.completeError(error)`	|Menyelesaikan `Future` dengan error|
    |`completer.isCompleted`	|Cek apakah future sudah diselesaikan|

- **⚠️ Penting**
    - complete hanya bisa dipanggil sekali. Kalau dua kali, akan melempar error.

    - Jangan lupakan completeError untuk kondisi error.

    - Sangat berguna saat menjembatani API berbasis callback ke Future.

- **🔁 Contoh dalam Konversi Callback ke Future**
    Misalnya kita punya fungsi callback seperti ini:

    ```dart
    void getUserFromAPI(void Function(String user) onSuccess) {
    // Pura-pura ambil data
    Timer(Duration(seconds: 1), () {
        onSuccess("User123");
    });
    }
    ```
    Mau ubah jadi fungsi `Future`, kita bisa pakai `Completer`:

    ```dart
    Future<String> getUserFuture() {
    final completer = Completer<String>();

    getUserFromAPI((user) {
        completer.complete(user);
    });

    return completer.future;
    }
    ```


- **Menggunakan semua properti dan method Completer:**

    - **`.future`**

    - **`.complete(value)`**

    - **`.completeError(error)`**

    - **`.isCompleted`**

- **Menangani logika async yang dipicu oleh interaksi UI (misalnya tombol)**

- **Menunjukkan bagaimana menangani error dan keberhasilan**

- **🔧 Kasus: Dialog Konfirmasi Asinkron dengan Timeout dan Error
    Kita akan buat:**

    - Sebuah tombol yang membuka dialog

    - Dialog ini punya tombol "Ya" dan "Tidak"

    - Jika pengguna tidak menjawab dalam 5 detik, akan timeout

    - Kita gunakan Completer untuk mengontrol hasil dialog

#### 🧱 Kode Lengkap Flutter
```dart
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MyPage()));
}

class MyPage extends StatelessWidget {
  Future<String> showConfirmationDialog(BuildContext context) {
    final completer = Completer<String>();

    // ⏰ Timeout dalam 5 detik
    Timer(Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.completeError("Timeout: Tidak ada respon pengguna.");
        Navigator.pop(context);
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah anda yakin?"),
          actions: [
            TextButton(
              onPressed: () {
                if (!completer.isCompleted) {
                  completer.complete("Ya");
                  Navigator.pop(context);
                }
              },
              child: Text("Ya"),
            ),
            TextButton(
              onPressed: () {
                if (!completer.isCompleted) {
                  completer.complete("Tidak");
                  Navigator.pop(context);
                }
              },
              child: Text("Tidak"),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demo Completer")),
      body: Center(
        child: ElevatedButton(
          child: Text("Tampilkan Konfirmasi"),
          onPressed: () async {
            try {
              String result = await showConfirmationDialog(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("anda memilih: $result")),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Gagal: $e")),
              );
            }
          },
        ),
      ),
    );
  }
}
```
- **🔍 Penjelasan**
    |Bagian	|Penjelasan|
    |:------|:---------|
    |`Completer<String>`	|Membuat objek untuk mengontrol Future|
    |`completer.future`	|Dikirim keluar untuk `await` atau `.then()`|
    |`completer.complete("Ya")` / `"Tidak"`	|Dipanggil saat tombol ditekan|
    |`completer.completeError(...)`	|Dipanggil kalau user tidak merespon|
    |`completer.isCompleted`	|Dicek sebelum `complete()` agar tidak error|

- **⚠️ Tips**
    - `isCompleted` wajib dicek sebelum `complete()` untuk mencegah error "Future already completed".

    - `completeError` cocok untuk error terkontrol (timeout, cancel, dsb).

    - Ini sering dipakai untuk dialog konfirmasi, animasi kustom, event listener, dsb.