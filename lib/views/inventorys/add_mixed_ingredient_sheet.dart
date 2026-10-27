import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ingredient_controller.dart';
import '../../models/ingredient_model.dart';

class AddMixedIngredientSheet extends StatefulWidget {
  const AddMixedIngredientSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const AddMixedIngredientSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<AddMixedIngredientSheet> createState() =>
      _AddMixedIngredientSheetState();
}

class _AddMixedIngredientSheetState extends State<AddMixedIngredientSheet> {
  final IngredientController controller = Get.find<IngredientController>();

  final TextEditingController nameC = TextEditingController();
  final TextEditingController unitC = TextEditingController();

  // Controller baru untuk hasil jadi (Yield) dari resep ini
  final TextEditingController yieldC = TextEditingController(text: '1');
  final TextEditingController minBarStockC = TextEditingController(text: '10');

  bool optionalStock = false;

  List<Map<String, dynamic>> composition = [];

  void _pickIngredient() {
    var rawIngredients = controller.ingredients
        .where((ing) => ing.isMixed == false)
        .toList();

    if (rawIngredients.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Belum ada bahan baku mentah yang terdaftar.",
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Bahan Baku Dasar",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: rawIngredients.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    var ing = rawIngredients[index];
                    bool isAlreadyAdded = composition.any(
                      (comp) => comp['ingredient'].id == ing.id,
                    );

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        ing.name,
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
                        "Satuan: ${ing.unit}",
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
                              setState(() {
                                composition.add({
                                  'ingredient': ing,
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

  void _save() {
    if (nameC.text.trim().isEmpty || unitC.text.trim().isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Nama dan Satuan bahan campuran wajib diisi.",
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    int yieldAmount = int.tryParse(yieldC.text) ?? 0;
    if (yieldAmount <= 0) {
      Get.snackbar(
        "Peringatan",
        "Hasil jadi (yield) harus lebih dari 0.",
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    if (composition.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Tambahkan minimal 1 bahan penyusun.",
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return;
    }

    List<Map<String, dynamic>> finalComposition = [];
    for (var comp in composition) {
      int amount = int.tryParse(comp['amountC'].text) ?? 0;
      if (amount <= 0) {
        Get.snackbar(
          "Peringatan",
          "Takaran untuk ${(comp['ingredient'] as IngredientModel).name} tidak boleh kosong.",
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return;
      }
      finalComposition.add({
        'ingredient_id': (comp['ingredient'] as IngredientModel).id,
        'amount': amount,
      });
    }

    // Pass defaultYield ke controller
    controller.saveMixedIngredient(
      name: nameC.text.trim(),
      unit: unitC.text.trim(),
      minStock: 0,
      minBarStock: int.tryParse(minBarStockC.text) ?? 10,
      optionalStock: optionalStock,
      defaultYield: yieldAmount, // Parameter baru
      composition: finalComposition,
    );

    Get.back();
    Get.snackbar(
      "Berhasil",
      "Resep bahan campuran disimpan.",
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.blender_rounded,
                      color: Colors.purple.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Buat Bahan Campuran",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Definisi resep untuk produksi Bar",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Nama & Satuan
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: nameC,
                      decoration: InputDecoration(
                        labelText: "Nama Bahan",
                        labelStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
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
                    child: TextField(
                      controller: unitC,
                      decoration: InputDecoration(
                        labelText: "Unit",
                        labelStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
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
              const SizedBox(height: 16),

              // Form Yield & Min Bar Stock
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: yieldC,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Hasil Jadi (Yield)",
                        labelStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: minBarStockC,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Min. Stok Bar",
                        labelStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 16),

              // Komposisi
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

              if (composition.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    // 👇 Tambahkan .text pada yieldC
                    "Pilih bahan mentah yang dibutuhkan untuk menghasilkan ${yieldC.text.isEmpty ? '1' : yieldC.text} ${unitC.text.isEmpty ? 'unit' : unitC.text} racikan ini.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: composition.length,
                itemBuilder: (context, index) {
                  var item = composition[index];
                  IngredientModel ing = item['ingredient'];
                  TextEditingController amtC = item['amountC'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                            ing.name,
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
                              hintText: "0",
                              suffixText: ing.unit,
                              suffixStyle: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
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
                          onPressed: () =>
                              setState(() => composition.removeAt(index)),
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
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  onPressed: _pickIngredient,
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Simpan
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: controller.isLoading.value ? null : _save,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "SIMPAN BAHAN CAMPURAN",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
