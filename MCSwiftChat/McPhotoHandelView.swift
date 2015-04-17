import UIKit
protocol McPhotoHandelViewDelegate{
    func handelPhoto(data:NSData,fileName:String)
}
class McPhotoHandelView: UIView, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var delegate: McPhotoHandelViewDelegate?
    var toImageBtn = UIButton()
    var toCameraBtn = UIButton()
    var superVc: UIViewController!
    let btnSize: CGSize = CGSize(width: 120, height: 40)
    init(frame: CGRect, superVc: UIViewController) {
        super.init(frame: frame)
        self.superVc = superVc
        toImageBtn.frame = CGRectMake((frame.width - btnSize.width)/2, 20, btnSize.width, btnSize.height)
        toImageBtn.setTitle("相册", forState: UIControlState.Normal)
        toImageBtn.backgroundColor = UIColor.lightGrayColor()
        toImageBtn.layer.cornerRadius = 4
        toImageBtn.layer.masksToBounds = true
        toImageBtn.addTarget(self, action: "goImage", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(toImageBtn)
        
        toCameraBtn.frame = CGRectMake((frame.width - btnSize.width)/2, 40 + btnSize.height, btnSize.width, btnSize.height)
        toCameraBtn.setTitle("拍照", forState: UIControlState.Normal)
        toCameraBtn.backgroundColor = UIColor.lightGrayColor()
        toCameraBtn.layer.cornerRadius = 4
        toCameraBtn.layer.masksToBounds = true
        toCameraBtn.addTarget(self, action: "goCamera", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(toCameraBtn)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //打开相机
    func goCamera(){
        println("----gpCamera")
        //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
        var sourceType = UIImagePickerControllerSourceType.Camera
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true//设置可编辑
        picker.sourceType = sourceType
        self.superVc.presentViewController(picker, animated: true, completion: nil)//进入照相界面
    }
    
    func goImage(){
        var pickerImage = UIImagePickerController()
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            pickerImage.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            pickerImage.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickerImage.sourceType)!
        }
        pickerImage.delegate = self
        pickerImage.allowsEditing = true
        self.superVc.presentViewController(pickerImage, animated: true, completion: nil)
    }
    
    //选择好照片后choose后执行的方法
    var uploadImgUrl:NSURL?
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        println("choose--------->>")
        var img = info[UIImagePickerControllerOriginalImage] as! UIImage
        var smallImg = self.scaleFromImage(img, size: CGSize(width: img.size.width * 0.8,height: img.size.height * 0.8))
        println(img.size)
        println(smallImg.size)
        var pathExtension = "png"
        if let imgUrl = info[UIImagePickerControllerReferenceURL] as? NSURL{
            pathExtension = imgUrl.pathExtension!
        }
        var format = NSDateFormatter()
        format.dateFormat="yyyyMMddHHmmss"
        var currentFileName = "\(format.stringFromDate(NSDate())).\(pathExtension)"//"\(appDelegate.user.id!)-avatar-\(format.stringFromDate(NSDate())).\(pathExtension)"
        var imageData = UIImagePNGRepresentation(smallImg)
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var documentsDirectory : AnyObject = paths[0]
        var fullPathToFile = documentsDirectory.stringByAppendingPathComponent(currentFileName)
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(fullPathToFile) {
            // probably won't happen. want to do something about it?
            println("photo exists")
        }else{
            
        }
        imageData.writeToFile(fullPathToFile, atomically: false)
        uploadImgUrl = NSURL(fileURLWithPath: fullPathToFile)
        var data = NSData(contentsOfFile: self.uploadImgUrl!.path!)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        println("choose----ss----->>")
        self.delegate?.handelPhoto(data!, fileName: currentFileName)
        println("choose----ssssssss----->>")
    }
    
    //修改图片尺寸
    func scaleFromImage(image:UIImage,size:CGSize)->UIImage{
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //cancel后执行的方法
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        println("cancel--------->>")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
}
