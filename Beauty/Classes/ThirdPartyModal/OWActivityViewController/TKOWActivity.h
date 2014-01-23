//
//  TKOWActivity.h
//  Tapatalk
//
//  Created by Luo Hui on 13-7-2.
//
//

#import "OWActivity.h"

@interface TKOWActivity : OWActivity
- (id)initWithTitle:(NSString *)title image:(UIImage *)image actionBlock:(OWActivityActionBlock)actionBlock;

@end
