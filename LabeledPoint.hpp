//
//  LabeledPoint.hpp
//  graphics-lab-1
//
//  Created by Daniel Shiposha on 20/02/2018.
//

#ifndef LabeledPoint_hpp
#define LabeledPoint_hpp

#include <ginseng/graphics/Point.h>

class LabeledPoint : public ginseng::graphics::Point
{
public:
    LabeledPoint(const ginseng::math::Vector2D &position, const std::string &label);
    
    virtual void draw(ginseng::graphics::DrawDevice &) const override;
    
    void set_label(const std::string &);
    
private:
    std::string label;
};

#endif /* LabeledPoint_hpp */
