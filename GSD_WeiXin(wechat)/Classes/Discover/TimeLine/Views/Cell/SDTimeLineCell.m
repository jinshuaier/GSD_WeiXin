//
//  SDTimeLineCell.m
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//

/*
 
 *********************************************************************************
 *
 * GSD_WeiXin
 *
 * QQ交流群: 362419100(2群) 459274049（1群已满）
 * Email : gsdios@126.com
 * GitHub: https://github.com/gsdios/GSD_WeiXin
 * 新浪微博:GSD_iOS
 *
 * 此“高仿微信”用到了很高效方便的自动布局库SDAutoLayout（一行代码搞定自动布局）
 * SDAutoLayout地址：https://github.com/gsdios/SDAutoLayout
 * SDAutoLayout视频教程：http://www.letv.com/ptv/vplay/24038772.html
 * SDAutoLayout用法示例：https://github.com/gsdios/SDAutoLayout/blob/master/README.md
 *
 *********************************************************************************
 
 */

#import "SDTimeLineCell.h"

#import "SDTimeLineCellModel.h"
#import "UIView+SDAutoLayout.h"

#import "SDTimeLineCellCommentView.h"

#import "SDWeiXinPhotoContainerView.h"

#import "SDTimeLineCellOperationMenu.h"

const CGFloat contentLabelFontSize = 15;
CGFloat maxContentLabelHeight = 0; // 根据具体font而定

NSString *const kSDTimeLineCellOperationButtonClickedNotification = @"SDTimeLineCellOperationButtonClickedNotification";
#define rgb(r, g, b)    [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
@implementation SDTimeLineCell

