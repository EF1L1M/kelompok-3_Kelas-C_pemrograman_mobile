// Studi Kasus 1 - Student Grade Tracker

// Ketentuan (bisa diubah)
const double nilaiMinimalLulus = 60;
const int kehadiranMinimal = 75;

// Function: menentukan grade dari nilai
String tentukanGrade(double nilai) {
  if (nilai >= 85) {
    return 'A';
  } else if (nilai >= 75) {
    return 'B';
  } else if (nilai >= 65) {
    return 'C';
  } else if (nilai >= 50) {
    return 'D';
  } else {
    return 'E';
  }
}

// Function: menentukan status kelulusan
String tentukanStatus(double nilai, int kehadiran) {
  if (nilai >= nilaiMinimalLulus && kehadiran >= kehadiranMinimal) {
    return 'LULUS';
  } else if (nilai < nilaiMinimalLulus && kehadiran < kehadiranMinimal) {
    return 'TIDAK LULUS (nilai & kehadiran kurang)';
  } else if (nilai < nilaiMinimalLulus) {
    return 'TIDAK LULUS (nilai kurang)';
  } else {
    return 'TIDAK LULUS (kehadiran kurang)';
  }
}

void main() {
  // Data mahasiswa: nama, nilai, kehadiran (%)
  final List<Map<String, dynamic>> daftarMahasiswa = [
    {'nama': 'Andi', 'nilai': 88.5, 'kehadiran': 95},
    {'nama': 'Budi', 'nilai': 72.0, 'kehadiran': 80},
    {'nama': 'Citra', 'nilai': 55.0, 'kehadiran': 90},
    {'nama': 'Dewi', 'nilai': 91.0, 'kehadiran': 60},
    {'nama': 'Eko', 'nilai': 45.5, 'kehadiran': 50},
  ];

  int jumlahLulus = 0;
  int jumlahTidakLulus = 0;
  double totalNilai = 0;

  print('=========== STUDENT GRADE TRACKER ===========');

  for (int i = 0; i < daftarMahasiswa.length; i++) {
    final data = daftarMahasiswa[i];

    String nama = data['nama'];
    double nilai = (data['nilai'] as num).toDouble();
    int kehadiran = data['kehadiran'];

    String grade = tentukanGrade(nilai);
    String status = tentukanStatus(nilai, kehadiran);

    totalNilai += nilai;
    if (status == 'LULUS') {
      jumlahLulus++;
    } else {
      jumlahTidakLulus++;
    }

    print('${i + 1}. $nama');
    print('   Nilai     : ${nilai.toStringAsFixed(1)}');
    print('   Kehadiran : $kehadiran%');
    print('   Grade     : $grade');
    print('   Status    : $status');
    print('-----------------------------------------------');
  }

  double rataRata = totalNilai / daftarMahasiswa.length;

  print('RINGKASAN');
  print('Jumlah mahasiswa : ${daftarMahasiswa.length}');
  print('Lulus            : $jumlahLulus');
  print('Tidak lulus      : $jumlahTidakLulus');
  print('Rata-rata nilai  : ${rataRata.toStringAsFixed(2)}');
}
