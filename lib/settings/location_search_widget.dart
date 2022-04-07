import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';

class LocationSearchWidget extends StatefulWidget {
  const LocationSearchWidget({
    required this.apiKey,
    required this.onSelected,
    this.searchHint = 'Search',
    required this.context,
    this.popOnSelect = false,
    required this.location,
    Key? key,
  }) : super(key: key);

  /// True if there is different search screen and you want to pop screen on select
  final bool popOnSelect;

  ///To get the height of the page
  final BuildContext context;

  /// API Key of the MapBox.
  final String apiKey;

  /// The callback that is called when one Place is selected by the user.
  final void Function(MapBoxPlace place) onSelected;

  /// The point around which you wish to retrieve place information.
  final Location location;

  ///Search Hint Localization
  final String searchHint;

  @override
  _LocationSearchWidgetState createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();
  late AnimationController _animationController;

  // SearchContainer height.
  late Animation _containerHeight;

  // Place options opacity.
  late Animation _listOpacity;

  List<MapBoxPlace>? _placePredictions = [];

  Timer? _debounceTimer;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _containerHeight = Tween<double>(
      begin: 73,
      end: MediaQuery.of(widget.context).size.height - 60,
    ).animate(
      CurvedAnimation(
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
        parent: _animationController,
      ),
    );

    _listOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
        parent: _animationController,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        width: MediaQuery.of(context).size.width,
        child: _searchContainer(
          child: _searchInput(context),
        ),
      );

  // Widgets
  Widget _searchContainer({required Widget child}) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return Container(
            height: _containerHeight.value,
            decoration: _containerDecoration(),
            padding: const EdgeInsets.only(left: 0, right: 0, top: 15),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: child,
                ),
                const SizedBox(height: 10),
                if (_placePredictions != null)
                  Expanded(
                    child: Opacity(
                      opacity: _listOpacity.value,
                      child: ListView(
                        // addSemanticIndexes: true,
                        // itemExtent: 10,
                        children: <Widget>[
                          for (var places in _placePredictions!)
                            _placeOption(places),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
  }

  Widget _searchInput(BuildContext context) {
    return Center(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              decoration: _inputStyle(),
              controller: _textEditingController,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
              onChanged: (value) async {
                if (_debounceTimer != null) {
                  _debounceTimer!.cancel();
                }
                _debounceTimer = Timer(
                  const Duration(milliseconds: 750),
                  () async {
                    await _autocompletePlace(value);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                );
              },
            ),
          ),
          Container(width: 15),
          GestureDetector(
            child: const Icon(Icons.search, color: Colors.blue),
            onTap: () {},
          )
        ],
      ),
    );
  }

  Widget _placeOption(MapBoxPlace prediction) {
    String? place = prediction.text;
    String? fullName = prediction.placeName;

    return MaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      onPressed: () => _selectPlace(prediction),
      child: ListTile(
        title: Text(
          place != null
              ? place.length < 45
                  ? place
                  : "${place.replaceRange(45, place.length, "")} ..."
              : "",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
          maxLines: 1,
        ),
        subtitle: Text(
          fullName ?? "",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03),
          maxLines: 1,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 0,
        ),
      ),
    );
  }

  // Styling
  InputDecoration _inputStyle() {
    return InputDecoration(
      hintText: widget.searchHint,
      border: InputBorder.none,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
    );
  }

  BoxDecoration _containerDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
      boxShadow: [
        BoxShadow(color: Colors.black, blurRadius: 0, spreadRadius: 0)
      ],
    );
  }

  // Methods
  Future _autocompletePlace(String input) async {
    /// Will be called when the input changes. Making callbacks to the Places
    /// Api and giving the user Place options
    ///
    if (input.isNotEmpty) {
      var placesSearch = PlacesSearch(
        apiKey: widget.apiKey,
      );

      final predictions = await placesSearch.getPlaces(
        input,
        location: widget.location,
      );

      await _animationController.animateTo(0.5);

      setState(() => _placePredictions = predictions);

      await _animationController.forward();
    } else {
      await _animationController.animateTo(0.5);
      setState(() => _placePredictions = []);
      await _animationController.reverse();
    }
  }

  void _selectPlace(MapBoxPlace prediction) async {
    /// Will be called when a user selects one of the Place options.

    // Dont allow null values
    prediction = MapBoxPlace(
      id: prediction.id ?? "",
      type: prediction.type ?? FeatureType.FEATURE,
      placeType: prediction.placeType ?? [],
      addressNumber: prediction.addressNumber ?? "-1",
      properties: prediction.properties ?? Properties(),
      text: prediction.text ?? "No text",
      placeName: prediction.placeName ?? "No name",
      bbox: prediction.bbox ?? [],
      center: prediction.center ?? [],
      geometry: prediction.geometry ?? Geometry(),
      context: prediction.context ?? [],
      matchingText: prediction.matchingText ?? "",
      matchingPlaceName: prediction.matchingPlaceName ?? "",
    );

    // Sets TextField value to be the location selected
    _textEditingController.value = TextEditingValue(
      text: prediction.toString(),
      selection: TextSelection.collapsed(offset: prediction.toString().length),
    );

    // Makes animation
    await _animationController.animateTo(0.5);
    setState(() {
      _placePredictions = [];
      // _selectedPlace = prediction;
    });
    _animationController.reverse();

    // Calls the `onSelected` callback
    widget.onSelected(prediction);
    if (widget.popOnSelect) Navigator.pop(context);
  }
}
