/// @file PhoneFlasher.d
/// 
/// @brief Main program file
///
/// @license LGPLv3 (see LICENSE file)
/// @author KonstantIMP
/// @date 2020
module PhoneFlasher;
import LogViewer;

import std.concurrency;
import std.process;
import std.system;
import std.file;

import core.thread;

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
        send(parent, cast(double)(0.0));

        if(adb == "" || rom == "") {
            send(parent, "You need specify ROM and ADB path first");
            send(parent, cast(int)(-1)); return;
        }

        string full_adb = adb ~ (os == OS.linux ? "adb" : "\\adb.exe");
        string full_fastboot = (os == OS.linux ? "sudo " : "") ~ adb ~ (os == OS.linux ? "fastboot" : "fastboot.exe");

        send(parent, "Flashing started. Dont\'t touch your device!!!");
        send(parent, "Full ADB path is : " ~ full_adb);
        send(parent, "Full fastboot path is : " ~ full_fastboot);

        runCommand(full_adb ~ " reboot bootloader");
        send(parent, "Reboot to bootloader. Waiting 10 seconds...");

        Thread.sleep(dur!("seconds")(10));

        send(parent, "Formatting system partition");
        runCommand(full_fastboot ~ " erase system");

        send(parent, "Formatting vendor partition");
        runCommand(full_fastboot ~ " erase vendor");

        send(parent, "Flashing abl_a partition...");
        runCommand(full_fastboot ~ " flash abl_a " ~ rom ~ "abl.img");
        send(parent, "abl_a partition were flashed!"); 

        send(parent, "Flashing abl_b partition...");
        runCommand(full_fastboot ~ " flash abl_b " ~ rom ~ "abl.img");
        send(parent, "abl_b partition were flashed!"); send(parent, cast(double)(0.0003));

        send(parent, "Flashing xbl_a partition...");
        runCommand(full_fastboot ~ " flash xbl_a " ~ rom ~ "xbl.img");
        send(parent, "xbl_a partition were flashed!");

        send(parent, "Flashing xbl_b partition...");
        runCommand(full_fastboot ~ " flash xbl_b " ~ rom ~ "xbl.img");
        send(parent, "xbl_b partition were flashed!"); send(parent, cast(double)(0.0013));

        send(parent, "Flashing bluetooth_a partition...");
        runCommand(full_fastboot ~ " flash bluetooth_a " ~ rom ~ "bluetooth.img");
        send(parent, "bluetooth_a partition were flashed!"); send(parent, cast(double)(0.0016));

        send(parent, "Flashing boot_a partition...");
        runCommand(full_fastboot ~ " flash boot_a " ~ rom ~ "boot.img");
        send(parent, "boot_a partition were flashed!"); send(parent, cast(double)(0.019));

        send(parent, "Flashing cda_a partition...");
        runCommand(full_fastboot ~ " flash cda_a " ~ rom ~ "cda.img");
        send(parent, "cda_a partition were flashed!"); send(parent, cast(double)(0.021));

        send(parent, "Flashing cmnlib_a partition...");
        runCommand(full_fastboot ~ " flash cmnlib_a " ~ rom ~ "cmnlib.img");
        send(parent, "cmnlib_a partition were flashed!"); send(parent, cast(double)(0.0213));

        send(parent, "Flashing cmnlib64_a partition...");
        runCommand(full_fastboot ~ " flash cmnlib64_a " ~ rom ~ "cmnlib64.img");
        send(parent, "cmnlib64_a partition were flashed!"); send(parent, cast(double)(0.0216));

        send(parent, "Flashing devcfg_a partition...");
        runCommand(full_fastboot ~ " flash devcfg_a " ~ rom ~ "devcfg.img");
        send(parent, "devcfg_a partition were flashed!"); send(parent, cast(double)(0.022));

        send(parent, "Flashing dsp_a partition...");
        runCommand(full_fastboot ~ " flash dsp_a " ~ rom ~ "dsp.img");
        send(parent, "dsp_a partition were flashed!"); send(parent, cast(double)(0.024));

        send(parent, "Flashing hidden_a partition...");
        runCommand(full_fastboot ~ " flash hidden_a " ~ rom ~ "hidden.img");
        send(parent, "hidden_a partition were flashed!"); send(parent, cast(double)(0.034));

        send(parent, "Flashing hyp_a partition...");
        runCommand(full_fastboot ~ " flash hyp_a " ~ rom ~ "hyp.img");
        send(parent, "hyp_a partition were flashed!"); send(parent, cast(double)(0.03415));

        send(parent, "Flashing keymaster_a partition...");
        runCommand(full_fastboot ~ " flash keymaster_a " ~ rom ~ "keymaster.img");
        send(parent, "keymaster_a partition were flashed!"); send(parent, cast(double)(0.03445));

        send(parent, "Flashing mdtp_a partition...");
        runCommand(full_fastboot ~ " flash mdtp_a " ~ rom ~ "mdtp.img");
        send(parent, "mdtp_a partition were flashed!"); send(parent, cast(double)(0.043));

        send(parent, "Flashing mdtpsecapp_a partition...");
        runCommand(full_fastboot ~ " flash mdtpsecapp_a " ~ rom ~ "mdtpsecapp.img");
        send(parent, "mdtpsecapp_a partition were flashed!"); send(parent, cast(double)(0.044));

        send(parent, "Flashing modem_a partition...");
        runCommand(full_fastboot ~ " flash modem_a " ~ rom ~ "modem.img");
        send(parent, "modem_a partition were flashed!"); send(parent, cast(double)(0.074));

        send(parent, "Flashing nvdef_a partition...");
        runCommand(full_fastboot ~ " flash nvdef_a " ~ rom ~ "nvdef.img");
        send(parent, "nvdef_a partition were flashed!"); send(parent, cast(double)(0.0755));

        send(parent, "Flashing pmic_a partition...");
        runCommand(full_fastboot ~ " flash pmic_a " ~ rom ~ "pmic.img");
        send(parent, "pmic_a partition were flashed!"); send(parent, cast(double)(0.077));

        send(parent, "Flashing rpm_a partition...");
        runCommand(full_fastboot ~ " flash rpm_a " ~ rom ~ "rpm.img");
        send(parent, "rpm_a partition were flashed!"); send(parent, cast(double)(0.078));

        send(parent, "Flashing splash_a partition...");
        runCommand(full_fastboot ~ " flash splash_a " ~ rom ~ "splash.img");
        send(parent, "splash_a partition were flashed!"); send(parent, cast(double)(0.088));

        send(parent, "Flashing system_a partition...");
        runCommand(full_fastboot ~ " flash system_a " ~ rom ~ "system.img");
        send(parent, "system_a partition were flashed!"); send(parent, cast(double)(0.7825));

        send(parent, "Flashing systeminfo_a partition...");
        runCommand(full_fastboot ~ " flash systeminfo_a " ~ rom ~ "systeminfo.img");
        send(parent, "systeminfo_a partition were flashed!");

        send(parent, "Flashing tz_a partition...");
        runCommand(full_fastboot ~ " flash tz_a " ~ rom ~ "tz.img");
        send(parent, "tz_a partition were flashed!"); send(parent, cast(double)(0.79));

        send(parent, "Flashing vendor_a partition...");
        runCommand(full_fastboot ~ " flash vendor_a " ~ rom ~ "vendor.img");
        send(parent, "vendor_a partition were flashed!"); send(parent, cast(double)(0.92));

        send(parent, "Erasing tmp files from phone");

        send(parent, "Formatting ssd partition");
        runCommand(full_fastboot ~ " erase ssd"); send(parent, cast(double)(0.93));

        send(parent, "Formatting misc partition");
        runCommand(full_fastboot ~ " erase misc"); send(parent, cast(double)(0.94));

        send(parent, "Formatting sti partition");
        runCommand(full_fastboot ~ " erase sti"); send(parent, cast(double)(0.95));

        send(parent, "Formatting ddr partition");
        runCommand(full_fastboot ~ " erase ddr"); send(parent, cast(double)(0.96));

        send(parent, "Formatting securefs partition");
        runCommand(full_fastboot ~ " erase securefs"); send(parent, cast(double)(0.97));

        send(parent, "Formatting box partition");
        runCommand(full_fastboot ~ " erase box"); send(parent, cast(double)(0.98));

        send(parent, "Formatting boot_b partition");
        runCommand(full_fastboot ~ " erase boot_b"); send(parent, cast(double)(0.99));

        send(parent, "Setting \'A\' as active slot...");
        runCommand(full_fastboot ~ " --set-active=a");

        send(parent, "Factory reset");
        runCommand(full_fastboot ~ " -w");

        send(parent, "Flashing done! Reboot phone...");
        runCommand(full_fastboot ~ " reboot"); send(parent, cast(double)(1.0));

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