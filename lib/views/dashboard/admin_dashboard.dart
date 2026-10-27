import 'package:admin_fungi/views/akutansi/DashboardAkuntansiPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/dashboard_menus.dart';
// Controllers
import '../../controllers/admin_controller.dart';
import '../../controllers/AkuntansiController.dart';
import '../riwayat_pembatalan.dart';

// Custom Dashboard Widgets
import 'dashboard_constants.dart';
import 'widgets/dashboard_cards.dart';
import 'widgets/dashboard_charts.dart';

class AdminDashboard extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());
  final AkuntansiController akunController = Get.put(AkuntansiController());

  AdminDashboard({super.key});

  Future<void> _refreshAllData() async {
    await controller.fetchDataFromFirebase();
    await akunController.fetchFinancialData();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.historySearchQuery.value = '';
      controller.historyPaymentFilter.value = 'Semua';
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // ==========================================
      // APP BAR (DENGAN TOMBOL REFRESH)
      // ==========================================
      appBar: AppBar(
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.green[700]),
            tooltip: "Muat Ulang Data",
            onPressed: _refreshAllData,
          ),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value || akunController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Colors.green[700]),
          );
        }

        // Deteksi ukuran layar
        double screenWidth = MediaQuery.of(context).size.width;
        bool isDesktop =
            screenWidth >
            800; // Anggap layar > 800px adalah Laptop/Tablet besar

        return RefreshIndicator(
          onRefresh: _refreshAllData,
          color: Colors.green[700],
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            // Bungkus dengan Center & ConstrainedBox agar tidak melar di laptop
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ), // Batas maksimal lebar konten
                child: Padding(
                  // Padding lebih besar jika di laptop
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 1. MENU ATAS ---
                      const DashboardMenus(),
                      SizedBox(height: isDesktop ? 35 : 25),

                      // --- 2. KARTU AKSES AKUNTANSI & STATISTIK KASIR ---
                      // Jika desktop, taruh bersebelahan. Jika HP, atas-bawah.
                      if (isDesktop)
                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildAkuntansiButton()),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 2,
                              child: _buildStatistikOperasional(),
                            ),
                          ],
                        )
                      else ...[
                        _buildAkuntansiButton(),
                        const SizedBox(height: 30),
                        const Text(
                          "STATISTIK OPERASIONAL",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildStatistikOperasional(),
                      ],

                      SizedBox(height: isDesktop ? 40 : 35),

                      // --- 3. GRAFIK KEUANGAN (RESPONSIVE) ---
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("GRAFIK LABA RUGI"),
                                  DailyProfitBarChart(
                                    controller: akunController,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("GRAFIK ARUS KAS"),
                                  DailyOmsetLineChart(
                                    controller: akunController,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _buildSectionTitle("GRAFIK LABA RUGI"),
                        DailyProfitBarChart(controller: akunController),
                        const SizedBox(height: 30),
                        _buildSectionTitle("GRAFIK ARUS KAS"),
                        DailyOmsetLineChart(controller: akunController),
                      ],

                      SizedBox(height: isDesktop ? 40 : 30),

                      // --- 4. GRAFIK KOMPOSISI ASET ---
                      // Pada Desktop bisa ditaruh di tengah atau lebar terbatas
                      _buildSectionTitle("KOMPOSISI ASET (NERACA)"),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: MarginPieChart(controller: akunController),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // =========================================================================
  // WIDGET BANTUAN (DIPISAH AGAR KODE LEBIH RAPI)
  // =========================================================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: DashboardStyles.titleStyle().copyWith(
          fontSize: 12,
          letterSpacing: 1.0,
          color: Colors.blueGrey[700],
        ),
      ),
    );
  }

  Widget _buildAkuntansiButton() {
    return InkWell(
      onTap: () => Get.to(() => DashboardAkuntansiPage()),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.blue.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Akuntansi & Laba Rugi",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Cek Omset, Pengeluaran, Laba Bersih",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistikOperasional() {
    return Row(
      children: [
        Expanded(
          child: MiniStatCard(
            title: "Total Trx",
            value: "${controller.totalTrxCount}",
            icon: Icons.receipt_rounded,
            color: Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: MiniStatCard(
            title: "Total Void",
            value: controller.formatRupiah(controller.totalVoidLost.value),
            icon: Icons.delete_sweep_rounded,
            color: Colors.red.shade500,
            onTap: () => Get.to(() => VoidHistoryPage()),
          ),
        ),
      ],
    );
  }
}
