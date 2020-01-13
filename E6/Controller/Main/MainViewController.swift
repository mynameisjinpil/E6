//
//  ViewController.swift
//  E6
//
//  Created by yujinpil on 04/09/2019.
//  Copyright © 2019 portrayer. All rights reserved.
//

// TODO:- Swift slider value when choosing filter element

import UIKit
import E6Framework
import AVFoundation
import Photos

public let AppDefault = UserDefaults.standard

// DEBUG
let CAMERA_DEVICE = true

// MARK:- Size

// Device size
struct ScreenSize {
  static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
  static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
  static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  public let DEVICE_BOUNDS = UIScreen.main.bounds
}

public let PREVIEW_HEIGHT = (ScreenSize.SCREEN_WIDTH * 4) / 3
public let REMAIN_SPACE = ((ScreenSize.SCREEN_HEIGHT - PREVIEW_HEIGHT))

private let defaultFilterValue: [String : Float] = ["brightnessS": 0.0, "brightnessH": 0.0,
                                                    "contrast": 0.0, "highlights": 0.5,
                                                    "shadows": 0.75, "level": 1.0,
                                                    "saturation": 1.0, "red": 0.0,
                                                    "green": 0.0, "blue": 0.0,
                                                    "sharpen": 0.4, "blur": 0.4]


private let testValue: [String : Float] = ["brightnessS": -100.0, "brightnessH": -100.0,
"contrast": -100.0, "highlights": -100.0,
"shadows": -100.0, "level": -100.0,
"saturation": -100.0, "red": -100.0,
"green": -100.0, "blue": -100.0,
"sharpen": -100.0, "blur": -100.0]


private var currentFilterValue: [String : Float] = defaultFilterValue
private var firstFilterValue: [String : Float] = testValue
private var secondFilterValue: [String : Float] = testValue
private var thirdFilterValue: [String : Float] = testValue

class MainViewController: UIViewController {
  // MARK:- Variables
  
  // MARK: Camera
  // Camera Model
  private var filterCamera: E6Camera!
  private var videoFilters: E6Filters!
  private var photoFilters: E6Filters!
  
  private var delay: CaptureDelay = .zero
  private var tickTok: Int = 0
  
  // MARK: UI
  private var isGridOn: Bool = false {
    didSet {
      self.gridView.isHidden = !(self.gridView.isHidden)
    }
  }
  private var allButtons: [UIButton]!
  // Bottom UI
  private var captureButton: UIButton!
  private var galleryButton: UIButton!
  private var filterButton: UIButton!
  private var filmSelectCollectionView: UICollectionView!
  private var filterSelectCollectionView: UICollectionView!
  
  // Bottom UI Button Size
  private var bottomViewSpace: CGFloat = (ScreenSize.SCREEN_WIDTH) * (79/414)
  private var captureButtonSize: CGSize = CGSize(width: (10.46/100) * ScreenSize.SCREEN_HEIGHT,
                                                 height: (10.46/100) * ScreenSize.SCREEN_HEIGHT)
  private var galleryButtonSize: CGSize = CGSize(width: (47.5 / 736) * ScreenSize.SCREEN_HEIGHT,
                                                 height: (36.5 / 736) * ScreenSize.SCREEN_HEIGHT)
  private var filterButtonSize: CGSize = CGSize(width: (47.5 / 736) * ScreenSize.SCREEN_HEIGHT,
                                                height: (44 / 736) * ScreenSize.SCREEN_HEIGHT)
  
  // Button Cons Array For Animation
  private var captureButtonConsArr: [NSLayoutConstraint] = []
  private var filterButtonConsArr: [NSLayoutConstraint] = []
  private var galleryButtonConsArr: [NSLayoutConstraint] = []
  
  private var captureButtonConsArr2: [NSLayoutConstraint] = []
  private var filterButtonConsArr2: [NSLayoutConstraint] = []
  private var galleryButtonConsArr2: [NSLayoutConstraint] = []
  
  // Top UI
  private var flipButton: UIButton!
  private var timerButton: UIButton!
  private var ratioButton: UIButton!
  private var flashButton: UIButton!
  private var settingButton: UIButton!
  
  // Slider UI
  private var sliderView: UIView!
  @IBOutlet weak var slider: IndicatorSlider!
  private var sliderLabel: UILabel!
  
  // Slider Butto
  @IBOutlet weak var sliderButtonView: UIView!
  @IBOutlet weak var redButton: SelectButton!
  @IBOutlet weak var greenButton: SelectButton!
  @IBOutlet weak var blueButton: SelectButton!
  
  // Other UI
  private var delayLabel: UILabel!
  private var previewView: UIImageView!
  private var gridView: UIImageView!
  private var focusView: UIView?
  
  // View state
  private var isShow: Bool = false
  
  // Filter state
  private enum WhichFilm {
    case original
    case first
    case second
    case third
    
    func rawValue() -> Int {
      switch self {
      case .original: return 0
      case .first: return 1
      case .second: return 2
      case .third: return 3
      }
    }
  }
  
  private var whichFilm: WhichFilm = .original
  
  private var whichFilter: String = ""
  
  private var photoManager = PHCachingImageManager()
  
  func setFilterDefault() {
    let launchedBefore = AppDefault.bool(forKey: "launchedBefore")
    
    if launchedBefore  {
      print("Not first launch.")
      
      if let data = UserDefaults.standard.object(forKey: "firstFilm") as? Data {
        firstFilterValue = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float])!
      }
      
