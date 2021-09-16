part of yandex_mapkit;

class DrivingRoute {
  const DrivingRoute(this.geometry, this.metadata, this.waypointsMetadata);

  final List<Point> geometry;
  final DrivingSectionMetadata metadata;
  final List<DrivingSectionMetadata> waypointsMetadata;
}
