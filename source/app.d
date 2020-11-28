/// @file app.d
/// 
/// @brief Main program file
///
/// @license LGPLv3 (see LICENSE file)
/// @author KonstantIMP
/// @date 2020
module NFlasher;
import NFlasherWin;

import gtk.Application;
import gtk.Builder;
import gtk.Main;

void main( string [] args) {
	Main.init(args);

    Application app = new Application("org.nokia.flasher.kimp", GApplicationFlags.FLAGS_NONE);
    
    app.addOnActivate((gio.Application.Application) {
        Builder bc = new Builder();
        bc.addFromResource("/kimp/ui/NFlasherWin.glade");

        NFlasherWin win = new NFlasherWin(bc, "main_window");
        win.showAll(); app.addWindow(win);
    });

    app.run(args);
}
