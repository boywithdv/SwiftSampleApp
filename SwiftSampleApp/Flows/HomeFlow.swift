// Legacy file — replaced by TimelineFlow. Kept to avoid .pbxproj changes.
import UIKit
import RxFlow

final class HomeFlow: Flow {
    var root: Presentable { UIViewController() }
    func navigate(to step: Step) -> FlowContributors { .none }
}
