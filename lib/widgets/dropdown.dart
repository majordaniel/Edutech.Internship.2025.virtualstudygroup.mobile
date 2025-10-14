import 'package:flutter/material.dart';
import 'package:edify_app/constants/colors.dart';

class FullWidthDropdown extends StatefulWidget {
  const FullWidthDropdown({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FullWidthDropdownState createState() => _FullWidthDropdownState();
}

class _FullWidthDropdownState extends State<FullWidthDropdown> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: DropdownButton<String>(
        value: selectedCategory,
        hint: Text('Criminal law'),
        isExpanded: true, // Makes dropdown take full width
        onChanged: (String? newValue) {
          setState(() {
            selectedCategory = newValue;
          });
        },
        items:
            <String>[
              'Criminal Law',
              'Criminal book',
              'Education',
              'Health',
              'Business',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        style: TextStyle(color: AppColors.primaryBlack),
        icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryBlack),
        dropdownColor: AppColors.primaryOrangeLight,
      ),
    );
  }
}
