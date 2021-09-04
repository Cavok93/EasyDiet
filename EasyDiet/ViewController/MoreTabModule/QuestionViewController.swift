//
//  QuestionViewController.swift
//  EasyDiet
//
//  Created by 심정섭 on 2021/09/03.
//

import UIKit

class QuestionViewController: UIViewController {
    
    struct Question {
        let questionStr: String
        let answerStr: String
        var isExpand: Bool
    }
    
    var list = [
        Question(questionStr: "계산기준일이 언제인가요?", answerStr: "달력 기준으로 가장 먼저 신체정보를 등록한 날입니다.", isExpand: false),
        Question(questionStr: "목표 체중 등록은 어떻게 하나요?", answerStr: "그래프 화면 우측 상단에 '+' 버튼을 탭하시면 등록이 가능합니다.", isExpand: false),
        Question(questionStr: "신체정보 삭제는 어떻게 하나요?", answerStr: "달력 화면 우측 하단의 쓰레기통 아이콘을 탭하시면 삭제가 가능합니다. 전체 데이터 삭제를 하시고자 하는 경우 더보기 화면에서 '전체 데이터 삭제' 를 탭하시면 됩니다. 단, 삭제된 데이터는 복구가 불가능합니다.", isExpand: false)
    ]
    
    @IBOutlet weak var listTableView: UITableView!
    
    private func configureTableView() {
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        listTableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
}

extension QuestionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuestionTableViewCell.identifier, for: indexPath) as? QuestionTableViewCell else { return UITableViewCell() }
        let target = list[indexPath.row]
        cell.questionLabel.text = target.questionStr
        switch target.isExpand  {
        case true:
            cell.answerLabel.text = target.answerStr
            cell.arrowImageView.image = UIImage(systemName: "chevron.up")
            cell.answerLabelTopConstraint.constant = 10
            if  let text = cell.answerLabel.text {
                let font = UIFont.boldSystemFont(ofSize: 20.0)
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: (text as NSString).range(of: "+"))
                attributedString.addAttribute(.font, value: font, range: (text as NSString).range(of: "+"))
            cell.answerLabel.attributedText = attributedString
            }
        case false:
            cell.answerLabel.text = nil
            cell.arrowImageView.image = UIImage(systemName: "chevron.down")
            cell.answerLabelTopConstraint.constant = 0
        }
        return cell
    }
}

extension QuestionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        list[indexPath.row].isExpand = !list[indexPath.row].isExpand
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
