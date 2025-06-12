import 'dart:async';

import 'package:flutter/material.dart';

class CompleterSample extends StatelessWidget {
  const CompleterSample({super.key});

  Future<String> showConfirmationDialog(BuildContext context) {
    final completer = Completer<String>();

    Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.completeError('Timeout: tidak ada respon pengguna');
        Navigator.pop(context);
      }
    });
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah anda yakin?'),
            actions: [
              TextButton(
                onPressed: () {
                  if (!completer.isCompleted) {
                    completer.complete('Ya');
                    Navigator.pop(context);
                  }
                },
                child: const Text('Ya'),
              ),
              TextButton(
                onPressed: () {
                  if (!completer.isCompleted) {
                    completer.complete('Tidak');
                    Navigator.pop(context);
                  }
                },
                child: const Text('Tidak'),
              ),
            ],
          );
        });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Complter'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              try {
                String result = await showConfirmationDialog(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Anda memilih: $result')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            child: const Text('Tampilkan Konfirmasi')),
      ),
    );
  }
}
