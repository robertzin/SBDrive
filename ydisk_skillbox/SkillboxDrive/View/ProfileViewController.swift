//
//  ProfileViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 18.11.2022.
//

import UIKit
import SnapKit
import Charts

final class ProfileViewController: UIViewController {
    
    private var totalSpace: Double?
    private var usedSpace: Double?
    private var activityIndicator = UIActivityIndicatorView()
    
    private var pieChart = PieChartView()
    var presenter: ProfilePresenterPrototol!
    
    private lazy var button: UIButton = {
        var container = AttributeContainer()
        container.font = Constants.Fonts.button

        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(Constants.Text.uploadedFiles, attributes: container)
        configuration.image = Constants.Image.chevronR
        configuration.imagePadding = 108.0
        configuration.imagePlacement = .trailing
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.backgroundColor = .white
        
        // title
        button.setTitle(Constants.Text.uploadedFiles, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        
        // shadow
        button.layer.borderWidth = 0.25
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 2.0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowColor = Constants.Colors.details?.cgColor
        return button
    }()
    
    private lazy var noConnectionLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.noInternet
        label.font = Constants.Fonts.small
        label.textColor = .white
        label.textAlignment = .center
        label.center = view.center
        return label
    }()
    
    private lazy var noConnectionView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = Constants.Colors.noConnection
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleConnectionLabel(notification: Notification(name: NSNotification.Name(rawValue:  "connectivityStatusChanged")))
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectionLabel(notification:)), name: NSNotification.Name(rawValue:  "connectivityStatusChanged"), object: nil)
        view.backgroundColor = .white
        presenter.getDiskInfo()
        setupViews()
    }
    
    @objc func handleConnectionLabel(notification: Notification) {
            if NetworkMonitor.shared.isConnected {
//                debugPrint("Connected")
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1, delay: 0.15) {
                        self.viewDissapear(view: self.noConnectionView)
                    } completion: { _ in
                        self.noConnectionLabel.removeFromSuperview()
                        self.noConnectionView.removeFromSuperview()
                    }
                }
            } else {
//                debugPrint("Not connected")
                DispatchQueue.main.async {
                    self.view.addSubview(self.noConnectionView)
                    self.noConnectionView.snp.makeConstraints { make in
                        make.width.equalToSuperview()
                        make.height.equalTo(40)
                        make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                    }
                    
                    self.noConnectionView.addSubview(self.noConnectionLabel)
                    self.noConnectionLabel.snp.makeConstraints { make in
                        make.width.equalTo(self.noConnectionView)
                        make.height.equalTo(self.noConnectionView)
                        make.centerX.equalTo(self.noConnectionView.snp.centerX)
                    }
                    UIView.animate(withDuration: 1, delay: 0.15) {
                        self.viewAppear(view: self.noConnectionView)
                    }
                }
            }
        }
    
    private func viewDissapear(view: UIView) { view.alpha = 0 }
    
    private func viewAppear(view: UIView) { view.alpha = 1 }
    
    func configureButton() {
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(16)
            make.height.equalTo(45)
            make.top.equalTo(pieChart.snp.bottom).offset(32)
        }
        
        button.addAction(UIAction(handler: { [weak self] action in
            self?.presenter.pushVC()
        }), for: .touchUpInside)
    }
    
    private func configurePieChart() {
        pieChart.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide.layoutFrame.width * 100 / 157)
            make.height.equalTo(view.safeAreaLayoutGuide.layoutFrame.height * 10 / 13)
            make.centerX.equalToSuperview()
        }
        let usedSpaceString = String(format: "%.2f", usedSpace! / 1000000000.00)
        let leftSpaceString = String(format: "%.2f", (totalSpace! - usedSpace!) / 1000000000.00)
        let totalSpaceString = String(format: "%.0f", totalSpace! / 1000000000.00)
        
        var entries: [ChartDataEntry] = []
        entries.append(PieChartDataEntry(value: usedSpace!, label: "\(Constants.Text.occupied) - \(usedSpaceString) \(Constants.Text.gb)"))
        entries.append(PieChartDataEntry(value: totalSpace!, label: "\(Constants.Text.left) - \(leftSpaceString) \(Constants.Text.gb)"))
        let set = PieChartDataSet(entries: entries, label: "")
        set.selectionShift = 0
        
        var colors: [UIColor] = []
        colors.append(Constants.Colors.accent2!)
        colors.append(Constants.Colors.details!)
        set.colors = colors
        
        let data = PieChartData(dataSet: set)
        pieChart.data = data
        pieChart.sliceTextDrawingThreshold = .infinity
        pieChart.holeRadiusPercent = CGFloat(0.65)
        pieChart.rotationEnabled = false
