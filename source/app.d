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
    Application app = new Application("org.n_flasher.kimp", GApplicationFlags.FLAGS_NONE);
    
    /// When application is ready
    app.addOnActivate((gio.Application.Application) {
        /// Loading UI from .glade file
        Builder bc = new Builder();
        try {
            version(linux) bc.addFromResource("/kimp/ui/NFlasherWin.glade");
            else bc.addFromFile("..\\res\\NFlasherWin.glade");
        }
        catch (Exception) {
            /// Error while loading .glade file
            MessageDialog err = new MessageDialog(null, GtkDialogFlags.MODAL | GtkDialogFlags.USE_HEADER_BAR,
                    GtkMessageType.ERROR, GtkButtonsType.OK, true, "<span size='x-large'>Woof!</span>\nIt is a <span underline='single' font_weight='bold'>critical error</span> with resource loaging.\nTo solve it - reinstall the program  <span size='small'>(╯°^°)╯┻━┻</span>", null);
            app.addWindow(err); err.showAll(); err.run();
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
