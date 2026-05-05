import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../theme/app_colors.dart';
import '../../providers/inventory_provider.dart';
import '../../models/inventory_item.dart';

class AddInventoryPanel extends ConsumerStatefulWidget {
  const AddInventoryPanel({super.key});

  @override
  ConsumerState<AddInventoryPanel> createState() => _AddInventoryPanelState();
}

class _AddInventoryPanelState extends ConsumerState<AddInventoryPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  
  String? _selectedType;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _productTypes = [
    {'label': 'Physical Inventory', 'icon': PhosphorIcons.package()},
    {'label': 'Finished Goods', 'icon': PhosphorIcons.checkCircle()},
    {'label': 'Maintenance & Repair', 'icon': PhosphorIcons.wrench()},
    {'label': 'Consumable Supplies', 'icon': PhosphorIcons.batteryFull()},
    {'label': 'Food & Beverage', 'icon': PhosphorIcons.coffee()},
    {'label': 'Retail Merchandise', 'icon': PhosphorIcons.tag()},
    {'label': 'Components', 'icon': PhosphorIcons.puzzlePiece()},
    {'label': 'Spare Parts', 'icon': PhosphorIcons.gear()},
    {'label': 'Custom', 'icon': PhosphorIcons.dotsThree()},
  ];

  Future<void> _submitToBackend() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a product type")));
       return;
    }

    setState(() => _isSubmitting = true);

    try {
      final item = InventoryItem(
        name: _nameController.text,
        quantity: int.tryParse(_qtyController.text) ?? 0,
        price: double.tryParse(_priceController.text) ?? 0.0,
        productType: _selectedType!,
        inventoryPlace: _placeController.text,
        date: _dateController.text,
      );

      await ref.read(inventoryProvider.notifier).ingestItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Success: Item added to warehouse"), backgroundColor: Colors.green),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _placeController.clear();
        _priceController.clear();
        _qtyController.clear();
        setState(() {
          _selectedType = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildField(
                          "Date...", _dateController,
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              _dateController.text = DateFormat('yyyy-MM-dd').format(date);
                            }
                          },
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _buildField(
                          "Time in...", _timeController,
                          readOnly: true,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppColors.navyMid, // Header background & hand
                                      onPrimary: Colors.white, // Header text
                                      onSurface: AppColors.navyMid, // Numbers & Text
                                      secondary: AppColors.gold, // Selection highlight
                                    ),
                                    timePickerTheme: TimePickerThemeData(
                                      backgroundColor: Colors.white,
                                      dayPeriodTextColor: AppColors.navyMid,
                                      dayPeriodColor: AppColors.gold.withValues(alpha: 0.2),
                                      dialBackgroundColor: AppColors.offWhite,
                                      dialHandColor: AppColors.navyMid,
                                      dialTextColor: AppColors.navyMid,
                                      entryModeIconColor: AppColors.navyMid,
                                      hourMinuteTextColor: AppColors.navyMid,
                                      hourMinuteColor: AppColors.gold.withValues(alpha: 0.1),
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.navyMid, // OK/Cancel button text
                                      ),
                                    ),
                                  ),
                                  child: MediaQuery(
                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                    child: child!,
                                  ),
                                );
                              },
                            );
                            if (time != null) {
                              final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                              _timeController.text = formattedTime;
                            }
                          },
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      "Product Name...", _nameController,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                    ),
                    const SizedBox(height: 12),
                    _buildTypeDropdown(),
                    const SizedBox(height: 12),
                    _buildField(
                      "Inventory Place...", _placeController,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]'))],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildField(
                          "Unit Price...", _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _buildField(
                          "Quantity...", _qtyController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.navyMid,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: const [
          Icon(Icons.assignment_outlined, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text("Add Inventory", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildField(
    String hint, 
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
        errorStyle: const TextStyle(fontSize: 10, height: 0.8),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
      items: _productTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type['label'],
          child: Row(
            children: [
              Icon(type['icon'], size: 18, color: AppColors.navyMid),
              const SizedBox(width: 10),
              Text(type['label'], style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedType = val),
      decoration: InputDecoration(
        hintText: "Product Type...",
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        errorStyle: const TextStyle(fontSize: 10, height: 0.8),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitToBackend,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isSubmitting 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navyDark))
          : const Text("Add to Inventory", style: TextStyle(color: AppColors.navyDark, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