      if let data = UserDefaults.standard.object(forKey: "secondFilm") as? Data {
        secondFilterValue = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float])!
      }
      
      if let data = UserDefaults.standard.object(forKey: "thirdFilm") as? Data {
        thirdFilterValue = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float])!
      }
      
    } else {
      print("First launch, setting UserDefault.")
      let savedData = NSKeyedArchiver.archivedData(withRootObject: defaultFilterValue as Any)
      
      UserDefaults.standard.set(savedData, forKey: "firstFilm")
      UserDefaults.standard.set(savedData, forKey: "secondFilm")
      UserDefaults.standard.set(savedData, forKey: "thirdFilm")
      
      UserDefaults.standard.set(true, forKey: "launchedBefore")
      
      if let data = UserDefaults.standard.object(forKey: "firstFilm") as? Data {
        firstFilterValue = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float])!
      }
      
      if let data = UserDefaults.standard.object(forKey: "secondFilm") as? Data {
        secondFilterValue = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float])!
      }
      
      if let data = UserDefaults.standard.object(forKey: "thirdFilm") as? Data {
        thirdFilterValue = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float])!
      }
    }
  }
  
  func saveFilter() {
    let savedData = NSKeyedArchiver.archivedData(withRootObject: currentFilterValue as Any)

    switch whichFilm {
    case .original: break
    case .first: UserDefaults.standard.set(savedData, forKey: "firstFilm")
    case .second: UserDefaults.standard.set(savedData, forKey: "secondFilm")
    case .third: UserDefaults.standard.set(savedData, forKey: "thirdFilm")
    }
  }
  
  // MARK:- Life Cycle
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setFilterDefault()
    
    if CAMERA_DEVICE {
      filterCamera = E6Camera()
      filterCamera.videoOutput.delegate = self
      filterCamera.startSession()
      
      videoFilters = E6Filters.sharedForVideo
      photoFilters = E6Filters.sharedForPhoto
    }
    buildView()
    initViewState()
    
    let thumbImage = slider.currentThumbImage
    let scaledThumb = UIImage(cgImage: (thumbImage?.cgImage)!, scale: 5, orientation: .up)
    
    slider.setThumbImage(scaledThumb, for: .normal)
    slider.setThumbImage(scaledThumb, for: .highlighted)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.focusAndExposeTap))
    self.previewView.isUserInteractionEnabled = true
    self.previewView.addGestureRecognizer(tapGesture)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    allButtons = [captureButton, galleryButton, filterButton, flipButton, timerButton, ratioButton, flashButton, settingButton]
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    saveFilter()
  }
  
  // MARK:- UI Build Function
  
  private func buildView(){
    if CAMERA_DEVICE == true {
      addPreviewView()
      addGridView()
      self.view.sendSubviewToBack(previewView)
    }
    
    // bottom
    addCaptureButton()
    addGalleryButton()
    addFilterButton()
    addFilmSelectCollectionView()
    addFilterSelectCollectionView()
    
    // top
    addRatioButton()
    addTimerButton()
    addFlashButton()
    addFlipButton()
    addSettingButton()
    
    // other
    addDelayLabel()
    addSliderView()
    
    // Slider
    addSlider()
    addSliderDeco()
    addSliderLabel()
    
    // SliderButton
    addSliderButtonView()
    addGreenButton()
    addRedButton()
    addBlueButton()
  }
  
  // MARK:- Core View
  
  private func addPreviewView() {
    let view: UIImageView = UIImageView()
    
    self.view.addSubview(view)
    self.view.contentMode = .scaleAspectFit
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    
    let constraints: NSLayoutConstraint = {
      let cons: NSLayoutConstraint
      
      if DeviceType.IPHONE_X || DeviceType.IPHONE_XR_OR_XS_MAX {
        cons = view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40)
      }
      else {
        cons = view.topAnchor.constraint(equalTo: self.view.topAnchor)
      }
      
      return cons
    }()
    
    let height =  view.heightAnchor.constraint(equalToConstant: PREVIEW_HEIGHT)
    let width = view.widthAnchor.constraint(equalToConstant: ScreenSize.SCREEN_WIDTH)
    
    NSLayoutConstraint.activate([centerX, constraints, height, width])
        
    self.previewView = view
  }
  
  private func addGridView() {
    let view: UIImageView = UIImageView()
    
    self.view.addSubview(view)
    self.view.contentMode = .scaleAspectFit
    
    view.isHidden = true
    view.image = UIImage(named: "grid_3_4")
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    
    let constraints: NSLayoutConstraint = {
      let cons: NSLayoutConstraint
      
      if DeviceType.IPHONE_X || DeviceType.IPHONE_XR_OR_XS_MAX {
        cons = view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40)
      }
      else {
        cons = view.topAnchor.constraint(equalTo: self.view.topAnchor)
      }
      
      return cons
    }()
    
    let height =  view.heightAnchor.constraint(equalToConstant: PREVIEW_HEIGHT)
    let width = view.widthAnchor.constraint(equalToConstant: ScreenSize.SCREEN_WIDTH)
    
    NSLayoutConstraint.activate([centerX, constraints, height, width])
    
    self.view.bringSubviewToFront(view)
    self.gridView = view
  }
  
  private func addCaptureButton() {
    let button: UIButton = UIButton()
    
    guard let buttonImage = UIImage(named: "cam_captureButton") else {
      fatalError("[Main] Capture button image did not load")
    }
    
    button.setImage(buttonImage, for: .normal)
    
    button.addTarget(self, action: #selector(capture(_:)), for: .touchUpInside)
    
    self.view.addSubview(button)
    
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    let bottom: NSLayoutConstraint = {
      let cons: NSLayoutConstraint!
      
      if DeviceType.IPHONE_X || DeviceType.IPHONE_XR_OR_XS_MAX {
        cons = button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(PREVIEW_HEIGHT - REMAIN_SPACE - buttonImage.size.height) / 2)
      }
      else {
        cons = button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -45)
      }
      
      return cons
    }()
    
    let height = button.heightAnchor.constraint(equalToConstant: captureButtonSize.height)
    let width = button.widthAnchor.constraint(equalToConstant: captureButtonSize.width)
    
    self.captureButtonConsArr = [centerX, bottom, height, width]
    
    NSLayoutConstraint.activate(captureButtonConsArr)
    
    self.captureButton = button
  }
  
  private func addGalleryButton() {
    let button: UIButton = UIButton()
    
    guard let buttonImage = UIImage(named: "cam_galleryButton") else {
      fatalError("[Main] Gallery button image did not load")
    }
    button.setImage(buttonImage, for: .normal)
    button.addTarget(self, action: #selector(goToGallery(_:)), for: .touchUpInside)
    
    self.view.addSubview(button)
    
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let centerY = button.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor)
    let right = button.rightAnchor.constraint(equalTo: captureButton.leftAnchor, constant: -1 * ScreenSize.SCREEN_WIDTH * (79/414))
    let height = button.heightAnchor.constraint(equalToConstant: galleryButtonSize.height)
    let width = button.widthAnchor.constraint(equalToConstant: galleryButtonSize.width)
    
    NSLayoutConstraint.activate([centerY, right, height, width])
    
    self.galleryButton = button
  }
  
  private func addFilterButton() {
    let button: UIButton = UIButton()
    guard let buttonImage: UIImage = UIImage(named: "cam_filterButton") else {
      fatalError("[Main] Filter button image did not load")
    }
    button.setImage(buttonImage, for: .normal)
    button.addTarget(self, action: #selector(showFilterCollectionView(_:)), for: .touchUpInside)
    
    self.view.addSubview(button)
    
    
    
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let centerY = button.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor)
    let left = button.leftAnchor.constraint(equalTo: captureButton.rightAnchor, constant: ScreenSize.SCREEN_WIDTH * (79/414))
    let height = button.heightAnchor.constraint(equalToConstant: filterButtonSize.height)
    let width = button.widthAnchor.constraint(equalToConstant: filterButtonSize.width)
    
    NSLayoutConstraint.activate([centerY, left, height, width])
    
    self.filterButton = button
  }
  
  // MARK: Top Button
  // Center Y is related with ratio button
  
  private func addRatioButton() {
    let button: UIButton = UIButton()
    let buttonImage: UIImage! = UIImage(named: "cam_ratio3to4")
    
    button.setImage(buttonImage, for: .normal)
    button.addTarget(self, action: #selector(changePreviewRatio(_:)), for: .touchUpInside)
    
    self.view.addSubview(button)
    
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    let top: NSLayoutConstraint = {
      let constraint: NSLayoutConstraint!
      
      if DeviceType.IPHONE_X || DeviceType.IPHONE_XR_OR_XS_MAX {
        constraint = button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                                                 constant: (REMAIN_SPACE / 4) - 50 - buttonImage.size.height / 2)
      } else {
        constraint = button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                                                 constant: (REMAIN_SPACE / 4) - buttonImage.size.height / 2)
      }
      
      return constraint
    }()
    
    NSLayoutConstraint.activate([centerX, top])
    
    self.ratioButton = button
  }
  
  private func addTimerButton() {
    let button: UIButton = UIButton()
    let buttonImage: UIImage! = UIImage(named: "cam_timer")
    button.setImage(buttonImage, for: .normal)
    button.addTarget(self, action: #selector(setCaptureDelay(_:)), for: .touchUpInside)
    
    self.view.addSubview(button)
    
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let right = button.rightAnchor.constraint(equalTo: self.ratioButton.leftAnchor,
                                              constant: -1 * (ScreenSize.SCREEN_WIDTH / 8) + 5)
    let centerY = button.centerYAnchor.constraint(equalTo: self.ratioButton.centerYAnchor)
    
    NSLayoutConstraint.activate([right, centerY])
    self.timerButton = button
  }
  
  private func addFlashButton() {
    let button: UIButton = UIButton()
    let buttonImage: UIImage! = UIImage(named: "cam_flashOff")
    button.setImage(buttonImage, for: .normal)
    button.addTarget(self, action: #selector(changeFlash(_:)), for: .touchUpInside)
    
    self.view.addSubview(button)
    
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let left = button.leftAnchor.constraint(equalTo: self.ratioButton.rightAnchor,
                                            constant: ScreenSize.SCREEN_WIDTH / 8 - 5)
    let centerY = button.centerYAnchor.constraint(equalTo: self.ratioButton.centerYAnchor)
    
    NSLayoutConstraint.activate([left, centerY])
    
    self.flashButton = button
  }
  
  private func addFlipButton() {
    let button: UIButton = UIButton()
    let buttonImage: UIImage! = UIImage(named: "cam_flip")
    button.setImage(buttonImage, for: .normal)
    button.addTarget(self, action: #selector(flipCamera(_:)), for: .touchUpInside)
    
    self.view.addSubview(button)
    
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let right = button.rightAnchor.constraint(equalTo: self.timerButton.leftAnchor,
                                              constant: -1 * ScreenSize.SCREEN_WIDTH / 8 + 5)
    let centerY = button.centerYAnchor.constraint(equalTo: self.ratioButton.centerYAnchor)
    
    NSLayoutConstraint.activate([right, centerY])
    
    self.flipButton = button
  }
  
  private func addSettingButton() {
    
    let button: UIButton = UIButton()
    let buttonImage: UIImage! = UIImage(named: "cam_setting")
    button.setImage(buttonImage, for: .normal)
    button.addTarget(self, action: #selector(goToPreference(_:)), for: .touchUpInside)
    
    self.view.addSubview(button)
    
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let left = button.leftAnchor.constraint(equalTo: self.flashButton.rightAnchor,
                                            constant: ScreenSize.SCREEN_WIDTH / 8 - 5)
    let centerY = button.centerYAnchor.constraint(equalTo: self.ratioButton.centerYAnchor)
    
    NSLayoutConstraint.activate([left, centerY])
    
    self.settingButton = button
  }
  
  private func addDelayLabel() {
    let label = UILabel()
    label.text = "0"
    label.font = UIFont(name: label.font.fontName, size: 200)
    label.textColor = .white
    label.isHidden = true
    
    self.view.addSubview(label)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    let centerY = label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40)
    
    NSLayoutConstraint.activate([centerX, centerY])
    
    self.delayLabel = label
  }
  
  // MARK: Collection View
  
  private func addFilmSelectCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    layout.itemSize = CGSize(width: 50, height: 50)
    layout.scrollDirection = .horizontal
    
    let collectionView: UICollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
    
    collectionView.allowsMultipleSelection = false
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(FilmCell.self, forCellWithReuseIdentifier: "FilmCell")
    
    self.view.addSubview(collectionView)
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    let leading = collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
    let trailling = collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
    let bottom = collectionView.bottomAnchor.constraint(equalTo: captureButton.topAnchor)
    let height: NSLayoutConstraint = {
      var cons:NSLayoutConstraint!
      
      if DeviceType.IPHONE_XR_OR_XS_MAX || DeviceType.IPHONE_X {
        cons = collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: -(PREVIEW_HEIGHT + (REMAIN_SPACE / 2) + 80))
      }
      else {
        cons = collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: -(PREVIEW_HEIGHT + (REMAIN_SPACE / 2) - 10))
      }
      
      return cons
    }()
    
    NSLayoutConstraint.activate([leading, trailling, height, bottom])
    
    self.filmSelectCollectionView = collectionView
  }
  
  private func addFilterSelectCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    layout.itemSize = CGSize(width: 50, height: 50)
    layout.scrollDirection = .horizontal
    
    let collectionView: UICollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
    
    self.view.addSubview(collectionView)
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    let leading = collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
    let trailling = collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
    let bottom = collectionView.bottomAnchor.constraint(equalTo: captureButton.topAnchor)
    let height: NSLayoutConstraint = {
      var cons:NSLayoutConstraint!
      
      if DeviceType.IPHONE_XR_OR_XS_MAX || DeviceType.IPHONE_X {
        cons = collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor,
                                                      constant: -(PREVIEW_HEIGHT + (REMAIN_SPACE / 2) + 80))
      }
      else {
        cons = collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor,
                                                      constant: -(PREVIEW_HEIGHT + (REMAIN_SPACE / 2) - 10))
      }
      
      return cons
    }()
    
    NSLayoutConstraint.activate([leading, trailling, height, bottom])
    
    self.filterSelectCollectionView = collectionView
  }
  
  // MARK: Slider UI
  private func addSliderView() {
    let view = UIView()
    
    view.backgroundColor = .clear
    
    self.view.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    let height = view.heightAnchor.constraint(equalToConstant: 50)
    let width = view.widthAnchor.constraint(equalTo: self.view.widthAnchor)
    let bottom = view.bottomAnchor.constraint(equalTo: self.filterSelectCollectionView.topAnchor)
    let centerX = view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    
    NSLayoutConstraint.activate([height, width, bottom, centerX])
    
    self.sliderView = view
  }
  
  private func addSlider() {
    sliderView.addSubview(slider)
    
    slider.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = slider.centerXAnchor.constraint(equalTo: self.sliderView.centerXAnchor)
    let centerY = slider.centerYAnchor.constraint(equalTo: self.sliderView.centerYAnchor)
    let width = slider.widthAnchor.constraint(equalTo: self.sliderView.widthAnchor, multiplier: 0.6)
    let height = slider.heightAnchor.constraint(equalTo: self.sliderView.heightAnchor, multiplier: 0.6)
    
    NSLayoutConstraint.activate([centerX, centerY, width, height])
  }
  
  private func addSliderDeco() {
    let deco = UIImageView()
    deco.image = UIImage(named: "slider_deco")
    
    sliderView.addSubview(deco)
    
    deco.translatesAutoresizingMaskIntoConstraints = false
    
    let right = deco.rightAnchor.constraint(equalTo: slider.leftAnchor, constant: -17)
    let centerY = deco.centerYAnchor.constraint(equalTo: slider.centerYAnchor)
    
    NSLayoutConstraint.activate([right, centerY])
  }
  
  private func addSliderLabel() {
    let label = UILabel()
    label.font = UIFont(name: label.font.fontName, size: 17)
    label.text = "0"
    label.textColor = .white
    
    sliderView.addSubview(label)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    
    let left = label.leftAnchor.constraint(equalTo: slider.rightAnchor, constant: 17)
    let centerY = label.centerYAnchor.constraint(equalTo: slider.centerYAnchor)
    
    NSLayoutConstraint.activate([left, centerY])
    
    self.sliderLabel = label
  }
  
  // MARK: Slider Button Something
  func addSliderButtonView() {
    
    sliderButtonView.translatesAutoresizingMaskIntoConstraints = false
    
    let leading = sliderButtonView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
    let trailling = sliderButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
    let bottom = sliderButtonView.bottomAnchor.constraint(equalTo: self.sliderView.topAnchor)
    let height = sliderButtonView.heightAnchor.constraint(equalToConstant: 35)
    
    NSLayoutConstraint.activate([leading, trailling, bottom, height])
  }
  
  func addRedButton() {
    redButton.translatesAutoresizingMaskIntoConstraints = false
    
    let leading = redButton.leadingAnchor.constraint(equalTo: sliderButtonView.leadingAnchor)
    let trailing = redButton.trailingAnchor.constraint(equalTo: greenButton.leadingAnchor)
    let top = redButton.topAnchor.constraint(equalTo: sliderButtonView.topAnchor)
    let bottom = redButton.bottomAnchor.constraint(equalTo: sliderButtonView.bottomAnchor)
    
    NSLayoutConstraint.activate([leading, trailing, top, bottom])
  }
  
  func addGreenButton() {
    greenButton.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = greenButton.centerXAnchor.constraint(equalTo: sliderButtonView.centerXAnchor)
    let top = greenButton.topAnchor.constraint(equalTo: sliderButtonView.topAnchor)
    let bottom = greenButton.bottomAnchor.constraint(equalTo: sliderButtonView.bottomAnchor)
    let width = greenButton.widthAnchor.constraint(equalToConstant: view.frame.size.width / 3)
    
    NSLayoutConstraint.activate([centerX, top, bottom, width])
  }
  
  func addBlueButton() {
    blueButton.translatesAutoresizingMaskIntoConstraints = false
    
    let leading = blueButton.leadingAnchor.constraint(equalTo: greenButton.trailingAnchor)
    let trailing = blueButton.trailingAnchor.constraint(equalTo: sliderButtonView.trailingAnchor)
    let top = blueButton.topAnchor.constraint(equalTo: sliderButtonView.topAnchor)
    let bottom = blueButton.bottomAnchor.constraint(equalTo: sliderButtonView.bottomAnchor)
    
    NSLayoutConstraint.activate([leading, trailing, top, bottom])
  }
  
  // MARK: Button Animation
  func increaseButtonAnimation() {
    NSLayoutConstraint.deactivate(captureButtonConsArr2)
    
    NSLayoutConstraint.activate(captureButtonConsArr)
    
    self.view.layoutIfNeeded()
  }
  
  func decreaseButtonAnimation() {
    NSLayoutConstraint.deactivate(captureButtonConsArr)
    
    captureButton.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = captureButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    let bottom = captureButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24.5)
    let height = captureButton.heightAnchor.constraint(equalToConstant: captureButtonSize.height * (2 / 3))
    let width = captureButton.widthAnchor.constraint(equalToConstant: captureButtonSize.width * (2 / 3))
    
    captureButtonConsArr2 = [centerX, bottom, height, width]
    
    NSLayoutConstraint.activate(captureButtonConsArr2)
    
    self.view.layoutIfNeeded()
  }
  
  // MARK: Function For UI
  
  
  @IBAction func sliding(_ sender: UISlider) {
    let fakeValue: Float!
    
    switch whichFilter {
    case "level":
      fakeValue = ((slider.value * 10.0) - 7.0) * 1.66669999
      sliderLabel.text = String(format: "%.0f", fakeValue)
      currentFilterValue["level"] = sender.value
    case "brightness":
      fakeValue = ((slider.value * 10.0) + 5.0)
      sliderLabel.text = String(format: "%.0f", fakeValue)
      
      let shadowValue = -(sender.value)
      currentFilterValue["brightnessH"] = sender.value
      currentFilterValue["brightnessS"] = shadowValue
    case "contrast":
      fakeValue = ((slider.value * 100.0) + 7.0) * (0.7142)
      sliderLabel.text = String(format: "%.0f", fakeValue)
      currentFilterValue["contrast"] = sender.value
    case "saturation":
      fakeValue = ((slider.value * 10.0)) * 0.5
      sliderLabel.text = String(format: "%.0f", fakeValue)
      currentFilterValue["saturation"] = sender.value
    case "red":
      fakeValue = ((slider.value * 10.0) + 10.0) * 0.33333333
      sliderLabel.text = String(format: "%.0f", fakeValue)
      currentFilterValue["red"] = sender.value
    case "green":
      fakeValue = ((slider.value * 10.0) + 10.0) * 0.33333333
      sliderLabel.text = String(format: "%.0f", fakeValue)
      currentFilterValue["green"] = sender.value
    case "blue":
      fakeValue = ((slider.value * 10.0) + 10.0) * 0.33333333
      sliderLabel.text = String(format: "%.0f", fakeValue)
      currentFilterValue["blue"] = sender.value
    case "highlights":
      fakeValue = ((slider.value * 10.0) + 15.0) * 0.333333
      sliderLabel.text = String(format: "%.0f", fakeValue)
      currentFilterValue["highlights"] = sender.value
    case "shadows":
      changeSliderTitle(10.0, -6.0, 1.25)
      currentFilterValue["shadows"] = sender.value
    case "sharpen":
      changeSliderTitle(10.0, -4, 0.38461538)
      currentFilterValue["sharpen"] = sender.value
    case "blur":
      changeSliderTitle(10.0, 5.0, 1.111111)
      currentFilterValue["blur"] = sender.value

    default:
      print("[IndicatorSlider] function sliding: How can you do that?")
    }
    
    self.videoFilters.parameter = currentFilterValue
    self.photoFilters.parameter = currentFilterValue
  }
  
  
  @IBAction private func focusAndExposeTap(_ gesture: UITapGestureRecognizer) {
     
     let location = gesture.location(in: previewView)
     let focus_x = location.x / previewView.frame.size.width
     let focus_y = location.y / previewView.frame.size.height
     
     let foucusPoint = CGPoint(x: 1 - focus_x, y: focus_y)
     
     let focusRect = CGRect(origin: CGPoint(x: location.x - 30,
                                            y: location.y - 30),
                            size: CGSize(width: 60, height: 60))
     
     focusView = UIView(frame: focusRect)
     focusView?.alpha = 1.0
     focusView?.layer.backgroundColor = UIColor.clear.cgColor
     focusView?.layer.borderColor = UIColor.white.cgColor
     focusView?.layer.borderWidth = 1.0
     
     self.previewView.addSubview(focusView!)
     self.previewView.bringSubviewToFront(focusView!)
     
     UIView.animate(withDuration: 0.3,
                    delay: 1.0,
                    options: .curveEaseOut,
                    animations: { self.focusView?.alpha = 0.0 },
                    completion: nil
     )
     
    filterCamera.focus(with: .autoFocus, exposureMode: .autoExpose, at: foucusPoint, monitorSubjectAreaChange: true)
   }
   
   @objc
   func setDefaultFocusAndExposure() {
     let devicePoint = CGPoint(x: 0.5, y: 0.5)
     filterCamera.focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: true)
   }
   
  @IBAction func capture(_ sender: UIButton) {
    
    makeAllButtonsDisable()
    
    let time = DispatchTime.now() + .seconds(delay.rawValue())
    var timer = Timer()
    timer = Timer.scheduledTimer(timeInterval: 1,
                                 target: self,
                                 selector: #selector(timerCallback),
                                 userInfo: nil,
                                 repeats: true)
    
    self.tickTok = self.delay.rawValue()
    
    self.delayLabel.isHidden = false
    
    DispatchQueue.main.asyncAfter(deadline: time) {
      
      
      self.filterCamera.photoOutput.capturePhoto()
      
      self.delayLabel.isHidden = true
      
      timer.invalidate()
      self.delayLabel.text = String(self.delay.rawValue())
      
      self.makeAllButtonsAble()
    }
  }
  
  // Make time tick it
  @objc func timerCallback(){
    tickTok -= 1
    self.delayLabel.text = String(self.tickTok)
  }
  
  @IBAction func goToGallery(_ sender: UIButton) {
    let storyboard: UIStoryboard = UIStoryboard(name: "Gallery", bundle: nil)
    let navigationViewController = storyboard.instantiateViewController(withIdentifier: "galleryViewController") as! UINavigationController
    let galleryViewController = navigationViewController.topViewController as! GalleryViewController
//    galleryViewController.photoManager = self.photoManager
    
    navigationViewController.modalPresentationStyle = .fullScreen
    
    self.present(navigationViewController, animated: true, completion: nil)
  }
  
  @IBAction func changePreviewRatio(_ sender: UIButton) {
    filterCamera.changeRatio()
    
    switch filterCamera.ratio {
    case .square:
      ratioButton.setImage(UIImage(named: "cam_ratio1to1"), for: .normal)
    case .rectangle: ratioButton.setImage(UIImage(named: "cam_ratio3to4"), for: .normal)
    case .none: print("??")
    }
  }
  
  @IBAction func showFilterCollectionView(_ sender: UIButton) {
    let filmViewIsShow = !filmSelectCollectionView.isHidden
    let filterViewIsShow = !filterSelectCollectionView.isHidden
    
    saveFilter()
    
    filterSelectCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .init(), animated: false)
    
    sliderButtonView.isHidden = true
    
    resetCellState()
    
    if filmViewIsShow == filmViewIsShow {
      
      if filterViewIsShow {
        filmSelectCollectionView.isHidden = true
        filterSelectCollectionView.isHidden = true
        sliderView.isHidden = true
        sliderButtonView.isHidden = true
      }
      else {
        filmSelectCollectionView.isHidden = false
      }
    }
    if filmViewIsShow == true {
      filmSelectCollectionView.isHidden = true
    }
    if filterViewIsShow == true {
      filterSelectCollectionView.isHidden = true
    }
    
    
    if isShow {
      UIView.animate(withDuration: 0.2,
                     animations: { self.increaseButtonAnimation() },
                     completion: { res in
                      self.isShow = false
                      self.filterButton.isEnabled = true })
    }
    else {
      UIView.animate(withDuration: 0.2,
                     animations: { self.decreaseButtonAnimation() },
                     completion: { res in
                      self.isShow = true
                      self.filterButton.isEnabled = true })
    }
    
    isShow = !isShow
  }
  
  @IBAction func flipCamera(_ sender: UIButton) {
    filterCamera.flipCamera()
  }
  
  @IBAction func setCaptureDelay(_ sender: UIButton) {
    switch self.delay {
    case .zero: self.delay = .three
    case .three: self.delay = .six
    case .six: self.delay = .ten
    case .ten: self.delay = .zero
    }
    
    dealWithSetDelay(self.delay)
  }
  
  private func dealWithSetDelay(_ delay: CaptureDelay) {
    // set image to timer button
    let image: UIImage!
    
    switch delay {
    case .zero: image = UIImage(named: "cam_timer")
    case .three: image = UIImage(named: "cam_timer_3sec")
    case .six: image = UIImage(named: "cam_timer_6sec")
    case .ten: image = UIImage(named: "cam_timer_10sec")
    }
    self.timerButton.setImage(image, for: .normal)
    
    // add label to preview layer
    self.delayLabel.isHidden = false
    
    let time = DispatchTime.now() + .milliseconds(500)
    
    DispatchQueue.main.async(execute: {
      self.delayLabel.text = "\(delay.rawValue())"
    })
    DispatchQueue.main.asyncAfter(deadline: time) {
      self.delayLabel.isHidden = true
    }
  }
  
  @IBAction func changeFlash(_ sender: UIButton) {
    let captureOutput = filterCamera.photoOutput
    
    switch captureOutput.flash! {
    case .off:
      captureOutput.flash = .on
      flashButton.setImage(UIImage(named: "cam_flashOn"), for: .normal)
    case .on:
      captureOutput.flash = .off
      flashButton.setImage(UIImage(named: "cam_flashOff"), for: .normal)
    case .auto:
      print("???!")
    @unknown default:
      print("???!")

    }
  }
  
  @IBAction func goToPreference(_ sender:UIButton) {
    let storyboard: UIStoryboard = UIStoryboard(name: "Preference", bundle: nil)
    let navigationViewController = storyboard.instantiateViewController(withIdentifier: "preferenceViewController")
    let preferenceViewController = navigationViewController.children.first as! PreferenceViewController
    preferenceViewController.delegate = self
    preferenceViewController.isSilence = self.filterCamera.photoOutput.silence
    preferenceViewController.isGridOn = self.isGridOn
    
    navigationViewController.modalPresentationStyle = .fullScreen
    self.present(navigationViewController, animated: true, completion: nil)
  }
  
  @IBAction func redButtonTapped(_ sender: Any) {
    self.slider.setColorInitPoint()
    whichFilter = "red"
    
    redButton.isTapped = !(redButton.isTapped)
    slider.isEnabled = true
    
    greenButton.initState()
    blueButton.initState()
    
    self.slider.minimumValue = -1.0
    self.slider.maximumValue = 2.0
    self.slider.value = currentFilterValue["red"]!
    let fakeValue = ((slider.value * 10.0) + 10.0) * 0.33333333
    sliderLabel.text = String(format: "%.0f", fakeValue)
  }
  
  @IBAction func greenButtonTapped(_ sender: Any) {
    self.slider.setColorInitPoint()
    whichFilter = "green"

    greenButton.isTapped = !(greenButton.isTapped)
    slider.isEnabled = true
    
    redButton.initState()
    blueButton.initState()
    
    self.slider.minimumValue = -1.0
    self.slider.maximumValue = 2.0
    self.slider.value = currentFilterValue["green"]!
    
    let fakeValue = ((slider.value * 10.0) + 10.0) * 0.33333333
    sliderLabel.text = String(format: "%.0f", fakeValue)
  }
  
  @IBAction func blueButtonTapped(_ sender: Any) {
    self.slider.setColorInitPoint()
    whichFilter = "blue"

    blueButton.isTapped = !(blueButton.isTapped)
    slider.isEnabled = true
    
    redButton.initState()
    greenButton.initState()
    
    self.slider.minimumValue = -1.0
    self.slider.maximumValue = 2.0
    self.slider.value = currentFilterValue["blue"]!
    
    let fakeValue = ((slider.value * 10.0) + 10.0) * 0.33333333
    sliderLabel.text = String(format: "%.0f", fakeValue)
  }
  
  // MARK:- View State Control Function
  
  // Make all buttons disable
  func makeAllButtonsDisable() {
    for button in allButtons {
      button.isEnabled = false
    }
  }
  
  // Make all buttons able
  func makeAllButtonsAble() {
    for button in allButtons {
      button.isEnabled = true
    }
  }
  
  func initViewState() {
    // State of view when app init
    filmSelectCollectionView.isHidden = true
    filterSelectCollectionView.isHidden = true
    sliderView.isHidden = true
    sliderButtonView.isHidden = true
  }
  
  func resetCellState() {
    // 내가 이걸 쓰고싶을때가 언제언제지? -> 일단 show filter button 눌렸을 때, 인덱스가 [0]인 filter select cell button 을 눌렀을 때
    for cell in filterSelectCollectionView.visibleCells {
      let filterCell = cell as! FilterCell
      filterCell.makeUnSelected()
    }
  }
}

