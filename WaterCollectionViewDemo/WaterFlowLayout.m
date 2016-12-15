//
//  WaterFlowLayout.m
//  WaterCollectionViewDemo
//
//  Created by tianyaxu on 16/12/15.
//  Copyright © 2016年 tianyaxu. All rights reserved.
//

#import "WaterFlowLayout.h"

#define CollectionWidth self.collectionView.frame.size.width

//每一行之间的间距
static const CGFloat RowMargin = 10;
//每一列的间距
static const CGFloat ColumnMargin = 10;
//每一列之间的间距top,left,bottom,right
static const UIEdgeInsets DefaultsInsets = {10, 10, 10, 10};
//默认的列数
static const int ColumsCount = 3;

@interface WaterFlowLayout()

//每一列的最大值
@property (nonatomic, strong) NSMutableArray *columnMaxYs;
//存放cell的布局属性
@property (nonatomic, strong) NSMutableArray *attrsArray;

@end

@implementation WaterFlowLayout

#pragma mark -懒加载
- (NSMutableArray *)columnMaxYs {
    if (!_columnMaxYs) {
        _columnMaxYs = [NSMutableArray array];
    }
    return _columnMaxYs;
}

- (NSMutableArray *)attrsArray {
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

#pragma mark -内部方法
//确定collection View的content size
- (CGSize)collectionViewContentSize {
    CGFloat destMaxY = [self.columnMaxYs[0] doubleValue];
    //找出最长的一列的最大Y值
    for (int i = 1; i < self.columnMaxYs.count; i ++) {
        CGFloat columnMaxY = [self.columnMaxYs[i] doubleValue];
        if (destMaxY < columnMaxY) {
            destMaxY = columnMaxY;
        }
    }
    return CGSizeMake(0, destMaxY + DefaultsInsets.bottom);
}

//在该方法中设置cell的布局属性，该方法在collectionview每次刷新的时候，都会调用该方法
- (void)prepareLayout {
    [super prepareLayout];
    
    //重置每一列的最大Y值
    [self.columnMaxYs removeAllObjects];
    for (int i = 0; i < ColumsCount; i ++) {
        [self.columnMaxYs addObject:@(DefaultsInsets.top)];
    }
    
    //计算所有的Cell的布局属性
    [self.attrsArray removeAllObjects];
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
}

//collection view滑动cell重用时会不断的调用该方法获取当前可见区域的布局属性
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

//cell的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    //cell的水平间距
    CGFloat xMargin = DefaultsInsets.left + DefaultsInsets.right + (ColumsCount - 1) * ColumnMargin;
    // cell的宽度
    CGFloat w = (CollectionWidth - xMargin) / ColumsCount;
    //cell的高度，随机高度
    CGFloat h = 50 + arc4random_uniform(150);
    
    CGFloat destMaxY = [self.columnMaxYs[0] doubleValue];
    int destColumn = 0;
    //找出最短的那一列列号和最小Y值
    for (int i = 1; i < self.columnMaxYs.count; i ++) {
        CGFloat columnMaxY = [self.columnMaxYs[i] doubleValue];
        
        if (destMaxY > columnMaxY) {
            destMaxY = columnMaxY;
            destColumn = i;
        }
    }
    
    //计算cell的x坐标
    CGFloat x  = DefaultsInsets.left + destColumn * (w + ColumnMargin);
    //计算cell的y坐标
    CGFloat y = destMaxY + RowMargin;
    //设置cell的frame
    attrs.frame = CGRectMake(x, y, w, h);
    //获取cell的坐标值＋高度值，即cell最终位置的y坐标
    self.columnMaxYs[destColumn] = @(CGRectGetMaxY(attrs.frame));
    return attrs;
}

@end
