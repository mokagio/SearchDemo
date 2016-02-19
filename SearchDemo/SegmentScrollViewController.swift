import UIKit
import Cartography

class SegmentScrollViewController: UIViewController, UIScrollViewDelegate {

    class Page {
        let title: String
        let view: UIView

        init(title: String, view: UIView) {
            self.title = title
            self.view = view
        }
    }

    var scrollView: UIScrollView!
    var segmentControl: UISegmentedControl!

    var pages: [Page] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentControl = UISegmentedControl(items: pages.map({ $0.title }))
        segmentControl.selectedSegmentIndex = 0
        view.addSubview(segmentControl)

        scrollView = UIScrollView()
        view.addSubview(scrollView)

        let segmentControlPadding: CGFloat = 8

        constrain(segmentControl) { view in
            let superview = view.superview!

            view.width == superview.width * 0.8
            view.top == superview.top + segmentControlPadding
            view.centerX == superview.centerX
            // No need to set the height, the system enforses it :)
        }

        constrain(scrollView) { view in
            let superview = view.superview!

            view.left == superview.left
            view.right == superview.right
            view.bottom == superview.bottom
        }

        constrain(segmentControl, scrollView) { top, bottom in
            top.bottom == bottom.top - segmentControlPadding
        }

        segmentControl.addTarget(self, action: "switchTableView", forControlEvents: .ValueChanged)

        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
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
}
