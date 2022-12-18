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
    
    private var token = ""
    private var totalSpace: Double?
    private var usedSpace: Double?
    
    private var pieChart = PieChartView()
    private let urlString = "https://cloud-api.yandex.net/v1/disk/"
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        do { token = try KeyChain.shared.getToken() }
        catch { print("error while getting token in ProfileVC: \(error.localizedDescription)") }
        setupViews()
        getData()
    }
    
    private func getData() {
        NetworkService.shared.fileDownload(urlString: urlString) { [weak self] result in
            switch result {
            case .success(let data):
                let dict = NetworkService.shared.JSONtoDictionary(dataString: data!)
//                for i in dict! {
//                    print(i)
//                }
                DispatchQueue.main.async {
                    self?.totalSpace = dict!["total_space"] as? Double
                    self?.usedSpace = dict!["used_space"] as? Double
                    self?.configurePieChart()
                }
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    func configureButton() {
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(16)
            make.height.equalTo(45)
            make.top.equalTo(pieChart.snp.bottom).offset(32)
        }
        
        button.addAction(UIAction(handler: { action in
            let vc = PublishedMainViewController()
            vc.presenter = PublishedMainPresenter(view: vc, networkService: NetworkService.shared)
            self.navigationController?.pushViewController(vc, animated: true)
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
            
            let yesAction = UIAlertAction(title: Constants.Text.yes, style: .default) { action in
                self.logOut()
                self.dismiss(animated: true)
                PresenterManager.shared.show(vc: .login)
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
    
    private func logOut() {
        do { try KeyChain.shared.deleteToken() }
        catch { print("error while deleting token: \(error.localizedDescription)") }
        CoreDataManager.shared.deleteAllEntities()
        
        var request = URLRequest(url: URL(string: "https://oauth.yandex.ru/revoke_token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let dataString = "access_token=\(token)&client_id=\(Constants.clientId)&client_secret=\(Constants.clientSecret)"
        let data : Data = dataString.data(using: .utf8)!
        request.httpBody = data
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("Success")
                default:
                    print("Status: \(response.statusCode)")
                }
            }
        }.resume()
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
