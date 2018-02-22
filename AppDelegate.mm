#import "AppDelegate.h"

#include <Cocoa/Cocoa.h>

#include <ginseng/graphics/Graphics.h>

#include <iostream>

#import <AppKit/NSAlert.h>

#include "LabeledPoint.hpp"
#include "math.hpp"

using namespace ginseng;
using namespace ginseng::graphics;
using namespace ginseng::math;

NSString *IMAGE_PATH = @"/Users/mrshiposha/Desktop/image.tga";

@interface AppDelegate () {
    NSImage *ns_image;
    image::TGA *image;
    std::map<size_t, LabeledPoint> point_map;
    
    Triangle *triangle;
    graphics::Line *min_bisector;
    Cross *current_cursor;
    
    double kx, ky;
    double padding;
    double offset_x;
    double offset_y;
}


- (void)create_initial_image;

- (void)clear_image;

- (void)update_image;

- (void)error: (NSString*)message;

@end

@implementation AppDelegate

//@synthesize window = _windows;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    kx = ky = 1.0;
    padding = 100;
    
    offset_x = 0;
    offset_y = 0;
    
    triangle = nullptr;
    min_bisector = nullptr;
    current_cursor = nullptr;
    
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
    
    [self clear_image];
}

- (void)clear_image {
    auto size = image->size();
    for (size_t i = 0, j = 0; i < size.width; ++i)
        for (j = 0; j < size.height; ++j)
            image->pixel({i, j}) = Color::rgba(0, 0, 0, 1.0);
}

- (void)update_image {
    [self clear_image];
    
    auto
        left  = point_map.begin(),
        right = point_map.begin(),
        up    = point_map.begin(),
        down  = point_map.begin();
    
    if(point_map.size() >= 2)
    {

        for(auto it = ++point_map.begin(); it != point_map.end(); ++it)
        {
            if (it->second.position().x() < left->second.position().x())
                left = it;
            if (it->second.position().x() > right->second.position().x())
                right = it;
            if (it->second.position().y() > up->second.position().y())
                up = it;
            if (it->second.position().y() < down->second.position().y())
                down = it;
        }
        
        double right_left_diff = right->second.position().x() - left->second.position().x();
        double up_down_diff = up->second.position().y() - down->second.position().y();
        
        if(right_left_diff != 0)
            kx = (image->size().width  - 2*padding)/right_left_diff;
        else
            kx = 1;
        
        if(up_down_diff != 0)
            ky = (image->size().height - 2*padding)/up_down_diff;
        else
            ky = 1;
        
        offset_x = left->second.position().x();
        offset_y = down->second.position().y();

    }
    else
        kx = ky = 1.0;
    
    if(triangle)
    {
        image->draw(*triangle, Color::rgba(0, 255, 0));
//        image->draw(Circle(bisectors_intersection_point(*triangle), 50), Color::rgba(255, 255, 255));
    }
    
    if(min_bisector)
        image->draw(*min_bisector, Color::rgba(0, 255, 255));
    
    for(auto &&pair : point_map)
    {
        std::cout << "x: " << (pair.second.position().x() - offset_x)*kx + offset_x + padding << ", y: " << (pair.second.position().y() - offset_y)*ky + offset_y + padding << std::endl;
        image->draw
        (
            LabeledPoint(pair.second)
                .position
                ({
                    (pair.second.position().x() - offset_x)*kx + offset_x + padding,
                    (pair.second.position().y() - offset_y)*ky + offset_y + padding,
                    0
                }),
            Color::rgba(255, 0, 0)
        );
    }
    
    if(current_cursor)
    {
        std::cout << "CURRENT CURSOR" << std::endl;
       image->draw(*current_cursor, Color::rgba(255, 0, 255));
    }
    
    image->write([IMAGE_PATH UTF8String]);
    ns_image = [[NSImage alloc] initWithContentsOfFile: IMAGE_PATH];
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
    
    static size_t point_id = 1;
    
    double x_src = [self.x_field_new doubleValue],
           y_src = [self.y_field_new doubleValue];
    
    double x = std::round(x_src),
           y = std::round(y_src);
    
    if(std::find_if(point_map.begin(), point_map.end(),
                 [&x, &y](const auto &pair)
                 {
                     return pair.second.position().x() == x && pair.second.position().y() == y;
                 }) != point_map.end())
    {
        [self error:@"Такая точка уже существует"];
        return;
    }
    
    std::stringstream stream;
    stream << "№" << point_id
    << "(" << x_src << ";"
    << y_src << ")";
    
    LabeledPoint new_point({x, y}, stream.str());
    point_map.emplace(std::make_pair(point_id, new_point));
    
    [self.point_selector addItemWithTitle:[NSString stringWithUTF8String:std::to_string(point_id).c_str()]];
    
    ++point_id;
    
    [self update_image];
}

- (void)error: (NSString*)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Ошибка"];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSAlertStyleWarning];
    
    [alert runModal];
}

