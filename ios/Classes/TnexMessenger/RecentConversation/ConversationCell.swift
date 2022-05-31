//
//  ConversationCell.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import UIKit
import SwipeCellKit
import RxSwift

class ConversationCell: SwipeTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var avatarImageVIew: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    public var disposeBag: DisposeBag? = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private var _viewModel: ConversationCellViewModel?
    var viewModel: ConversationCellViewModel! {
        get { return _viewModel }
        set {
            if newValue != _viewModel {
                disposeBag = DisposeBag()

                _viewModel = newValue
                viewModelChanged()
            }
        }
    }
    
    private func viewModelChanged() {
        bindViewAndViewModel()
        _viewModel?.reactIfNeeded()
    }
    
    func bindViewAndViewModel() {
        guard let viewModel = viewModel, let disposeBag = self.disposeBag else { return }
        viewModel.rxDisplayName.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] (name) in
            self?.titleLabel.text = name
        }).disposed(by: disposeBag)
        viewModel.rxLastMessage.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] (content) in
            self?.contentLabel.text = content
        }).disposed(by: disposeBag)
        viewModel.rxTime.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] (timeString) in
            self?.timeLabel.text = timeString
        }).disposed(by: disposeBag)
    }
}
