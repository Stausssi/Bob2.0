import 'package:bob/handler/storage_handler.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_search/colors/color.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:settings_ui/settings_ui.dart';

import '../handler/storage_handler.dart';
import '../util.dart';
import 'location_search_widget.dart';

enum LinkedTileType {
  /// Creates a switchable settings tile
  toggle,

  /// Creates a [SettingsTile] with a single line text input
  text,

  /// Creates a [SettingsTile] with a multiline text input
  multilineText,

  /// Creates a [SettingsTile] with a location picker
  location,

  /// Creates a [SettingsTile] with a dropdown menu
  dropdown
}

/// Wrapper to extend [AbstractSettingsTile]
class LinkedSettingsTile extends AbstractSettingsTile {
  const LinkedSettingsTile({
    required this.title,
    this.description,
    required this.settingKey,
    required this.type,
    this.leading,
    this.onChange,
    Key? key,
  }) : super(key: key);

  /// The title of the [SettingsTile]
  final String title;

  /// The optional description of the [SettingsTile]
  final String? description;

  /// The unique identifier of the value in the [StorageHandler]
  final String settingKey;

  /// The type of the [SettingsTile]
  final LinkedTileType type;

  /// The optional leading widget of the [SettingsTile]
  final Widget? leading;

  /// An optional function being called every time the value of the [SettingsTile]
  /// is changed
  final Function(dynamic value)? onChange;

  @override
  Widget build(BuildContext context) {
    return _LinkedStatefulTile(
      title: title,
      description: description,
      settingKey: settingKey,
      type: type,
      leading: leading,
      onChange: onChange,
    );
  }
}

/// Links a [SettingsTile] to a key/value pairing in the [StorageHandler]
class _LinkedStatefulTile extends StatefulWidget {
  const _LinkedStatefulTile({
    required this.title,
    this.description,
    required this.settingKey,
    required this.type,
    this.leading,
    this.onChange,
    Key? key,
  }) : super(key: key);

  /// The title of the [SettingsTile]
  final String title;

  /// The optional description of the [SettingsTile]
  final String? description;

  /// The unique identifier of the value in the [StorageHandler]
  final String settingKey;

  /// The type of the [SettingsTile]
  final LinkedTileType type;

  /// The optional leading widget of the [SettingsTile]
  final Widget? leading;

  /// An optional function being called every time the value of the [SettingsTile]
  /// is changed
  final Function(dynamic value)? onChange;

  @override
  _LinkedStatefulTileState createState() => _LinkedStatefulTileState();
}

class _LinkedStatefulTileState extends State<_LinkedStatefulTile> {
  /// Contains the widget for the description of the [SettingsTile]
  late Widget? descriptionWidget;

  /// [Text] widget representing the title of the [SettingsTile]
  late Widget titleWidget;

  /// Needed for changing the value of the [TextField]s programmatically
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    // Load both description and title
    descriptionWidget =
        widget.description != null ? Text(widget.description!) : null;
    titleWidget = Text(widget.title);

    if (widget.type == LinkedTileType.text ||
        widget.type == LinkedTileType.multilineText) {
      if (widget.type == LinkedTileType.multilineText) {
        _textController.text =
            StorageHandler.getValue<List<String>>(widget.settingKey)
                .join("\n")
                .trim();
      } else {
        _textController.text = StorageHandler.getValue(widget.settingKey);
      }
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
    super.initState();
  }

  /// Persists the given [value] to storage and (optionally) calls the [widget.onChange]
  /// callback
  _saveValue(dynamic value) {
    StorageHandler.saveValue(widget.settingKey, value);

    if (widget.onChange != null) {
      widget.onChange!(value);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case LinkedTileType.toggle:
        return _buildToggleTile();
      case LinkedTileType.text:
        return _buildTextTile();
      case LinkedTileType.multilineText:
        return _buildMultilineTextTile();
      case LinkedTileType.location:
        return _buildLocationTile();
      case LinkedTileType.dropdown:
        return _buildDropdownTile();
    }
  }

  /// Creates a toggleable [SettingsTile]
  Widget _buildToggleTile() {
    bool value = StorageHandler.getValue(widget.settingKey);

    return SettingsTile.switchTile(
      title: titleWidget,
      description: descriptionWidget,
      leading: widget.leading,
      initialValue: value,
      onToggle: _saveValue,
    );
  }

  /// Creates a [SettingsTile] with a single line text input as a trailing widget
  Widget _buildTextTile() {
    return SettingsTile(
      title: titleWidget,
      description: descriptionWidget,
      leading: widget.leading,
      trailing: Expanded(
        child: TextField(
          controller: _textController,
          maxLines: 1,
          onChanged: _saveValue,
        ),
      ),
    );
  }

  /// Creates (one or two???) [SettingsTile] to allow a multiline text input
  Widget _buildMultilineTextTile() {
    return SettingsTile(
      title: titleWidget,
      description: descriptionWidget,
      leading: widget.leading,
      trailing: Expanded(
        child: TextField(
          controller: _textController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          onChanged: (String value) {
            _saveValue(value.split('\n'));
          },
        ),
      ),
    );
  }

  /// Creates a tile opening a [LocationPicker] in a new window
  Widget _buildLocationTile() {
    MapBoxPlace place = StorageHandler.getValue(widget.settingKey);

    return SettingsTile.navigation(
      title: titleWidget,
      description: descriptionWidget,
      leading: widget.leading,
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LocationPicker(
              place: place,
              onSelected: _saveValue,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownTile() {
    String value = StorageHandler.getValue(widget.settingKey);

    List<DropdownMenuItem<String>> items = [];

    switch (widget.settingKey) {
      case SettingKeys.gasolineType:
        items = gasolineTypes;
        break;

      case SettingKeys.preferedVehicle:
        items = preferredVehicles;
        break;
    }

    return SettingsTile(
        title: titleWidget,
        description: descriptionWidget,
        leading: widget.leading,
        trailing: DropdownButton(
          value: value,
          items: items,
          onChanged: _saveValue,
        ));
  }
}

/// This class implements a Location picker, which uses MapBox to autocomplete
/// address search requests
class LocationPicker extends StatefulWidget {
  const LocationPicker(
      {required this.place, required this.onSelected, Key? key})
      : super(key: key);

  final MapBoxPlace place;
  final Function(MapBoxPlace) onSelected;

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  @override
  Widget build(BuildContext context) {
    Location location =
        Location(lat: widget.place.center![1], lng: widget.place.center![0]);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select your Location",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: CustomColors.blackBackground,
        shadowColor: Colors.transparent,
        toolbarHeight: 100,
      ),
      body: Stack(
        children: [
          Image.network(
            StaticImage(
              apiKey: StorageHandler.getAPIKey("mapBox"),
            ).getStaticUrlWithMarker(
              center: location,
              width: MediaQuery.of(context).size.width.toInt(),
              marker: MapBoxMarker(
                markerColor: const RgbColor(255, 0, 0),
                markerLetter: 'circle',
                markerSize: MarkerSize.LARGE,
              ),
              zoomLevel: 14,
              style: MapBoxStyle.Streets,
              render2x: true,
            ),
          ),
          LocationSearchWidget(
            popOnSelect: true,
            apiKey: StorageHandler.getAPIKey("mapBox"),
            searchHint: 'Ort',
            location: location,
            onSelected: widget.onSelected,
            context: context,
          ),
        ],
      ),
    );
  }
}
