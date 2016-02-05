import UIKit

class SearchViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var segementControl: UISegmentedControl!

    let leftTableView = UITableView()
    let rightTableView = UITableView()

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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        leftTableView.frame = CGRect(origin: .zero, size: scrollView.frame.size)
        rightTableView.frame = CGRect(
            origin: CGPoint(x: scrollView.frame.size.width, y: 0),
            size: scrollView.frame.size
        )

        scrollView.contentSize = CGSize(
            width: 2 * scrollView.frame.size.width,
            height: scrollView.frame.size.height
        )

        scrollView.addSubview(leftTableView)
        scrollView.addSubview(rightTableView)
    }

    func switchTableView() {
        switch segementControl.selectedSegmentIndex {
        case 0:
            scrollView.scrollRectToVisible(leftTableView.frame, animated: true)
        case 1:
            scrollView.scrollRectToVisible(rightTableView.frame, animated: true)
        case _:
            break
        }
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
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
