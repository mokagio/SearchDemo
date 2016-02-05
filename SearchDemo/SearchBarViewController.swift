import UIKit
import Cartography

class SearchBarViewController: UIViewController {

    let searchBar = UISearchBar()
    let containerView = UIView()

    var verticalCenterConstraint: NSLayoutConstraint!
    var topDistanceConstraint: NSLayoutConstraint!

    let hidesContentBeforeDismissingKeyboard = true

    var childViewController: UIViewController? {
        didSet {
        guard let viewController = childViewController else {
            return
        }

        self.addChildViewController(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        // TODO: Is this necessary?
        viewController.view.setNeedsLayout()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        view.addSubview(searchBar)
        view.addSubview(containerView)

        constrain(searchBar) { view in
            let superview = view.superview!

            view.left == superview.left
            view.right == superview.right
            // No need to set the height, the system enforces it :)
        }
        constrain(containerView) { view in
            let superview = view.superview!

            view.left == superview.left
            view.right == superview.right
            view.bottom == superview.bottom
        }
        constrain(searchBar, containerView) { top, bottom in
            bottom.top == top.bottom
        }

        verticalCenterConstraint = NSLayoutConstraint(
            item: searchBar,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0
        )
        view.addConstraint(verticalCenterConstraint)

        topDistanceConstraint = NSLayoutConstraint(
            item: searchBar,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1,
            constant: view.frame.size.height / 2 - searchBar.frame.size.height / 2
        )
        topDistanceConstraint.priority = UILayoutPriorityDefaultLow
        view.addConstraint(topDistanceConstraint)

        searchBar.delegate = self
        searchBar.placeholder = "What are you looking for?"

        containerView.layer.opacity = 0
    }
}

extension SearchBarViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)

        navigationController?.setNavigationBarHidden(true, animated: true)

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
        let runAnimations: () -> () = { [weak self] in
            searchBar.setShowsCancelButton(false, animated: true)
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
            self?.moveSearchBarToCenter()
        }

        if hidesContentBeforeDismissingKeyboard {
            runAnimations()
        } else {
            hideContainedView {
                runAnimations()
            }
        }

        return true
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if hidesContentBeforeDismissingKeyboard {
            hideContainedView {
                searchBar.resignFirstResponder()
            }
        } else {
            searchBar.resignFirstResponder()
        }
    }

    private func hideContainedView(completion: () -> ()) {
        UIView.animateWithDuration(
            0.2,
            animations: { [weak self] in
                guard let this = self else {
                    return
                }

                this.containerView.layer.opacity = 0

                this.view.layoutIfNeeded()
            },
            completion: { finished in
                guard finished else {
                    return
                }

                completion()
            }
        )
    }

    private func moveSearchBarToCenter(completion: (() -> ())? = .None) {
        topDistanceConstraint.constant = 0

        UIView.animateWithDuration(
            0.3,
            animations: { [weak self] in
                guard let this = self else {
                    return
                }

                this.view.addConstraints([this.verticalCenterConstraint])
                this.topDistanceConstraint.constant = this.view.frame.size.height / 2 - this.searchBar.frame.size.height / 2

                this.view.layoutIfNeeded()
            },
            completion: { finished in
                guard finished else {
                    return
                }
                
                completion?()
            }
        )
    }
}
