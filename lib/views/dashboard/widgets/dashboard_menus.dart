import 'package:admin_fungi/views/HppMonitorPage.dart';
import 'package:admin_fungi/views/inventorys/inventory_dashboard.dart';
import 'package:admin_fungi/views/monitor_bar_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../products/manage_menu_page.dart';

class DashboardMenus extends StatelessWidget {
  const DashboardMenus({super.key});

  Widget _menuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _menuItem(
          title: "Kelola Menu & Resep",
          subtitle: "Tambah produk, atur harga & takaran resep",
          icon: Icons.restaurant_menu,
          color: Colors.blue,
          onTap: () => Get.to(() => const ManageMenuPage()),
        ),
        const SizedBox(height: 15),
        _menuItem(
          title: "Stok Bahan Baku (Inventory)",
          subtitle: "Cek sisa Gula, Susu, Cup, dll",
          icon: Icons.inventory,
          color: Colors.orange,
          onTap: () => Get.to(() => const InventoryDashboard()),
        ),
        const SizedBox(height: 15),
        _menuItem(
          title: "Cek HPP Produk",
          subtitle: "Lihat biaya produksi dan profitabilitas",
          icon: Icons.calculate,
          color: Colors.blueAccent,
          onTap: () => Get.to(() => HppMonitorPage()),
        ),
        const SizedBox(height: 15),
        _menuItem(
          title: "Cek Kasir",
          subtitle: "Lihat status shift dan stok bar",
          icon: Icons.point_of_sale,
          color: Colors.green,
          onTap: () => Get.to(() => MonitorBarPage()),
        ),
      ],
    );
  }
}