- (IBAction)remove_point:(id)sender {
    if([self.point_selector selectedItem] == nil)
    {
        [self error:@"Точка для удаления не выбрана"];
        return;
    }
    
    long long selected_index = [self.point_selector indexOfSelectedItem];
    
    point_map.erase([[[self.point_selector selectedItem] title] longLongValue]);
    [self.point_selector removeItemAtIndex:selected_index];
    
    [self update_image];
}

- (IBAction)change_point:(id)sender {
    if([self.point_selector selectedItem] == nil)
    {
        [self error:@"Точка для изменения не выбрана"];
        return;
    }
    
    if([[self.x_field_change stringValue] length] == 0 || [[self.y_field_change stringValue] length] == 0)
    {
        [self error:@"Неверные данные"];
        return;
    }
    
    size_t point_id = [[[self.point_selector selectedItem] title] intValue];
    
    std::stringstream stream;
    stream << "№" << point_id
    << "(" << [self.x_field_change doubleValue] << ";" << [self.y_field_change doubleValue] << ")";
    
    double x = std::round([self.x_field_change doubleValue]),
           y = std::round([self.y_field_change doubleValue]);
    
    
    
    auto &point = point_map.at(point_id);
    point.set_position({x, y, 0});
    point.set_label(stream.str());
    
    [self update_image];
}
- (IBAction)solve:(id)sender {
    
    std::vector<Triangle> triangles;
    
    auto it_1 = point_map.begin(), it_2 = point_map.begin(), it_3 = point_map.begin(),
    end_1 = point_map.end(), end_2 = point_map.end(), end_3 = point_map.end();
    
    --end_2;
    --end_1; --end_1;
    
    auto it_2_begin = ++it_2;
    
    auto it_2_border = --end_2;
    ++end_2;
    
    ++it_3; ++it_3;
    auto it_3_begin = it_3;
    
    auto it_3_border = --end_3;
    ++end_3;
    
    for(; it_1 != end_1; ++it_1)
    {
        for(it_2 = it_2_begin; it_2 != end_2; ++it_2)
        {
            for(it_3 = it_3_begin; it_3 != end_3; ++it_3)
            {
                std::cout << "{ " <<it_1->second.position()<<", "<<it_2->second.position()<<", "<<it_3->second.position() << "}" << std::endl;
                triangles.push_back(Triangle({it_1->second.position(), it_2->second.position(), it_3->second.position()}));
            }
            
            if(it_3_begin != it_3_border)
                ++it_3_begin;
        }
        
        if(it_2_begin != it_2_border)
            ++it_2_begin;
    }
    
    auto get_max_bisector = [](auto bisectors)
    {
        auto [a, b, c] = bisectors;
        
        auto a_length = a.length();
        auto b_length = b.length();
        auto c_length = c.length();
        auto max = std::max(a_length, std::max(b_length, c_length));
        
        auto epsilon = std::numeric_limits<double>::epsilon();
        if(std::abs(max - a_length) < epsilon)
            return a;
        else if(std::abs(max - b_length) < epsilon)
            return b;
        else
            return c;
        
    };
    

    auto it = triangles.begin(), end = triangles.end(), min_it = triangles.begin();

    graphics::Line min(get_max_bisector(bisectors(*it)));
    graphics::Line current_bisector(min);
    for(++it; it != end; ++it)
    {
        current_bisector = get_max_bisector(bisectors(*it));
        if (current_bisector.length() < min.length())
        {
            min = current_bisector;
            min_it = it;
        }
    }
    
    triangle = &*min_it;
    triangle->first_point
    ({
        (triangle->first_point().x() - offset_x)*kx + offset_x + padding,
        (triangle->first_point().y() - offset_y)*ky + offset_y + padding,
        0
    });
    
    triangle->second_point
    ({
        (triangle->second_point().x() - offset_x)*kx + offset_x + padding,
        (triangle->second_point().y() - offset_y)*ky + offset_y + padding,
        0
    });
    
    triangle->third_point
    ({
        (triangle->third_point().x() - offset_x)*kx + offset_x + padding,
        (triangle->third_point().y() - offset_y)*ky + offset_y + padding,
        0
    });
    
    min_bisector = &min;
    min_bisector->first_point
    ({
        (min_bisector->first_point().x() - offset_x)*kx + offset_x + padding,
        (min_bisector->first_point().y() - offset_y)*ky + offset_y + padding,
        0
    });
    min_bisector->second_point
    ({
        (min_bisector->second_point().x() - offset_x)*kx + offset_x + padding,
        (min_bisector->second_point().y() - offset_y)*ky + offset_y + padding,
        0
    });
    
    [self update_image];
    triangle = nullptr;
    min_bisector = nullptr;
}

- (IBAction)point_select:(id)sender {
    size_t point_id = [[[self.point_selector selectedItem] title] intValue];
    
    LabeledPoint point = point_map.at(point_id);
    point.position
    ({
        (point.position().x() - offset_x)*kx + offset_x + padding,
        (point.position().y() - offset_y)*ky + offset_y + padding,
        0
    });
    
    Cross cursor(point.position(), 5);
    current_cursor = &cursor;
    [self update_image];
    current_cursor = nullptr;
}
@end
