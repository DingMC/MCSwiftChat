import UIKit
import AVFoundation
class McMessageCell: UITableViewCell {

    var avatarBtnView: UIButton!
    var messageView: McMessageContentView!
    var timeLable: UILabel!
    var nameLabel: UILabel!
    var message: McMessage!
    
    var cellHeight: CGFloat?
    
//    var player: AVAudioPlayer!
    var audio: McAVAudioPlayer!
    
    let Margin: CGFloat = 10//内间距
    let AvatarWH: CGFloat = 44//头像宽高
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        //1.创建时间
        self.timeLable = UILabel()
        self.timeLable.textAlignment = NSTextAlignment.Center
        self.timeLable.textColor = TimeLabelTextColor
        self.timeLable.font = ChatTimeFont
        self.contentView.addSubview(self.timeLable)
        //2.创建头像
        self.avatarBtnView = UIButton()
        self.avatarBtnView.layer.cornerRadius = 4
        self.avatarBtnView.layer.masksToBounds = true
        self.contentView.addSubview(avatarBtnView)
        //3.创建姓名
        self.nameLabel = UILabel()
        self.nameLabel.textAlignment = NSTextAlignment.Center
        self.nameLabel.textColor = TimeLabelTextColor
        self.nameLabel.font = ChatTimeFont
        self.contentView.addSubview(self.nameLabel)
        //4.创建聊天框
        self.messageView = McMessageContentView()
        self.messageView.layer.cornerRadius = 4
        self.messageView.layer.masksToBounds = true
        self.messageView.addTarget(self, action: "didMessageView", forControlEvents: UIControlEvents.TouchUpInside)
        self.contentView.addSubview(self.messageView)
        
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置cell的内容Frame
    func setMessageFrame(message: McMessage){
        self.message = message
        //1.计算时间的位置
        if self.message.showDateLabel{
            var format = NSDateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.timeLable.text = format.stringFromDate(self.message!.strTime!)
            self.timeLable.sizeToFit()
            self.timeLable.center = CGPoint(x: ScreenBounds.width/2, y: self.timeLable.frame.height/2 + 10)
        }
        
        //2.计算头像的位置
        var avatarY = self.timeLable.frame.height + Margin + 10
        var avatarX: CGFloat!
        var nameX: CGFloat!
        if self.message.from == .Other{
            avatarX = 10
            nameX = 10
            self.nameLabel.textAlignment = NSTextAlignment.Left
            self.messageView.backgroundColor = UIColor.whiteColor()
        }else{
            self.messageView.backgroundColor = UIColor.greenColor()
            avatarX = ScreenBounds.width - 10 - AvatarWH
            nameX = ScreenBounds.width - 80
            self.nameLabel.textAlignment = NSTextAlignment.Right
        }
        self.avatarBtnView.frame = CGRectMake(avatarX, avatarY, AvatarWH, AvatarWH)
        let url:NSURL = NSURL(string: self.message!.strIcon!)!
        let request:NSURLRequest = NSURLRequest(URL:url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{(response:NSURLResponse!,data:NSData!,error:NSError!)->Void in
            if data != nil{
                let img = UIImage(data: data)
                if img != nil{
                    self.avatarBtnView.setBackgroundImage(img, forState: UIControlState.Normal)
                }
            }
        })
        
        //3.计算姓名的位置
        var nameY = avatarY + self.avatarBtnView.frame.height
        self.nameLabel.frame = CGRectMake(nameX, nameY, 70, 20)
        self.nameLabel.text = self.message.strName
        
        //4.消息内容处理
        var messageY = self.timeLable.frame.height + Margin + 10
        self.messageView.initContent(message)
        self.messageView.frame.origin.y = messageY
        if self.message.from == .Me{
            self.messageView.frame.origin.x = ScreenBounds.width - 15 - AvatarWH - self.messageView.frame.size.width
        }else{
            self.messageView.frame.origin.x = avatarX + AvatarWH + 5
        }
        self.cellHeight = max(nameY + self.nameLabel.frame.height, messageY + self.messageView.frame.height) + Margin
    }
    
    //MARK: 处理点击聊天类容事件
    func didMessageView(){
        switch self.message.type{
        case .Text:
            break
        case .Picture:
            break
        case .Voice:
            self.audio = McAVAudioPlayer.sharedInstance
            self.audio.delegate = self
            if self.message.voice != nil{
                self.audio.playSongWithData(self.message.voice!)
            }else if self.message.voiceURL != nil{
                self.audio.playSongWithUrl(self.message.voiceURL!)
            }
            break
        default:
            break
        }
    }
}

extension McMessageCell: McAVAudioPlayerDelegate{
    func McAVAudioPlayerBeiginLoadVoice(){
        self.messageView.beginLoadVoice()
    }
    func McAVAudioPlayerBeiginPlay(){
        self.messageView.didLoadVoice()
    }
    func McAVAudioPlayerDidFinishPlay(){
        self.messageView.stopPlay()
        McAVAudioPlayer.sharedInstance.stopSound()
    }
}
