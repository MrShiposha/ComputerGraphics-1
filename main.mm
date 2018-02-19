#import <AppKit/NSApplication.h> // NSApplicationMain

#include <iostream>

namespace ginseng
{
    namespace application
    {
        namespace implementation
        {
            void ___prestart(int, char**);
        }
    }
    
    void initialize();
    
    void deinitialize();
}

int main(int argc, char *argv[]) {
    ginseng::application::implementation::___prestart(argc, argv);
    ginseng::initialize();
    
    int result = NSApplicationMain(argc, (const char**) argv);
    
    ginseng::deinitialize();
    
    return result;
}
