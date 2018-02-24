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
    std::map<size_t, LabeledPoint> saved_map;
    
    Triangle *triangle;
    graphics::Line *min_bisector;
    graphics::Ring *min_inscribed_circle;
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

- (void)set_changes_controls_enabled: (BOOL)is_enabled;

@end

@implementation AppDelegate

//@synthesize window = _windows;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    kx = ky = 1.0;
    padding = 110;
    
    offset_x = 0;
    offset_y = 0;
    
    triangle = nullptr;
    min_bisector = nullptr;
    min_inscribed_circle = nullptr;
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
    {
        image->draw(*min_bisector, Color::rgba(0, 255, 255));
        image->draw(*min_inscribed_circle, Color::rgba(0, 255, 255));
        image->draw(graphics::Point(min_inscribed_circle->position()), Color::rgba(255, 255, 0));
    }
    
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
        image->draw(*current_cursor, Color::rgba(255, 255, 0));
        image->draw(Ring(current_cursor->position(), current_cursor->size()), Color::rgba(255, 255, 0));
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

- (IBAction)clear_screen:(id)sender {
    point_map.clear();
    [self set_changes_controls_enabled:NO];
    [self.solve_button setEnabled:NO];
    [self.point_selector removeAllItems];
    [self update_image];
}

- (IBAction)save:(id)sender {
    saved_map = point_map;
    [self.load_button setEnabled:YES];
}

- (IBAction)load:(id)sender {
    point_map = saved_map;
    [self update_image];
    
    if(!point_map.empty())
    {
        for(auto &&pair : point_map)
            [
                self.point_selector addItemWithTitle:
                [NSString stringWithUTF8String:std::to_string(pair.first).c_str()]
            ];
        [self set_changes_controls_enabled:YES];
    }
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
    
    [self set_changes_controls_enabled:YES];
    
    if(is_all_points_on_same_line(point_map))
        [self.solve_button setEnabled:NO];
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
    
    if(point_map.empty())
        [self set_changes_controls_enabled:NO];
    
    if(is_all_points_on_same_line(point_map))
        [self.solve_button setEnabled:NO];
    
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

    double min_length = 0;
    double new_length = 0;
    for(++it; it != end; ++it)
    {
        if(is_triangle_degenerate(*it))
            continue;
        
        new_length = get_max_bisector(bisectors(*it)).length();
        if (new_length < min_length || min_length == 0)
        {
            min_length = new_length;
            min_it = it;
        }
    }
    
    triangle = &*min_it;
    triangle->first_point
    ({
        (triangle->first_point().x() - offset_x)*kx + offset_x + padding,
        (triangle->first_point().y() - offset_y)*ky + offset_y + padding,
    });
    
    triangle->second_point
    ({
        (triangle->second_point().x() - offset_x)*kx + offset_x + padding,
        (triangle->second_point().y() - offset_y)*ky + offset_y + padding,
    });
    
    triangle->third_point
    ({
        (triangle->third_point().x() - offset_x)*kx + offset_x + padding,
        (triangle->third_point().y() - offset_y)*ky + offset_y + padding,
    });
    
    triangle->first_point(triangle->first_point().rounded());
    triangle->second_point(triangle->second_point().rounded());
    triangle->third_point(triangle->third_point().rounded());
    
    
    graphics::Line min(get_max_bisector(bisectors(*triangle)));
    min_bisector = &min;
    
    Ring ring(inscribed_circle(*triangle));
    ring.position(ring.position().rounded());
    
    min_inscribed_circle = &ring;
    
    [self update_image];
    triangle = nullptr;
    min_bisector = nullptr;
    min_inscribed_circle = nullptr;
}

- (IBAction)point_select:(id)sender {
    if(point_map.empty())
        return;
    
    size_t point_id = [[[self.point_selector selectedItem] title] intValue];
    
    LabeledPoint point = point_map.at(point_id);
    point.position
    ({
        (point.position().x() - offset_x)*kx + offset_x + padding,
        (point.position().y() - offset_y)*ky + offset_y + padding,
        0
    });
    
    Cross cursor(point.position(), 6.0);
    current_cursor = &cursor;
    [self update_image];
    current_cursor = nullptr;
}

- (void)set_changes_controls_enabled: (BOOL)is_enabled {
    [self.change_button setEnabled:is_enabled];
    [self.remove_button setEnabled:is_enabled];
    [self.solve_button setEnabled:is_enabled];
    [self.point_selector setEnabled:is_enabled];
    [self.x_field_change setEnabled:is_enabled];
    [self.y_field_change setEnabled:is_enabled];
}

@end
