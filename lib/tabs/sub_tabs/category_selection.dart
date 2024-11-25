import 'package:flutter/material.dart';

class CategorySelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final List<int> selectedCategoryIds;
  final Function(List<int> selectedIds) onSelectionChanged;

  CategorySelectionWidget({
    required this.categories,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
  });

  @override
  _CategorySelectionWidgetState createState() => _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget> {
  late List<int> _selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = List<int>.from(widget.selectedCategoryIds);
  }

  void _handleCategorySelection(Map<String, dynamic> category) {
    setState(() {
      if (_selectedCategoryIds.contains(category['id'])) {
        _selectedCategoryIds.remove(category['id']);
      } else {
        _selectedCategoryIds.add(category['id']);
      }
      // Llamamos al callback para notificar los cambios
      widget.onSelectionChanged(_selectedCategoryIds);
    });
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    bool isSelected = _selectedCategoryIds.contains(category['id']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(category['name']),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: Colors.blue)
              : Icon(Icons.circle_outlined),
          onTap: () {
            _handleCategorySelection(category);
          },
        ),
        if (category['children'] != null && category['children'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: category['children'].map<Widget>((child) {
                return _buildCategoryItem(child);
              }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.categories.map((category) => _buildCategoryItem(category)).toList(),
    );
  }
}
