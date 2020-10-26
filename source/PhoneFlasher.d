module PhoneFlasher;
import LogViewer;

import std.concurrency;
import std.process;
import std.system;
import std.file;

import std.stdio;

synchronized class PhoneFlasher {
    public this() @safe {
        adb = rom = "";
    }

    bool checkValue(ref LogViewer _log, string _adb_path, string _rom_path) @safe {
        _log.makeRecord("Checking ADB tools path");

        if(!exists(_adb_path ~ "adb" ~ (os == OS.linux ? "" : ".exe"))) {
            _log.makeRecord("ADB doesn\'t exist at \'" ~ _adb_path ~ "\'");
            return false;
        }
        if(!exists(_adb_path ~ "fastboot" ~ (os == OS.linux ? "" : ".exe"))) {
            _log.makeRecord("Fastboot doesn\'t exist at \'" ~ _adb_path ~ "\'");
            return false;
        }

        _log.makeRecord("ADB found : OK");
        _log.makeRecord("Fastboot found : OK");

        _log.makeRecord("Checking stock ROM path");

        for(size_t i = 0; i < rom_files.length; i++) {
            if(exists(_rom_path  ~ rom_files[i])) _log.makeRecord(rom_files[i] ~ " found : OK");
            else {
                _log.makeRecord(_rom_path ~ rom_files[i] ~ " didn\'t found : ERROR");
                return false;
            }
        }

        adb = _adb_path;
        rom = _rom_path;

        return true;
    }

    public void startFlashing(Tid parent) @trusted {
        

        send(parent, cast(int)(-1));
    }

    private void runCommand(string cmd) @trusted {
        Pid runned_p = spawnShell(cmd, std.stdio.stdin, File("adb_out.log", "a+"));
        wait(runned_p);
    }

    private string adb;
    private string rom;

    private string [] log_r;

    private string [] rom_files = [
        "abl.img", "bluetooth.img", "boot.img",
        "cda.img", "cmnlib64.img", "cmnlib.img",
        "devcfg.img", "dsp.img", "hidden.img",
        "hyp.img", "keymaster.img", "mdtp.img",
        "mdtpsecapp.img", "modem.img", "nvdef.img",
        "pmic.img", "rpm.img", "splash.img",
        "system.img", "systeminfo.img", "tz.img",
        "vendor.img", "xbl.img"
    ];
}