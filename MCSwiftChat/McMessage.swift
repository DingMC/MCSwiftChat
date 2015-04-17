
import UIKit

enum MessageType{//当前消息的类型
    case Text//文字
    case Picture//图片
    case Voice//声音
}

enum MessageFrom{//当前消息发送方
    case Me//自己
    case Other//别人
}

enum MessageState{//当前发送消息状态
    case Successed//发送成功
    case Sending//发送中
    case Failed//发送失败
}
class McMessage: NSObject {
    var strIcon: String?
    var strId: String?
    var strTime: NSDate?
    var strTime1: String?
    var strName: String?
    
    var strContent: String?
    var picture: UIImage?
    var voice: NSData?
    var voiceURL: NSURL?
    var strVoiceTime: Int?
    
    var type: MessageType = .Text// 消息类型默认是文字
    var from: MessageFrom = .Me// 默认是自己发送
    var state: MessageState = .Successed// 默认消息发送成功
    
    var showDateLabel = true
    
    func setMessageWithDic(dic: NSDictionary){
        self.strIcon = dic["strIcon"] as? String
        self.strId = dic["strId"] as? String
        self.strTime = dic["strTime"] as? NSDate
        self.strName = dic["strName"] as? String
        
        if let from = dic["from"] as? Int{
            if from == 1{
                self.from = .Other
            }
        }
        
        if let type = dic["type"] as? Int{
            switch type{
            case 0:
                self.type = .Text
                self.strContent = dic["strContent"] as? String
                break
            case 1:
                self.type = .Picture
                self.picture = dic["picture"] as? UIImage
                break
            case 2:
                self.type = .Voice
                self.voice = dic["voice"] as? NSData
                self.voiceURL = dic["voiceURL"] as? NSURL
                self.strVoiceTime = dic["strVoiceTime"] as? Int
                break
            default:
                break
            }
        }
    }
    
    func minuteOffSetStart(start: NSDate?, end: NSDate){
        if start == nil{
            self.showDateLabel = true
            return
        }
        
        var timeInterval = end.timeIntervalSinceDate(start!)
        //相距3分钟显示时间Label
        println(timeInterval)
        if fabs(timeInterval) > 3*60{
            self.showDateLabel = true
        }else{
            self.showDateLabel = false
        }
    }
}


