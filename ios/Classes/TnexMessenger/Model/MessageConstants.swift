//
//  MessageConstants.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 23/03/2022.
//

import Foundation
import MatrixSDK

public struct MessageConstants {
    static let messageBodyKey: String = kMXMessageBodyKey
    static let messageTypeKey: String = kMXMessageTypeKey
    
    static let previewPaddingTopBottom: CGFloat = 10.0
    static let previewDescPaddingTitle: CGFloat = 4

    //Mention chat
    static let mentionDisplayName = "All"
    static let mentionAllTarget = "all"
    static let phoneRegex: String = "\\b[0-9]{8,11}\\b"
    static let urlRegex: String = "(^|[\\s.:;?\\-\\]<\\(])" +
        "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
    // MARK: - Static functions

    static public func calcMaxWidthMessage() -> CGFloat {
        return UIScreen.main.bounds.size.width - 150
    }
    
    static public func calcMaxWidthImageThumb() -> CGFloat {
        return UIScreen.main.bounds.size.width / 2
    }

    static public func calcMaxHeightImageThumb() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }

    static public func calcMaxWidthCell() -> CGFloat {
        return calcMaxWidthMessage() + 12 * 2
    }

    static public func calcPreviewHeightImage() -> CGFloat {
        let widthImage = calcMaxWidthCell()
        let heightImage = widthImage * 133 / 237
        return heightImage
    }
    
    public enum ActionView {
        public enum ReplyView {
            static public let contentMediaInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
            static public let mediaSize: CGSize = CGSize(width: 40, height: 40)
            static public let mediaRadius: CGFloat = 4
            static public let contentTextInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            static public let bottomPadding: CGFloat = -18
            static public let contentFont: UIFont = UIFont.systemFont(ofSize: 13)
            static public let rightReplyIconPadding: CGFloat = 4
            
        }
        
        public enum RemoveView {
            static public let contentInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            static public let bottomPadding: CGFloat = 0
        }
        public enum ReactionView {
            static public let topPadding: CGFloat = -8
        }
        
        static public let backgroundColor: UIColor = UIColor.fromHex("#F6F6F6")
        static public let cornerRadius: CGFloat = 14
    }
    public enum ActionNote {
        static public let contentInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 42, bottom: 8, right: 42)
        static public let bottomPadding: CGFloat = 0
    }
    
    public enum Images {
        static public let replyImage: UIImage? = UIImage(named: "mk_icon_chat_reply", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        static public let editIncomingImage: UIImage? = UIImage(named: "mk-edit-message-incoming", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        static public let editOutgoingImage: UIImage? = UIImage(named: "mk-edit-message-outgoing", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        static public let markReplyImage: UIImage? = UIImage(named: "mk_icon_mark_reply", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        static public let markSaveImage: UIImage? = UIImage(named: "mk_icon_bookmark", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        static public let markForwardImage: UIImage? = UIImage(named: "mk_icon_mark_forward", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        static public let videoIcon: UIImage? = UIImage(named: "mk_icon_chat_video", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        static public let hdIcon: UIImage? = UIImage(named: "mk_ic_imageHD", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        public enum Call {
            
            public enum Video {
                static public let incoming: UIImage? = UIImage(named: "mk_ic_videocall_incoming", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static public let outgoing: UIImage? = UIImage(named: "mk_ic_videocall_outgoing", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static public let misscall: UIImage? = UIImage(named: "mk_ic_videocall_misscall", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static public let hangup: UIImage? = UIImage(named: "mk_ic_videocall_hangup", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
            }
            
            public enum Audio {
                static public let incoming: UIImage? = UIImage(named: "mk_ic_audiocall_incoming", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static public let outgoing: UIImage? = UIImage(named: "mk_ic_audiocall_outgoing", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static public let misscall: UIImage? = UIImage(named: "mk_ic_audiocall_misscall", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static public let hangup: UIImage? = UIImage(named: "mk_ic_audiocall_hangup", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
            }
            
        }
    
        public enum Status {
            public static let sending: UIImage? = UIImage(named: "mk_icon_msg_sending", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
            public static let sent: UIImage? = UIImage(named: "mk_icon_msg_sent", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
            public static let failed: UIImage? = UIImage(named: "mk_icon_message_failed", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        }

    }
    
    public enum Limit {
        static public let minContainerBodyHeight: CGFloat = abs(MessageConstants.ActionView.ReplyView.bottomPadding) * 2
        static public let maxActionReplyTextHeight: CGFloat = 36
    }
    
    public enum Colors {
        public static let bubbleBorderColor: UIColor = UIColor.fromHex("#DEDFE2")
        public static let incomingBubbleBackgroundColor: UIColor = UIColor.fromHex("#EDEDED")
        public static let outgoingBubbleBackgroundColor: UIColor = UIColor.fromHex("#375464")
        struct TextLabel {
            static let phoneOutgoing: UIColor = UIColor.white
            static let phoneIncoming: UIColor = UIColor.fromHex("#1A1A1A")
            static let urlOutgoing: UIColor = UIColor.white
            static let urlIncoming: UIColor = UIColor.fromHex("#1A1A1A")
            static let mentionOutgoing: UIColor = UIColor.white
            static let mentionIncoming: UIColor = UIColor.fromHex("#30A960")
            static let linkPreviewTitle: UIColor = UIColor.fromHex("#1A1A1A")
            static let linkPreviewTeaser: UIColor = UIColor.fromHex("#808080")
            static let textMessageOutgoing: UIColor = UIColor.white
            static let textMessageIncoming: UIColor = UIColor.fromHex("#1A1A1A")
        }
    }
    
    public enum Sizes {
        
        static let videoIconSize: CGSize = CGSize(width: 48, height: 48)
        static let progressHeight: CGFloat = 6
        public static let reactionHeight: CGFloat = 28
        public static let avatarSize: CGSize = CGSize(width: 30, height: 30)
        public static let statusSize: CGSize = CGSize(width: 14, height: 14)
        public static let seenAvatarSize: CGSize = CGSize(width: 16, height: 16)
        public static let seenInfoHeight: CGFloat = 22
        public enum Donate {
            static public let iconCoin: CGSize = CGSize(width: 16, height: 16)
            static public let donateInfoHeight: CGFloat = 36
        }
        
        public enum Call {
            static public let callView: CGSize = CGSize(width: 210, height: 64)
            static public let statusIcon: CGSize = CGSize(width: 40, height: 40)
        }
        
        public enum Preview {
            static public let paddingTopBottom: CGFloat = 10.0
            static public let descPaddingTitle: CGFloat = 4
            static public let paddingLeftRight: CGFloat = 12
            static public let imageRatio: CGFloat = 0.6
        }
        
        enum Conference {
            static let widthOfCell: CGFloat = 260
        }
        
    }
    
    public enum ContentInsets {
        public static let donate: UIEdgeInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
        public static let incomingMessagePadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 18)
        public static let outgoingMessagePadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 2)
        public enum Text {
            static public let incomingMessageLabelInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            static public let outgoingMessageLabelInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        }
        public enum Call {
            static public let statusIcon: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            static public let callInfo: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
        public enum File {
            static public let textInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
    }
    
    public enum MultiMediaCell {
        static public let paddingCell: CGFloat = 2.0
    }
    
}
