import UIKit
import Cartography

class SearchViewController: UIViewController, UIScrollViewDelegate {

    class Page {
        let title: String
        let view: UIView

        init(title: String, view: UIView) {
            self.title = title
            self.view = view
        }
    }

    var scrollView: UIScrollView!
    let constrainGroup = ConstraintGroup()
    var segmentControl: UISegmentedControl!

    var pages: [Page] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        pages = [
            Page(title: "First", view: UITableView()),
            Page(title: "Second", view: UITableView()),
        ]

        segmentControl = UISegmentedControl(items: pages.map({ $0.title }))
        segmentControl.selectedSegmentIndex = 0
        view.addSubview(segmentControl)

        scrollView = UIScrollView()
        view.addSubview(scrollView)

        constrain(segmentControl) { view in
            guard let superView = view.superview else {
                return
            }

            // Height picked from the IB default. How to make it resilient to
            // changes in iOS default values?
            view.height == 28
            view.width == superView.width * 0.8
            view.top == superView.top + 8
            view.centerX == superView.centerX
        }

        constrain(scrollView) { view in
            guard let superView = view.superview else {
                return
            }

            view.left == superView.left
            view.right == superView.right
            view.bottom == superView.bottom
        }

        constrain(segmentControl, scrollView) { top, bottom in
            top.bottom == bottom.top - 8
        }

        segmentControl.addTarget(self, action: "switchTableView", forControlEvents: .ValueChanged)

        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false

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

        pages
            .map { $0.view }
            .enumerate()
            .forEach { index, view in
                view.frame = CGRect(
                    origin: CGPoint(x: scrollView.frame.size.width * CGFloat(index), y: 0),
                    size: scrollView.frame.size
                )
                // TODO: Is this the best call we can make?
                view.layoutIfNeeded()

                scrollView.addSubview(view)
        }

        scrollView.contentSize = CGSize(
            width: CGFloat(pages.count) * scrollView.frame.size.width,
            height: scrollView.frame.size.height
        )
    }

    func switchTableView() {
        guard segmentControl.selectedSegmentIndex < pages.count else {
            return
        }
        let targetTable = pages.map({ $0.view })[segmentControl.selectedSegmentIndex]

        scrollView.scrollRectToVisible(targetTable.frame, animated: true)
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)

        guard pageIndex != segmentControl.selectedSegmentIndex else {
            return
        }

        segmentControl.selectedSegmentIndex = pageIndex
    }

    // MARK: Keyboard

    func keyboardWillBeShown(notification: NSNotification) {
        guard let (duration, keyboardHeight, curveOption) = keyboardAnimationInfo(fromNotification: notification) else {
            return
        }

        constrain(scrollView, replace: constrainGroup) { view in
            guard let superView = view.superview else {
                return
            }

            view.bottom == superView.bottom - keyboardHeight
        }

        UIView.animateWithDuration(
            duration,
            delay: 0,
            options: [curveOption],
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            },
            completion: .None
        )
    }

    func keyboardWillBeHide(notification: NSNotification) {
        guard let (duration, _, curveOption) = keyboardAnimationInfo(fromNotification: notification) else {
            return
        }

        constrain(scrollView, replace: constrainGroup) { view in
            guard let superView = view.superview else {
                return
            }

            view.bottom == superView.bottom
        }

        UIView.animateWithDuration(
            duration,
            delay: 0,
            options: [curveOption],
            animations: { [weak self] in
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
