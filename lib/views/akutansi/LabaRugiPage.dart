import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/AkuntansiController.dart';

class LabaRugiPage extends StatelessWidget {
  LabaRugiPage({super.key});

  final AkuntansiController controller = Get.find<AkuntansiController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Laporan Laba Rugi",
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
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HEADER LAPORAN
              const Text(
                "PT FUNGI CAFE GROUP",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text(
                "LAPORAN LABA RUGI",
                style: TextStyle(fontSize: 14, letterSpacing: 2),
              ),
              Text(
                "Per ${controller.periodLabel.value}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // SECTION 1: PENDAPATAN
              _buildSectionHeader("Pendapatan"),
              _buildAccountRow(
                "4-1000",
                "Penjualan Produk",
                controller.totalOmset.value,
              ),
              _buildTotalRow("Total Pendapatan", controller.totalOmset.value),
              const SizedBox(height: 20),

              // SECTION 2: HPP
              _buildSectionHeader("Harga Pokok Penjualan (HPP)"),
              _buildAccountRow(
                "5-1000",
                "Beban Pokok Penjualan",
                controller.totalHPP.value,
              ),
              _buildTotalRow(
                "Total Harga Pokok Penjualan",
                controller.totalHPP.value,
                isDeduction: true,
              ),
              const SizedBox(height: 30),

              // FINAL LABA BERSIH (Murni dari Produk)
              Builder(
                builder: (context) {
                  bool isProfit = controller.labaBersih.value >= 0;
                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      border: Border.all(
                        color: isProfit
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isProfit
                              ? "Laba Bersih Produk"
                              : "Rugi Bersih Produk",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          controller.formatRupiah(controller.labaBersih.value),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isProfit ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // SECTION 3: BIAYA OPERASIONAL
              _buildSectionHeader("Biaya Operasional"),
              _buildAccountRow(
                "6-1000",
                "Biaya Operasional (Listrik, Gaji, dll)",
                controller.biayaOperasional.value,
              ),
              _buildTotalRow(
                "Total Biaya Operasional",
                controller.biayaOperasional.value,
                isDeduction: true,
              ),
              const SizedBox(height: 20),

              // PENDAPATAN BERSIH OPERASIONAL
              _buildSummaryRow(
                "Pendapatan Bersih Operasional",
                controller.labaBersih.value,
              ),
              const SizedBox(height: 40),

              // ==========================================
              // FINAL LABA BERSIH ATAU RUGI BERSIH
              // ==========================================
              Builder(
                builder: (context) {
                  bool isProfit = controller.labaBersih.value >= 0;
                  Color themeColor = isProfit ? Colors.green : Colors.red;
                  Color bgColor = isProfit
                      ? Colors.green.shade50
                      : Colors.red.shade50;
                  Color borderColor = isProfit
                      ? Colors.green.shade200
                      : Colors.red.shade200;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isProfit ? "Laba Bersih" : "Rugi Bersih",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          controller.formatRupiah(controller.labaBersih.value),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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

  // --- COMPONENT: HEADER SEKSI ---
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  // --- COMPONENT: BARIS AKUN ---
  Widget _buildAccountRow(
    String code,
    String name,
    int amount, {
    bool isDeduction = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              code,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(child: Text(name)),
          Text(
            isDeduction
                ? "(${NumberFormat.decimalPattern('id_ID').format(amount.abs())})"
                : NumberFormat.decimalPattern('id_ID').format(amount),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT: TOTAL PER SEKSI ---
  Widget _buildTotalRow(String label, int amount, {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Container(
            padding: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black)),
            ),
            child: Text(
              isDeduction
                  ? "(${NumberFormat.decimalPattern('id_ID').format(amount.abs())})"
                  : NumberFormat.decimalPattern('id_ID').format(amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT: RINGKASAN (LABA KOTOR / OP) ---
  Widget _buildSummaryRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          controller.formatRupiah(amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
