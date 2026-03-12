//
//  CombineLearningHostingViewController.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI

/// SwiftUI の CombineLearningView を UIKit 世界で扱うためのラッパー
final class CombineLearningHostingViewController: UIHostingController<CombineLearningView> {

    private let viewModel: CombineLearningViewModel

    init(viewModel: CombineLearningViewModel) {
        self.viewModel = viewModel
        super.init(rootView: CombineLearningView(viewModel: viewModel))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
