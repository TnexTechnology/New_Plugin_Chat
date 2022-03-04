import Flutter
import UIKit
import MatrixSDK
import SDWebImage

public class SwiftTnexchatPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tnexchat", binaryMessenger: registrar.messenger())
    let instance = SwiftTnexchatPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      gotoChatDetail()
    result("iOS " + UIDevice.current.systemVersion)
  }
    private func gotoChatDetail() {
            APIManager.shared
              configSDImageManage()
            let currentVC = UIViewController.visibleViewController()
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let gotoAction = UIAlertAction(title: "Goto", style: .default, handler: {[weak self] _ in
                self?.gotoViewController()
            })
            let alertVC = UIAlertController.init(title: "title", message: "Oke", preferredStyle: .alert)
            alertVC.addAction(cancelAction)
            alertVC.addAction(gotoAction)
            currentVC?.present(alertVC, animated: true, completion: nil)
        }

          private func gotoViewController() {
              APIManager.shared.loginToken {[weak self] isSuccess in
                          if isSuccess {
                              guard let rooms = APIManager.shared.getRooms() else { return }
                              let vc = ConversationViewController(rooms: rooms)
                                          let navi = UINavigationController(rootViewController: vc)
                                          navi.modalPresentationStyle = .fullScreen
                                          UIViewController.visibleViewController()?.present(navi, animated: true, completion: nil)
                          }
                      }

          }
      
      func configSDImageManage() {
          
      //    let webpCoder = SDImageWebPCoder.shared
      //    SDImageCodersManager.shared.addCoder(webpCoder)
          
          SDImageCache.shared.config.maxDiskAge = 3600 * 24 * 7 //1 Week
                  
          SDImageCache.shared.config.maxMemoryCost = 1024 * 1024 * 20 //Aprox 20 images
                                  
      //        SDImageCache.shared.config.shouldCacheImagesInMemory = false // Disable memory cache, may cause cell-reusing flash because disk query is async
          SDImageCache.shared.config.shouldUseWeakMemoryCache = false // Disable weak cache, may see blank when return from background because memory cache is purged under pressure
          SDImageCache.shared.config.diskCacheReadingOptions = .mappedIfSafe // Use mmap for disk cache query
          SDWebImageManager.shared.optionsProcessor = SDWebImageOptionsProcessor() { url, options, context in
              // Disable Force Decoding in global, may reduce the frame rate
              var mutableOptions = options
              mutableOptions.insert(.avoidDecodeImage)
              return SDWebImageOptionsResult(options: mutableOptions, context: context)
          }
      }
  }
