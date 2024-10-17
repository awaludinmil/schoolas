<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Content-Type: application/json");

// Konfigurasi Database
define('DB_HOST', 'localhost');
define('DB_USER', 'praktikum_Ojan');
define('DB_PASS', 'daytt123*363#');
define('DB_NAME', 'praktikum_ti_2022_KLPK_Ojan');

$koneksi = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($koneksi->connect_error) {
    die(json_encode(["status" => "error", "pesan" => "Koneksi gagal: " . $koneksi->connect_error]));
}

$metode = $_SERVER['REQUEST_METHOD'];

switch ($metode) {
    case 'GET':
        if (isset($_GET['kd_info'])) {
            $kd_info = $koneksi->real_escape_string($_GET['kd_info']);
            $sql = "SELECT * FROM informasi WHERE kd_info = '$kd_info'";
            $result = $koneksi->query($sql);

            if ($result && $result->num_rows > 0) {
                // Data ditemukan
                $data = $result->fetch_assoc();
                echo json_encode([
                    "status" => "sukses",
                    "message" => "Data ditemukan",
                    "data" => $data
                ]);
            } else {
                // Data tidak ditemukan
                echo json_encode([
                    "status" => "error",
                    "message" => "Info dengan kd_info $kd_info tidak ditemukan"
                ]);
            }
        } else {
            // Ambil semua data
            $sql = "SELECT * FROM info";
            $result = $koneksi->query($sql);
            $data = $result->fetch_all(MYSQLI_ASSOC);
            echo json_encode([
                "status" => "sukses",
                "message" => "Data info",
                "data" => $data
            ]);
        }
        break;

    case 'POST':
        $input = json_decode(file_get_contents('php://input'), true);
        $judul_info = $koneksi->real_escape_string($input['judul_info']);
        $isi_info = $koneksi->real_escape_string($input['isi_info']);
        $tgl_post_info = $koneksi->real_escape_string($input['tgl_post_info']);
        $status_info = $koneksi->real_escape_string($input['status_info']);
        $kd_petugas = $koneksi->real_escape_string($input['kd_petugas']);

        $query = "INSERT INTO info (judul_info, isi_info, tgl_post_info, status_info, kd_petugas) 
                VALUES ('$judul_info', '$isi_info', '$tgl_post_info', '$status_info', '$kd_petugas')";
        
        if ($koneksi->query($query)) {
            echo json_encode(["status" => "sukses", "pesan" => "Data berhasil ditambahkan"]);
        } else {
            echo json_encode(["status" => "error", "pesan" => "Gagal menambahkan data: " . $koneksi->error]);
        }
        break;

    case 'PUT':
        if (isset($_GET['kd_info'])) {
            $kd_info = $koneksi->real_escape_string($_GET['kd_info']);
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (isset($input['judul_info'], $input['isi_info'], $input['tgl_post_info'], $input['status_info'], $input['kd_petugas'])) {
                $judul_info = $koneksi->real_escape_string($input['judul_info']);
                $isi_info = $koneksi->real_escape_string($input['isi_info']);
                $tgl_post_info = $koneksi->real_escape_string($input['tgl_post_info']);
                $status_info = $koneksi->real_escape_string($input['status_info']);
                $kd_petugas = $koneksi->real_escape_string($input['kd_petugas']);

                $query = "UPDATE info SET 
                            judul_info = '$judul_info', 
                            isi_info = '$isi_info', 
                            tgl_post_info = '$tgl_post_info', 
                            status_info = '$status_info', 
                            kd_petugas = '$kd_petugas' 
                        WHERE kd_info = '$kd_info'";
                
                if ($koneksi->query($query)) {
                    echo json_encode(["status" => "sukses", "pesan" => "Data berhasil diperbarui"]);
                } else {
                    echo json_encode(["status" => "error", "pesan" => "Gagal memperbarui data: " . $koneksi->error]);
                }
            } else {
                echo json_encode(["status" => "error", "message" => "Input tidak lengkap"]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "kd_info tidak ditemukan"]);
        }
        break;

    case 'DELETE':
        if (isset($_GET['kd_info'])) {
            $kd_info = $koneksi->real_escape_string($_GET['kd_info']);
            $query = "DELETE FROM info WHERE kd_info = '$kd_info'";

            if ($koneksi->query($query)) {
                echo json_encode(["status" => "sukses", "pesan" => "Data berhasil dihapus"]);
            } else {
                echo json_encode(["status" => "error", "pesan" => "Gagal menghapus data: " . $koneksi->error]);
            }
        } else {
            echo json_encode(["status" => "error", "pesan" => "kd_info tidak ditemukan"]);
        }
        break;

    default:
        echo json_encode(["status" => "error", "pesan" => "Metode tidak valid"]);
        break;
}

$koneksi->close();
?>
