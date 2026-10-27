class Chamada {

  String callerId;
  String callerName;
  String callerPic;
  String receiverId;
  String receiverName;
  String receiverPic;
  String channelId;
  bool hasDialled;

  Chamada({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.channelId,
    this.hasDialled,
  });

  Map<String, dynamic> toMap(Chamada chamada) {
    Map<String, dynamic> chamadaMap = Map();
    chamadaMap["caller_id"] = chamada.callerId;
    chamadaMap["caller_name"] = chamada.callerName;
    chamadaMap["caller_pic"] = chamada.callerPic;
    chamadaMap["receiver_id"] = chamada.receiverId;
    chamadaMap["receiver_name"] = chamada.receiverName;
    chamadaMap["receiver_pic"] = chamada.receiverPic;
    chamadaMap["channel_id"] = chamada.channelId;
    chamadaMap["has_dialled"] = chamada.hasDialled;
    return chamadaMap;
  }

  Chamada.fromMap(Map chamadaMap) {
    this.callerId = chamadaMap["caller_id"];
    this.callerName = chamadaMap["caller_name"];
    this.callerPic = chamadaMap["caller_pic"];
    this.receiverId = chamadaMap["receiver_id"];
    this.receiverName = chamadaMap["receiver_name"];
    this.receiverPic = chamadaMap["receiver_pic"];
    this.channelId = chamadaMap["channel_id"];
    this.hasDialled = chamadaMap["has_dialled"];
  }

}