{
    UIImageView *_iconView;
    UILabel *_nameLable;
    UILabel *_contentLabel;
    SDWeiXinPhotoContainerView *_picContainerView;
    UILabel *_timeLabel;
    UIButton *_moreButton;
    UIButton *_operationButton;
    UIView *_lineView; //细线
    UIButton *_commentBtn; //评论的框
    UIView *_garyView; //灰框
    SDTimeLineCellCommentView *_commentView;
    BOOL _shouldOpenContentLabel;
    SDTimeLineCellOperationMenu *_operationMenu;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setup
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveOperationButtonClickedNotification:) name:kSDTimeLineCellOperationButtonClickedNotification object:nil];
    
    _shouldOpenContentLabel = NO;
    
    _iconView = [UIImageView new];
    _iconView.layer.cornerRadius = 20;
    _iconView.layer.masksToBounds = YES;
    
    _nameLable = [UILabel new];
    _nameLable.font = [UIFont systemFontOfSize:14];
    _nameLable.textColor = [UIColor colorWithRed:(54 / 255.0) green:(71 / 255.0) blue:(121 / 255.0) alpha:0.9];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.numberOfLines = 0;
    if (maxContentLabelHeight == 0) {
        maxContentLabelHeight = _contentLabel.font.lineHeight * 3;
    }
    
    _moreButton = [UIButton new];
    [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
    [_moreButton setTitleColor:TimeLineCellHighlightedColor forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    _operationButton = [UIButton new];
    [_operationButton setImage:[UIImage imageNamed:@"AlbumOperateMore"] forState:UIControlStateNormal];
    [_operationButton addTarget:self action:@selector(operationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _picContainerView = [SDWeiXinPhotoContainerView new];
    
    __weak typeof(self) weakSelf = self;
    
    _commentView = [SDTimeLineCellCommentView new];
    [_commentView setDidClickCommentLabelBlock:^(NSString *commentId, CGRect rectInWindow) {
        if (weakSelf.didClickCommentLabelBlock) {
            weakSelf.didClickCommentLabelBlock(commentId, rectInWindow, weakSelf.indexPath);
        }
    }];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.textColor = [UIColor lightGrayColor];
    
    _lineView = [UIView new];
    _lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    _commentBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [_commentBtn setImage:[UIImage imageNamed:@"comment_zhan"] forState:(UIControlStateNormal)];
    [_commentBtn addTarget:self action:@selector(operationButtonClicked) forControlEvents:(UIControlEventTouchUpInside)];
    
    _garyView = [UIView new];
    _garyView.backgroundColor = rgb(236,236,236);
    
    _operationMenu = [SDTimeLineCellOperationMenu new];

    [_operationMenu setLikeButtonClickedOperation:^{
        if ([weakSelf.delegate respondsToSelector:@selector(didClickLikeButtonInCell:)]) {
            [weakSelf.delegate didClickLikeButtonInCell:weakSelf];
        }
    }];
    [_operationMenu setCommentButtonClickedOperation:^{
        if ([weakSelf.delegate respondsToSelector:@selector(didClickcCommentButtonInCell:)]) {
            [weakSelf.delegate didClickcCommentButtonInCell:weakSelf];
        }
    }];

    
    NSArray *views = @[_iconView, _nameLable, _contentLabel, _moreButton, _picContainerView, _timeLabel, _operationButton, _commentView,_lineView,_commentBtn,_garyView];
    
    [self.contentView sd_addSubviews:views];
    
    UIView *contentView = self.contentView;
    CGFloat margin = 10;
    
    _iconView.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(contentView, margin + 5)
    .widthIs(40)
    .heightIs(40);
    
    _nameLable.sd_layout
    .leftSpaceToView(_iconView, margin)
    .topEqualToView(_iconView)
    .heightIs(15);
    [_nameLable setSingleLineAutoResizeWithMaxWidth:200];
    
    _timeLabel.sd_layout
    .leftEqualToView(_nameLable)
    .topSpaceToView(_nameLable, 8)
    .heightIs(10)
    .autoHeightRatio(0);
    
    _contentLabel.sd_layout
    .leftEqualToView(_iconView)
    .topSpaceToView(_iconView, 12)
    .rightSpaceToView(contentView, margin)
    .autoHeightRatio(0);
    
    // morebutton的高度在setmodel里面设置
    _moreButton.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_contentLabel, 0)
    .widthIs(30);
    
    
    _picContainerView.sd_layout
    .leftEqualToView(_contentLabel); // 已经在内部实现宽度和高度自适应所以不需要再设置宽度高度，top值是具体有无图片在setModel方法中设置
    
//    _timeLabel.sd_layout
//    .leftEqualToView(_contentLabel)
//    .topSpaceToView(_picContainerView, margin)
//    .heightIs(15)
//    .autoHeightRatio(0);
    
//    _lineView.sd_layout
//    .rightSpaceToView(contentView, 22)
//    .topSpaceToView(_picContainerView, 8)
//    .heightIs(1)
//    .widthIs(0);
//    _operationButton.backgroundColor = [UIColor greenColor];
    
    _lineView.sd_layout
    .leftSpaceToView(contentView, 10)
    .rightSpaceToView(contentView, margin)
    .topSpaceToView(_picContainerView, 12)
    .heightIs(0);
    
    _commentView.sd_layout
    .leftEqualToView(_contentLabel)
    .rightSpaceToView(self.contentView, margin)
    .topSpaceToView(_lineView, 0); // 已经在内部实现高度自适应所以不需要再设置高度
    _commentView.backgroundColor = [UIColor clearColor];
    
    _commentBtn.sd_layout
    .leftEqualToView(_contentLabel)
    .rightSpaceToView(self.contentView, margin)
    .heightIs(27);
    _commentBtn.backgroundColor = [UIColor clearColor];
    
    _garyView.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .topSpaceToView(_commentBtn, 20)
    .heightIs(12);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setModel:(SDTimeLineCellModel *)model
{
    _model = model;
    
    _commentView.frame = CGRectZero;
    [_commentView setupWithLikeItemsArray:model.likeItemsArray commentItemsArray:model.commentItemsArray];
    
    _shouldOpenContentLabel = NO;
    
    _iconView.image = [UIImage imageNamed:model.iconName];
    _nameLable.text = model.name;
    // 防止单行文本label在重用时宽度计算不准的问题
    [_nameLable sizeToFit];
    _contentLabel.text = model.msgContent;
    _picContainerView.picPathStringsArray = model.picNamesArray;
    
    if (model.shouldShowMoreButton) { // 如果文字高度超过60
        _moreButton.sd_layout.heightIs(20);
        _moreButton.hidden = NO;
        if (model.isOpening) { // 如果需要展开
            _contentLabel.sd_layout.maxHeightIs(MAXFLOAT);
            [_moreButton setTitle:@"收起" forState:UIControlStateNormal];
        } else {
            _contentLabel.sd_layout.maxHeightIs(maxContentLabelHeight);
            [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
        }
    } else {
        _moreButton.sd_layout.heightIs(0);
        _moreButton.hidden = YES;
    }
    
    CGFloat picContainerTopMargin = 0;
    if (model.picNamesArray.count) {
        picContainerTopMargin = 10;
    }
    _picContainerView.sd_layout.topSpaceToView(_moreButton, picContainerTopMargin);
    
    UIView *bottomView;
    
    if (!model.commentItemsArray.count && !model.likeItemsArray.count) {
        _commentView.fixedWidth = @0; // 如果没有评论或者点赞，设置commentview的固定宽度为0（设置了fixedWith的控件将不再在自动布局过程中调整宽度）
        _commentView.fixedHeight = @0; // 如果没有评论或者点赞，设置commentview的固定高度为0（设置了fixedHeight的控件将不再在自动布局过程中调整高度）
        _commentView.sd_layout.topSpaceToView(_lineView, 0);
        _commentBtn.sd_layout.topSpaceToView(_commentView, 0);
        _garyView.sd_layout.topSpaceToView(_commentBtn, 12);
//        _operationMenu.sd_layout.topSpaceToView(_operationButton, 0);
        bottomView = _garyView;
//        _operationMenu.backgroundColor = [UIColor redColor];
    } else {
        _commentView.fixedHeight = nil; // 取消固定宽度约束
        _commentView.fixedWidth = nil; // 取消固定高度约束
        _commentView.sd_layout.topSpaceToView(_lineView, 0);
        _commentBtn.sd_layout.topSpaceToView(_commentView, 0);
        _garyView.sd_layout.topSpaceToView(_commentBtn, 12);

        bottomView = _garyView;
    }
    
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:0];
    
    _timeLabel.text = @"1分钟前";
}

//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    if (_operationMenu.isShowing) {
//        _operationMenu.show = NO;
//    }
//}

#pragma mark - private actions

- (void)moreButtonClicked
{
    if (self.moreButtonClickedBlock) {
        self.moreButtonClickedBlock(self.indexPath);
    }
}

- (void)operationButtonClicked
{
    [self postOperationButtonClickedNotification];
    _operationMenu.show = !_operationMenu.isShowing;
}

- (void)receiveOperationButtonClickedNotification:(NSNotification *)notification
{
    UIButton *btn = [notification object];
    
    if (btn != _operationButton && _operationMenu.isShowing) {
        _operationMenu.show = NO;
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self postOperationButtonClickedNotification];
    if (_operationMenu.isShowing) {
        _operationMenu.show = NO;
    }
}

- (void)postOperationButtonClickedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDTimeLineCellOperationButtonClickedNotification object:_operationButton];
}

@end
