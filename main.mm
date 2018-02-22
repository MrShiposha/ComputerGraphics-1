#import <AppKit/NSApplication.h> // NSApplicationMain

#include <AppKit/NSAlert.h>

#include <ginseng/3rd-party/boost/filesystem.hpp>

#include <iostream>
#include <unistd.h>

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
