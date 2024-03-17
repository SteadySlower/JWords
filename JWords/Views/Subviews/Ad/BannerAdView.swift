
import SwiftUI

extension View {
    func withBannerAD() -> some View {
        #if os(iOS)
        ModifiedContent(content: self, modifier: AddBannerViewModifier())
        #elseif os(macOS)
        self
        #endif
    }
}

#if os(iOS)
//import GoogleMobileAds

private struct AddBannerViewModifier: ViewModifier {
    
    private let adWidth: CGFloat
    
    init() {
        let deviceWidth = Constants.Size.deviceWidth
        let deviceHeight = Constants.Size.deviceHeight
        self.adWidth = deviceWidth < deviceHeight ? deviceWidth : deviceHeight
    }
    
    func body(content: Content) -> some View {
        VStack {
            content
//            BannerView(adWidth: adWidth)
//                .frame(height: 59)
        }
    }
}

//private struct BannerView: UIViewControllerRepresentable {
//    private let adWidth: CGFloat
//    private let bannerView = GADBannerView()
//    private let adUnitID = (Bundle.main.infoDictionary?["BannerAdUnitID"] as? String) ?? "/6499/example/banner"
//    
//    init(adWidth: CGFloat) {
//        self.adWidth = adWidth
//    }
//    
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let bannerViewController = UIViewController()
//        bannerView.adUnitID = adUnitID
//        bannerView.rootViewController = bannerViewController
//        bannerView.delegate = context.coordinator
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        bannerViewController.view.addSubview(bannerView)
//        // Constrain GADBannerView to the bottom of the view.
//        NSLayoutConstraint.activate([
//            bannerView.bottomAnchor.constraint(
//                equalTo: bannerViewController.view.safeAreaLayoutGuide.bottomAnchor),
//            bannerView.centerXAnchor.constraint(equalTo: bannerViewController.view.centerXAnchor),
//        ])
//        
//        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(adWidth)
//        bannerView.load(GADRequest())
//        
//        return bannerViewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, GADBannerViewDelegate
//    {
//        let parent: BannerView
//        
//        init(_ parent: BannerView) {
//            self.parent = parent
//        }
//        
//        // MARK: - GADBannerViewDelegate methods
//        
//        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
//            print("디버그: DID RECEIVE AD")
//        }
//        
//        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
//            print("디버그: DID NOT RECEIVE AD: \(error.localizedDescription)")
//        }
//    }
//}
#endif