// MARK: Collection View Delegate

extension MainViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == self.filmSelectCollectionView {
      return 4
    } else {
      return 11
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // About Cell Making
    if collectionView == self.filmSelectCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilmCell", for: indexPath) as! FilmCell
      cell.configureView(indexPath)
      
      cell.label.text = (FILMICONS[indexPath.row][1] as! String)
      cell.imageView.image =  (FILMICONS[indexPath.row][0] as! UIImage)
      
      return cell
    }
    else if collectionView == self.filterSelectCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
      cell.configureView(indexPath)
      
      let image: UIImage!
      let text: String!
      
      if indexPath.row == 0 {
        image = (FILMICONS[whichFilm.rawValue()][0] as! UIImage)
        text = " "
      }
      else {
        image = (MENUICONS[indexPath.row-1][0] as! UIImage)
        text = (MENUICONS[indexPath.row-1][1] as! String)
      }
      
      cell.imageView.image = image
      cell.label.text = text
      
      return cell
    }
    else {
      let cell = UICollectionViewCell()
      
      return cell
    }
  }
}
extension MainViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    // 셀 클릭에 관한 함수
    
    if collectionView == self.filmSelectCollectionView {
      if indexPath.row == 0 {
        whichFilm = .original
        currentFilterValue = defaultFilterValue
      }
      else if indexPath.row == 1 {
        whichFilm = .first
        
        if let data = AppDefault.object(forKey: "firstFilm") as? Data {
          firstFilterValue = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float])!
        }
        currentFilterValue = firstFilterValue
      }
      else if indexPath.row == 2 {
         whichFilm = .second
        
        if let data = AppDefault.object(forKey: "secondFilm") as? Data {
          secondFilterValue = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float])!
        }
        currentFilterValue = secondFilterValue
      }
      else if indexPath.row == 3 {
        whichFilm = .third
        
        if let data = AppDefault.object(forKey: "thirdFilm") as? Data {
          thirdFilterValue = (NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Float])!
        }
        currentFilterValue = thirdFilterValue

      }
      
      let cell = collectionView.cellForItem(at: indexPath) as! FilmCell
      
      let indexPaths: [IndexPath]! = collectionView.indexPathsForSelectedItems
  
      let willChangedCell = filterSelectCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! FilterCell
      
      willChangedCell.imageView.image = (FILMICONS[whichFilm.rawValue()][0] as! UIImage)
      
      for idx in indexPaths {
        if indexPath == idx {
          if indexPath == IndexPath(row: 0, section: 0) {
            // 노필터일경우
            isShow = false
            filmSelectCollectionView.isHidden = true
            increaseButtonAnimation()
            currentFilterValue = defaultFilterValue
            return false
          }
          // 한번더 클릭했을 경우
          cell.rootView.backgroundColor = .white
          collectionView.selectItem(at: idx, animated: true, scrollPosition: [])
          
          filmSelectCollectionView.isHidden = true
          filterSelectCollectionView.isHidden = false
          
          return false
        }
        else {
          // 클릭한게 잇는데 다른곳을 클릭했을 경우
          let otherCell = collectionView.cellForItem(at: idx) as! FilmCell
          otherCell.rootView.backgroundColor = .black
          collectionView.deselectItem(at: idx, animated: true)
        }
      }
      
      cell.rootView.backgroundColor = .white
      collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
      
      videoFilters.parameter = currentFilterValue
      photoFilters.parameter = currentFilterValue
      
      return false
    }
    else if collectionView == self.filterSelectCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as! FilterCell
      let indexPaths: [IndexPath]! = collectionView.indexPathsForSelectedItems
      
      slider.isEnabled  = true
          
      switch indexPath.row {
      case 0:
        saveFilter()
        resetCellState()
        sliderButtonView.isHidden = true
        sliderView.isHidden = true
        filterSelectCollectionView.isHidden = true
        filmSelectCollectionView.isHidden = false
        return false
      case 1:
        sliderButtonView.isHidden = true
        
        for cell in collectionView.visibleCells {
          let tempCell = cell as! FilterCell
          tempCell.label.textColor = .white
        }
        
        for idx in collectionView.indexPathsForSelectedItems ?? [] {
          collectionView.deselectItem(at: idx, animated: false)
        }
        
        sliderView.isHidden = true
        
        currentFilterValue = defaultFilterValue
        self.videoFilters.parameter = currentFilterValue
        self.photoFilters.parameter = currentFilterValue
        
        // TDOO:- Filter Reset
        return false
      case 2:
        // level
        self.slider.setMidInitPoint()
        changeSliderState("level", 0.7, 1.3, currentFilterValue["level"]!)
        changeSliderTitle(10.0, -7.0, 1.66669999)
      case 3:
        // brightness
        self.slider.setMidInitPoint()
        changeSliderState("brightness", -0.5, 0.5, currentFilterValue["brightnessH"]!)
        changeSliderTitle(10.0, 5.0, 1.0)
      case 4:
        // contrast
        self.slider.setMidInitPoint()
        changeSliderState("contrast", -0.07, 0.07, currentFilterValue["contrast"]!)
        changeSliderTitle(100.0, 7.0, 0.7142)
      case 5:
        // saturation
        self.slider.setMidInitPoint()
        changeSliderState("saturation", 0.0, 2.0, currentFilterValue["saturation"]!)
        changeSliderTitle(10.0, 0.0, 0.5)
      case 6:
        // color
        redButton.setTitleColor(.white, for: .normal)
        greenButton.setTitleColor(.white, for: .normal)
        blueButton.setTitleColor(.white, for: .normal)
        
        self.slider.setMidInitPoint()
        changeSliderState("color", -1.0, 1.0, 0.0)
        sliderLabel.text = " "
        slider.isEnabled = false
      case 7:
        // highlights
        self.slider.setHighlightsInitPoint()
        changeSliderState("highlights", -1.5, 1.5, currentFilterValue["highlights"]!)
        changeSliderTitle(10.0, 15.0, 0.33333333)
        
      case 8:
        // shadows
        self.slider.setShadowsInitPoint()
        changeSliderState("shadows", 0.6, 1.4, currentFilterValue["shadows"]!)
        changeSliderTitle(10.0, -6.0, 1.25)
        
      case 9:
        // sharpen
        self.slider.setSharpenInitPoint()
        changeSliderState("sharpen", 0.4, 3.0, currentFilterValue["sharpen"]!)
        changeSliderTitle(10.0, -4, 0.38461538)
        
      case 10:
        // blur
        self.slider.setBlurInitPoint()
        changeSliderState("blur", -0.5, 0.4, currentFilterValue["blur"]!)
        changeSliderTitle(10.0, 5.0, 1.111111)
      default:
        print("__")
      }
      
      if indexPaths.count == 0 {
        sliderView.isHidden = false
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        cell.label.textColor = .red
        if cell.label.text == "Color" {
          self.sliderButtonView.isHidden = false
        }
        else {
          sliderButtonView.isHidden = true
        }
      }
      else {
        if indexPaths.first == indexPath {
          collectionView.deselectItem(at: indexPath, animated: false)
          sliderButtonView.isHidden = true
          sliderView.isHidden = true
          cell.label.textColor = .white
        }
        else {
          for row in collectionView.visibleCells {
            let tempCell = row as! FilterCell
            tempCell.label.textColor = .white
          }
          sliderView.isHidden = false
          cell.label.textColor = .red
          collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
          
          if cell.label.text == "Color" {
            self.sliderButtonView.isHidden = false
          }
          else {
            sliderButtonView.isHidden = true
          }
        }
      }
      
      return false
    }
    return false
  }
  
  
  func changeSliderState(_ title: String, _ min: Float, _ max: Float, _ current: Float) {
    self.whichFilter = title
    self.slider.minimumValue = min
    self.slider.maximumValue = max
    self.slider.value = current
  }
  
  func changeSliderTitle(_ first: Float, _ second: Float, _ third: Float) {
    let fakeValue = ((slider.value * first) + second) * third
    sliderLabel.text = String(format: "%.0f", fakeValue)
  }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    if collectionView == self.filmSelectCollectionView {
      let forEqualSpace = ScreenSize.SCREEN_WIDTH - (50.0 * 4)
      return forEqualSpace / 4
    } else {
      return 20
    }
  }
}

extension MainViewController: DeviceVideoDataOutputDelegate {
  func sendImage(_ image: UIImage) {
    DispatchQueue.main.async {
      self.previewView.contentMode = .scaleAspectFit
      let filmCell = self.filmSelectCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! FilmCell
      
      filmCell.imageView.image = image
      self.previewView.image = image
    }
  }
}

extension MainViewController: PreferenceViewControllerDelegate {
  func passGrid(_ value: Bool) {
    self.isGridOn = value
  }
  
  func passSlience(_ value: Bool) {
    self.filterCamera.photoOutput.silence = value
  }
  
//  func passGrid(_ value: Bool) {
//    self.isGridOn = value
//  }
}
