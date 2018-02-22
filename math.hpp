//
//  math.hpp
//  graphics-lab-1
//
//  Created by Daniel Shiposha on 21/02/2018.
//

#ifndef math_hpp
#define math_hpp

#include <ginseng/graphics/Graphics.h>

ginseng::math::Vector2D bisectors_intersection_point(const ginseng::graphics::Triangle &triangle);

std::tuple<ginseng::graphics::Line, ginseng::graphics::Line, ginseng::graphics::Line>
bisectors(const ginseng::graphics::Triangle &);

#endif /* math_hpp */
