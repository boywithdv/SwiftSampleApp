import UIKit

class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // embed tab bar programmatically if needed
        if children.isEmpty {
            // find tab bar controller in storyboard
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let tab = sb.instantiateViewController(withIdentifier: "RootTabBar") as? RootTabBarViewController {
                addChild(tab)
                tab.view.frame = view.bounds
                view.addSubview(tab.view)
                tab.didMove(toParent: self)
            }
        }
    }
}
