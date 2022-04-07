import 'package:bob/handler/storage_handler.dart';
import 'package:flutter/material.dart';

class UserSettings extends StatelessWidget {
  UserSettings({Key? key}) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.text = StorageHandler.getValue(SettingKeys.userName);
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );

    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
          labelText: "Dein Name",
          hintText: "Gebe hier deinen vollen Namen ein"),
      onChanged: (value) {
        StorageHandler.saveValue(SettingKeys.userName, value);
      },
    );
  }
}
