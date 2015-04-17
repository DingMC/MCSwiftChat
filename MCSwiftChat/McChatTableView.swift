
import UIKit

class McChatTableView: UITableView, UITableViewDataSource, UITableViewDelegate{
    var cellArray = [McMessage]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.dataSource = self
        self.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.separatorStyle = UITableViewCellSeparatorStyle.None
        self.backgroundColor = ChatBackgroundColor
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return cellArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        return cell.frame.size.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = McMessageCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellId")
        var curMessage = cellArray[indexPath.row]
        if indexPath.row > 0{
            curMessage.minuteOffSetStart(cellArray[indexPath.row-1].strTime, end: curMessage.strTime!)
        }else{
            curMessage.minuteOffSetStart(nil, end: curMessage.strTime!)
        }
        cell.setMessageFrame(curMessage)
        cell.frame.size.height = cell.cellHeight!
        return cell
    }
    
    func scrollToBottom(){//显示最后一行消息
        if self.cellArray.count > 0 {
            var indexPath = NSIndexPath(forRow: self.cellArray.count - 1, inSection: 0)
            self.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
    }
    
    //MARK: 数据源处理
    func loadHistory(){//加载历史聊天记录...需要数据持久化处理...
        
    }
    
    func sendMessage(message: McMessage){//新曾消息记录
        self.cellArray.append(message)
        self.reloadData()
        self.scrollToBottom()
    }

}
