module NFlasherWin;
import LogViewer;

import std.system;

import glib.c.types;
import gtk.c.types;

import gtk.FileChooserDialog;
import gtk.AboutDialog;

import gdk.Pixbuf;

import gtk.Builder;
import gtk.Window;
import gtk.Widget;

import gtk.ProgressBar;
import gtk.Button;
import gtk.Entry;

extern (C) GObject * gtk_builder_get_object (GtkBuilder * builder, const char * name);

alias slot = void; 

class NFlasherWin : Window {
    public this(ref Builder _builder, string _wname) @trusted { 
        super(cast(GtkWindow *)gtk_builder_get_object(_builder.getBuilderStruct(), _wname.ptr));
        setDefaultSize(450, 200); setBorderWidth(10); ui_builder = _builder;

        createUI(); connectSignal(); initValues();
    }

    private void createUI() @trusted {
        flash_pb = cast(ProgressBar)ui_builder.getObject("flash_pb");

        set_adb_btn = cast(Button)ui_builder.getObject("set_adb_btn");
        set_rom_btn = cast(Button)ui_builder.getObject("set_rom_btn");
        flash_btn = cast(Button)ui_builder.getObject("flash_btn");

        adb_en = cast(Entry)ui_builder.getObject("adb_en");
        rom_en = cast(Entry)ui_builder.getObject("rom_en");
    
        log_v = new LogViewer(ui_builder, "log_sw");
    }

    private void connectSignal() @trusted {
        (cast(Button)ui_builder.getObject("about_btn")).addOnClicked(&showAbout);

        set_adb_btn.addOnClicked(&setEntry);
        set_rom_btn.addOnClicked(&setEntry);

        addOnDestroy(&quitApp);
    }

    private void initValues() @trusted {
        log_v.logFilePath("n_flasher.log");
        log_v.makeRecord("Program started");

        if(os == OS.linux) {
            log_v.makeRecord("Your OS type : linux");
            log_v.makeRecord("Fastboot tools must be at \'/usr/bin/\'");
            adb_en.setText("/usr/bin/");
        } 
        else {
            log_v.makeRecord("Your OS type : Windows");
            log_v.makeRecord("You need manualy set path to fatsboot tools");
        }
    }

    private ProgressBar flash_pb;

    private Button set_adb_btn;
    private Button set_rom_btn;
    private Button flash_btn;

    private Entry adb_en;
    private Entry rom_en;

    private Builder ui_builder;

    private LogViewer log_v;

    protected slot setEntry(Button pressed) {
        FileChooserDialog open_folder = new FileChooserDialog((pressed == set_adb_btn ? "Set ADB tools path" : "Set stock ROM path"),
                                                                this, FileChooserAction.SELECT_FOLDER, null, null);
        int responce = open_folder.run();

        if(responce == ResponseType.OK) {
            if(pressed == set_adb_btn) {
                log_v.makeRecord("Setting ADB tools path as : " ~ open_folder.getFilename());
                adb_en.setText(open_folder.getFilename());
            }
            else {
                log_v.makeRecord("Setting stock ROM path as : " ~ open_folder.getFilename());
                rom_en.setText(open_folder.getFilename());
            }
        }
        else log_v.makeRecord("Setting " ~ (pressed == set_adb_btn ? "ADB tools " : "stock ROM ") ~ "path canceld");

        open_folder.destroy();
    }

    protected slot showAbout(Button pressed) {
        AboutDialog about = new AboutDialog();

        about.setVersion("0.0.1");

        about.run(); about.destroy();
    }

    protected slot quitApp(Widget window) {
        log_v.makeRecord("Program closed");
    }
}