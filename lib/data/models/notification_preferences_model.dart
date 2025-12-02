import 'package:json_annotation/json_annotation.dart';

part 'notification_preferences_model.g.dart';

@JsonSerializable()
class NotificationPreferencesModel {
  final bool priceDrops;
  final bool newDiscounts;
  final bool stockAlerts;
  final bool generalNews;

  const NotificationPreferencesModel({
    this.priceDrops = true,
    this.newDiscounts = true,
    this.stockAlerts = false,
    this.generalNews = false,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesModelToJson(this);

  NotificationPreferencesModel copyWith({
    bool? priceDrops,
    bool? newDiscounts,
    bool? stockAlerts,
    bool? generalNews,
  }) {
    return NotificationPreferencesModel(
      priceDrops: priceDrops ?? this.priceDrops,
      newDiscounts: newDiscounts ?? this.newDiscounts,
      stockAlerts: stockAlerts ?? this.stockAlerts,
      generalNews: generalNews ?? this.generalNews,
    );
  }
}
