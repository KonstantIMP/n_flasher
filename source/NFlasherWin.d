/// @file NFlasherWin.d
/// 
/// @brief Main program file
///
/// @license LGPLv3 (see LICENSE file)
/// @author KonstantIMP
/// @date 2020
module NFlasherWin;
import LogViewer;
import PhoneFlasher;
import Defines;

import std.system;

import glib.c.types;
import gtk.c.types;

import gtk.FileChooserDialog;
import gtk.MessageDialog;
import gtk.AboutDialog;

import gtk.CheckButton;
import gtk.ToggleButton;

import gdkpixbuf.Pixbuf;

import gtk.Builder;
import gtk.Window;
import gtk.Widget;

import gtk.ProgressBar;
import gtk.Button;
import gtk.Entry;

import gtk.Main;

import glib.Timeout;

import std.concurrency;
import core.thread;
import std.stdio;

import core.stdc.stdlib;

/// @brief  NFlasherWin Main window widget
///
/// Contains all UI elements
class NFlasherWin : Window {
    /// @brief  Basic constructor for widget
    /// Init child widgets, build ui and connect signals
    public this(ref Builder _builder, string _wname) @trusted { 
        super((cast(Window)(_builder.getObject(_wname))).getWindowStruct());
        setDefaultSize(450, 200); setBorderWidth(10); ui_builder = _builder;

        createUI(); connectSignal(); initValues();
    }

    /// @brief Get widgets from builder and create log viewer
    private void createUI() @trusted {
        flash_pb = cast(ProgressBar)ui_builder.getObject("flash_pb");

        set_adb_btn = cast(Button)ui_builder.getObject("set_adb_btn");
        set_rom_btn = cast(Button)ui_builder.getObject("set_rom_btn");
        flash_btn = cast(Button)ui_builder.getObject("flash_btn");

        vbmeta_btn = cast(CheckButton)ui_builder.getObject("vbmeta_check");
        reboot_btn = cast(CheckButton)ui_builder.getObject("reboot_check");

        adb_en = cast(Entry)ui_builder.getObject("adb_en");
        rom_en = cast(Entry)ui_builder.getObject("rom_en");
    
        slot_btn = cast(ToggleButton)ui_builder.getObject("slot_btn");

        svb_flash_btn = cast(Button)ui_builder.getObject("svb_flash_btn");

        log_v = new LogViewer(ui_builder, "log_sw");

        try {
            version(linux) setIcon(Pixbuf.newFromResource("/kimp/img/n_flasher.png", 64, 64, true));
            else setIcon(new Pixbuf("..\\res\\n_flasher.png", 64, 64, true));
        }
        catch(Exception) {
            MessageDialog war = new MessageDialog(this, GtkDialogFlags.MODAL | GtkDialogFlags.USE_HEADER_BAR,
                    GtkMessageType.WARNING, GtkButtonsType.OK, "Hello!\nThere was a problem(not critical) loading resources!\nReinstall program to solve program...", null);
            war.showAll(); war.run(); war.destroy();
        }
    }

    /// @brief Connect signals for buttons
    private void connectSignal() @trusted {
        (cast(Button)ui_builder.getObject("about_btn")).addOnClicked(&showAbout);

        set_adb_btn.addOnClicked(&setEntry);
        set_rom_btn.addOnClicked(&setEntry);
        flash_btn.addOnClicked(&flashStart);

        vbmeta_btn.addOnToggled(&vbmetaChanged);
        reboot_btn.addOnToggled(&rebootChanged);

        slot_btn.addOnToggled(&slotChanged);

        svb_flash_btn.addOnClicked(&flasSVBhStart);

        addOnDestroy(&quitApp);
    }

    /// @brief Setup start values for different platforms
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

    /// @brief Slot for setting PATH for ADB and ROM
    protected void setEntry(Button pressed) @trusted {
        FileChooserDialog open_folder = new FileChooserDialog((pressed == set_adb_btn ? "Set ADB tools path" : "Set stock ROM path"),
                                                                this, FileChooserAction.SELECT_FOLDER, null, null);
        immutable int responce = open_folder.run();

        if(responce == ResponseType.OK) {
            if(pressed == set_adb_btn) {
                log_v.makeRecord("Setting ADB tools path as : " ~ open_folder.getFilename());
                adb_en.setText(open_folder.getFilename() ~ (os == OS.linux ? '/' : '\\'));
            }
            else {
                log_v.makeRecord("Setting stock ROM path as : " ~ open_folder.getFilename());
                rom_en.setText(open_folder.getFilename() ~ (os == OS.linux ? '/' : '\\'));
            }
        }
        else log_v.makeRecord("Setting " ~ (pressed == set_adb_btn ? "ADB tools " : "stock ROM ") ~ "path canceld");

        open_folder.destroy();
    }

    /// @brief Making vbmeta record
    protected void vbmetaChanged(ToggleButton t) @trusted {
        log_v.makeRecord("vbmeta flashing is : " ~ (t.getActive() == true ? "YES" : "NO"));
    } 

    protected void rebootChanged(ToggleButton t) @trusted {
        log_v.makeRecord("Reboot after flashing : " ~ (t.getActive() == true ? "YES" : "NO"));
    }

    protected void slotChanged(ToggleButton t) @trusted {
        log_v.makeRecord("Slot for flashing : " ~ (t.getActive() == true ? "B" : "A"));
    }

