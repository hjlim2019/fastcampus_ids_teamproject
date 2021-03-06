//
//  MyPageViewController.swift
//  WeatherSound
//
//  Created by HyunJomi on 2017. 8. 7..
//  Copyright © 2017년 HyunJung. All rights reserved.
//

import UIKit
import SDWebImage


class MyPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var myPageTableView: UITableView!
    
    @IBOutlet weak var userInfoViewContainer: UIView!
    @IBOutlet weak var userInfoView: UIView! //배경
    @IBOutlet weak var backgroundProfileImageView: UIImageView!//프로필사진배경
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet weak var profileImgView: UIImageView! //프로필사진
    @IBOutlet weak var profileLable: UILabel!
    @IBOutlet weak var myListButton: UIButton!
    
    let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let indicatorContainer: UIView = UIView()
    
    var loginVC: LoginViewController?
    
    //    var userPlayLists: [UserPlayList] = []

    //MARK:- view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myPageTableView.register(UINib.init(nibName: "EditMyListTableViewCell", bundle: nil), forCellReuseIdentifier: EditMyListTableViewCell.reuseId)
        
        self.myPageTableView.delegate = self
        self.myPageTableView.dataSource = self
        
        self.myPageTableView.separatorStyle = .none
        
        self.prepareView()
        
        self.showIndicator()

        //user profile request
        
        if UserDefaults.standard.bool(forKey: Authentication.isLoginSucceed){
            LoginDataCenter.shared.requestUserInfoFromServer(with: UserDefaults.standard.integer(forKey: Authentication.pk),
                                                             token: UserDefaults.standard.string(forKey: Authentication.token)!,
                                                             comletion: {
                                                                self.setProfie()
                                                                
                                                                //user play list request
                                                                DataCenter.shared.getMyList { (userPlayLists) in
                                                                    self.myPageTableView.reloadData()
                                                                    self.indicatorContainer.removeFromSuperview()
                                                                }
            })
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        print("isLoginSucceed: ",UserDefaults.standard.bool(forKey: Authentication.isLoginSucceed))
//        print("LoginDataCenter.shared.myLoginInfo: ",LoginDataCenter.shared.myLoginInfo ?? "no data in LoginDataCenter.shared.myLoginInfo")
        
        if UserDefaults.standard.bool(forKey: Authentication.isLoginSucceed) == false && LoginDataCenter.shared.myLoginInfo == nil { // 로그아웃 상태
            print("logout----mypage vc will appear")
            let storyboard = UIStoryboard.init(name: "LoginAndSignup", bundle: nil)
            self.loginVC = storyboard.instantiateViewController(withIdentifier: "Login") as? LoginViewController
            
            self.loginVC?.reqCompletionBlock = {
                self.setProfie()
                
                //user play list request
                DataCenter.shared.getMyList { (userPlayLists) in
                    self.myPageTableView.reloadData()
                    self.indicatorContainer.removeFromSuperview()
                    
                    self.loginVC?.dismiss(animated: false, completion: nil)
                }
            }
            
            self.loginVC?.modalPresentationStyle = .overFullScreen
            self.present(loginVC!, animated: false, completion: nil)
       
        }else{
            print("login----mypage vc will appear")
            self.myPageTableView.reloadData()
            self.indicatorContainer.removeFromSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewwilldisappear")
        self.myPageTableView.reloadData()
    }
    
    func didLoginReloadData() {
        
        print("didLoginReloadData")
        
        self.myPageTableView.reloadData()
        
    }
    
    //MARK:- method
    func backToHome(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func hamHandler(){
        
        let sideMenuVC: SideMenuViewController = SideMenuViewController(nibName: "SideMenuViewController", bundle: nil)
        sideMenuVC.modalPresentationStyle = .overFullScreen
        
        self.present(sideMenuVC, animated: true, completion: nil)
    }
    
    func prepareView(){
        //navigation barbuttonItem 추가
        let leftBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        let attributedLeftString: NSMutableAttributedString = NSMutableAttributedString(string: "< HOME", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.26, blue:0.28, alpha:1.00)])
        leftBtn.setAttributedTitle(attributedLeftString, for: .normal)
        leftBtn.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "hamMenu"), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.addTarget(self, action: #selector(hamHandler), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        let rect = self.view.bounds
        
        self.myPageTableView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height-55)
        self.userInfoViewContainer.frame = CGRect(x: 0, y: 0, width: rect.width, height: 300)
        self.userInfoView.frame = CGRect(x: 0, y: 0, width: rect.width, height: 245)
        self.myListButton.frame = CGRect(x: rect.minX+20, y: self.userInfoView.frame.maxY+12.5,width: rect.width, height: 30)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "내 리스트 편집  > ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold), NSForegroundColorAttributeName: UIColor(red:0.29, green:0.56, blue:0.89, alpha:1.00)])
        self.myListButton.contentHorizontalAlignment = .left
        self.myListButton.setAttributedTitle(attributedString, for: .normal)
        
        self.profileImgView.frame = CGRect(x: self.userInfoView.frame.midX-40, y: self.userInfoView.frame.midY-64+40, width: 80, height: 80)
        self.profileImgView.layer.cornerRadius = 40
        
        self.backgroundProfileImageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: 245)
        self.backgroundProfileImageView.contentMode = .center
        
        self.effectView.frame = self.userInfoView.frame
        
        self.userInfoView.bringSubview(toFront: self.profileImgView)
        self.userInfoView.bringSubview(toFront: self.profileLable)
        
        self.profileLable.frame = CGRect(x: 0, y:  self.profileImgView.frame.maxY+2, width: rect.width, height: 50)
        self.profileLable.textAlignment = .center
        self.profileLable.numberOfLines = 0
    }
    
    func setProfie(){
        
        if let userInfo = LoginDataCenter.shared.myLoginInfo?.img_profile,
            let url = URL(string: userInfo){
            self.profileImgView.sd_setImage(with: url)
            self.backgroundProfileImageView.sd_setImage(with: url)
        }
        if let nickname = LoginDataCenter.shared.myLoginInfo?.nickname{
            let attributedProfileString: NSMutableAttributedString = NSMutableAttributedString(string: nickname, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight), NSForegroundColorAttributeName: UIColor.white])

            self.profileLable.attributedText = attributedProfileString
        }

        self.profileLable.numberOfLines = 0
    }
    
    func showIndicator(){
        let rect = self.view.bounds
        
        indicatorContainer.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        indicatorContainer.backgroundColor = .white
        
        indicator.frame = CGRect(x:rect.midX-40, y: rect.midY-40, width: 80, height: 80)
        indicator.activityIndicatorViewStyle = .gray
        
        indicatorContainer.addSubview(indicator)
        self.navigationController?.view.addSubview(indicatorContainer)
        
        indicator.startAnimating()
    }
    
    //MARK:- tableView delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let label : UILabel = UILabel(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width-40, height: 30))
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        
        if DataCenter.shared.myPlayLists.count == 0{
            label.text = "내 리스트가 없습니다."
            label.textAlignment = .center
        }else{
            label.text = "내 리스트"
        }
        view.backgroundColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:0.05)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataCenter.shared.myPlayLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: EditMyListTableViewCell = tableView.dequeueReusableCell(withIdentifier: EditMyListTableViewCell.reuseId, for: indexPath) as! EditMyListTableViewCell
        let playList = DataCenter.shared.myPlayLists[indexPath.row]
        
        cell.set(listName: playList.name,count: playList.musicList.count)
        cell.set(iconOf: playList.weather)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        cell.selectionStyle = .none
        
        let storyboard = UIStoryboard.init(name: "MainView", bundle: nil)
        let detailVC: DetailListViewController = storyboard.instantiateViewController(withIdentifier: "DetailListViewController") as! DetailListViewController
        
//        detailVC.detailMyPlayList = DataCenter.shared.myPlayLists[indexPath.row]
        detailVC.detailIndex = indexPath.row
        
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    @IBAction func MyListButtonTouched(_ sender: UIButton) {
    }
    
    
    
}
