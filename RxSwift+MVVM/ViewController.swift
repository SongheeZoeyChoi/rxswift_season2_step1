//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

//class Ob

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

        func downloadJson(_ url: String) -> Observable<String?> {
            // [21.10.31] TODO: 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
            return Observable.create() { f in // Observable.create() 로 observable 만듦
            DispatchQueue.global().async {
                let url = URL(string: url)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    f.onNext(json) // onNext 메소드 통해서 전달(리턴)해주고
                    f.onCompleted() // reference count 순환참조 없애주는 역할 (클로저가 없어지면서 순환참조없어짐)
                }
            }
            return Disposables.create()
        }
        
    }
        
    
    // MARK: SYNC

    // RxSwift : 비동기적으로 나중에 생기는 데이터를 리턴 값으로 전달해주는 것.
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        // [21.10.31] TODO: 2. Observable로 오는 데이터를 받아서 처리하는 방법
        downloadJson(MEMBER_LIST_URL)
            .subscribe { event in // subscribe (==나중에오면) 에서는 event 가 오는데,
                // event에는 next/completed/error 가 있음
                switch event {
                case let .next(json):
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                case .completed:
                    break
                case .error:
                    break
                }
            }
        
    }
}




