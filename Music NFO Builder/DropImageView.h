//
//  DropImageView.h
//  Music NFO Builder
//
//  Created by Shasta on 09/12/12.
//
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>

//<NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>
@interface DropImageView : NSImageView  {
    
    
    BOOL highlight;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
-(NSDictionary*)read:(NSString *)path;

@end
