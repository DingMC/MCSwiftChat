import UIKit
protocol McInputMessageViewDelegate: NSObjectProtocol{
    func sendMessageText(message: String)
    func sendMessagePhoto(data: NSData, fileName: String)
    func sendMessageVoice(voiceURL: NSURL, fileName: String, voiceTime: Int)
}
class McInputMessageView: UIView, UITextViewDelegate, UITextFieldDelegate{
    var delegate: McInputMessageViewDelegate?
    
    var inputTextView: UITextView!
    var sendMessageBtn: UIButton!
    var isAbleToSendText = false
    
    var sendPhotoBgView: UIImageView!
    var sendPhotoBtn: UITextField!
    var mcPhotoHandelView: McPhotoHandelView!
    
    var voiceOrTextBtn: UIButton!
    var pressToRecorderBtn: UIButton!
    
    var superVc: UIViewController!
    init(frame: CGRect, superVc: UIViewController) {
        super.init(frame: frame)
        self.backgroundColor = InputViewBackgroundColor
        self.superVc = superVc
        //输入框
        self.inputTextView = UITextView()
        self.inputTextView.frame = CGRectMake(45, 5, frame.width - 90, frame.height - 10)
        self.inputTextView.layer.cornerRadius = 4
        self.inputTextView.layer.masksToBounds = true
        self.inputTextView.delegate = self
        self.addSubview(inputTextView)
        
        //文字发送按钮
        self.sendMessageBtn = UIButton(frame: CGRectMake(frame.width - 40, 5, 35, frame.height - 10))
        self.sendMessageBtn.setBackgroundImage(UIImage(named: "chat_send_message.png"), forState: UIControlState.Normal)
        self.sendMessageBtn.setTitle("发送", forState: UIControlState.Normal)
        self.sendMessageBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        self.sendMessageBtn.addTarget(self, action: "didSendMessageBtn", forControlEvents: UIControlEvents.TouchUpInside)
        self.sendMessageBtn.hidden = true
        self.addSubview(sendMessageBtn)
        
        //弹出选择图片按钮
        self.mcPhotoHandelView = McPhotoHandelView(frame: CGRectMake(0, 0, ScreenBounds.width, 160), superVc: superVc)
        self.mcPhotoHandelView.delegate = self
        self.sendPhotoBgView = UIImageView(frame: CGRectMake(frame.width - 37.5, 5, 30, 30))
        self.sendPhotoBgView.image = UIImage(named: "chat_take_picture.png")
        self.sendPhotoBgView.userInteractionEnabled = true
        self.addSubview(sendPhotoBgView)
        
        self.sendPhotoBtn = UITextField(frame: CGRectMake(0, 0, 30, 30))
        self.sendPhotoBtn.layer.cornerRadius = 15
        self.sendPhotoBtn.layer.masksToBounds = true
        self.sendPhotoBtn.backgroundColor = UIColor.clearColor()
        self.sendPhotoBtn.inputView = self.mcPhotoHandelView
        self.sendPhotoBtn.tintColor = UIColor.clearColor()
        self.sendPhotoBtn.delegate = self
        self.sendPhotoBgView.addSubview(sendPhotoBtn)
        
        //切换语音和文字输入框按钮
        self.voiceOrTextBtn = UIButton(frame: CGRectMake(5, 5, 30, 30))
        self.voiceOrTextBtn.setBackgroundImage(UIImage(named: "chat_input_message.png"), forState: UIControlState.Normal)
        self.voiceOrTextBtn.setBackgroundImage(UIImage(named: "chat_voice_record.png"), forState: UIControlState.Selected)
        self.voiceOrTextBtn.addTarget(self, action: "didVoiceOrTextBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(voiceOrTextBtn)
        
        //按下开始录音按钮
        self.pressToRecorderBtn = UIButton(frame: CGRectMake(80, 5, frame.width - 160, frame.height - 10))
        self.pressToRecorderBtn.layer.cornerRadius = 4
        self.pressToRecorderBtn.layer.masksToBounds = true
        self.pressToRecorderBtn.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.pressToRecorderBtn.layer.borderWidth = 1
        self.pressToRecorderBtn.backgroundColor = UIColor.whiteColor()
        self.pressToRecorderBtn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        self.pressToRecorderBtn.setTitle("按住说话", forState: UIControlState.Normal)
        self.pressToRecorderBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        self.pressToRecorderBtn.addTarget(self, action: "beginRecordVoice:", forControlEvents: UIControlEvents.TouchDown)
        self.pressToRecorderBtn.addTarget(self, action: "endRecordVoice:", forControlEvents: UIControlEvents.TouchUpInside)
        self.pressToRecorderBtn.addTarget(self, action: "cancelRecordVoice:", forControlEvents: UIControlEvents.TouchUpOutside)
        self.pressToRecorderBtn.addTarget(self, action: "RemindDragExit:", forControlEvents: UIControlEvents.TouchDragExit)
        self.pressToRecorderBtn.addTarget(self, action: "RemindDragEnter:", forControlEvents: UIControlEvents.TouchDragEnter)
        self.pressToRecorderBtn.hidden = true
        self.addSubview(pressToRecorderBtn)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didVoiceOrTextBtn(btn: UIButton){//点击切换语音和文字输入
        btn.selected = !btn.selected
        if btn.selected{
            self.inputTextView.resignFirstResponder()
            self.sendPhotoBtn.resignFirstResponder()
            self.inputTextView.hidden = true
            self.pressToRecorderBtn.hidden = false
        }else{
            self.inputTextView.hidden = false
            self.pressToRecorderBtn.hidden = true
        }
    }
    
    func getStringLength(str:NSString)->Int{
        return str.length
    }
    
    func getCurBtnShowType(){
        if self.getStringLength(inputTextView.text) > 0{
            self.sendMessageBtn.hidden = false
            self.sendPhotoBgView.hidden = true
        }else{
            self.sendMessageBtn.hidden = true
            self.sendPhotoBgView.hidden = false
        }

    }
    
    //MARK: 处理语音按钮的各种方法-----
    var mcRecorder = McRecorderController.sharedInstance
    var recorderTime: Int!
    var recorderTimer: NSTimer!
    func beginRecordVoice(button: UIButton){
        println("--------begin")
        mcRecorder.delegate = self
        mcRecorder.toRecord()
        if self.mcRecorder.recorder != nil{
            recorderTime = 0
            self.recorderTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countVoiceTime", userInfo: nil, repeats: true)
            McProgressHUD.show(self.superVc.view)
        }
    }
    func endRecordVoice(button: UIButton?){
        println("--------send")
        if self.recorderTimer != nil{
            mcRecorder.stopRecord()
            self.recorderTimer?.invalidate()
            self.recorderTimer = nil
        }
    }
    
    func cancelRecordVoice(button: UIButton){
        println("--------cancel")
        if self.recorderTimer != nil{
            mcRecorder.cancelRecord()
            self.recorderTimer?.invalidate()
            self.recorderTimer = nil
        }
        McProgressHUD.dismissWithError("录音取消")
    }
    func RemindDragExit(button: UIButton){
        McProgressHUD.changeSubTitle("松开取消发送")
    }
    func RemindDragEnter(button: UIButton){
        McProgressHUD.changeSubTitle("上滑取消发送")
    }
    func countVoiceTime(){
        println("--------\(recorderTime)")
        self.recorderTime!++
        if recorderTime >= 60{
            self.endRecordVoice(nil)
        }
    }
    //-------------------------------------------

    
    //MARK: text的delegate代理方法------
    func textViewDidBeginEditing(textView: UITextView) {
        self.getCurBtnShowType()
    }
    
    func textViewDidChange(textView: UITextView) {
       self.getCurBtnShowType()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.getCurBtnShowType()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.voiceOrTextBtn.selected = false
        self.inputTextView.hidden = false
        self.pressToRecorderBtn.hidden = true
    }
    //--------------------------------
    
    //MARK: 发送消息----
    func didSendMessageBtn(){
        if self.getStringLength(inputTextView.text) > 0{
            self.inputTextView.resignFirstResponder()
            self.sendPhotoBtn.resignFirstResponder()
            self.delegate?.sendMessageText(self.inputTextView.text)
            self.inputTextView.text = ""
            self.getCurBtnShowType()
        }
    }
}

extension McInputMessageView: McPhotoHandelViewDelegate{
    func handelPhoto(data:NSData,fileName:String){
        self.delegate?.sendMessagePhoto(data, fileName: fileName)
    }
}

extension McInputMessageView: McRecorderControllerDelegate{
    func failRecord(failedStr: String){
        McProgressHUD.dismissWithError(failedStr)
        
        //缓冲消失时间（最好有回调消失完成)
        self.pressToRecorderBtn.enabled = false
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.pressToRecorderBtn.enabled = true
        })

    }
    func endConvertWithData(voiceURL: NSURL, fileName: String, voiceTime: Int){
        self.delegate?.sendMessageVoice(voiceURL, fileName: fileName, voiceTime: voiceTime)
        McProgressHUD.dismissWithSuccess("录音成功")
        
        //缓冲消失时间（最好有回调消失完成）
        self.pressToRecorderBtn.enabled = false
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.pressToRecorderBtn.enabled = true
        })

    }
}
