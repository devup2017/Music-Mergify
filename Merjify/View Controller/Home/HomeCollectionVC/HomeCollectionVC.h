//
//  HomeCollectionVC.h
//  Merjify
//
//  Created by Abhishek Kumar on 15/07/16.
//  Copyright © 2016 Netforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCollectionVC : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@end
