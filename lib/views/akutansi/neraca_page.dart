import 'package:admin_fungi/controllers/AkuntansiController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NeracaPage extends StatelessWidget {
  NeracaPage({super.key});

  final AkuntansiController controller = Get.find<AkuntansiController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Laporan Neraca",
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
            children: [
              // HEADER
              const Text(
                "PT KIVA HAN GROUP",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(
                "LAPORAN NERACA",
                style: TextStyle(fontSize: 14, letterSpacing: 1.5),
              ),
              Text(
                "Per ${controller.periodLabel.value}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Sesuaikan bagian dua kolomnya:
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KOLOM KIRI: ASET ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderRow("Harta (Aset)"),
                        _buildDataRow(
                          "1-101",
                          "Kas (Tunai)",
                          controller.kasBesar.value,
                        ),
                        _buildDataRow(
                          "1-102",
                          "Bank (QRIS/Transfer)",
                          controller.bankMandiri.value,
                        ),
                        _buildDataRow(
                          "1-103",
                          "Piutang Usaha",
                          controller.piutangUsaha.value,
                        ),
                        _buildDataRow(
                          "1-104",
                          "Persediaan Bahan",
                          controller.totalPersediaanBahan.value,
                        ),
                        const SizedBox(height: 10),
                        _buildTotalRow(
                          "Total Harta",
                          controller.totalAsetLancar.value,
                        ),
                      ],
                    ),
                  ),

                  const VerticalDivider(width: 20),

                  // --- KOLOM KANAN: EKUITAS ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderRow("Modal (Ekuitas)"),
                        _buildDataRow(
                          "3-101",
                          "Modal Awal",
                          controller.saldoAwalKas.value,
                        ),
                        _buildDataRow(
                          "3-102",
                          "Laba Akumulatif",
                          (controller.totalEkuitas.value -
                              controller.saldoAwalKas.value),
                        ),
                        const SizedBox(height: 10),
                        _buildTotalRow(
                          "Total Modal",
                          controller.totalEkuitas.value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Divider(thickness: 1, color: Colors.black),

              // FOOTER BALANCE CHECK
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFinalTotal(
                    "Jumlah Aset",
                    controller.totalAsetLancar.value,
                  ),
                  _buildFinalTotal(
                    "Jumlah Kewajiban dan Modal",
                    controller.totalEkuitas.value,
                  ),
                ],
              ),

              // INDIKATOR BALANCE
              if (controller.totalAsetLancar.value !=
                  controller.totalEkuitas.value)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(10),
                  color: Colors.red.shade50,
                  child: const Text(
                    "⚠️ Neraca Belum Seimbang (Unbalanced)",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
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
  // --- WIDGET HELPERS ---

  Widget _buildHeaderRow(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black26)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildDataRow(String code, String name, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(
              code,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 11))),
          Text(
            NumberFormat.decimalPattern('id_ID').format(amount),
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, int amount) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            NumberFormat.decimalPattern('id_ID').format(amount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalTotal(String label, int amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 5),
        Text(
          controller.formatRupiah(amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
