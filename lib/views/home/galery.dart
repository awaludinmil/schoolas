import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Tambahkan import ini untuk menggunakan File

class GaleryScreen extends StatefulWidget {
  @override
  _GaleryScreenState createState() => _GaleryScreenState();
}

class _GaleryScreenState extends State<GaleryScreen> {
  List<dynamic> galeryData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGaleryData();
  }

  Future<void> fetchGaleryData() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/galery.php'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        galeryData = jsonData['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data galeri')),
      );
    }
  }

  void showGaleryForm({Map<String, dynamic>? item}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GaleryFormDialog(
          item: item,
          onSave: (newItem) {
            if (item == null) {
              addGaleryItem(newItem);
            } else {
              editGaleryItem(newItem);
            }
          },
        );
      },
    );
  }

  Future<void> addGaleryItem(Map<String, dynamic> newItem) async {
    final url = Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/galery.php');
    var request = http.MultipartRequest('POST', url);

    request.fields['judul_galery'] = newItem['judul_galery'];
    request.fields['isi_galery'] = newItem['isi_galery'];
    request.fields['tgl_post_galery'] = newItem['tgl_post_galery'];
    request.fields['status_galery'] = newItem['status_galery'];
    request.fields['kd_petugas'] = newItem['kd_petugas'];

    if (newItem['foto_galery'] != null) {
      request.files.add(await http.MultipartFile.fromPath('foto_galery', newItem['foto_galery'].path));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil menambahkan item galeri')),
      );
      fetchGaleryData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan item galeri')),
      );
    }
  }

  Future<void> editGaleryItem(Map<String, dynamic> updatedItem) async {
    final url = Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/galery.php?kd_galery=${updatedItem['kd_galery']}');
    
    Map<String, dynamic> jsonData = {
      'kd_galery': updatedItem['kd_galery'],
      'judul_galery': updatedItem['judul_galery'],
      'isi_galery': updatedItem['isi_galery'],
      'tgl_post_galery': updatedItem['tgl_post_galery'],
      'status_galery': updatedItem['status_galery'],
      'kd_petugas': updatedItem['kd_petugas'],
    };
    
    if (updatedItem['foto_galery'] != null) {
      List<int> imageBytes = await updatedItem['foto_galery'].readAsBytes();
      String base64Image = base64Encode(imageBytes);
      jsonData['foto_galery'] = 'data:image/png;base64,$base64Image';
    }

    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['status'] == 'sukses') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Berhasil memperbarui item galeri')),
          );
          fetchGaleryData();
        } else {
          throw Exception(responseBody['message'] ?? 'Gagal memperbarui galeri');
        }
      } else {
        throw Exception('Gagal memperbarui galeri: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui item galeri: ${e.toString()}')),
      );
    }
  }

  Future<void> deleteGaleryItem(String kdGalery) async {
    final url = Uri.parse('https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/galery.php?kd_galery=$kdGalery');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'sukses') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil menghapus item galeri')),
        );
        fetchGaleryData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus item galeri: ${jsonResponse['message'] ?? 'Terjadi kesalahan'}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus item galeri: Kesalahan jaringan')),
      );
    }
  }

  Future<void> _refreshGaleryData() async {
    await fetchGaleryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeri'),
        backgroundColor: Colors.blue, // Warna sederhana untuk AppBar
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGaleryData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: galeryData.length,
                itemBuilder: (context, index) {
                  final item = galeryData[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Spacing sederhana
                    child: ListTile(
                      leading: Image.network(
                        'https://praktikum-cpanel-unbin.com/kelompok_ojan/api_flutter/uploads/${item['foto_galery']}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      ),
                      title: Text(item['judul_galery']),
                      subtitle: Text(item['isi_galery']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => showGaleryForm(item: item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Konfirmasi Hapus'),
                                  content: Text('Apakah Anda yakin ingin menghapus item ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        deleteGaleryItem(item['kd_galery']);
                                      },
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showGaleryForm(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // Warna sederhana untuk FAB
      ),
    );
  }
}

class GaleryFormDialog extends StatefulWidget {
  final Map<String, dynamic>? item;
  final Function(Map<String, dynamic>) onSave;

  const GaleryFormDialog({Key? key, this.item, required this.onSave}) : super(key: key);

  @override
  _GaleryFormDialogState createState() => _GaleryFormDialogState();
}

class _GaleryFormDialogState extends State<GaleryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _isiController;
  late TextEditingController _tglPostController;
  late TextEditingController _statusController;
  late TextEditingController _kdPetugasController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.item?['judul_galery'] ?? '');
    _isiController = TextEditingController(text: widget.item?['isi_galery'] ?? '');
    _tglPostController = TextEditingController(text: widget.item?['tgl_post_galery'] ?? '');
    _statusController = TextEditingController(text: widget.item?['status_galery'] ?? '');
    _kdPetugasController = TextEditingController(text: widget.item?['kd_petugas'] ?? '');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _tglPostController.dispose();
    _statusController.dispose();
    _kdPetugasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Tambah Galeri' : 'Edit Galeri'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(labelText: 'Judul Galeri'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _isiController,
                decoration: InputDecoration(labelText: 'Isi Galeri'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Isi harus diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tglPostController,
                decoration: InputDecoration(labelText: 'Tanggal Post'),
              ),
              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(labelText: 'Status'),
              ),
              TextFormField(
                controller: _kdPetugasController,
                decoration: InputDecoration(labelText: 'Kode Petugas'),
              ),
              SizedBox(height: 20),
              _selectedImage == null
                  ? Text('Tidak ada gambar yang dipilih')
                  : Image.file(
                      _selectedImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Pilih Gambar'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'judul_galery': _judulController.text,
                'isi_galery': _isiController.text,
                'tgl_post_galery': _tglPostController.text,
                'status_galery': _statusController.text,
                'kd_petugas': _kdPetugasController.text,
                'foto_galery': _selectedImage,
                'kd_galery': widget.item?['kd_galery'],
              });
              Navigator.of(context).pop();
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
