import UIKit
import RxFlow
import RxSwift
import RxCocoa

final class SplashViewController: UIViewController, Stepper {
    // MARK: - Properties
    let steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Beauty Sample App"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        // 初回に実行される
        super.viewDidLoad()
        // UIのセットアップ
        setupUI()
        // スプラッシュアニメーションの開始
        startSplashAnimation()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        // viewにテキストラベルを追加する
        view.addSubview(titleLabel)
        // テキストラベルのレイアウトを設定する
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Animation
    private func startSplashAnimation() {
        // 1秒後にホーム画面に遷移する
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.steps.accept(AppStep.splashComplete)
        }
    }
}
