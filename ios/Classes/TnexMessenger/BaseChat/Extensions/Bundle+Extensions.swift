/*
 MIT License

 Copyright (c) 2017-2020 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

internal extension Bundle {
    #if IS_SPM
    static var messageKitAssetBundle: Bundle = Bundle.module
    #else
    static var messageKitAssetBundle: Bundle {
        let bundle = Bundle(for: BaseChatViewController.self)
        guard let url = bundle.url(forResource: "GapoMessage", withExtension: "bundle") else { return bundle }
        guard let podBundle = Bundle(url: url) else { return bundle }
        return podBundle
//        return Bundle(for: MessagesViewController.self)
    }
    #endif
    
}

public class GapoMessageBundle {
    public class func getBundle() -> Bundle {
        let bundle = Bundle(for: self)
        guard let url = bundle.url(forResource: "GapoMessage", withExtension: "bundle") else { return bundle }
        guard let podBundle = Bundle(url: url) else { return bundle }
        return podBundle
    }
}
