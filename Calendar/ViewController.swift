//
//  ViewController.swift
//  Calendar
//
//  Created by Chung EXI-Nguyen on 6/9/22.
//

import UIKit

class CalendarUtils {
    let calendar: Calendar = Calendar.current
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter
    }()
    
    func getFirstDayInMonth(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.month, .year], from: date)

        guard let month = comps.month,
              let year = comps.year,
              let ans = dateFormatter.date(from: "01-\(month)-\(year)") else {
            return Date()
        }
        return ans
    }
    
    func nextMonth(_ date: Date) -> Date {
        guard let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: date) else {
            return Date()
        }
        return getFirstDayInMonth(nextMonthDate)
    }
    
    func prevMonth(_ date: Date) -> Date {
        guard let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: date) else {
            return Date()
        }
        return getFirstDayInMonth(prevMonthDate)
    }
    
    func getWeekDayOffset(_ date: Date) -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return weekday - 1
    }
    
    func getMaxDay(_ date: Date) -> Int {
        let firstDayInCurrentMonth = getFirstDayInMonth(date)
        let fistDayInNextMonth = nextMonth(firstDayInCurrentMonth)
        let diff = calendar.dateComponents([.day],
                                           from: firstDayInCurrentMonth,
                                           to: fistDayInNextMonth)
        return diff.day!
    }
    
    func dateDisplay(_ format: String, _ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}


class ViewModel {
    var currentDate: Date
    var calendarUtils = CalendarUtils()
    var monthString = [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat"
    ]
    
    init() {
        currentDate = calendarUtils.getFirstDayInMonth(Date())
    }
    
    func nextMonth() {
        currentDate = calendarUtils.nextMonth(currentDate)
    }
    
    func prevMonth() {
        currentDate = calendarUtils.prevMonth(currentDate)
    }
    
    func getWeekDayOffSet() -> Int {
        return calendarUtils.getWeekDayOffset(currentDate)
    }
    
    func getMaxDay() -> Int {
        return calendarUtils.getMaxDay(currentDate)
    }
    
    func getMonthDisplay(_ index: Int) -> String {
        guard index < monthString.count else {
            return ""
        }
        return monthString[index]
    }
    
    func getDateDisplay(_ index: Int) -> String {
        // max row = 6, max col = 7
        // offset = 3
        // row of cell 1 = (3 + index(0)) / row(7)
        // col of cell 1 = (3 + index(0)) % row(7)
        
        let offset = getWeekDayOffSet()
        let maxDay = getMaxDay()
        let date = index - offset
        if date >= 0 && date < maxDay {
            return "\(date+1)"
        }
        return ""
    }
    
    func getCurrentMonthYearDislay() -> String {
        calendarUtils.dateDisplay("MM-yyyy", currentDate)
    }
}

class ViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var prevButton: UIBarButtonItem!
    @IBOutlet var nextButton: UIBarButtonItem!
    @IBOutlet var currentDateButton: UIBarButtonItem!
    
    var viewModel: ViewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDelegates()
    }
    
    func setupView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 0,
                                           bottom: 0,
                                           right: 0)
        
        let viewWidth = view.frame.width
        let itemSize = viewWidth / 7
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView.collectionViewLayout = layout
        collectionView.register(DateCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        currentDateButton.tintColor = .label
        
        reloadAllData()
    }
    
    
    func setupDelegates() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @IBAction func buttonTapped(_ barButtonItem: UIBarButtonItem) {
        if barButtonItem == prevButton {
            viewModel.prevMonth()
        } else {
            viewModel.nextMonth()
        }
        reloadAllData()
    }
    
    func reloadAllData() {
        currentDateButton.title = viewModel.getCurrentMonthYearDislay()
        collectionView.reloadData()
    }
}

class DateCollectionViewCell: UICollectionViewCell {
    static let identifier = "DateCollectionViewCell"
    
    private let textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        return textLabel
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.text = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    public func configure(with val: String) {
        textLabel.text = val
        
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 7
        }
        return 7 * 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DateCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let section = indexPath.section
        if section == 0 {
            cell.configure(with: viewModel.getMonthDisplay(indexPath.row))
        } else {
            cell.configure(with: viewModel.getDateDisplay(indexPath.row))
        }
        return cell
    }
}


