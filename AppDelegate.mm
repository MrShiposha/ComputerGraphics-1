#import "AppDelegate.h"

#include <Cocoa/Cocoa.h>

#include <ginseng/graphics/image/TGA.h>
#include <ginseng/graphics/image/exception/InvalidImagePosition.h>

#include <ginseng/math/Vector2D.h>
#include <ginseng/graphics/Line.h>
#include <ginseng/graphics/Circle.h>
#include <ginseng/graphics/Point.h>
#include <ginseng/graphics/Triangle.h>

#include <iostream>

#import <AppKit/NSAlert.h>

using namespace ginseng::graphics;
using namespace ginseng::math;

NSString *IMAGE_PATH = @"/Users/mrshiposha/Desktop/image.tga";

@interface AppDelegate () {
    NSImage *ns_image;
    image::TGA *image;
}

- (void)create_initial_image;

- (void)update_image;

- (void)error: (NSString*)message;

@end

@implementation AppDelegate

//@synthesize window = _windows;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self create_initial_image];
    [self update_image];
    
    // Window on top
    [self.window orderFrontRegardless];
    
    // Set formatters
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setDecimalSeparator:@"."];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.x_field_new setFormatter:formatter];
    [self.y_field_new setFormatter:formatter];
}

- (void)create_initial_image {
    auto view_size = self.image_view.frame.size;
    image = new image::TGA(image::Image::Size(view_size.width, view_size.height));
    
    auto size = image->size();
    for (size_t i = 0, j = 0; i < size.width; ++i)
        for (j = 0; j < size.height; ++j)
            image->pixel({i, j}) = Color::rgba(0, 0, 0, 1.0);
}

- (void)update_image {
    image->write([IMAGE_PATH UTF8String]);
    ns_image = [[NSImage alloc] initWithContentsOfFile: IMAGE_PATH];
    std::cout << ns_image << std::endl;
    [self.image_view setImage: ns_image];
    [self.image_view setNeedsDisplay: YES];
    [self.image_view display];
}

- (IBAction)show_preferences:(id)sender {
    [self.preferences_window makeKeyAndOrderFront:self];
}

- (IBAction)show_about:(id)sender {
    [self.about_window makeKeyAndOrderFront:self];
}

- (IBAction)add_point:(id)sender {
    
    static double k = 5.;
    static double dx = 350, dy = 1;
    
    
    ginseng::graphics::Point point
    ({
        static_cast<long long>([self.x_field_new doubleValue]),
        static_cast<long long>([self.y_field_new doubleValue])
    });
    
    point.transforms() << scale(k, k) << translate(dx, dy);
    point.transforms().compute();

    --dx;
    ++dy;
    k += 0.5;
    
    try
    {
        image->draw
        (
         point,
         Color::rgba(255, 0, 0, 1.0)
        );
    }
    catch (const image::exception::InvalidImagePosition &iip)
    {
        [self error:@"Неверная позиция точки"];
    }
    
    [self update_image];
}

- (void)error: (NSString*)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Ошибка отрисовки"];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSAlertStyleWarning];
    
    [alert runModal];
}

@end