    /// @brief Slot for open AboutDialog
    protected void showAbout(Button pressed) @trusted {
        AboutDialog about = new AboutDialog();

        about.setVersion(Defines.str_ver);
        about.setAuthors(["KonstantIMP"]);
        about.setProgramName("n_flasher");
        about.setLicenseType(GtkLicense.LGPL_3_0);
        about.setCopyright("Copyright © 2020, KonstantIMP");
        about.setComments("Simple app for Nokia 7.1 flashing");
        about.setWebsite("https://github.com/KonstantIMP/n_flasher");
        
        try {
            if(os == OS.linux) about.setLogo(Pixbuf.newFromResource("/kimp/img/n_flasher.png", 96, 96, true));
            else about.setLogo(new Pixbuf("res\\n_flasher.png", 96, 96, true));
        }
        catch(Exception) {
            MessageDialog war = new MessageDialog(this, GtkDialogFlags.MODAL | GtkDialogFlags.USE_HEADER_BAR,
                    GtkMessageType.WARNING, GtkButtonsType.OK, "Hello!\nThere was a problem(not critical) loading resources!\nReinstall program to solve program...", null);
            war.showAll(); war.run(); war.destroy();
        }
        
        about.run(); about.destroy();
    }

    /// @brief Slot for app quit (make record in log)
    protected void quitApp(Widget window) @trusted {
        log_v.makeRecord("Program closed");
    }

    /// @brief Slot for flashing start
    protected void flashStart(Button _pressed) @trusted {
        flasher = new shared PhoneFlasher();

        /// Check rom
        if(flasher.checkValue(log_v, adb_en.getText(), rom_en.getText(), vbmeta_btn.getActive())) {
            MessageDialog are_you_sure = new MessageDialog(this, GtkDialogFlags.MODAL,
                GtkMessageType.WARNING, GtkButtonsType.YES_NO, "All actions with your phone are performed at your own risk. The Creator of this SOFTWARE is not responsible for your further actions. Want to continue?");

            /// Warning user
            if(are_you_sure.run() != ResponseType.YES) {
                are_you_sure.destroy(); return;
            } are_you_sure.destroy();

            /// Disable buttons
            setUISentensive(false);

            /// Spawn flashing process
            child_tid = spawn(&flasher.startFlashing, thisTid, vbmeta_btn.getActive(), reboot_btn.getActive(), slot_btn.getActive());

            /// Ui updater connect
            ui_updater = new Timeout(500, &updateUI);
        }
    }

    protected void flasSVBhStart(Button _pressed) @trusted {
        flasher = new shared PhoneFlasher();

        /// Check rom
        if(flasher.checkSVBValue(log_v, adb_en.getText(), rom_en.getText())) {
            MessageDialog are_you_sure = new MessageDialog(this, GtkDialogFlags.MODAL,
                GtkMessageType.WARNING, GtkButtonsType.YES_NO, "All actions with your phone are performed at your own risk. The Creator of this SOFTWARE is not responsible for your further actions. Want to continue?");

            /// Warning user
            if(are_you_sure.run() != ResponseType.YES) {
                are_you_sure.destroy(); return;
            } are_you_sure.destroy();

            /// Disable buttons
            setUISentensive(false);

            /// Spawn flashing process
            child_tid = spawn(&flasher.startSVBFlashing, thisTid, reboot_btn.getActive(), slot_btn.getActive());

            /// Ui updater connect
            ui_updater = new Timeout(500, &updateUI);
        }
    }

    /// @brief Slot for ui updating while flashing is being
    protected bool updateUI() @trusted {
        receiveTimeout(dur!("msecs")(50),
            (int code) {
                setUISentensive(true);

                ui_updater.stop();
            },
            (double fr) { flash_pb.setFraction(fr); },
            (string rec) {
                log_v.makeRecord(rec);
                while(Main.eventsPending()) Main.iteration();
            });

        return true;
    }

    private void setUISentensive(bool value) {
        svb_flash_btn.setSensitive(value);
        
        set_adb_btn.setSensitive(value);
        set_rom_btn.setSensitive(value);

        vbmeta_btn.setSensitive(value);
        reboot_btn.setSensitive(value);

        vbmeta_btn.setSensitive(value);
        reboot_btn.setSensitive(value);

        flash_btn.setSensitive(value);

        slot_btn.setSensitive(value);

        adb_en.setSensitive(value);
        rom_en.setSensitive(value);
    }

    /// @brief flash_pb Flashing process %
    private ProgressBar flash_pb;

    /// @brief set_adb_btn Button for ADB PATH setting
    private Button set_adb_btn;
    /// @brief set_rom_btn Button for ROM PATH setting
    private Button set_rom_btn;
    /// @brief flash_btn Button for flashing starting
    private Button flash_btn;

    private Button svb_flash_btn;

    private CheckButton vbmeta_btn;

    private CheckButton reboot_btn;

    /// @brief adb_en Entry for ADB PATH setting
    private Entry adb_en;
    /// @brief rom_en Entry for ROM PATH setting
    private Entry rom_en;

    private ToggleButton slot_btn;

    /// @brief ui_builder UI builder object
    private Builder ui_builder;

    /// @brief log_v Widget for Log viewing
    private LogViewer log_v;

    /// @brief flasher Flasher object (Class for flashing)
    private shared PhoneFlasher flasher;

    /// @brief ui_updater UI updating timeout
    private Timeout ui_updater;

    /// @brief child_tid Child tid for getting data
    private Tid child_tid;
}