
import UIKit

class McMessageContentView: UIButton {
    var backLabel: UILabel!
    var backImageView: UIImageView!
    var voiceImageView: UIImageView!
    var voiceTimeLabel: UILabel!
    var message: McMessage!
    
    func initContent(message:McMessage){//处理三种不同类型的消息界面...
        self.message = message
        var contentW: CGFloat = ScreenBounds.width - 120
        switch message.type{
        case .Text:
            self.backLabel = UILabel()
            self.backLabel.frame = CGRectMake(5, 5, contentW, 20)
            self.backLabel.textColor = UIColor.blackColor()
            self.backLabel.font = UIFont.systemFontOfSize(14)
            self.backLabel.numberOfLines = 0
            var attributedString = NSMutableAttributedString(string: self.message.strContent!)
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, (self.message.strContent! as NSString).length))
            self.backLabel.attributedText = attributedString
            self.backLabel.sizeToFit()
            self.addSubview(self.backLabel)
            self.bounds.size.width = self.backLabel.bounds.size.width + 10
            self.bounds.size.height = self.backLabel.bounds.size.height + 10
            println(self.backLabel.bounds.size.height)
            if self.backLabel.bounds.size.height < 30 && self.backLabel.bounds.size.height > 20{
                self.bounds.size.height -= 5
            }
            break
        case .Picture:
            self.backImageView = UIImageView()
            self.backImageView.frame = CGRectMake(5, 5, contentW, contentW)
            self.backImageView.image = message.picture!
            if message.picture != nil{
                var pH = message.picture!.size.height
                var pW = message.picture!.size.width
                if pH > pW{
                    self.backImageView.frame.size.width = pW * contentW / pH
                }else{
                    self.backImageView.frame.size.height = pH * contentW / pW
                }
            }
            self.addSubview(self.backImageView)
            self.bounds.size.width = self.backImageView.bounds.size.width + 10
            self.bounds.size.height = self.backImageView.bounds.size.height + 10
            break
        case .Voice:
            self.voiceTimeLabel = UILabel()
            self.voiceTimeLabel.text = "\(self.message.strVoiceTime!)\""
            self.voiceTimeLabel.textColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.8)
            self.voiceTimeLabel.font = UIFont.systemFontOfSize(12)
            self.voiceImageView = UIImageView()
            if message.from == .Me{
                self.voiceTimeLabel.textAlignment = NSTextAlignment.Right
                self.voiceTimeLabel.frame = CGRectMake(5, 5, 45, 25)
                self.voiceImageView.frame = CGRectMake(60, 5, 25, 25)
                self.voiceImageView.image = UIImage(named: "chat_animation_white3.png")
                var imgs = [UIImage]()
                imgs.append(UIImage(named: "chat_animation_white1.png")!)
                imgs.append(UIImage(named: "chat_animation_white2.png")!)
                imgs.append(UIImage(named: "chat_animation_white3.png")!)
                self.voiceImageView.animationImages = imgs
            }else{
                self.voiceTimeLabel.textAlignment = NSTextAlignment.Left
                self.voiceTimeLabel.frame = CGRectMake(40, 5, 45, 25)
                self.voiceImageView.frame = CGRectMake(5, 5, 25, 25)
                self.voiceImageView.image = UIImage(named: "chat_animation3.png")
                var imgs = [UIImage]()
                imgs.append(UIImage(named: "chat_animation1.png")!)
                imgs.append(UIImage(named: "chat_animation2.png")!)
                imgs.append(UIImage(named: "chat_animation3.png")!)
                self.voiceImageView.animationImages = imgs
            }
            self.voiceImageView.animationDuration = 1
            self.voiceImageView.animationRepeatCount = 0
            self.addSubview(voiceTimeLabel)
            self.addSubview(voiceImageView)
            self.bounds.size.width = self.voiceImageView.bounds.size.width + self.voiceTimeLabel.bounds.size.width + 20
            self.bounds.size.height = self.voiceImageView.bounds.size.height + 10
            break
        default:
            break
        }
    }
    
    //MARK: 处理播放语音时的图片动画效果
    func beginLoadVoice(){
        self.voiceImageView.hidden = true
    }
    
    func didLoadVoice(){
        self.voiceImageView.hidden = false
        self.voiceImageView.startAnimating()
    }
    
    func stopPlay(){
        self.voiceImageView.stopAnimating()
    }
    //.......

}
