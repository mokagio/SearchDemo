import UIKit

class SearchViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var segementControl: UISegmentedControl!

    let leftTableView = UITableView()
    let rightTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        segementControl.addTarget(self, action: "switchTableView", forControlEvents: .ValueChanged)

        scrollView.pagingEnabled = true
        scrollView.delegate = self
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
}
