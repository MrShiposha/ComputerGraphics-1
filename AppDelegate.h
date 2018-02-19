#import <AppKit/NSApplication.h> // NSApplicationDelegate
#import <AppKit/NSTextField.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSImageView.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSPanel *preferences_window;

@property (assign) IBOutlet NSPanel *about_window;

@property (assign) IBOutlet NSImageView *image_view;

@property (assign) IBOutlet NSTextField *x_field_new;

@property (assign) IBOutlet NSTextField *y_field_new;

- (IBAction)show_preferences:(id)sender;
- (IBAction)show_about:(id)sender;

- (IBAction)add_point:(id)sender;

@end
