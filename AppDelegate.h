#import <AppKit/NSApplication.h> // NSApplicationDelegate
#import <AppKit/NSTextField.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSImageView.h>
#import <AppKit/NSPopUpButton.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSPanel *preferences_window;

@property (assign) IBOutlet NSPanel *about_window;

@property (assign) IBOutlet NSImageView *image_view;

@property (assign) IBOutlet NSTextField *x_field_new;

@property (assign) IBOutlet NSTextField *y_field_new;

- (IBAction)show_preferences:(id)sender;
- (IBAction)show_about:(id)sender;
@property (assign) IBOutlet NSButton *solve_button;
@property (assign) IBOutlet NSButton *change_button;
@property (assign) IBOutlet NSButton *remove_button;
- (IBAction)clear_screen:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)load:(id)sender;
@property (assign) IBOutlet NSButton *load_button;

- (IBAction)add_point:(id)sender;
@property (assign) IBOutlet NSPopUpButton *point_selector;
- (IBAction)remove_point:(id)sender;
- (IBAction)change_point:(id)sender;
@property (assign) IBOutlet NSTextField *x_field_change;
@property (assign) IBOutlet NSTextField *y_field_change;
- (IBAction)solve:(id)sender;
- (IBAction)point_select:(id)sender;

@end
