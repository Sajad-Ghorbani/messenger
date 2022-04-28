import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class EditProfileButton extends StatelessWidget {
  const EditProfileButton(
      {Key? key,
      required this.onOKPressed,
      required this.usernameController,
      required this.phoneController})
      : super(key: key);

  final VoidCallback onOKPressed;
  final TextEditingController usernameController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        'edit',
        style: kTextContent,
      ),
      onPressed: () {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.INFO_REVERSED,
          headerAnimationLoop: false,
          animType: AnimType.BOTTOMSLIDE,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input for change',
                    style: kTextContent,
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'User Name',
                    ),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              usernameController.clear();
                              phoneController.clear();
                              Navigator.pop(context);
                            },
                            child: const SizedBox(
                              height: 40,
                              child: Center(
                                  child: Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Material(
                          color: kGreenColor,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: onOKPressed,
                            child: const SizedBox(
                              height: 40,
                              child: Center(
                                  child: Text(
                                'Ok',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
          showCloseIcon: true,
        ).show();
      },
    );
  }
}
