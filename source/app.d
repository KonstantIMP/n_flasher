/// @file app.d
/// 
/// @brief Main program file
///
/// @license LGPLv3 (see LICENSE file)
/// @author KonstantIMP
/// @date 2021
module NFlasher;
import NFlasherWin;

import gtk.Application;
import gtk.MessageDialog;
import gtk.Builder;
import gtk.Main;

import core.stdc.locale;
import core.stdc.stdlib;
import std.system;
import std.string;
import std.conv;

import djtext.core;

/// @brief  Main program function (Start point)
/// @param[in]  args    Input program arguments
int main( string [] args) {
    /// Getting current locale
    if(indexOf(to!(string)(setlocale(LC_ALL, "")), "ru_RU") != -1) defaultLocale = "ru_RU";

    /// GTKd init
	Main.init(args);

    /// Creating and register app
    Application app = new Application("org.n_flasher.kimp", GApplicationFlags.FLAGS_NONE);
    
    /// When application is ready
    app.addOnActivate((gio.Application.Application) {
        /// Loading UI from .glade file
        Builder bc = new Builder();
        try {
            version(linux) {
                bc.addFromResource("/kimp/ui/NFlasherWin.glade");
                loadAllLocales("./locale");
            }
            else {
                bc.addFromFile("..\\res\\NFlasherWin.glade");
                loadAllLocales("..\\locale\\");
            }
        }
        catch (Exception) {
            /// Error while loading .glade file
            MessageDialog err = new MessageDialog(null, GtkDialogFlags.MODAL | GtkDialogFlags.USE_HEADER_BAR,
                    GtkMessageType.ERROR, GtkButtonsType.OK, true, "<span size='x-large'>" ~ _("Woof!") ~ "</span>\n" ~ _("It is a") ~ " <span underline='single' font_weight='bold'>" ~ _("critical error") ~ "</span> " ~ _("with resource loaging.") ~ "\n" ~ _("To solve it - reinstall the program") ~ "  <span size='small'>(╯°^°)╯┻━┻</span>", null);
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
