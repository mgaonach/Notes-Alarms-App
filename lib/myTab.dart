import 'package:flutter/material.dart';

abstract class MyTab extends StatelessWidget {
  final String title = null;
  final Icon icon = null;

  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return null;
  }
}
