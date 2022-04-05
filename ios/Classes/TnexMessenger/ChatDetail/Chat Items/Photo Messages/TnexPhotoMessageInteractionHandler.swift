//
//  TnexPhotoMessageInteractionHandler.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 25/03/2022.
//

import Foundation
import ImageViewer_swift

final class TnexPhotoMessageInteractionHandler: TnexMessageInteractionHandler<TnextPhotoMessageModel, PhotoMessageViewModel<TnextPhotoMessageModel>>, PhotoMessageInteractionHandlerProtocol {
    
    func userDidTapOnImage(message: TnextPhotoMessageModel, viewModel: PhotoMessageViewModel<TnextPhotoMessageModel>, imageView: UIImageView) {
        guard let urlString = message.mediaItem.urlString, let url = URL(string: urlString) else { return }
        let datasource = TnexImageDatasource(
            imageItems: [url].compactMap {
                ImageItem.url($0, placeholder: imageView.image)
        })
        let option = ImageViewerOption.rightNavItemTitle("Download") { index in
            guard let image = imageView.image else { return }
            DownloadManager.shared.saveImageToLibrary(image: image) { isSucceed in
                print("Download thanh cong")
            }
        }
        let imageCarousel = ImageCarouselViewController.init(
            sourceView: imageView,
            imageDataSource: datasource,
            imageLoader: URLSessionImageLoader(),
            options: [option],
            initialIndex: 0)
        UIViewController.topController()?.present(imageCarousel, animated: true)
    }
    
    
    
    
}

class TnexImageDatasource:ImageDataSource {
    
    private(set) var imageItems:[ImageItem]
    
    init(imageItems: [ImageItem]) {
        self.imageItems = imageItems
    }
    
    func numberOfImages() -> Int {
        return imageItems.count
    }
    
    func imageItem(at index: Int) -> ImageItem {
        return imageItems[index]
    }
}
