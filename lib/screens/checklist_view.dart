import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../utils/checklist_data.dart';
import '../utils/pregnancy_data.dart';

class ChecklistView extends StatefulWidget {
  final AppStrings strings;

  const ChecklistView({super.key, required this.strings});

  @override
  State<ChecklistView> createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  String _selectedCategory = 'all';
  Set<String> _checkedIds = {};
  List<ChecklistItem> _customItems = [];

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    final checked = prefs.getStringList('checklist_checked') ?? [];
    final customRaw = prefs.getString('checklist_custom');
    List<ChecklistItem> loadedCustom = [];
    if (customRaw != null) {
      final decoded = jsonDecode(customRaw) as List<dynamic>;
      loadedCustom = decoded
          .map((e) => ChecklistItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (mounted) {
      setState(() {
        _checkedIds = checked.toSet();
        _customItems = loadedCustom;
      });
    }
  }

  Future<void> _toggleItem(String id) async {
    final updated = Set<String>.from(_checkedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('checklist_checked', updated.toList());
    setState(() => _checkedIds = updated);
  }

  Future<void> _addCustomItem(String title, String category) async {
    final item = ChecklistItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      titleFa: title,
      titleEn: title,
      isCustom: true,
    );
    final updated = [item, ..._customItems];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'checklist_custom',
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
    setState(() => _customItems = updated);
  }

  Future<void> _deleteCustomItem(String id) async {
    final updatedCustom = _customItems.where((e) => e.id != id).toList();
    final updatedChecked = Set<String>.from(_checkedIds)..remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'checklist_custom',
      jsonEncode(updatedCustom.map((e) => e.toJson()).toList()),
    );
    await prefs.setStringList('checklist_checked', updatedChecked.toList());
    setState(() {
      _customItems = updatedCustom;
      _checkedIds = updatedChecked;
    });
  }

  Future<void> _showAddDialog() async {
    final s = widget.strings;
    String newTitle = '';
    String selectedCat =
        _selectedCategory == 'all' ? 'mom_bag' : _selectedCategory;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(s.addItemBtn),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(hintText: s.itemHint),
                onChanged: (v) => newTitle = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCat,
                decoration: InputDecoration(labelText: s.categoryLabel),
                items: [
                  DropdownMenuItem(value: 'medical', child: Text(s.catMedical)),
                  DropdownMenuItem(value: 'mom_bag', child: Text(s.catMomBag)),
                  DropdownMenuItem(value: 'baby_bag', child: Text(s.catBabyBag)),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedCat = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancelBtn),
            ),
            FilledButton(
              onPressed: () {
                final trimmed = newTitle.trim();
                if (trimmed.isNotEmpty) {
                  _addCustomItem(trimmed, selectedCat);
                }
                Navigator.pop(ctx);
              },
              child: Text(s.confirmBtn),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryName(String cat, AppStrings s) {
    switch (cat) {
      case 'medical':
        return s.catMedical;
      case 'mom_bag':
        return s.catMomBag;
      case 'baby_bag':
        return s.catBabyBag;
      default:
        return s.catAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final allItems = [..._customItems, ...defaultChecklistItems];
    final filtered = _selectedCategory == 'all'
        ? allItems
        : allItems.where((e) => e.category == _selectedCategory).toList();

    final doneCount =
        allItems.where((e) => _checkedIds.contains(e.id)).length;
    final totalCount = allItems.length;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;

    final progressText = s.isFa
        ? JalaliDate.toPersianDigits(s.checklistProgress(doneCount, totalCount))
        : s.checklistProgress(doneCount, totalCount);

    final categories = ['all', 'medical', 'mom_bag', 'baby_bag'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        progressText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(s.addItemBtn),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(_categoryName(cat, s)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: filtered.length,
            itemBuilder: (ctx, idx) {
              final item = filtered[idx];
              final checked = _checkedIds.contains(item.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  value: checked,
                  onChanged: (_) => _toggleItem(item.id),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    s.isFa ? item.titleFa : item.titleEn,
                    style: TextStyle(
                      decoration: checked ? TextDecoration.lineThrough : null,
                      color: checked
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    _categoryName(item.category, s),
                    style: const TextStyle(fontSize: 12),
                  ),
                  secondary: item.isCustom
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _deleteCustomItem(item.id),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
