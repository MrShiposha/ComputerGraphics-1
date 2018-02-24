//
//  math.cpp
//  graphics-lab-1
//
//  Created by Daniel Shiposha on 21/02/2018.
//

#include "math.hpp"
#include <iostream>

using namespace ginseng;

math::Vector2D bisectors_intersection_point(const graphics::Triangle &triangle)
{
    auto side_1_length = (triangle.second_point() - triangle.first_point()).length();
    auto side_2_length = (triangle.third_point() - triangle.second_point()).length();
    auto side_3_length = (triangle.first_point() - triangle.third_point()).length();
    double side_sum = side_1_length + side_2_length + side_3_length;
    
    double x =
         (
            side_2_length*triangle.first_point().x()
          + side_3_length*triangle.second_point().x()
          + side_1_length*triangle.third_point().x()
         ) / side_sum;
    
    double y =
        (
            side_2_length*triangle.first_point().y()
          + side_3_length*triangle.second_point().y()
          + side_1_length*triangle.third_point().y()
        ) / side_sum;
    
    return math::Vector2D(x, y);
}

ginseng::graphics::Ring inscribed_circle(const ginseng::graphics::Triangle &triangle)
{
    auto bisects_intersection = bisectors_intersection_point(triangle);
    auto side_1_vector = triangle.second_point() - triangle.first_point();
    auto side_2_vector = triangle.third_point() - triangle.first_point();
    
    double cos_angle = (side_1_vector).dot(side_2_vector) / (side_1_vector.length()*side_2_vector.length());
    double sin_half_angle = sqrt((1 - cos_angle)/2);
    
    double radius = sin_half_angle*(bisects_intersection - triangle.first_point()).length();
    
    return graphics::Ring(bisects_intersection, radius);
}

bool is_triangle_degenerate(const ginseng::graphics::Triangle &triangle)
{
    return math::Line(triangle.first_point(), triangle.second_point() - triangle.first_point())
            .is_contains(triangle.third_point());
}

bool is_all_points_on_same_line(const std::map<size_t, LabeledPoint> &point_map)
{
    if(point_map.size() < 3)
        return true;
    
    std::cout << "!!!!" << std::endl;
    auto it = point_map.begin(), end = point_map.end();
    
    math::Line line(it->second.position(), (++it)->second.position() - point_map.begin()->second.position());
    for(; it != end; ++it)
        if(!line.is_contains(it->second.position()))
            return false;
    
    return true;
}

std::tuple<graphics::Line, graphics::Line, graphics::Line>
bisectors(const ginseng::graphics::Triangle &triangle)
{
    std::cout << triangle << std::endl;
    std::cout << "DIRECTION_1: " << triangle.second_point() - triangle.first_point() << std::endl;
    std::cout << "DIRECTION_2: " << triangle.third_point()  - triangle.second_point() << std::endl;
    std::cout << "DIRECTION_3: " << triangle.first_point()  - triangle.third_point() << std::endl;
    
    math::Line side_1(triangle.first_point(),  triangle.second_point() - triangle.first_point());
    math::Line side_2(triangle.second_point(), triangle.third_point()  - triangle.second_point());
    math::Line side_3(triangle.third_point(),  triangle.first_point()  - triangle.third_point());
    
    auto bisects_intersection = bisectors_intersection_point(triangle);
    
    std::cout << "INTERSECTION: " << bisects_intersection << std::endl;
    std::cout << "BIS_DIRECTION_1: " << bisects_intersection - triangle.first_point() << std::endl;
    std::cout << "BIS_DIRECTION_2: " << bisects_intersection - triangle.second_point() << std::endl;
    std::cout << "BIS_DIRECTION_3: " << bisects_intersection - triangle.third_point() << std::endl;
    
    math::Line bisect_1(triangle.first_point(),  bisects_intersection - triangle.first_point());
    math::Line bisect_2(triangle.second_point(), bisects_intersection - triangle.second_point());
    math::Line bisect_3(triangle.third_point(),  bisects_intersection - triangle.third_point());
    
    auto bisect_1_end = bisect_1.intersection(side_2).round();
    auto bisect_2_end = bisect_2.intersection(side_3).round();
    auto bisect_3_end = bisect_3.intersection(side_1).round();
    
    std::cout << "1? = " << std::boolalpha << bisect_1.is_contains(bisects_intersection) << " // " << bisect_1.is_contains(triangle.first_point()) << std::endl;
    std::cout << "2? = " << std::boolalpha << bisect_2.is_contains(bisects_intersection) << " // " << bisect_2.is_contains(triangle.second_point()) << std::endl;
    std::cout << "3? = " << std::boolalpha << bisect_3.is_contains(bisects_intersection) << " // " << bisect_3.is_contains(triangle.third_point()) << std::endl;
    
    return std::make_tuple
    (
        graphics::Line(triangle.first_point(),  bisect_1_end),
        graphics::Line(triangle.second_point(), bisect_2_end),
        graphics::Line(triangle.third_point(),  bisect_3_end)
    );
}

//std::tuple<double, double, double> get_line_qs(const Vector3D &a, const Vector3D &b)
//{
//    double A = b.y() - a.y();
//    double B = a.x() - b.x();
//    double C = b.x()*a.y() - b.y()*a.x();
//
//    return std::make_tuple(A, B, C);
//}
//
//graphics::Line get_triangle_max_height(const ginseng::graphics::Triangle &triangle)
//{
//    double h1 = 0.0, h2 = 0.0, h3 = 0.0;
//
//    // A, B, C - коэф-ты уравнения прямой для каждой стороны
//
//    // Первая сторона
//    auto [A1, B1, C1] = get_line_qs(triangle.first_point(), triangle.second_point());
//    h1 = std::abs(A1*triangle.third_point().x()*B1*triangle.third_point().y() + C1) / sqrt(A1*A1 + B1*B1);
//
//    // Вторая сторона
//    auto [A2, B2, C2] = get_line_qs(triangle.second_point(), triangle.third_point());
//    h2 = std::abs(A2*triangle.first_point().x()*B2*triangle.first_point().y() + C2) / sqrt(A2*A2 + B2*B2);
//
//    // Третья сторона
//    auto [A3, B3, C3] = get_line_qs(triangle.first_point(), triangle.third_point());
//    h3 = std::abs(A3*triangle.second_point().x()*B3*triangle.second_point().y() + C3) / sqrt(A3*A3 + B3*B3);
//
//
//    double max = std::max(h1, std::max(h2, h3));
//    double px = 0., py = 0.;
//
//    auto set_px_py = [&px, &py](const Vector3D &vector, double A, double B, double C)
//    {
//        py = ( B*C/A + B*vector.x() - A*vector.y()) / (-B*B/A - A);
//        px = (-B*py - C) / A;
//    };
//
//    if(h1 == max)
//    {
//        set_px_py(triangle.third_point(), A1, B1, C1);
//        return Line(triangle.third_point(), {px, py, 0.});
//    }
//    else if(h2 == max)
//    {
//        set_px_py(triangle.first_point(), A2, B2, C2);
//        return Line(triangle.first_point(), {px, py, 0.});
//    }
//    else if(h3 == max)
//    {
//        set_px_py(triangle.second_point(), A3, B3, C3);
//        return Line(triangle.second_point(), {px, py, 0.});
//    }
//}

