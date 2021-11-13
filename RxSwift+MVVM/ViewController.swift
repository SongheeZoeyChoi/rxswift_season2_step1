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

//class

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

//    var disposable : Disposable? // disposable 변수 선언해서 viewWillDisappear에서 dispose() 시킬 수 있음
//    var disposable : [Disposable] = [] // observable 작업 여러개 있는 경우에 Disposable에 등록해놨다가 viewWillDisappear 에서 다 등록 해제 시킬 수도 있음
    // Disposable sugar //
    // 멤버변수라서 viewWillDisappear 에서 특별히 처리해 주지 않아도
    // 해당 클래스 나가면
    // 클래스가 가지고 있는 멤버변수도 날라가면서
    // disposable의 멤버변수인 DisposeBag()도 다 날라감.
    // 이제 여기서 DisposeBag에만 insert()로 observable 담아주면 됨.
    var disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        disposable?.dispose() // 다운받고 있는 도중에 나가면 동작 취소 됨.
//        disposable.forEach{ $0.dispose() } // array로 disposable 등록 해놨다가 컨트롤러 나가면 forEach로 한꺼번에 등록 해제 시킬수도 있음
        
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

    func downloadJson(_ url: String) -> Observable<String> {
        
        // sugar api //
//        return Observable.just("Hello World") // 보내는게 하나일 때 just 쓰면 아래 작업 안해도 됨.
        return Observable.from(["Hello", "World"]) // from은 배열안에 있는 값 하나씩 보냄
        
//        // 데이터 하나 보낼 때 이런식으로 보냄 .. 근데 귀찮잖아! 그럼 위에처럼 사용해보자
//        return Observable.create { emitter in
//            emitter.onNext("Hello World")
//            emitter.onCompleted()
//            return Disposables.create()
//        }
        
        
        
        
//        //TODO: 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
//        return Observable.create() {emitter in
//            let url = URL(string: url)!
//            let task = URLSession.shared.dataTask(with: url) { data, _, err in
//                guard err == nil else {
//                    emitter.onError(err!)
//                    return
//                }
//
//                if let dat = data, let json = String(data: dat,encoding: .utf8) {
//                    emitter.onNext(json) // onNext 여러개 보내도 됨.
//                }
//                emitter.onCompleted() // observable 끝났을때 부름
//            }
//            task.resume()
//
//            return Disposables.create() { // Disposable 리턴
//                task.cancel()
//            }
//        }
        
        
        
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
        
        // Stream zip //
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")
        
        // Disposable 사용 //
//        let d = Observable.zip(jsonObservable, helloObservable) {$1 + "\n" + $0} // 변수 받았다가 넣는것도 귀찮기 때문에
        Observable.zip(jsonObservable, helloObservable) {$1 + "\n" + $0}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
            
        //Observable 변수 만들어서  DisposeBag에 담아줌
//        disposable.insert(d) //이렇게 변수 받았다가 넣는것도 귀찮아서 operator도 있음
        // DisposeBag Operator //
            .disposed(by: disposeBag) // disposed(by: )로 DisposeBag에 해당 Obsevable 담는다!!!
        
        
        
        
//        // Operator //
//        _ = downloadJson(MEMBER_LIST_URL)
//            .map { json in json?.count ?? 0} // operator
//            .filter { cnt in cnt > 0 } // operator
//            .map { "\($0)"} // operator
//            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default)) //어디서 쓰던지 순서 상관없이, 어디에 있든, 어디 쓰레드를 쓰는지 지정해 줌
//            .observeOn(MainScheduler.instance) // sugar api : operator
//            .subscribe(onNext: {json in
////                DispatchQueue.main.async { // 이거 대신에 위에 sugar api 사용 --> observeOn(MainScheduler.instance) 사용할 수 있음
//                    self.editView.text = json
//                    self.setVisibleWithAnimation(self.activityIndicator, false)
////                }
//            })
        
        
        
        
//        // sugar api //
//        _ = downloadJson(MEMBER_LIST_URL)
//            .subscribe(onNext: {print($0)},
//                       onError: {err in print(err)},
//                       onCompleted: {print("완료!")})
        
//        // TODO: 2. Observable로 오는 데이터를 받아서 처리하는 방법
//        // 기본 사용방법
//        _ = downloadJson(MEMBER_LIST_URL)
//            .subscribe { event in
//                switch event {
//                case .next:
//                    print(event)
//                    break
//
//                case .error:
//                    break
//
//                case .completed:
//                    break
//                }
//            }
        
//        downloadJson(MEMBER_LIST_URL)
//            .debug() // debug 넣으면 어떤데이터가 전달되는지 다 찍힘
//            .subscribe { event in // subscribe (==나중에오면) 에서는 event 가 오는데,
//                // event에는 next/completed/error 가 있음
//                switch event {
//                case let .next(json):
//                    DispatchQueue.main.async { // main Thread 가 아닌 곳에서 바꾸려고 하니까 에러 발생하여 넣어줌
//                        self.editView.text = json
//                        self.setVisibleWithAnimation(self.activityIndicator, false)
//                    }
//
//                case .completed:
//                    break
//                case .error:
//                    break
//                }
//            }
       
    }
}




