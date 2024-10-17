import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<Info> _infoList = [];

  @override
  void initState() {
    super.initState();
    fetchInfos();
  }

  // Fungsi untuk mengambil data dari API
  Future<void> fetchInfos() async {
    final response = await http.get(Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/info.php'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'] as List;
      setState(() {
        _infoList = data.map((info) => Info.fromJson(info)).toList();
      });
    } else {
      throw Exception('Failed to load infos');
    }
  }

  // Fungsi untuk menambah data
  Future<void> addInfo(Info info) async {
    final response = await http.post(
      Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/info.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'judul_info': info.judulInfo,
        'isi_info': info.isiInfo,
        'tgl_post_info': info.tglPostInfo,
        'status_info': info.statusInfo,
        'kd_petugas': info.kdPetugas,
      }),
    );

    if (response.statusCode == 200) {
      fetchInfos();
    } else {
      throw Exception('Failed to add info');
    }
  }

  // Fungsi untuk mengedit data
  Future<void> editInfo(Info info) async {
    final response = await http.put(
      Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/info.php?kd_info=${info.kdInfo}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'judul_info': info.judulInfo,
        'isi_info': info.isiInfo,
        'tgl_post_info': info.tglPostInfo,
        'status_info': info.statusInfo,
        'kd_petugas': info.kdPetugas,
      }),
    );

    if (response.statusCode == 200) {
      fetchInfos();
    } else {
      throw Exception('Failed to edit info');
    }
  }

  // Fungsi untuk menghapus data
  Future<void> deleteInfo(String kdInfo) async {
    final response = await http.delete(
      Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/info.php?kd_info=$kdInfo'),
    );

    if (response.statusCode == 200) {
      fetchInfos();
    } else {
      throw Exception('Failed to delete info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Info'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddDialog();
            },
          ),
        ],
      ),
      body: _infoList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _infoList.length,
                itemBuilder: (context, index) {
                  final info = _infoList[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(Icons.info, color: Colors.blueAccent),
                      title: Text(
                        info.judulInfo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(info.isiInfo),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              _showEditDialog(info);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteInfo(info.kdInfo);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Dialog untuk menambah info
  void _showAddDialog() {
    TextEditingController judulController = TextEditingController();
    TextEditingController isiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(labelText: 'Info Title'),
              ),
              TextField(
                controller: isiController,
                decoration: const InputDecoration(labelText: 'Info Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newInfo = Info(
                  kdInfo: '',
                  judulInfo: judulController.text,
                  isiInfo: isiController.text,
                  tglPostInfo: DateTime.now().toIso8601String().split('T')[0],
                  statusInfo: '1',
                  kdPetugas: '1',
                );
                addInfo(newInfo);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Dialog untuk mengedit info
  void _showEditDialog(Info info) {
    TextEditingController judulController = TextEditingController(text: info.judulInfo);
    TextEditingController isiController = TextEditingController(text: info.isiInfo);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(labelText: 'Info Title'),
              ),
              TextField(
                controller: isiController,
                decoration: const InputDecoration(labelText: 'Info Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedInfo = Info(
                  kdInfo: info.kdInfo,
                  judulInfo: judulController.text,
                  isiInfo: isiController.text,
                  tglPostInfo: info.tglPostInfo,
                  statusInfo: info.statusInfo,
                  kdPetugas: info.kdPetugas,
                );
                editInfo(updatedInfo);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// Model Info
class Info {
  String kdInfo;
  String judulInfo;
  String isiInfo;
  String tglPostInfo;
  String statusInfo;
  String kdPetugas;

  Info({
    required this.kdInfo,
    required this.judulInfo,
    required this.isiInfo,
    required this.tglPostInfo,
    required this.statusInfo,
    required this.kdPetugas,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      kdInfo: json['kd_info'],
      judulInfo: json['judul_info'],
      isiInfo: json['isi_info'],
      tglPostInfo: json['tgl_post_info'],
      statusInfo: json['status_info'],
      kdPetugas: json['kd_petugas'],
    );
  }
}
