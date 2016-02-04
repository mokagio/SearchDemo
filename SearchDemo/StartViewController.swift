import UIKit

class StartViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var verticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet var topDistanceConstraint: NSLayoutConstraint!
    @IBOutlet var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self

        containerView.layer.opacity = 0
    }
}

extension StartViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)

        navigationController?.setNavigationBarHidden(true, animated: true)

        topDistanceConstraint.constant = view.frame.size.height / 2 - searchBar.frame.size.height / 2

        UIView.animateKeyframesWithDuration(0.6, delay: 0, options: [], animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: { [weak self] in
                guard let this = self else {
                    return
                }

                this.view.removeConstraints([this.verticalCenterConstraint])
                this.topDistanceConstraint.constant = 0
                this.view.layoutIfNeeded()
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { [weak self] in
                guard let this = self else {
                    return
                }

                this.containerView.layer.opacity = 1
                this.view.layoutIfNeeded()
            })
        }, completion: .None)

        return true
    }

    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)

        topDistanceConstraint.constant = 0

        UIView.animateWithDuration(0.3) { [weak self] in
            guard let this = self else {
                return
            }

            this.view.addConstraints([this.verticalCenterConstraint])
            this.topDistanceConstraint.constant = this.view.frame.size.height / 2 - this.searchBar.frame.size.height / 2

            this.view.layoutIfNeeded()
        }

        return true
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        UIView.animateWithDuration(
            0.3,
            animations: { [weak self] in
                guard let this = self else {
                    return
                }

                this.containerView.layer.opacity = 0

                this.view.layoutIfNeeded()
            },
            completion: { finished in
                searchBar.resignFirstResponder()
            }
        )
    }
}
