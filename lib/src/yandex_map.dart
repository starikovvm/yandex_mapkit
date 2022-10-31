part of yandex_mapkit;

/// Android specific settings for [YandexMap].
class AndroidYandexMap {
  /// Whether to render [YandexMap] with a [AndroidViewSurface] to build the Google Maps widget.
  ///
  /// This implementation uses hybrid composition to render the YandexMap Widget on Android.
  /// This comes at the cost of some performance on Android versions below 10.
  /// See https://flutter.dev/docs/development/platform-integration/platform-views#performance for more information.
  ///
  /// Defaults to true.
  static bool useAndroidViewSurface = true;
}

/// A widget which displays a map using Yandex maps service.
class YandexMap extends StatefulWidget {
  /// A `Widget` for displaying Yandex Map
  const YandexMap({
    Key? key,
    this.onMapCreated,
    this.onMapTap,
    this.onMapLongTap,
    this.onMapSizeChanged,
    this.onMapRendered,
  }) : super(key: key);

  static const String viewType = 'yandex_mapkit/yandex_map';

  /// Callback method for when the map is ready to be used.
  ///
  /// Pass to [YandexMap.onMapCreated] to receive a [YandexMapController] when the
  /// map is created.
  final MapCreatedCallback? onMapCreated;

  /// Called once when [YandexMap] is first rendered on screen.
  ///
  /// The difference between [YandexMap.onMapCreated] and this callback
  /// is that [YandexMap.onMapCreated] is called before the map is actually rendered.
  ///
  /// This happens because native view creation is asynchronous.
  /// Our widget is created before flutter sizes and paints the corresponding native view.
  final GenericCallback? onMapRendered;

  /// Called every time a [YandexMap] is resized.
  final ArgumentCallback<MapSize>? onMapSizeChanged;

  /// Called every time a [YandexMap] is tapped.
  final ArgumentCallback<Point>? onMapTap;

  /// Called every time a [YandexMap] is long tapped.
  final ArgumentCallback<Point>? onMapLongTap;

  @override
  _YandexMapState createState() => _YandexMapState();
}

class _YandexMapState extends State<YandexMap> {
  YandexMapController? _controller;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (AndroidYandexMap.useAndroidViewSurface) {
        return PlatformViewLink(
            viewType: YandexMap._viewType,
            surfaceFactory:
                (BuildContext context, PlatformViewController controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: widget.gestureRecognizers,
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: YandexMap._viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: _creationParams(),
                creationParamsCodec: StandardMessageCodec(),
                onFocus: () => params.onFocusChanged(true),
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
                ..create();
            });
      } else {
        return AndroidView(
          viewType: YandexMap._viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: _creationParams(),
        );
      }
    } else {
      return UiKitView(
        viewType: YandexMap.viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
        },
      );
    }
  }

  void _onPlatformViewCreated(int id) {
    _controller = YandexMapController.init(id, this);

    if (widget.onMapCreated != null) {
      widget.onMapCreated!(_controller!);
    }
  }

  void onMapRendered() {
    if (widget.onMapRendered != null) {
      widget.onMapRendered!();
    }
  }

  void onMapSizeChanged(MapSize size) {
    if (widget.onMapSizeChanged != null) {
      widget.onMapSizeChanged!(size);
    }
  }

  void onMapTap(Point point) {
    if (widget.onMapTap != null) {
      widget.onMapTap!(point);
    }
  }

  void onMapLongTap(Point point) {
    if (widget.onMapLongTap != null) {
      widget.onMapLongTap!(point);
    }
  }
}
