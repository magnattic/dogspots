import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:dogspots/geopoint_serializer.dart';
import 'package:dogspots/src/spot.dart';

part 'serializers.g.dart';

@SerializersFor([Spot])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(GeoPointSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
