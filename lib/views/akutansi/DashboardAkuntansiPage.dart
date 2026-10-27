import 'package:admin_fungi/views/akutansi/LabaRugiPage.dart';
import 'package:admin_fungi/views/akutansi/arus_kas_page.dart';
import 'package:admin_fungi/views/akutansi/neraca_page.dart';
// import 'package:admin_fungi/views/akutansi/pemasukan_lain_page.dart';
// import 'package:admin_fungi/views/akutansi/pengeluaran_lain_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/AkuntansiController.dart';
import 'laporan_harian_page.dart'; // Import halaman laporan harian

class DashboardAkuntansiPage extends StatelessWidget {
  DashboardAkuntansiPage({super.key});

  final AkuntansiController controller = Get.put(AkuntansiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Pusat Akuntansi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // TOMBOL RELOAD HALAMAN
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            tooltip: "Muat Ulang Data",
            onPressed: () {
              controller.fetchFinancialData();
              Get.snackbar(
                "Sukses",
                "Data berhasil diperbarui",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Jenis Laporan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  // _buildMenuCard(
                  //   title: "Pemasukan Lain",
                  //   subtitle: "Input manual",
                  //   icon: Icons.add_chart,
                  //   color: Colors.orange,
                  //   onTap: () => Get.to(() => PemasukanLainPage()),
                  // ),
                  // _buildMenuCard(
                  //   title: "Pengeluaran",
                  //   subtitle: "Biaya operasional",
                  //   icon: Icons.shopping_cart_checkout,
                  //   color: Colors.red,
                  //   // 👇 UBAH BAGIAN INI 👇
                  //   onTap: () => Get.to(() => PengeluaranLainPage()),
                  // ),
                  _buildMenuCard(
                    title: "Laporan Harian",
                    subtitle: "Log transaksi & nota",
                    icon: Icons.assignment,
                    color: Colors.blue,
                    onTap: () => Get.to(() => LaporanHarianPage()),
                  ),
                  _buildMenuCard(
                    title: "Laba Rugi",
                    subtitle: "Perhitungan profit",
                    icon: Icons.analytics,
                    color: Colors.green,
                    onTap: () => Get.to(() => LabaRugiPage()),
                  ),
                  _buildMenuCard(
                    title: "Arus Kas",
                    subtitle: "Aliran uang tunai",
                    icon: Icons.swap_horiz, // Ikon aliran
                    color: Colors.purple,
                    onTap: () => Get.to(() => ArusKasPage()),
                  ),

                  _buildMenuCard(
                    title: "Neraca",
                    subtitle: "Posisi keuangan",
                    icon: Icons.account_balance, // Ikon neraca
                    color: Colors.purple,
                    onTap: () => Get.to(() => NeracaPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
