import 'package:admin_fungi/controllers/AkuntansiController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ArusKasPage extends StatelessWidget {
  ArusKasPage({super.key});

  final AkuntansiController controller = Get.find<AkuntansiController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Laporan Arus Kas",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        // 👇 TAMBAHKAN TOMBOL FILTER DI SINI 👇
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.blue),
            tooltip: "Filter Waktu",
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER LAPORAN
              const Text(
                "PT FUNGI CAFE GROUP",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(
                "LAPORAN ARUS KAS",
                style: TextStyle(fontSize: 14, letterSpacing: 1.5),
              ),
              Text(
                "Per ${controller.periodLabel.value}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),

              // TABEL ARUS KAS
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38, width: 0.5),
                ),
                child: Column(
                  children: [
                    _buildSectionHeader("Arus Kas Aktivitas Operasional"),
                    _buildRow(
                      "Laba/Rugi Produk",
                      controller.labaBersih.value,
                      isBold: true,
                    ),
                    _buildRow(
                      "Kenaikan / Penurunan Piutang",
                      controller.kenaikanPenurunanPiutang.value,
                    ),
                    _buildRow(
                      "Kenaikan / Penurunan Stok Barang",
                      controller.kenaikanPenurunanPersediaan.value,
                    ),

                    _buildSubtotalRow(
                      "Total Kas Bersih Operasional",
                      controller.kasBersihOperasional.value,
                    ),

                    const Divider(
                      height: 0,
                      thickness: 0.5,
                      color: Colors.black38,
                    ),

                    // Bagian Saldo Akhir
                    _buildRow(
                      "Kenaikan/Penurunan Kas Periode Ini",
                      controller.kenaikanPenurunanKas.value,
                      isBold: true,
                    ),
                    _buildRow("Saldo Awal Kas", controller.saldoAwalKas.value),
                    _buildFinalRow(
                      "Saldo Kas Akhir Periode",
                      (controller.saldoAwalKas.value +
                          controller.kenaikanPenurunanKas.value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // 👇 FUNGSI UNTUK MEMUNCULKAN MENU FILTER 👇
  void _showFilterOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Filter Periode Laporan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Opsi 1: Bulan Ini
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text("Bulan Ini"),
              subtitle: const Text(
                "Data dari tanggal 1 sampai akhir bulan ini",
              ),
              onTap: () {
                controller.setMonth(DateTime.now());
                Get.back();
              },
            ),
            const Divider(),

            // Opsi 2: Rentang Tanggal
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.green),
              title: const Text("Pilih Rentang Tanggal Kustom"),
              subtitle: const Text("Tentukan tanggal awal dan akhir sendiri"),
              onTap: () async {
                Get.back(); // Tutup menu bawah dulu

                // 🌟 LOGIKA RESET TANGGAL AMAN SEBELUM KALENDER DIBUKA 🌟
                // Jika tanggal saat ini di Controller adalah tahun 2000 atau 2100 (Semua Waktu),
                // maka kita reset titik awal kalender ke hari ini agar tidak error & mudah dipilih.
                DateTime now = DateTime.now();
                DateTime safeStart = controller.startDate.value.year < 2010
                    ? now
                    : controller.startDate.value;
                DateTime safeEnd = controller.endDate.value.year > 2090
                    ? now
                    : controller.endDate.value;

                // Buka kalender bawaan Flutter
                DateTimeRange? range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100, 12, 31),
                  initialDateRange: DateTimeRange(
                    start: safeStart, // Menggunakan tanggal yang sudah di-reset
                    end: safeEnd, // Menggunakan tanggal yang sudah di-reset
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.blue,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                // Jika user jadi memilih tanggal (tidak batal)
                if (range != null) {
                  controller.setDateRange(range.start, range.end);
                }
              },
            ),
            const Divider(),

            // Opsi 3: Semua Waktu
            ListTile(
              leading: const Icon(Icons.all_inclusive, color: Colors.purple),
              title: const Text("Semua Waktu (Keseluruhan)"),
              subtitle: const Text("Tampilkan semua data sejak kafe buka"),
              onTap: () {
                controller.setAllTime();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        border: Border(bottom: BorderSide(color: Colors.black38, width: 0.5)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildRow(
    String title,
    int amount, {
    bool isBold = false,
    bool isDeduction = false,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 0.5,
              color: Colors.black38,
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  "Rp",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  isDeduction || amount < 0
                      ? "(${NumberFormat.decimalPattern('id_ID').format(amount.abs())})"
                      : NumberFormat.decimalPattern('id_ID').format(amount),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtotalRow(String title, int amount) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF1F3F5),
        border: Border(bottom: BorderSide(color: Colors.black38, width: 0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 0.5,
              color: Colors.black38,
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  "Rp",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  amount < 0
                      ? "(${NumberFormat.decimalPattern('id_ID').format(amount.abs())})"
                      : NumberFormat.decimalPattern('id_ID').format(amount),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalRow(String title, int amount) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFE9ECEF)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 0.5,
              color: Colors.black38,
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  "Rp",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  amount < 0
                      ? "(${NumberFormat.decimalPattern('id_ID').format(amount.abs())})"
                      : NumberFormat.decimalPattern('id_ID').format(amount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
