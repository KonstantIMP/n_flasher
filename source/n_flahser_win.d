module kimp.NFlasherWin;

import gtk.LogMaker;

import gtk.Widget;
import gtk.Window;

import gtk.Main;

import gtk.ProgressBar;
import gtk.Button;
import gtk.Label;
import gtk.Entry;
import gtk.Grid;

import std.system;

alias slot = void; 

class NFlasherWin : Window {
    public this() @trusted { super("n_flasher");
        setDefaultSize(450, 200); setBorderWidth(10);

        create_ui(); connect_signal(); init_values();
    }

    private void create_ui() @trusted {
        main_grid = new Grid(); add(main_grid);

        flashing_pb = new ProgressBar();
        flashing_pb.setText("Flashing");
        flashing_pb.setShowText(true);
        main_grid.attach(flashing_pb, 0, 10, 9, 1);

        get_help_btn = new Button("Help");
        main_grid.attach(get_help_btn, 6, 2, 3, 1);

        set_adb_btn = new Button("...");
        main_grid.attach(set_adb_btn, 8, 0, 1, 1);

        set_rom_btn = new Button("...");
        main_grid.attach(set_rom_btn, 8, 1, 1, 1);

        flash_btn = new Button("Flash");
        main_grid.attach(flash_btn, 0, 11, 9, 1);

        adb_msg = new Label("ADB path :");
        adb_msg.setXalign(0.0); main_grid.attach(adb_msg, 0, 0, 2, 1);

        rom_msg = new Label("ROM path :");
        rom_msg.setXalign(0.0); main_grid.attach(rom_msg, 0, 1, 2, 1);

        log_msg = new Label("Log messages");
        log_msg.setXalign(0.0); main_grid.attach(log_msg, 0, 2, 6, 1);

        adb_en = new Entry();
        main_grid.attach(adb_en, 2, 0, 6, 1);

        rom_en = new Entry();
        main_grid.attach(rom_en, 2, 1, 6, 1);

        log_v = new LogMaker("n_flasher.log");
        main_grid.attach(log_v, 0, 3, 9, 7);

        main_grid.setRowSpacing(5);
        main_grid.setColumnSpacing(5);

        main_grid.setRowHomogeneous(true);
        main_grid.setColumnHomogeneous(true);
    }

    private void connect_signal() @trusted {

        addOnDestroy(&quitApp);
    }

    private void init_values() @trusted {
        log_v.make_record("Program started");

        if(os == OS.linux) {
            log_v.make_record("Your OS type : linux");
            log_v.make_record("Fastboot tools must be at \'/usr/bin/\'");
            adb_en.setText("/usr/bin/");
        } 
        else {
            log_v.make_record("Your OS type : Windows");
            log_v.make_record("You need manualy set path to fatsboot tools");
        }
    }

    public slot quitApp(Widget window) {
        log_v.make_record("Program closed");
    }

    private ProgressBar flashing_pb;

    private Button get_help_btn;
    private Button set_adb_btn;
    private Button set_rom_btn;
    private Button flash_btn;

    private Label adb_msg;
    private Label rom_msg;
    private Label log_msg;

    private Entry adb_en;
    private Entry rom_en;

    private Grid main_grid;

    private LogMaker log_v;
}