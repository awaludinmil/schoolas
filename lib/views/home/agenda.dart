import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  List<Agenda> _agendaList = [];

  @override
  void initState() {
    super.initState();
    fetchAgendas();
  }

  // Fungsi untuk mengambil data dari API
  Future<void> fetchAgendas() async {
    final response = await http.get(Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/agenda.php'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'] as List;
      setState(() {
        _agendaList = data.map((agenda) => Agenda.fromJson(agenda)).toList();
      });
    } else {
      throw Exception('Failed to load agendas');
    }
  }

  // Fungsi untuk menambah data
  Future<void> addAgenda(Agenda agenda) async {
    final response = await http.post(
      Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/agenda.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'judul_agenda': agenda.judulAgenda,
        'isi_agenda': agenda.isiAgenda,
        'tgl_agenda': agenda.tglAgenda,
        'tgl_post_agenda': agenda.tglPostAgenda,
        'status_agenda': agenda.statusAgenda,
        'kd_petugas': agenda.kdPetugas,
      }),
    );

    if (response.statusCode == 200) {
      fetchAgendas();
    } else {
      throw Exception('Failed to add agenda');
    }
  }

  // Fungsi untuk mengedit data
  Future<void> editAgenda(Agenda agenda) async {
    final response = await http.put(
      Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/agenda.php?kd_agenda=${agenda.kdAgenda}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'judul_agenda': agenda.judulAgenda,
        'isi_agenda': agenda.isiAgenda,
        'tgl_agenda': agenda.tglAgenda,
        'tgl_post_agenda': agenda.tglPostAgenda,
        'status_agenda': agenda.statusAgenda,
        'kd_petugas': agenda.kdPetugas,
      }),
    );

    if (response.statusCode == 200) {
      fetchAgendas();
    } else {
      throw Exception('Failed to edit agenda');
    }
  }

  // Fungsi untuk menghapus data
  Future<void> deleteAgenda(String kdAgenda) async {
    final response = await http.delete(
      Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/agenda.php?kd_agenda=$kdAgenda'),
    );

    if (response.statusCode == 200) {
      fetchAgendas();
    } else {
      throw Exception('Failed to delete agenda');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Sekolah'),
        backgroundColor: Color.fromARGB(255, 13, 64, 122),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAgendas,
          ),
        ],
      ),
      body: _agendaList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _agendaList.length,
                itemBuilder: (context, index) {
                  final agenda = _agendaList[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.event_note,
                        color: Colors.teal[300],
                        size: 40,
                      ),
                      title: Text(
                        agenda.judulAgenda,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        agenda.isiAgenda,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () {
                              _showEditDialog(agenda);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              deleteAgenda(agenda.kdAgenda);
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

  // Dialog untuk menambah agenda
  void _showAddDialog() {
    TextEditingController judulController = TextEditingController();
    TextEditingController isiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Agenda Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(labelText: 'Judul Agenda'),
              ),
              TextField(
                controller: isiController,
                decoration: const InputDecoration(labelText: 'Isi Agenda'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAgenda = Agenda(
                  kdAgenda: '',
                  judulAgenda: judulController.text,
                  isiAgenda: isiController.text,
                  tglAgenda: DateTime.now().toIso8601String().split('T')[0],
                  tglPostAgenda: DateTime.now().toIso8601String().split('T')[0],
                  statusAgenda: '1',
                  kdPetugas: '1',
                );
                addAgenda(newAgenda);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[400],
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Dialog untuk mengedit agenda
  void _showEditDialog(Agenda agenda) {
    TextEditingController judulController = TextEditingController(text: agenda.judulAgenda);
    TextEditingController isiController = TextEditingController(text: agenda.isiAgenda);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Agenda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(labelText: 'Judul Agenda'),
              ),
              TextField(
                controller: isiController,
                decoration: const InputDecoration(labelText: 'Isi Agenda'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedAgenda = Agenda(
                  kdAgenda: agenda.kdAgenda,
                  judulAgenda: judulController.text,
                  isiAgenda: isiController.text,
                  tglAgenda: agenda.tglAgenda,
                  tglPostAgenda: agenda.tglPostAgenda,
                  statusAgenda: agenda.statusAgenda,
                  kdPetugas: agenda.kdPetugas,
                );
                editAgenda(updatedAgenda);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[400],
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

// Model Agenda
class Agenda {
  String kdAgenda;
  String judulAgenda;
  String isiAgenda;
  String tglAgenda;
  String tglPostAgenda;
  String statusAgenda;
  String kdPetugas;

  Agenda({
    required this.kdAgenda,
    required this.judulAgenda,
    required this.isiAgenda,
    required this.tglAgenda,
    required this.tglPostAgenda,
    required this.statusAgenda,
    required this.kdPetugas,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      kdAgenda: json['kd_agenda'],
      judulAgenda: json['judul_agenda'],
      isiAgenda: json['isi_agenda'],
      tglAgenda: json['tgl_agenda'],
      tglPostAgenda: json['tgl_post_agenda'],
      statusAgenda: json['status_agenda'],
      kdPetugas: json['kd_petugas'],
    );
  }
}
