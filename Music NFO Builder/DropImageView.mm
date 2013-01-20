//
//  DropImageView.m
//  Music NFO Builder
//
//  Created by Shasta on 09/12/12.
//
//

#import "DropImageView.h"

#import <TagLib/fileref.h>
#import <TagLib/tag.h>
#import <TagLib/audioproperties.h>
#import <TagLib/flacproperties.h>
#import <TagLib/tstring.h>

@implementation DropImageView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code here.
        
        //[self setAlphaValue:0.5];
        highlight = NO;
        
        //[self registerForDraggedTypes:[NSArray arrayWithObjects:(id)kUTTypeFileURL, nil]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    
    if (highlight) {
        
        NSLog(@"highlight");
        
        

        //[self setAlphaValue:0.5];

        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth:3];
        [NSBezierPath strokeRect:dirtyRect];


    }
    else {
        NSLog(@"no highlight");
       
        //[self setAlphaValue:1];

    }
    
    [super drawRect:dirtyRect];
    
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    
    
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSLog(@"containsObject");
        
        NSArray *paths = [pboard propertyListForType:NSFilenamesPboardType];
        for (NSString *path in paths) {
            NSLog(@"path %@", path);

            
            NSError *error = nil;
            NSString *utiType = [[NSWorkspace sharedWorkspace] typeOfFile:path error:&error];
            
            if ([[NSWorkspace sharedWorkspace] type:utiType conformsToType:(id)kUTTypeFolder]) {
                
                NSLog(@"conformsToType");
                
                highlight = YES;
                [self setNeedsDisplay: YES];
                
                return NSDragOperationCopy;
            }
        }
    }
 
    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    
    highlight = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"performDragOperation");
    
    
    
    if ([sender draggingSource] != self) {
        
        NSString *folder = [[[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
        
        NSLog(@"folder %@", folder);
        
       NSFileManager *fm = [NSFileManager defaultManager];
    
        NSError *error;
        
       NSArray* files = [fm contentsOfDirectoryAtPath:folder error:&error];
        
        //NSLog(@"files %@", files); [[panel URL] path]
        NSLog(@"error %@", error);

        
        for(NSString *file in files) {
            NSString *path = [folder stringByAppendingPathComponent:file];

            //NSLog(@"path %@", path);
            
            NSDictionary* meta = [self read: path];
            
            //NSLog(@"length %lu", meta.count);
            
            if(meta.count > 0)
            {
                NSLog(@"meta %@", [meta description]);
                //break;
            }
                
            
            /*
             
             BOOL isDir = NO;
            [fm fileExistsAtPath:path isDirectory:(&isDir)];
            if(isDir) {
                [directoryList addObject:file];
            }
             */
        }
        
        
        
    }
    
    
    highlight = NO;
    [self setNeedsDisplay:YES];
    
    
    return YES;
}

-(NSDictionary*)read:(NSString *)path
{
    NSLog(@"path %@", path);
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    TagLib::FileRef f([path UTF8String]);
    
    const TagLib::FLAC::Properties *props = (TagLib::FLAC::Properties *)f.audioProperties();
        
    const TagLib::Tag *tag = f.tag();
    
    if(tag && props){
        
        TagLib::String artist, title, album, genre, comment;
        int year, track;
        
        artist = tag->artist();
        title = tag->title();;
        album = tag->album();
        genre = tag->genre();
        comment = tag->comment();
        
        
        year = tag->year();
        [dict setObject:[NSNumber numberWithInt:year] forKey:@"year"];
        
        track = tag->track();
        [dict setObject:[NSNumber numberWithInt:track] forKey:@"track"];
        
        if (!artist.isNull())
            [dict setObject:[NSString stringWithUTF8String:artist.toCString(true)] forKey:@"artist"];
        
        if (!album.isNull())
            [dict setObject:[NSString stringWithUTF8String:album.toCString(true)] forKey:@"album"];
        
        if (!title.isNull())
            [dict setObject:[NSString stringWithUTF8String:title.toCString(true)] forKey:@"title"];
        
        if (!genre.isNull())
            [dict setObject:[NSString stringWithUTF8String:genre.toCString(true)] forKey:@"genre"];
        
        [dict setObject:[NSNumber numberWithInt:props->length()] forKey:@"length"];
        
        //NSLog(@"%d", props->bitrate());
        [dict setObject:[NSNumber numberWithInt:props->bitrate()] forKey:@"bitRate"];
        [dict setObject:[NSNumber numberWithInt:props->sampleRate()] forKey:@"sampleRate"];
        [dict setObject:[NSNumber numberWithInt:props->channels()] forKey:@"channels"];

        [dict setObject:[NSNumber numberWithInt:props->sampleWidth()] forKey:@"sampleWidth"];

        
    }
    
    
    return dict;
    
}

@end
