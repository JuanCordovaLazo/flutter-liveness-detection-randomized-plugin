import 'dart:convert';

LivenessDetectionLabelModel livenessDetectionLabelModelFromJson(String str) =>
    LivenessDetectionLabelModel.fromJson(json.decode(str));

String livenessDetectionLabelModelToJson(LivenessDetectionLabelModel data) =>
    json.encode(data.toJson());

class LivenessDetectionLabelModel {
  String? blink;
  String? lookUp;
  String? lookDown;
  String? lookRight;
  String? lookLeft;
  String? smile;
  String? lookForward;

  LivenessDetectionLabelModel({
    this.blink,
    this.lookUp,
    this.lookDown,
    this.lookRight,
    this.lookLeft,
    this.smile,
    this.lookForward,
  });

  factory LivenessDetectionLabelModel.fromJson(Map<String, dynamic> json) =>
      LivenessDetectionLabelModel(
        blink: json["blink"],
        lookUp: json["lookUp"],
        lookDown: json["lookDown"],
        lookRight: json["lookRight"],
        lookLeft: json["lookLeft"],
        smile: json["smile"],
        lookForward: json["lookForward"],
      );

  Map<String, dynamic> toJson() => {
    "blink": blink,
    "lookUp": lookUp,
    "lookDown": lookDown,
    "lookRight": lookRight,
    "lookLeft": lookLeft,
    "smile": smile,
    "lookForward": lookForward,
  };
}
