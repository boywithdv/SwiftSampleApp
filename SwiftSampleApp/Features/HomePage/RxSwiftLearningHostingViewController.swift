//
//  RxSwiftLearningHostingViewController.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI

/// SwiftUI の RxSwiftLearningView を UIKit 世界で扱うためのラッパー
final class RxSwiftLearningHostingViewController: UIHostingController<RxSwiftLearningView> {

    private let viewModel: RxSwiftLearningViewModel

    init(viewModel: RxSwiftLearningViewModel) {
        self.viewModel = viewModel
        super.init(rootView: RxSwiftLearningView(viewModel: viewModel))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
