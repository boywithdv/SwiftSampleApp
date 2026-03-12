//
//  TileDetailViewModel.swift
//  SwiftSampleApp
//
//  Created by 佃 寿希也 on 2026/03/12.
//

import Foundation
import Combine
import RxFlow
import RxCocoa

final class TileDetailViewModel: ObservableObject, Stepper {

    // MARK: - Stepper
    let steps = PublishRelay<Step>()

    // MARK: - Published
    @Published private(set) var item: HomeTileItem

    // MARK: - Initialization
    init(item: HomeTileItem) {
        self.item = item
    }
}
