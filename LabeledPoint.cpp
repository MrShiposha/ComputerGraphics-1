//
//  LabeledPoint.cpp
//  graphics-lab-1
//
//  Created by Daniel Shiposha on 20/02/2018.
//

#include "LabeledPoint.hpp"

#include <ginseng/graphics/TextView.h>
#include <iostream>

using namespace ginseng::graphics;


LabeledPoint::LabeledPoint(const ginseng::math::Vector2D &position, const std::string &label)
: Point(position), label(label)
{}

void LabeledPoint::draw(DrawDevice &device, const Color &color) const
{
    constexpr unsigned int FONT_WIDTH = 11;
    constexpr unsigned int FONT_HEIGHT = 18;
    
    constexpr double LABEL_OFFSET = 7.;
    
    Point::draw(device, color);
    
    TextView
    (
     {position().x() + LABEL_OFFSET, position().y() + LABEL_OFFSET},
     ginseng::util::Font("Times New Roman", {FONT_WIDTH, FONT_HEIGHT}),
     label
    ).draw(device, Color::rgba(255, 255, 255));
}

void LabeledPoint::set_label(const std::string &label)
{
    this->label = label;
}
