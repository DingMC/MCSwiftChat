import UIKit

class ViewController: UIViewController{

    var chat_tv: McChatTableView!
    var topHeight: CGFloat = 64
    var inputMessageView: McInputMessageView!
    let photohandelHeight: CGFloat = 160
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChange:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChange:", name: UIKeyboardWillHideNotification, object: nil)
        self.createTopView()
        self.initChatView()
    }
    
    func createTopView(){
        let topView = UIView(frame: CGRectMake(0, 0, ScreenBounds.width, topHeight))
        topView.backgroundColor = UIColor.orangeColor()
        self.view.addSubview(topView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initChatView(){//初始聊天界面
        self.inputMessageView = McInputMessageView(frame: CGRectMake(0, ScreenBounds.height - 40, ScreenBounds.width,40), superVc: self)
        self.inputMessageView.delegate = self
        self.view.addSubview(inputMessageView)
        self.chat_tv = McChatTableView(frame: CGRectMake(0, topHeight, ScreenBounds.width, ScreenBounds.height - topHeight-40))
        self.view.addSubview(chat_tv)
        self.chat_tv.scrollToBottom()
    }
    
    func keyboardChange(notification: NSNotification){
        var userInfo = notification.userInfo! as NSDictionary
        var animationDuration = userInfo.valueForKey(UIKeyboardAnimationDurationUserInfoKey) as! NSTimeInterval
        var keyboardEndFrame = (userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue).CGRectValue()
        var rectH = keyboardEndFrame.size.height
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
            if notification.name == UIKeyboardWillShowNotification{
                self.chat_tv.frame.size.height = ScreenBounds.height - self.topHeight - 40 - rectH
                self.inputMessageView.frame.origin.y = ScreenBounds.height - 40 - rectH
            }else{
                self.chat_tv.frame.size.height = ScreenBounds.height - self.topHeight - 40
                self.inputMessageView.frame.origin.y = ScreenBounds.height - 40
            }
        }, completion: nil)
        if notification.name == UIKeyboardWillShowNotification{
            self.chat_tv.scrollToBottom()
        }
    }
}

extension ViewController: McInputMessageViewDelegate{
    func sendMessageText(message: String) {
        var messageDict = NSMutableDictionary()
        messageDict.setValue(message, forKey: "strContent")
        messageDict.setValue(NSDate(), forKey: "strTime")
        messageDict.setValue("蛋羹先生", forKey: "strName")
        messageDict.setValue(0, forKey: "type")
        messageDict.setValue(1, forKey: "from")
        messageDict.setValue("http://sys.bansuikj.com/uploads/idcard/1428054233-0de32994c23efd12dfa2afaf5c6ae6d6.png", forKey: "strIcon")
        var mcMessage = McMessage()
        mcMessage.setMessageWithDic(messageDict)
        self.chat_tv.sendMessage(mcMessage)
    }
    
    func sendMessagePhoto(data: NSData, fileName: String){
        var messageDict = NSMutableDictionary()
        messageDict.setValue(NSDate(), forKey: "strTime")
        messageDict.setValue("发图好玩啊", forKey: "strName")
        messageDict.setValue(1, forKey: "type")
        messageDict.setValue(1, forKey: "from")
        messageDict.setValue("http://sys.bansuikj.com/uploads/idcard/1428054233-0de32994c23efd12dfa2afaf5c6ae6d6.png", forKey: "strIcon")
        messageDict.setValue(UIImage(data: data), forKey: "picture")
        var mcMessage = McMessage()
        mcMessage.setMessageWithDic(messageDict)
        self.chat_tv.sendMessage(mcMessage)
    }
    func sendMessageVoice(voiceURL: NSURL, fileName: String, voiceTime: Int){
        var messageDict = NSMutableDictionary()
        messageDict.setValue(NSDate(), forKey: "strTime")
        messageDict.setValue("说话也好玩", forKey: "strName")
        messageDict.setValue(2, forKey: "type")
        messageDict.setValue(1, forKey: "from")
        messageDict.setValue("http://sys.bansuikj.com/uploads/idcard/1428054233-0de32994c23efd12dfa2afaf5c6ae6d6.png", forKey: "strIcon")
        messageDict.setValue(voiceURL, forKey: "voiceURL")
        messageDict.setValue(voiceTime, forKey: "strVoiceTime")
        var mcMessage = McMessage()
        mcMessage.setMessageWithDic(messageDict)
        self.chat_tv.sendMessage(mcMessage)
    }
}


