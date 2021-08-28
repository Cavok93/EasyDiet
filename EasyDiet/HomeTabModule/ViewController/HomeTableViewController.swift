//
//  HomeTableViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/08/27.
//

import UIKit
import FSCalendar


class HomeTableViewController: UITableViewController {
    


    
    static let identifier = "CalendarCell"
    
    
    enum State {
        case expand
        case shrink
        var selectState: UIImage {
            switch self {
            case .expand:
                let config = UIImage.SymbolConfiguration(pointSize: 10.0)
                let image = UIImage(systemName: "", withConfiguration: config)
                return image ?? UIImage()
            case .shrink:
                let config = UIImage.SymbolConfiguration(pointSize: 10.0)
                let image = UIImage(systemName: "chevron.down", withConfiguration: config)
                return image ?? UIImage()
            }
        }
    }
    
    lazy var visualView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualView = UIVisualEffectView(effect: blurEffect)
        visualView.translatesAutoresizingMaskIntoConstraints = false
        return visualView
    }()
    
    
    private var currentPageDate: Date?
    
    

    
    
    
    
    @IBOutlet weak var calendarBackButton: UIButton!
    @IBOutlet weak var calendarNextButton: UIButton!
    @IBOutlet weak var calendarHeaderLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        self.currentPageDate = cal.date(byAdding: dateComponents, to: self.currentPageDate ?? Date())
        self.calendar.setCurrentPage(self.currentPageDate ?? Date(), animated: true)
    }
    
    
    @objc private func changeNumberOfMemoLabelLine() {
        memoLabel.numberOfLines = memoLabel.numberOfLines == 3 ? 0 : 3
        switch memoLabel.numberOfLines {
        case 3:
            seeMoreButton.setTitle("더보기", for: .normal)
            seeMoreButton.setImage(State.shrink.selectState, for: .normal)
        case 0:
            seeMoreButton.setTitle("접기", for: .normal)
            seeMoreButton.setImage(State.expand.selectState, for: .normal)
        default:
            return
        }
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
        
        guard let navigationController = segue.destination as? UINavigationController, let vc = navigationController.children.first as? DetailTableViewController else { return }
        vc.date = calendar.selectedDate
        switch weightLabel.text == "\(0)" {
        case true:
            print("아직 안설정한 날짜")
        case false:
            let filteredDiaries = diaries.filter { $0.date == calendar.selectedDate }
            vc.diary = filteredDiaries.first
        }
    }
    
    @objc private func toPreviousMonth() {
        scrollCurrentPage(isPrev: true)
    }
    @objc private func toNextMonth() {
        scrollCurrentPage(isPrev: false)
    }
    
    var token:  NSObjectProtocol?
    
    
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    var diaries = [DiaryEntity]()
    
    func configureCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.headerHeight = 0
        calendar.scope = .month
        calendar.appearance.borderRadius = 0
        calendarHeaderLabel.text = calendar.currentPage.formatter
        calendar.appearance.titleWeekendColor = UIColor.systemPink
        calendar.appearance.headerDateFormat = "YYYY년 M월" //달력의 요일 글자 바꾸는 방법 1
        calendar.locale = Locale(identifier: "ko_KR") // 달력의 요일 글자 바꾸는 방법 2
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
        calendar.allowsMultipleSelection = false
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            
            view.tintColor = UIColor.systemGray6
            view.textLabel?.backgroundColor = UIColor.clear
            view.textLabel?.textColor = UIColor.black
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0
        case 1:
            return UITableView.automaticDimension
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return calendar.selectedDate?.sectionFormatter
        default:
            return nil
        }
    }

    
    
    func bmiConverter(_ weight: Float32, _ height: Float32) -> String {
        let result = (weight / ((height / 100) * (height / 100)))
        if result.isNaN {
            return "\(0)"
        }
        return  result.numberFormat
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: HomeTableViewController.identifier)
        diaries = DataManager.shared.fetchDiaryEntity(context: DataManager.shared.mainContext)
        token = NotificationCenter.default.addObserver(forName: Notification.Name.didInputData, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            guard let strongSelf = self else { return }
            strongSelf.diaries = DataManager.shared.fetchDiaryEntity(context: DataManager.shared.mainContext)
            let target = strongSelf.diaries.first
            strongSelf.weightLabel.text = "\(target?.weight ?? 0)"
            strongSelf.heightLabel.text = "\(target?.height ?? 0)"
            strongSelf.memoLabel.text = target?.memo ?? ""
            strongSelf.bmiLabel.text = strongSelf.bmiConverter(target?.weight ?? 0, target?.height ?? 0)
            strongSelf.tableView.reloadData()
            strongSelf.calendar.reloadData()
        }
        configureCalendar()
        seeMoreButton.addTarget(self, action: #selector(changeNumberOfMemoLabelLine), for: .touchUpInside)
        calendarBackButton.addTarget(self, action: #selector(toPreviousMonth), for: .touchUpInside)
        calendarNextButton.addTarget(self, action: #selector(toNextMonth), for: .touchUpInside)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        calendar.select(Date())
    }
    
}

extension HomeTableViewController: FSCalendarDelegate {
    
   

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendarHeaderLabel.text = calendar.currentPage.formatter
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let filteredDiaries = diaries.filter { $0.date == date } //MARK: 선택날짜에 저장되어 있는 데이터 추출
        for diary in filteredDiaries {
            weightLabel.text = "\(diary.weight)"
            heightLabel.text = "\(diary.height)"
            bmiLabel.text = bmiConverter(diary.weight, diary.height)
            return
        }
        weightLabel.text = "\(0)"
        heightLabel.text = "\(0)"
        bmiLabel.text = "\(0)"
        tableView.reloadData()
    }
}

extension HomeTableViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let savedDiaries = diaries.filter { $0.date == date }
        for diary in savedDiaries {
            return "\(diary.weight)"
        }
        return ""
    }
}



extension Float32 {
    var numberFormat: String {
        let str = String(format: "%.2f", self)
        return str
    }
}

extension UITableViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}




