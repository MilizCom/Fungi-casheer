import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controller.dart';
import '../dashboard_constants.dart';
import '../dashboard_dialogs.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AdminController controller;

  const DashboardAppBar({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DashboardColors.bgCanvas,
      elevation: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dashboard", style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            "Fungi Admin",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: controller.isUploadingSpreadsheet.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                  )
                : const Icon(Icons.table_chart, color: Colors.green),
            tooltip: "Update Semua Laporan (Penjualan & Void)",
            onPressed: controller.isUploadingSpreadsheet.value
                ? null
                : () async {
                    if (controller.filteredTransactions.isEmpty &&
                        controller.filteredVoids.isEmpty) {
                      Get.snackbar(
                        "Info",
                        "Tidak ada data apapun (Penjualan/Void) di tanggal ini.",
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    if (controller.filteredTransactions.isNotEmpty)
                      await controller.updateSpreadsheet();
                    await Future.delayed(const Duration(seconds: 2));
                    if (controller.filteredVoids.isNotEmpty) {
                      await controller.updateVoidSpreadsheet();
                    } else {
                      print("Skip Void: Data kosong");
                    }
                  },
          ),
        ),
        GestureDetector(
          onTap: () =>
              DashboardDialogs.showFilterBottomSheet(context, controller),
          child: Container(
            margin: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: DashboardColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    controller.filterLabel.value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
