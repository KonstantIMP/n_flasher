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
import gtk.MessageDialog;
import gtk.Builder;
import gtk.Main;

import core.stdc.stdlib;
import std.system;

/// @brief  Main program function (Start point)
/// @param[in]  args    Input program arguments
int main( string [] args) {
    /// GTKd init
	Main.init(args);

    /// Creating and register app
    Application app = new Application("org.nokia.flasher.kimp", GApplicationFlags.FLAGS_NONE);
    
    /// When application is ready
    app.addOnActivate((gio.Application.Application) {
        /// Loading UI from .glade file
        Builder bc = new Builder();
        try {
            if(os == OS.linux) bc.addFromResource("/kimp/ui/NFlasherWin.glade");
            else bc.addFromFile("res\\NFlasherWin.glade");
        }
        catch (Exception) {
            /// Error while loading .glade file
            MessageDialog err = new MessageDialog(null, GtkDialogFlags.MODAL | GtkDialogFlags.USE_HEADER_BAR,
                    GtkMessageType.ERROR, GtkButtonsType.OK, "Hello!\nThere was a problem loading resources!\nReinstall program to solve program...", null);
            signal_app.addWindow(err); err.showAll(); err.run();
            err.destroy();

            exit(-1);
        }

        /// Create window
        NFlasherWin win = new NFlasherWin(bc, "main_window");
        win.showAll(); app.addWindow(win);
    });

    /// Run app
    app.run(args);
    return 0;
}
