//
//  RxSwiftStateFlowHostingViewController.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI

/// SwiftUI の RxSwiftStateFlowView を UIKit 世界で扱うためのラッパー
final class RxSwiftStateFlowHostingViewController: UIHostingController<RxSwiftStateFlowView> {

    private let viewModel: RxSwiftStateFlowViewModel

    init(viewModel: RxSwiftStateFlowViewModel) {
        self.viewModel = viewModel
        super.init(rootView: RxSwiftStateFlowView(viewModel: viewModel))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
