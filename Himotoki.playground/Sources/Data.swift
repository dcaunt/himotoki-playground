import Foundation

public func JSONObjectFromPlaygroundResource(_ name: String, ext: String) -> AnyObject {
    let resourceURL = Bundle.main.url(forResource: name, withExtension: ext)
    let data = try? Data(contentsOf: resourceURL!)
    return try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject
}
