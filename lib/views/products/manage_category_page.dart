import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_category_controller.dart'; // Sesuaikan path

class ManageCategoryPage extends StatelessWidget {
  ManageCategoryPage({super.key});

  final AdminCategoryController controller = Get.put(AdminCategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Kelola Kategori Menu",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[700],
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Kategori Utama",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddCategoryDialog(context),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Colors.green[700]),
          );
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                Text(
                  "Belum ada kategori.",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            var cat = controller.categories[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
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
              child: Theme(
                // Menghilangkan garis pembatas bawaan ExpansionTile
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: Colors.green[700],
                  collapsedIconColor: Colors.grey[400],
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_copy_rounded,
                      color: Colors.green[700],
                      size: 20,
                    ),
                  ),
                  title: Text(
                    cat.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "${cat.subCategories.length} Sub-Kategori",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 8),

                          // LIST SUB KATEGORI (MENGGUNAKAN CHIP)
                          Wrap(
                            spacing: 8,
                            runSpacing: 12,
                            children: [
                              ...cat.subCategories.map(
                                (sub) => Chip(
                                  label: Text(
                                    sub,
                                    style: TextStyle(
                                      color: Colors.blueGrey[800],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.blueGrey.shade50,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  deleteIcon: const Icon(
                                    Icons.cancel_rounded,
                                    size: 18,
                                  ),
                                  onDeleted: () =>
                                      _confirmDeleteSub(cat.id, sub),
                                ),
                              ),

                              // TOMBOL TAMBAH SUB KATEGORI
                              ActionChip(
                                label: const Text(
                                  "+ Tambah Sub",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.orange[600],
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                onPressed: () => _showAddSubDialog(
                                  context,
                                  cat.id,
                                  cat.name,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // TOMBOL HAPUS KATEGORI UTAMA
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  _confirmDeleteCategory(cat.id, cat.name),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                                size: 18,
                              ),
                              label: const Text(
                                "Hapus Kategori Utama",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ==========================================================
  // DIALOGS & ALERTS
  // ==========================================================

  void _showAddCategoryDialog(BuildContext context) {
    TextEditingController nameC = TextEditingController();
    Get.defaultDialog(
      title: "Kategori Baru",
      titleStyle: const TextStyle(fontWeight: FontWeight.w800),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: nameC,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Contoh: Makanan, Minuman...",
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      textConfirm: "Simpan",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green[700],
      onConfirm: () => controller.addCategory(nameC.text),
    );
  }

  void _showAddSubDialog(BuildContext context, String catId, String catName) {
    TextEditingController nameC = TextEditingController();
    Get.defaultDialog(
      title: "Sub-Kategori untuk $catName",
      titleStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: nameC,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Contoh: Nasi, Mie, Kopi...",
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      textConfirm: "Tambah",
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange[700],
      onConfirm: () => controller.addSubCategory(catId, nameC.text),
    );
  }

  void _confirmDeleteCategory(String id, String name) {
    Get.defaultDialog(
      title: "Hapus $name?",
      middleText: "Seluruh sub-kategori di dalamnya juga akan terhapus.",
      textConfirm: "Hapus Permanen",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red[700],
      textCancel: "Batal",
      onConfirm: () => controller.deleteCategory(id),
    );
  }

  void _confirmDeleteSub(String catId, String subName) {
    Get.defaultDialog(
      title: "Hapus $subName?",
      middleText: "Sub-Kategori ini akan dihapus.",
      textConfirm: "Hapus",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red[700],
      onConfirm: () {
        Get.back(); // Tutup alert konfirmasi
        controller.deleteSubCategory(catId, subName);
      },
    );
  }
}
