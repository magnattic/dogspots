import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogspots/serializers.dart';

part 'spot.g.dart';

abstract class Spot implements Built<Spot, SpotBuilder> {
  Spot._();
  factory Spot([void Function(SpotBuilder) updates]) = _$Spot;

  String get name;
  GeoPoint get pos;
  @nullable
  String get description;
  String get category;
  bool get isFenced;

  Map<String, dynamic> toJson() {
    return serializers.serializeWith(Spot.serializer, this);
  }

  static Spot fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(Spot.serializer, json);
  }

  static Serializer<Spot> get serializer => _$spotSerializer;
}
