import 'dart:ui';

/// Name: SerenityClientConfig
///
/// Last Updated: 03/12/26
///
/// Last Updater: Parker DelBene
///
/// Function: This class holds the settings that dictate how the client looks.
class SerenityClientConfig {
  const SerenityClientConfig(this.primaryColor, this.secondaryColor,
      this.highlightColor, this.textColor);

  SerenityClientConfig.fromJson(Map<String, dynamic> json)
      : primaryColor = Color(json["primaryColor"]),
        secondaryColor = Color(json["secondaryColor"]),
        highlightColor = Color(json["highlightColor"]),
        textColor = Color(json["textColor"]);

  final Color primaryColor;
  final Color secondaryColor;
  final Color highlightColor;
  final Color textColor;

  Map<String, dynamic> toJson() {
    return {
      "primaryColor": primaryColor.toARGB32(),
      "secondaryColor": secondaryColor.toARGB32(),
      "highlightColor": highlightColor.toARGB32(),
      "textColor": textColor.toARGB32(),
    };
  }
}
