// Studi Kasus 2 - Simple Shopping Cart

// Function: format angka menjadi Rupiah, contoh 1500000 -> Rp1.500.000
String formatRupiah(num angka) {
  String s = angka.round().toString();
  String hasil = '';
  int hitung = 0;

  for (int i = s.length - 1; i >= 0; i--) {
    hasil = s[i] + hasil;
    hitung++;
    if (hitung % 3 == 0 && i != 0) {
      hasil = '.$hasil';
    }
  }
  return 'Rp$hasil';
}

// Function: hitung subtotal satu produk
int hitungSubtotalItem(int harga, int jumlah) {
  return harga * jumlah;
}

// Function: tentukan persentase diskon berdasarkan total belanja
// >= Rp500.000 -> 10%, >= Rp250.000 -> 5%, selain itu 0%
int tentukanPersenDiskon(int subtotal) {
  if (subtotal >= 500000) {
    return 10;
  } else if (subtotal >= 250000) {
    return 5;
  } else {
    return 0;
  }
}

void main() {
  // Data produk: nama, harga, jumlah pembelian
  final List<Map<String, dynamic>> keranjang = [
    {'nama': 'Mouse Wireless', 'harga': 150000, 'jumlah': 1},
    {'nama': 'Keyboard Mekanik', 'harga': 350000, 'jumlah': 1},
    {'nama': 'Kabel USB-C', 'harga': 35000, 'jumlah': 3},
    {'nama': 'Mousepad', 'harga': 50000, 'jumlah': 2},
  ];

  int subtotal = 0;

  print('=========== SIMPLE SHOPPING CART ===========');

  for (int i = 0; i < keranjang.length; i++) {
    String nama = keranjang[i]['nama'];
    int harga = keranjang[i]['harga'];
    int jumlah = keranjang[i]['jumlah'];

    int subtotalItem = hitungSubtotalItem(harga, jumlah);
    subtotal += subtotalItem;

    print('${i + 1}. $nama');
    print('   ${formatRupiah(harga)} x $jumlah = ${formatRupiah(subtotalItem)}');
  }

  int persenDiskon = tentukanPersenDiskon(subtotal);
  int nominalDiskon = subtotal * persenDiskon ~/ 100;
  int totalBayar = subtotal - nominalDiskon;

  print('---------------------------------------------');
  print('Subtotal       : ${formatRupiah(subtotal)}');

  if (persenDiskon > 0) {
    print('Diskon ($persenDiskon%)    : -${formatRupiah(nominalDiskon)}');
  } else {
    print('Diskon         : Tidak ada diskon');
  }

  print('TOTAL BAYAR    : ${formatRupiah(totalBayar)}');
  print('=============================================');
}
