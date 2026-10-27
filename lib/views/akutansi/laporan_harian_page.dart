import 'package:admin_fungi/views/akutansi/widgets/laporan_sheets.dart';
import 'package:admin_fungi/views/akutansi/widgets/laporan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/AkuntansiController.dart';

class LaporanHarianPage extends StatelessWidget {
  LaporanHarianPage({super.key});

  final AkuntansiController controller = Get.put(AkuntansiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Akuntansi & Keuangan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.blue),
            tooltip: "Filter Waktu",
            onPressed: () =>
                LaporanSheets.showFilterOptions(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchFinancialData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. INFO PERIODE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Periode: ${controller.periodLabel.value}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Icon(Icons.date_range, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. KARTU LABA BERSIH (Murni Omset - HPP)
                LaporanWidgets.buildMainCard(
                  controller: controller,
                  title: "Laba Bersih Produk",
                  amount: controller.labaBersih.value,
                  isProfit: controller.labaBersih.value >= 0,
                ),
                const SizedBox(height: 15),

                // 3. ROW OMSET & PENGELUARAN (HPP)
                Row(
                  children: [
                    Expanded(
                      child: LaporanWidgets.buildSubCard(
                        controller: controller,
                        title: "Omset (Masuk)",
                        amount: controller.totalOmset.value,
                        icon: Icons.arrow_downward_rounded,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: LaporanWidgets.buildSubCard(
                        controller: controller,
                        title: "HPP Bahan (Terpakai)",
                        amount: controller
                            .totalHPP
                            .value, // Disesuaikan dengan logika Akuntansi baru
                        icon: Icons.arrow_upward_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 4. TOMBOL LOG HARIAN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                      ),
                    ),
                    icon: const Icon(Icons.list_alt),
                    label: const Text(
                      "Lihat Ringkasan Harian",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () =>
                        LaporanSheets.showDailyLogSheet(context, controller),
                  ),
                ),
                const SizedBox(height: 30),

                // 5. DAFTAR NOTA TRANSAKSI
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  "Daftar Transaksi (Nota)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                LaporanWidgets.buildTransactionList(controller),
              ],
            ),
          ),
        );
      }),
    );
  }
}
