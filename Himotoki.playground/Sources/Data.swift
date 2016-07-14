import Foundation

public func JSONObjectFromPlaygroundResource(name: String, ext: String) -> AnyObject {
    let resourceURL = NSBundle.mainBundle().URLForResource(name, withExtension: ext)
    let data = NSData(contentsOfURL: resourceURL!)
    return try! NSJSONSerialization.JSONObjectWithData(data!, options: [])
}
