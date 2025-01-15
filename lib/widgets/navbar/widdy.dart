import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

AppBar appBar() {
  return AppBar(
    title: const Text(
      'Home',
      style: TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.white,
    elevation: 0.0,
    centerTitle: true,
    leading: GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icons/hamburg.svg',
          height: 20,
          width: 20,
        ),
        decoration: BoxDecoration(
            color: const Color(0xffF7F8F8),
            borderRadius: BorderRadius.circular(10)),
      ),
    )
  );
}
