import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum InputTextType { name, emailaddress, password, number, streetAddress }

class CustomTextFormFieldWidget extends StatelessWidget {
 final TextEditingController controller;
 final String labeltext;
 final bool isObsure;
 final InputTextType type;

 final RxBool obscure = true.obs;

  CustomTextFormFieldWidget({
    super.key,
    required this.controller,
    required this.labeltext,
    required this.isObsure,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    obscure.value = isObsure;
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field is empty';
            } else {
              if (type == InputTextType.name) {
                if (!RegExp(r"[a-zA-Z]+|\s").hasMatch(value)) {
                  return 'Enter valid name';
                }
              } else if (type == InputTextType.emailaddress) {
                if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)) {
                  return 'Enter valid email';
                }
              } else if (type == InputTextType.password) {
                if (value.length < 8) {
                  return 'Password should be at least 8 characters';
                }
              } else if (type == InputTextType.number) {
                if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                  return 'Enter valid number';
                }
              } else if (type == InputTextType.streetAddress) {
                if (value.length < 5) {
                  return 'Enter valid address';
                }
              }
            }

            return null;
          },
          onTapOutside: (e) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild?.unfocus();
            }
          },
          keyboardType: type == InputTextType.name
              ? TextInputType.name
              : type == InputTextType.password
                  ? TextInputType.visiblePassword
                  : type == InputTextType.number
                      ? TextInputType.number
                      : type == InputTextType.emailaddress
                          ? TextInputType.emailAddress
                          : TextInputType.streetAddress,
          obscureText: obscure.value,
          controller: controller,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: true,
              fillColor: Colors.white12,
              suffixIcon: isObsure == true
                  ? InkWell(
                      onTap: () {
                        obscure.toggle();
                      },
                      child: Icon(
                        obscure.value == true
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20.0,
                        color: Colors.black,
                      ),
                    )
                  : null,
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(10))),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(10))),
              focusedErrorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(10))),
              errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(10))),
              labelText: labeltext,
              labelStyle: const TextStyle(color: Colors.black)),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
