// Legacy file — replaced by ProfileFlow. Kept to avoid .pbxproj changes.
import UIKit
import RxFlow

final class MyPageFlow: Flow {
    var root: Presentable { UIViewController() }
    func navigate(to step: Step) -> FlowContributors { .none }
}
