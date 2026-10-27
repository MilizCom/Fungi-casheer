import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import 'dashboard_constants.dart';

class DashboardDialogs {
  static void showFilterBottomSheet(
    BuildContext context,
    AdminController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pilih Periode Laporan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _filterTile(
              Icons.today,
              "Hari Ini",
              () => controller.setFilterToday(),
            ),
            _filterTile(
              Icons.history,
              "Kemarin",
              () => controller.setFilterYesterday(),
            ),
            _filterTile(
              Icons.calendar_month,
              "Bulan Ini",
              () => controller.setFilterThisMonth(),
            ),
            _filterTile(Icons.date_range, "Custom Tanggal", () async {
              Get.back();
              var picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: DashboardColors.primaryColor,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null)
                controller.setCustomRange(picked.start, picked.end);
            }),
          ],
        ),
      ),
    );
  }

  static Widget _filterTile(IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DashboardColors.bgCanvas,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: DashboardColors.secondaryColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        onTap();
        if (Get.isBottomSheetOpen!) Get.back();
      },
    );
  }
}
