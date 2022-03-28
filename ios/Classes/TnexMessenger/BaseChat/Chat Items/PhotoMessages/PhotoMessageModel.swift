/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit

public protocol MediaItem {
    var image: UIImage? { get }
    var imageSize: CGSize { get }
    var urlString: String? { get }
    var displaySize: CGSize { get }
    var id: String? { get }
}

public protocol PhotoMessageModelProtocol: DecoratedMessageModelProtocol, ContentEquatableChatItemProtocol {
    var mediaItem: MediaItem { get }
}

open class PhotoMessageModel<MessageModelT: MessageModelProtocol>: BaseMessageModel<MessageModelT>, PhotoMessageModelProtocol {
    
    public let mediaItem: MediaItem
    public init(messageModel: MessageModelT, mediaItem: MediaItem) {
        self.mediaItem = mediaItem
        super.init(messageModel: messageModel)
    }
    public override func hasSameContent(as anotherItem: ChatItemProtocol) -> Bool {
        guard let anotherMessageModel = anotherItem as? PhotoMessageModel else { return false }
        return self.mediaItem.image == anotherMessageModel.mediaItem.image
            && self.mediaItem.urlString == anotherMessageModel.mediaItem.urlString
    }
    
    open func willBeShown() {
        //Update progres...
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }

    open func wasHidden() {
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }
}
