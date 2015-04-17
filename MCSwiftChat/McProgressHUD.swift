import UIKit

class McProgressHUD: UIView {
    var titleLabel: UILabel?
    var subTitleLabel: UILabel?
    var myTimer: NSTimer?
    var angle: Int = 0
    var centerLabel: UILabel?
    var edgeImageView: UIImageView?
    
    class var sharedView: McProgressHUD {//单例模式的使用
        struct Singleton {
            static let instance = McProgressHUD()
        }
        return Singleton.instance
    }
    
    
    class func show(superView:UIView){
        McProgressHUD.sharedView.show(superView)
    }
    
    func show(superView:UIView){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.centerLabel == nil{
                self.centerLabel = UILabel(frame: CGRectMake(0, 0, 150, 40))
                self.centerLabel!.backgroundColor = UIColor.clearColor()
            }
            if self.subTitleLabel == nil{
                self.subTitleLabel = UILabel(frame: CGRectMake(0, 0, 150, 20))
                self.subTitleLabel!.backgroundColor = UIColor.clearColor()
            }
            if self.titleLabel === nil{
                self.titleLabel = UILabel(frame: CGRectMake(0, 0, 150, 20))
                self.titleLabel!.backgroundColor = UIColor.clearColor()
            }
            if self.edgeImageView == nil{
                self.edgeImageView = UIImageView(image: UIImage(named: "chat_record_circle"))
            }
            self.subTitleLabel!.center = CGPointMake(ScreenBounds.width/2, ScreenBounds.height/2 + 30)
            self.subTitleLabel!.text = "上滑取消发送"
            self.subTitleLabel!.textAlignment = NSTextAlignment.Center
            self.subTitleLabel!.font = UIFont.boldSystemFontOfSize(14)
            self.subTitleLabel!.textColor = UIColor.whiteColor()
            
            self.titleLabel!.text = "时间限制"
            self.titleLabel!.center = CGPointMake(ScreenBounds.width/2,ScreenBounds.height/2 - 30)
            self.titleLabel!.textAlignment = NSTextAlignment.Center
            self.titleLabel!.font = UIFont.boldSystemFontOfSize(18)
            self.titleLabel!.textColor = UIColor.whiteColor()
            
            self.centerLabel!.center = CGPointMake(ScreenBounds.width/2, ScreenBounds.height/2)
            self.centerLabel!.text = "60"
            self.centerLabel!.textAlignment = NSTextAlignment.Center
            self.centerLabel!.font = UIFont.systemFontOfSize(30)
            self.centerLabel!.textColor = UIColor.yellowColor()
            
            self.edgeImageView!.frame = CGRectMake(0, 0, 154, 154)
            self.edgeImageView!.center = self.centerLabel!.center
            self.addSubview(self.edgeImageView!)
            self.addSubview(self.centerLabel!)
            self.addSubview(self.subTitleLabel!)
            self.addSubview(self.titleLabel!)
            self.frame = UIScreen.mainScreen().bounds
            self.backgroundColor = UIColor.grayColor()
            self.alpha = 0
            superView.addSubview(self)
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.alpha = 0.4
                }, completion: { (finished: Bool) -> Void in
                    
            })
            self.myTimer?.invalidate()
            self.myTimer = nil
            self.myTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
                target: self,
                selector: "startAnimation",
                userInfo: nil,
                repeats: true)
        })
    }
    func startAnimation(){
        self.angle -= 3
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationRepeatAutoreverses(true)
        if self.edgeImageView != nil{
            self.edgeImageView!.transform = CGAffineTransformMakeRotation(CGFloat(angle)*CGFloat(M_PI/180))
            var second = (self.centerLabel!.text! as NSString).doubleValue
            if second < 10.0{
                self.centerLabel!.textColor = UIColor.redColor()
            }else{
                self.centerLabel!.textColor = UIColor.yellowColor()
            }
            self.centerLabel!.text = "\(second - 0.1)"
        }
        UIView.commitAnimations()
    }
    
    class func changeSubTitle(str:String){
        McProgressHUD.sharedView.setState(str)
    }
    
    func setState(str: String){
        if self.subTitleLabel != nil{
            self.subTitleLabel!.text = str
        }
    }
    
    class func dismissWithSuccess(str: String){
        McProgressHUD.sharedView.dismiss(str)
    }
    class func dismissWithError(str: String){
        McProgressHUD.sharedView.dismiss(str)
    }
    func dismiss(state: String){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.centerLabel != nil && self.edgeImageView != nil && self.subTitleLabel != nil{
                self.myTimer?.invalidate()
                self.myTimer = nil
                self.subTitleLabel!.text = nil
                self.titleLabel!.text = nil
                self.centerLabel!.text = nil
                self.centerLabel!.text = state
                self.centerLabel!.textColor = UIColor.whiteColor()
                var timeLonger: NSTimeInterval!
                if state == "太短啦"{
                    timeLonger = 1.2
                }else{
                    timeLonger = 0.6
                }
                UIView.animateWithDuration(timeLonger, animations: { () -> Void in
                    self.alpha = 0
                    }, completion: { (finished: Bool) -> Void in
                        self.removeFromSuperview()
                        self.centerLabel!.removeFromSuperview()
                        self.centerLabel = nil
                        self.edgeImageView!.removeFromSuperview()
                        self.edgeImageView = nil
                        self.subTitleLabel!.removeFromSuperview()
                        self.subTitleLabel = nil
                })
            }
        })
    }
    
}
