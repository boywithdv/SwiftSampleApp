// Legacy file — replaced by SwiperFlow. Kept to avoid .pbxproj changes.
import UIKit
import RxFlow

final class ReservationFlow: Flow {
    var root: Presentable { UIViewController() }
    func navigate(to step: Step) -> FlowContributors { .none }
}