//        pieChart.clipsToBounds = true
        
        let centerText = "\(totalSpaceString) \(Constants.Text.gb)"
        let attributes: [NSAttributedString.Key: Any] = [.font: Constants.Fonts.header2!]
        let attrString = NSAttributedString(string: centerText, attributes: attributes)
        pieChart.centerAttributedText = attrString
        
        let legend = pieChart.legend
        legend.font = Constants.Fonts.mainBody!
        legend.orientation = .vertical
        legend.form = .circle
        legend.verticalAlignment = .bottom
        legend.yOffset = -15
        legend.yEntrySpace = 21
        legend.formSize = 21
        
        configureButton()
    }
    
    private func setupViews() {
        view.addSubview(pieChart)
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(140)
        }
        
        navigationItem.backButtonTitle = ""
        navigationItem.title = Constants.Text.profile
        navigationItem.rightBarButtonItem = makeRightButton()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Constants.Fonts.header2!]
    }
    
    private func makeRightButton() -> UIBarButtonItem {
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(buttonPressed))
        rightButton.tintColor = Constants.Colors.details
        return rightButton
    }
    
    @objc private func buttonPressed() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let msgAttributes = [NSAttributedString.Key.font: Constants.Fonts.small!, NSAttributedString.Key.foregroundColor: Constants.Colors.details]
        let msgString = NSAttributedString(string: Constants.Text.profile, attributes: msgAttributes as [NSAttributedString.Key : Any])
        let quitAction = UIAlertAction(title: Constants.Text.logOut, style: .destructive, handler: {_ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            
            let attributedStringTitle = NSAttributedString(string: Constants.Text.quit, attributes: [NSAttributedString.Key.font: Constants.Fonts.header2!])
            let attributedStringMessage = NSAttributedString(string: Constants.Text.wantLogOut, attributes: [NSAttributedString.Key.font: Constants.Fonts.mainBody!])
            
            let yesAction = UIAlertAction(title: Constants.Text.yes, style: .default) { [weak self] action in
                self?.presenter.performLogOut()
                self?.dismiss(animated: true)
            }
            alert.setValue(attributedStringTitle, forKey: "attributedTitle")
            alert.setValue(attributedStringMessage, forKey: "attributedMessage")
            alert.addAction(yesAction)
            alert.addAction(UIAlertAction(title: Constants.Text.no, style: .destructive))
            
            self.navigationController?.present(alert, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: Constants.Text.cancel, style: .cancel, handler: nil)
        
        alert.setValue(msgString, forKey: "attributedMessage")
        alert.addAction(quitAction)
        alert.addAction(cancelAction)
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension ProfileViewController: ProfileProtocol {
    func pushVC(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func success(dict: [String:AnyObject]) {
        handleConnectionLabel(notification: Notification(name: NSNotification.Name(rawValue:  "connectivityStatusChanged")))
        DispatchQueue.main.async { [weak self] in
            self?.totalSpace = dict["total_space"] as? Double
            self?.usedSpace = dict["used_space"] as? Double
            self?.configurePieChart()
            self?.activityIndicator.stopAnimating()
        }
    }
}

extension String {
    func toDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy HH:mm"
        
        let parsedDate = dateFormatter.date(from: self)
        return dateFormatterPrint.string(from: parsedDate ?? Date())
    }
}
