import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Where can we take you?',
        hintStyle: TextStyle(color: lightgrey,fontFamily: 'HelveticaNeueMedium'),
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: phonefieldColor,
      ),
    );
  }
}
