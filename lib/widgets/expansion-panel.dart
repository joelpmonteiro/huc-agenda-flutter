import 'package:flutter/material.dart';

class CustomExpansionPanel {
  bool expanded;
  Widget header;
  Widget body;
  CustomExpansionPanel(this.expanded, this.header, this.body);
}