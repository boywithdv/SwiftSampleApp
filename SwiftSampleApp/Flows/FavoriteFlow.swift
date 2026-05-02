// Legacy file — replaced by MapFlow. Kept to avoid .pbxproj changes.
import UIKit
import RxFlow

final class FavoriteFlow: Flow {
    var root: Presentable { UIViewController() }
    func navigate(to step: Step) -> FlowContributors { .none }
}
