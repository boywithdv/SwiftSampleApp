// Legacy file — replaced by SearchFlow. Kept to avoid .pbxproj changes.
import UIKit
import RxFlow

final class BrowsingFlow: Flow {
    var root: Presentable { UIViewController() }
    func navigate(to step: Step) -> FlowContributors { .none }
}
