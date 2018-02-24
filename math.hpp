//
//  math.hpp
//  graphics-lab-1
//
//  Created by Daniel Shiposha on 21/02/2018.
//

#ifndef math_hpp
#define math_hpp

#include <ginseng/graphics/Graphics.h>

#include "LabeledPoint.hpp"

ginseng::math::Vector2D bisectors_intersection_point(const ginseng::graphics::Triangle &triangle);

ginseng::graphics::Ring inscribed_circle(const ginseng::graphics::Triangle &triangle);

bool is_triangle_degenerate(const ginseng::graphics::Triangle &triangle);

bool is_all_points_on_same_line(const std::map<size_t, LabeledPoint> &point_map);

std::tuple<ginseng::graphics::Line, ginseng::graphics::Line, ginseng::graphics::Line>
bisectors(const ginseng::graphics::Triangle &);

#endif /* math_hpp */
