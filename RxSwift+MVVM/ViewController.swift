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
    
    // Observable의 생명주기
    // 1. create
    // 2. Subscribe
    // 3. onNext
    //===== 끝 =======
    // 4. onCompleted / onError
    // 5. Disposed : 동작이 끝난 옵저버블은 다시 재사용 못함

    func downloadJson(_ url: String) -> Observable<String?> {
        //TODO: 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        return Observable.create() {emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { data, _, err in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                
                if let dat = data, let json = String(data: dat,encoding: .utf8) {
                    emitter.onNext(json) // onNext 여러개 보내도 됨.
                }
                emitter.onCompleted() // observable 끝났을때 부름
            }
            task.resume()
            
            return Disposables.create() { // Disposable 리턴
                task.cancel()
            }
        }
        
//        return Observable.create() { f in // Observable.create() 로 observable 만듦
//            DispatchQueue.global().async {
//                let url = URL(string: url)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//
//                DispatchQueue.main.async {
//                    f.onNext(json) // onNext 메소드 통해서 전달(리턴)해주고
//                    f.onCompleted() // reference count 순환참조 없애주는 역할 (클로저가 없어지면서 순환참조없어짐)
//                }
//            }
//            return Disposables.create()
//        }
        
    }
        
    
    // MARK: SYNC

    // RxSwift : 비동기적으로 나중에 생기는 데이터를 리턴 값으로 전달해주는 것.
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        // TODO: 2. Observable로 오는 데이터를 받아서 처리하는 방법
        downloadJson(MEMBER_LIST_URL)
            .debug() // debug 넣으면 어떤데이터가 전달되는지 다 찍힘
            .subscribe { event in // subscribe (==나중에오면) 에서는 event 가 오는데,
                // event에는 next/completed/error 가 있음
                switch event {
                case let .next(json):
                    DispatchQueue.main.async { // main Thread 가 아닌 곳에서 바꾸려고 하니까 에러 발생하여 넣어줌
                        self.editView.text = json
                        self.setVisibleWithAnimation(self.activityIndicator, false)
                    }
                    
                case .completed:
                    break
                case .error:
                    break
                }
            }
        
    }
}




