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
    private let defaultWeight: Float32 = 0.0
    private let defaultHeight: Float32 = 0.0
    private let defaultBmi: Float32 = 0.0
    private let defaultMemo: String = ""
    private var currentPageDate: Date?
    private var token:  NSObjectProtocol?
    private var diaries = [DiaryEntity]()
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarBackButton: UIButton!
    @IBOutlet weak var calendarNextButton: UIButton!
    @IBOutlet weak var calendarHeaderLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var currentInformationView: UIView!
    @IBOutlet weak var dateControlStackView: UIStackView!
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        self.currentPageDate = cal.date(byAdding: dateComponents, to: self.currentPageDate ?? Date())
        self.calendar.setCurrentPage(self.currentPageDate ?? Date(), animated: true)
    }
    
    private func didSelectCalendarRow(_ calendar: FSCalendar) {
        let filteredDiaries = diaries.filter { $0.date == calendar.selectedDate } //MARK: 선택날짜에 저장되어 있는 데이터 추출
        if filteredDiaries.isEmpty {
            weightLabel.text = "\(defaultWeight)"
            heightLabel.text = "\(defaultHeight)"
            memoLabel.text = defaultMemo
            bmiLabel.text = "\(defaultBmi)"
        } else {
            for diary in filteredDiaries {
                weightLabel.text = "\(diary.weight)"
                heightLabel.text = "\(diary.height)"
                memoLabel.text = diary.memo
                bmiLabel.text = bmiConverter(diary.weight, diary.height)
            }
        }
        tableView.reloadData()
    }
    
    private func bmiConverter(_ weight: Float32, _ height: Float32) -> String {
        let result = (weight / ((height / 100) * (height / 100)))
        if result.isNaN {
            return "\(defaultBmi)"
        }
        return  result.numberFormat
    }
    
    private func configureCalendar() {
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
    
    private func configureTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    @objc private func changeNumberOfMemoLabelLine() {
        memoLabel.numberOfLines = memoLabel.numberOfLines == 3 ? 0 : 3
        switch memoLabel.numberOfLines {
        case 3:
            seeMoreButton.setTitle("더보기", for: .normal)
        case 0:
            seeMoreButton.setTitle("접기", for: .normal)
        default:
            return
        }
        tableView.reloadData()
    }
    
    @objc private func toPreviousMonth() {
        if currentPageDate ?? Date() < calendar.minimumDate {
            scrollCurrentPage(isPrev: false)
        } else {
            scrollCurrentPage(isPrev: true)
        }
    }
    
    @objc private func toNextMonth() {
        if currentPageDate ?? Date() > calendar.maximumDate {
            scrollCurrentPage(isPrev: true)
        } else {
            scrollCurrentPage(isPrev: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
        print(diaries.count)
        guard let navigationController = segue.destination as? UINavigationController, let vc = navigationController.children.first as? DetailTableViewController else { return }
        vc.dateForTopTitle = calendar.selectedDate
        let filteredDiaries = diaries.filter { $0.date == calendar.selectedDate }
        vc.diary = filteredDiaries.first
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendar.layer.shadowColor = UIColor.black.cgColor
        calendar.layer.shadowOffset = CGSize(width: 0, height: 0)
        calendar.layer.cornerRadius = 12
        calendar.layer.shadowRadius = 12
        calendar.layer.shadowOpacity = 0.1
        calendar.layer.masksToBounds = false
        calendar.layer.shadowPath = UIBezierPath(roundedRect: self.calendar.bounds, cornerRadius: calendar.layer.cornerRadius).cgPath
        
        dateControlStackView.layer.shadowColor = UIColor.black.cgColor
        dateControlStackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        dateControlStackView.layer.cornerRadius = 12
        dateControlStackView.layer.shadowRadius = 12
        dateControlStackView.layer.shadowOpacity = 0.1
        dateControlStackView.layer.masksToBounds = false
        dateControlStackView.layer.shadowPath = UIBezierPath(roundedRect: self.dateControlStackView.bounds, cornerRadius: dateControlStackView.layer.cornerRadius).cgPath
        
        currentInformationView.layer.shadowColor = UIColor.black.cgColor
        currentInformationView.layer.shadowOffset = CGSize(width: 0, height: 0)
        currentInformationView.layer.cornerRadius = 12
        currentInformationView.layer.shadowRadius = 12
        currentInformationView.layer.shadowOpacity = 0.1
        currentInformationView.layer.masksToBounds = false
        currentInformationView.layer.shadowPath = UIBezierPath(roundedRect: self.currentInformationView.bounds, cornerRadius: currentInformationView.layer.cornerRadius).cgPath
        
     
        
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCalendar()
        configureTableView()
        calendar.select(Date())
        diaries = DataManager.shared.fetchDiaryEntity(context: DataManager.shared.mainContext)
        token = NotificationCenter.default.addObserver(forName: Notification.Name.didInputData, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            guard let strongSelf = self else { return }
            strongSelf.diaries = DataManager.shared.fetchDiaryEntity(context: DataManager.shared.mainContext)
            strongSelf.weightLabel.text = "\(Operation.shared.weight ?? strongSelf.defaultWeight)"
            strongSelf.heightLabel.text = "\(Operation.shared.height ?? strongSelf.defaultHeight)"
            strongSelf.memoLabel.text = Operation.shared.memo ?? strongSelf.defaultMemo
            strongSelf.bmiLabel.text = strongSelf.bmiConverter(Operation.shared.weight ?? strongSelf.defaultWeight, Operation.shared.height ?? strongSelf.defaultHeight)
            strongSelf.calendar.reloadData()
            strongSelf.tableView.reloadData()
            
            if Operation.shared.isSave == true {
                strongSelf.showToast(message: "저장되었습니다.")
            } else if Operation.shared.isSave == false {
                strongSelf.showToast(message: "수정되었습니다.")
            } else if Operation.shared.isSave == nil {
                strongSelf.showToast(message: "삭제되었습니다.")
            }
        }
        seeMoreButton.addTarget(self, action: #selector(changeNumberOfMemoLabelLine), for: .touchUpInside)
        calendarBackButton.addTarget(self, action: #selector(toPreviousMonth), for: .touchUpInside)
        calendarNextButton.addTarget(self, action: #selector(toNextMonth), for: .touchUpInside)
        didSelectCalendarRow(calendar)
    }
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

extension HomeTableViewController: FSCalendarDelegate {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print(calendar)
        calendarHeaderLabel.text = calendar.currentPage.formatter
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        didSelectCalendarRow(calendar)
    }
    func minimumDate(for calendar: FSCalendar) -> Date {
        let minumunDate = Date()
        let cal = Calendar.current
        let dateComponents = DateComponents()
        let targetDay = cal.date(byAdding: dateComponents, to: minumunDate)
        guard let targetDay = targetDay else { return Date()}
        return targetDay.addingTimeInterval( -2.year)
        
    }
    func maximumDate(for calendar: FSCalendar) -> Date {
        let maximumDate = Date()
        let cal = Calendar.current
        let dateComponents = DateComponents()
        let targetDay = cal.date(byAdding: dateComponents, to: maximumDate)
        guard let targetDay = targetDay else { return Date()}
        return targetDay.addingTimeInterval( 2.year)
    }
}

extension HomeTableViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let savedDiaries = diaries.filter { $0.date == date }
        for diary in savedDiaries {
            return "\(diary.weight)kg"
        }
        return ""
    }
}




