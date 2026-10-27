import 'package:admin_fungi/controllers/ingredient_controller.dart';
import 'package:admin_fungi/models/ingredient_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Pastikan import form bahan campuran yang kita buat sebelumnya
import 'add_mixed_ingredient_sheet.dart';

class IngredientPage extends StatefulWidget {
  const IngredientPage({super.key});

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  final IngredientController controller = Get.put(IngredientController());

  final TextEditingController searchC = TextEditingController();
  String filterStatus = 'Semua';

  // ==========================================================
  // FORM TAMBAH BAHAN BAKU MENTAH (Baru)
  // ==========================================================
  void _showAddIngredientForm(BuildContext context) {
    final nameC = TextEditingController();
    final stockC = TextEditingController(text: "0");
    final minStockC = TextEditingController(text: "10");
    final minBarStockC = TextEditingController(text: "10");

    String selectedUnit = 'gr';
    bool isOptional = false;

    final List<String> unitOptions = [
      'gr',
      'ml',
      'pcs',
      'pack',
      'kg',
      'liter',
      'butir',
      'siung',
    ];

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "BUAT BAHAN BAKU BARU",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue[800],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameC,
                    decoration: InputDecoration(
                      labelText: "Nama Bahan",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: stockC,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Stok Awal Gudang",
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          items: unitOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setModalState(() => selectedUnit = val!),
                          decoration: InputDecoration(
                            labelText: "Unit",
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minStockC,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Min. Gudang",
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: minBarStockC,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Min. Stok Bar",
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text(
                      "Bahan Opsional",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "Pilih jika bahan ini tidak wajib selalu ada.",
                      style: TextStyle(fontSize: 11),
                    ),
                    activeColor: Colors.blue[700],
                    value: isOptional,
                    onChanged: (val) => setModalState(() => isOptional = val),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (nameC.text.isEmpty) return;
                        controller.saveIngredient(
                          name: nameC.text,
                          unit: selectedUnit,
                          stock: int.tryParse(stockC.text) ?? 0,
                          minStock: int.tryParse(minStockC.text) ?? 10,
                          minBarStock: int.tryParse(minBarStockC.text) ?? 5,
                          optionalStock: isOptional,
                        );
                        Get.back();
                      },
                      child: const Text(
                        "SIMPAN BAHAN BARU",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ==========================================================
  // KONFIRMASI HAPUS BAHAN
  // ==========================================================
  void _confirmDelete(IngredientModel ing) {
    Get.defaultDialog(
      title: "Hapus Bahan?",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      content: Text(
        "Apakah Anda yakin ingin menghapus '${ing.name}' secara permanen dari sistem?",
        textAlign: TextAlign.center,
      ),
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black87,
      onConfirm: () async {
        Get.back(); // Tutup dialog konfirmasi
        try {
          // Menghapus langsung dari Firestore
          await FirebaseFirestore.instance
              .collection('ingredients')
              .doc(ing.id)
              .delete();
          Get.snackbar(
            "Terhapus",
            "${ing.name} berhasil dihapus dari sistem.",
            backgroundColor: Colors.red.shade100,
          );
        } catch (e) {
          Get.snackbar(
            "Gagal",
            "Terjadi kesalahan: $e",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Master Data Stok",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload_outlined, color: Colors.green[700]),
            tooltip: "Export ke Excel",
            onPressed: () => controller.exportStockToSpreadsheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ==================================================
          // 1. HEADER (TOMBOL TAMBAH & SEARCH)
          // ==================================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // TOMBOL TAMBAH BERSEBELAHAN
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.blue.shade600,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue.shade50,
                          ),
                          icon: Icon(
                            Icons.add_box_rounded,
                            color: Colors.blue[700],
                            size: 18,
                          ),
                          label: Text(
                            "Bahan Baku",
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () => _showAddIngredientForm(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.purple.shade600,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.purple.shade50,
                          ),
                          icon: Icon(
                            Icons.blender_rounded,
                            color: Colors.purple[700],
                            size: 18,
                          ),
                          label: Text(
                            "Campuran",
                            style: TextStyle(
                              color: Colors.purple[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () =>
                              AddMixedIngredientSheet.show(), // Panggil BottomSheet Campuran
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchC,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Cari data stok...",
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.blueGrey[300],
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("Semua", Colors.blueGrey),
                      const SizedBox(width: 8),
                      _buildFilterChip("Mentah", Colors.blue),
                      const SizedBox(width: 8),
                      _buildFilterChip("Campuran", Colors.purple),
                      const SizedBox(width: 8),
                      _buildFilterChip("Menipis", Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // 2. LIST DATA BAHAN
          // ==================================================
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.blue[800]),
                );
              }

              var list = controller.ingredients.where((ing) {
                bool matchName = ing.name.toLowerCase().contains(
                  searchC.text.toLowerCase(),
                );
                bool isLow =
                    ing.stock <= ing.minStock ||
                    ing.barStock <= ing.minBarStock;

                bool matchStatus = true;
                if (filterStatus == 'Mentah')
                  matchStatus = ing.isMixed == false;
                if (filterStatus == 'Campuran')
                  matchStatus = ing.isMixed == true;
                if (filterStatus == 'Menipis') matchStatus = isLow;

                return matchName && matchStatus;
              }).toList();

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    "Tidak ada bahan ditemukan.",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildIngredientCard(list[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, MaterialColor color) {
    bool isSelected = filterStatus == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.shade50,
      labelStyle: TextStyle(
        color: isSelected ? color.shade800 : Colors.blueGrey[600],
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? color.shade600 : Colors.grey.shade300,
      ),
      onSelected: (val) {
        if (val) setState(() => filterStatus = label);
      },
    );
  }

  Widget _buildIngredientCard(IngredientModel ing) {
    bool isLow =
        ing.stock <= ing.minStock &&
        !ing.isMixed; // Campuran tidak punya minStock gudang
    Color statusColor = ing.isMixed
        ? Colors.purple
        : (isLow ? Colors.red : Colors.green);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
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
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              ing.isMixed ? Icons.blender_rounded : Icons.inventory_2_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        ing.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (ing.isMixed)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Campuran",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.purple.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  ing.isMixed
                      ? "Di Bar: ${ing.barStock} ${ing.unit}"
                      : "Gudang: ${ing.stock} ${ing.unit} | Bar: ${ing.barStock} ${ing.unit}",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // TOMBOL EDIT & HAPUS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_rounded,
                  color: Colors.blue[600],
                  size: 22,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                onPressed: () => _showForm(context, ing),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red[400],
                  size: 22,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                onPressed: () => _confirmDelete(ing),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FORM EDIT FULL (Mentah & Campuran Lengkap)
  // ==========================================================
  void _showForm(BuildContext context, IngredientModel ing) {
    final nameC = TextEditingController(text: ing.name);
    final stockC = TextEditingController(text: ing.stock.toString());
    final minStockC = TextEditingController(text: ing.minStock.toString());
    final minBarStockC = TextEditingController(
      text: ing.minBarStock.toString(),
    );

    // Asumsi nilai default yield adalah 1 jika tidak ditemukan
    final yieldC = TextEditingController(text: '1');

    String selectedUnit = ing.unit;
    bool isOptional = ing.optionalStock;
    final List<String> unitOptions = [
      'gr',
      'ml',
      'pcs',
      'pack',
      'kg',
      'liter',
      'butir',
      'siung',
    ];

    // Menyiapkan state komposisi khusus jika ini adalah Bahan Campuran
    List<Map<String, dynamic>> editComposition = [];
    if (ing.isMixed && ing.composition.isNotEmpty) {
      for (var comp in ing.composition) {
        var rawIng = controller.ingredients.firstWhereOrNull(
          (i) => i.id == comp['ingredient_id'],
        );
        if (rawIng != null) {
          editComposition.add({
            'ingredient': rawIng,
            'amountC': TextEditingController(text: comp['amount'].toString()),
          });
        }
      }
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            // FUNGSI LOKAL: Untuk menambah bahan penyusun baru saat di mode Edit
            void pickIngredientForEdit() {
              var rawIngredients = controller.ingredients
                  .where((i) => i.isMixed == false)
                  .toList();
              if (rawIngredients.isEmpty) {
                Get.snackbar(
                  "Peringatan",
                  "Belum ada bahan mentah.",
                  backgroundColor: Colors.orange.shade700,
                  colorText: Colors.white,
                );
                return;
              }
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    height: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pilih Bahan Baku",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: rawIngredients.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              var rawIng = rawIngredients[index];
                              bool isAlreadyAdded = editComposition.any(
                                (c) => c['ingredient'].id == rawIng.id,
                              );
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  rawIng.name,
                                  style: TextStyle(
                                    fontWeight: isAlreadyAdded
                                        ? FontWeight.normal
                                        : FontWeight.w700,
                                    color: isAlreadyAdded
                                        ? Colors.grey.shade400
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  "Satuan: ${rawIng.unit}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                trailing: isAlreadyAdded
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green.shade600,
                                      )
                                    : Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: Colors.purple.shade600,
                                      ),
                                onTap: isAlreadyAdded
                                    ? null
                                    : () {
                                        setModalState(() {
                                          editComposition.add({
                                            'ingredient': rawIng,
                                            'amountC': TextEditingController(),
                                          });
                                        });
                                        Get.back();
                                      },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ing.isMixed
                              ? "EDIT BAHAN CAMPURAN"
                              : "EDIT BAHAN MENTAH",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: ing.isMixed
                                ? Colors.purple[800]
                                : Colors.blueGrey[800],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // NAMA & UNIT
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: nameC,
                            decoration: InputDecoration(
                              labelText: "Nama Bahan",
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: unitOptions.contains(selectedUnit)
                                ? selectedUnit
                                : unitOptions[0],
                            items: unitOptions
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setModalState(() => selectedUnit = val!),
                            decoration: InputDecoration(
                              labelText: "Unit",
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // STOK & YIELD
                    if (!ing.isMixed) ...[
                      // Tampilan khusus Bahan Mentah
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockC,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: "Stok Gudang (Terkunci)",
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: minStockC,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Min. Gudang",
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Tampilan khusus Bahan Campuran
                      TextField(
                        controller: yieldC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Hasil Jadi (Yield)",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.grey.shade400,
                            size: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // MIN BAR & OPSIONAL (Berlaku untuk keduanya)
                    TextField(
                      controller: minBarStockC,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Peringatan Min. Stok Bar",
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Bahan Opsional",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: const Text(
                        "Tidak wajib ada di meja bar.",
                        style: TextStyle(fontSize: 11),
                      ),
                      activeColor: ing.isMixed
                          ? Colors.purple[700]
                          : Colors.blue[700],
                      value: isOptional,
                      onChanged: (val) => setModalState(() => isOptional = val),
                    ),

                    // ===============================================
                    // AREA KOMPOSISI (HANYA MUNCUL JIKA CAMPURAN)
                    // ===============================================
                    if (ing.isMixed) ...[
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      const Text(
                        "KOMPOSISI RESEP",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Colors.blueGrey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (editComposition.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            "Belum ada bahan penyusun.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: editComposition.length,
                        itemBuilder: (context, index) {
                          var item = editComposition[index];
                          IngredientModel compIng = item['ingredient'];
                          TextEditingController amtC = item['amountC'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    compIng.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: TextField(
                                    controller: amtC,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      suffixText: compIng.unit,
                                      suffixStyle: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.red.shade400,
                                    size: 20,
                                  ),
                                  onPressed: () => setModalState(
                                    () => editComposition.removeAt(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(color: Colors.purple.shade100),
                            foregroundColor: Colors.purple.shade700,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text(
                            "Tambah Bahan Penyusun",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: pickIngredientForEdit,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ing.isMixed
                              ? Colors.purple[700]
                              : Colors.blue[800],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (nameC.text.isEmpty) return;

                          if (ing.isMixed) {
                            // --- VALIDASI SIMPAN CAMPURAN ---
                            int yieldAmount = int.tryParse(yieldC.text) ?? 0;
                            if (yieldAmount <= 0) {
                              Get.snackbar(
                                "Peringatan",
                                "Hasil jadi (yield) harus diisi valid.",
                                backgroundColor: Colors.red.shade700,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            if (editComposition.isEmpty) {
                              Get.snackbar(
                                "Peringatan",
                                "Tambahkan minimal 1 bahan penyusun.",
                                backgroundColor: Colors.red.shade700,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            List<Map<String, dynamic>> finalComp = [];
                            for (var c in editComposition) {
                              int amt = int.tryParse(c['amountC'].text) ?? 0;
                              if (amt <= 0) {
                                Get.snackbar(
                                  "Peringatan",
                                  "Takaran resep tidak boleh 0.",
                                  backgroundColor: Colors.red.shade700,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              finalComp.add({
                                'ingredient_id':
                                    (c['ingredient'] as IngredientModel).id,
                                'amount': amt,
                              });
                            }

                            controller.saveMixedIngredient(
                              id: ing.id,
                              name: nameC.text,
                              unit: selectedUnit,
                              minBarStock: int.tryParse(minBarStockC.text) ?? 5,
                              optionalStock: isOptional,
                              defaultYield: yieldAmount,
                              composition: finalComp,
                            );
                          } else {
                            // --- SIMPAN MENTAH ---
                            controller.saveIngredient(
                              id: ing.id,
                              name: nameC.text,
                              unit: selectedUnit,
                              stock: int.tryParse(stockC.text) ?? 0,
                              minStock: int.tryParse(minStockC.text) ?? 10,
                              minBarStock: int.tryParse(minBarStockC.text) ?? 5,
                              optionalStock: isOptional,
                            );
                          }

                          Get.back();
                        },
                        child: const Text(
                          "SIMPAN PERUBAHAN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }
}
