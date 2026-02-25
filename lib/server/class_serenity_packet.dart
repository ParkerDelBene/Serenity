/// SerenityPacketType is only used to communicate along the text channels
///
/// It is not used on the voice channels, as the volume of data is too large,
/// and all the data sent along the voice channels are assumed to be voice data.
///
/// serenityInitPacket = sending over the initPacket
///
/// text = sending a chat message Format-> channelName;message
///
/// userInfo = sending / receiving serenityUser data
enum SerenityPacketTypeEnum {
  serenityInitPacket,
  serenityUpdatePacket,
  serverIcon,
  serverBanner,
  text,
  userInfo,
}

/// The SerenityPacket is uses as the data passed along the text Channel to
/// filter the types of data. It is not used with voice data to mitigate
/// overhead.
///
/// The SerenityPacket uses the SerenityPacketTypeEnum as the type filter, and
/// then has the data as a json serialized String, to be deserialized after the
/// type has been checked.
class SerenityPacket {
  const SerenityPacket(this.type, this.data);
  SerenityPacket.fromMap(Map<String, dynamic> json)
      : type = SerenityPacketTypeEnum.values.byName(json["type"]),
        data = json["data"];

  final SerenityPacketTypeEnum type;
  final dynamic data;

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "data": data,
    };
  }
}
