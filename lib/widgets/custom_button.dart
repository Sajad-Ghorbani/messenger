import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key? key,
      required this.text,
      required this.onTapped,
      required this.color})
      : super(key: key);

  final String text;
  final VoidCallback onTapped;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      color: kLightGreyColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTapped,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
              child: Text(
            text,
            style: kHeaderText.copyWith(
              color: color,
              fontSize: 18,
            ),
          )),
        ),
      ),
    );
  }
}
