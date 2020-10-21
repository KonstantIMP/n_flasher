module kimp.NFlasher;
import kimp.NFlasherWin;

import gtk.Application;
import gtk.Main;

void main( string [] args) {
	Main.init(args);

    Application app = new Application("org.nokia.flasher.kimp", GApplicationFlags.FLAGS_NONE);
    
    app.addOnActivate((gio.Application.Application) {
        NFlasherWin win = new NFlasherWin();
        win.showAll(); app.addWindow(win);
    });

    app.run(args);
}
