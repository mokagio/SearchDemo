import UIKit

class SearchViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var segementControl: UISegmentedControl!

    var tableViews: [UITableView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        segementControl.addTarget(self, action: "switchTableView", forControlEvents: .ValueChanged)

        scrollView.pagingEnabled = true
        scrollView.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillBeShown:",
            name: UIKeyboardWillShowNotification,
            object: .None
        )

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillBeHide:",
            name: UIKeyboardWillHideNotification,
            object: .None
        )

        (0..<segementControl.numberOfSegments).forEach { _ in
            tableViews.append(UITableView())
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableViews.enumerate().forEach { index, tableView in
            tableView.frame = CGRect(
                origin: CGPoint(x: scrollView.frame.size.width * CGFloat(index), y: 0),
                size: scrollView.frame.size
            )

            scrollView.addSubview(tableView)
        }

        scrollView.contentSize = CGSize(
            width: CGFloat(tableViews.count) * scrollView.frame.size.width,
            height: scrollView.frame.size.height
        )
    }

    func switchTableView() {
        guard segementControl.selectedSegmentIndex < tableViews.count else {
            return
        }
        let targetTable = tableViews[segementControl.selectedSegmentIndex]

        scrollView.scrollRectToVisible(targetTable.frame, animated: true)
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)

        guard pageIndex != segementControl.selectedSegmentIndex else {
            return
        }

        segementControl.selectedSegmentIndex = pageIndex
    }

    // MARK: Keyboard

    func keyboardWillBeShown(notification: NSNotification) {
        guard let (duration, keyboardHeight, curveOption) = keyboardAnimationInfo(fromNotification: notification) else {
            return
        }

        UIView.animateWithDuration(
            duration,
            delay: 0,
            options: [curveOption],
            animations: { [weak self] in
                self?.scrollViewBottomConstraint.constant = keyboardHeight
                self?.view.layoutIfNeeded()
            },
            completion: .None
        )
    }

    func keyboardWillBeHide(notification: NSNotification) {
        guard let (duration, _, curveOption) = keyboardAnimationInfo(fromNotification: notification) else {
            return
        }

        UIView.animateWithDuration(
            duration,
            delay: 0,
            options: [curveOption],
            animations: { [weak self] in
                self?.scrollViewBottomConstraint.constant = 0
                self?.view.layoutIfNeeded()
            },
            completion: .None
        )
    }

    func keyboardAnimationInfo(fromNotification notification: NSNotification) -> (
        NSTimeInterval, CGFloat, UIViewAnimationOptions
        )? {
            guard let infoDictionary = notification.userInfo else {
                return .None
            }

            guard let duration = infoDictionary[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval else {
                return .None
            }

            guard let keyboardFrame = (infoDictionary[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else {
                return .None
            }

            guard let rawValue = infoDictionary[UIKeyboardAnimationCurveUserInfoKey] as? Int else {
                return .None
            }
            guard let animationCurve = UIViewAnimationCurve(rawValue: rawValue) else {
                return .None
            }

            return (
                duration,
                keyboardFrame.size.height,
                UIViewAnimationOptions.option(withCurve: animationCurve)
            )
    }
}

extension UIViewAnimationOptions {
    static func option(withCurve curve: UIViewAnimationCurve) -> UIViewAnimationOptions {
        switch curve {
        case .EaseIn: return UIViewAnimationOptions.CurveEaseIn
        case .EaseInOut: return UIViewAnimationOptions.CurveEaseInOut
        case .EaseOut: return UIViewAnimationOptions.CurveEaseOut
        case .Linear: return UIViewAnimationOptions.CurveLinear
        }
    }
}
