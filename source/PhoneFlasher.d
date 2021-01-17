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

/// @brief Class for Nokia 7.1 flashing
synchronized class PhoneFlasher {
    /// @brief  Basic constructor for widget
    public this() @safe {
        adb = rom = "";
    }

    bool checkSVBValue(ref LogViewer _log, string _adb_path, string _rom_path) @safe {
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

        if(exists(_rom_path ~ "boot.img")) _log.makeRecord("boot.img" ~ " found : OK");
        else {
            _log.makeRecord(_rom_path ~ "boot.img" ~ " didn\'t found : ERROR");
            return false;
        }
        if(exists(_rom_path ~ "system.img")) _log.makeRecord("system.img" ~ " found : OK");
        else {
            _log.makeRecord(_rom_path ~ "system.img" ~ " didn\'t found : ERROR");
            return false;
        }
        if(exists(_rom_path ~ "vendor.img")) _log.makeRecord("vendor.img" ~ " found : OK");
        else {
            _log.makeRecord(_rom_path ~ "vendor.img" ~ " didn\'t found : ERROR");
            return false;
        }

        adb = _adb_path;
        rom = _rom_path;

        return true;
    }

    /// @brief Check that ROM folder contains all file for flashing
    bool checkValue(ref LogViewer _log, string _adb_path, string _rom_path, bool vbmeta) @safe {
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

        for(size_t i = 0; i < rom_files.length - 1; i++) {
            if(exists(_rom_path  ~ rom_files[i])) _log.makeRecord(rom_files[i] ~ " found : OK");
            else {
                _log.makeRecord(_rom_path ~ rom_files[i] ~ " didn\'t found : ERROR");
                return false;
            }
        }

        if(vbmeta == true) {
            if(exists(_rom_path ~ rom_files[rom_files.length - 1])) _log.makeRecord(rom_files[rom_files.length - 1] ~ " found : OK");
            else {
                _log.makeRecord(_rom_path ~ rom_files[rom_files.length - 1] ~ " didn\'t found : ERROR");
                return false;
            }
        }

        adb = _adb_path;
        rom = _rom_path;

        return true;
    }

    /// @brief Flash process
    /// @param[in] parent Parent Tid for data sending
    public void startFlashing(Tid parent, bool vbmeta, bool reboot, bool is_b) @trusted {
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

        // ~ (is_b == true ? "b " : "a ")

        send(parent, "Formatting system partition");
        runCommand(full_fastboot ~ " erase system_" ~ (is_b == true ? "b" : "a"));

        send(parent, "Formatting vendor partition");
        runCommand(full_fastboot ~ " erase vendor_" ~ (is_b == true ? "b" : "a"));

        send(parent, "Flashing abl_a partition...");
        runCommand(full_fastboot ~ " flash abl_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "abl.img");
        send(parent, "abl_a partition were flashed!"); 

        send(parent, "Flashing abl_b partition...");
        runCommand(full_fastboot ~ " flash abl_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "abl.img");
        send(parent, "abl_b partition were flashed!"); send(parent, cast(double)(0.0003));

        send(parent, "Flashing xbl_a partition...");
        runCommand(full_fastboot ~ " flash xbl_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "xbl.img");
        send(parent, "xbl_a partition were flashed!");

        send(parent, "Flashing xbl_b partition...");
        runCommand(full_fastboot ~ " flash xbl_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "xbl.img");
        send(parent, "xbl_b partition were flashed!"); send(parent, cast(double)(0.0013));

        send(parent, "Flashing bluetooth_a partition...");
        runCommand(full_fastboot ~ " flash bluetooth_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "bluetooth.img");
        send(parent, "bluetooth_a partition were flashed!"); send(parent, cast(double)(0.0016));

        send(parent, "Flashing boot_a partition...");
        runCommand(full_fastboot ~ " flash boot_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "boot.img");
        send(parent, "boot_a partition were flashed!"); send(parent, cast(double)(0.019));

        send(parent, "Flashing cda_a partition...");
        runCommand(full_fastboot ~ " flash cda_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "cda.img");
        send(parent, "cda_a partition were flashed!"); send(parent, cast(double)(0.021));

        send(parent, "Flashing cmnlib_a partition...");
        runCommand(full_fastboot ~ " flash cmnlib_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "cmnlib.img");
        send(parent, "cmnlib_a partition were flashed!"); send(parent, cast(double)(0.0213));

        send(parent, "Flashing cmnlib64_a partition...");
        runCommand(full_fastboot ~ " flash cmnlib64_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "cmnlib64.img");
        send(parent, "cmnlib64_a partition were flashed!"); send(parent, cast(double)(0.0216));

        send(parent, "Flashing devcfg_a partition...");
        runCommand(full_fastboot ~ " flash devcfg_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "devcfg.img");
        send(parent, "devcfg_a partition were flashed!"); send(parent, cast(double)(0.022));

        send(parent, "Flashing dsp_a partition...");
        runCommand(full_fastboot ~ " flash dsp_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "dsp.img");
        send(parent, "dsp_a partition were flashed!"); send(parent, cast(double)(0.024));

        send(parent, "Flashing hidden_a partition...");
        runCommand(full_fastboot ~ " flash hidden_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "hidden.img");
        send(parent, "hidden_a partition were flashed!"); send(parent, cast(double)(0.034));

        send(parent, "Flashing hyp_a partition...");
        runCommand(full_fastboot ~ " flash hyp_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "hyp.img");
        send(parent, "hyp_a partition were flashed!"); send(parent, cast(double)(0.03415));

        send(parent, "Flashing keymaster_a partition...");
        runCommand(full_fastboot ~ " flash keymaster_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "keymaster.img");
        send(parent, "keymaster_a partition were flashed!"); send(parent, cast(double)(0.03445));

        send(parent, "Flashing mdtp_a partition...");
        runCommand(full_fastboot ~ " flash mdtp_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "mdtp.img");
        send(parent, "mdtp_a partition were flashed!"); send(parent, cast(double)(0.043));

        send(parent, "Flashing mdtpsecapp_a partition...");
        runCommand(full_fastboot ~ " flash mdtpsecapp_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "mdtpsecapp.img");
        send(parent, "mdtpsecapp_a partition were flashed!"); send(parent, cast(double)(0.044));

        send(parent, "Flashing modem_a partition...");
        runCommand(full_fastboot ~ " flash modem_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "modem.img");
        send(parent, "modem_a partition were flashed!"); send(parent, cast(double)(0.074));

        send(parent, "Flashing nvdef_a partition...");
        runCommand(full_fastboot ~ " flash nvdef_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "nvdef.img");
        send(parent, "nvdef_a partition were flashed!"); send(parent, cast(double)(0.0755));

        send(parent, "Flashing pmic_a partition...");
        runCommand(full_fastboot ~ " flash pmic_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "pmic.img");
        send(parent, "pmic_a partition were flashed!"); send(parent, cast(double)(0.077));

        send(parent, "Flashing rpm_a partition...");
        runCommand(full_fastboot ~ " flash rpm_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "rpm.img");
        send(parent, "rpm_a partition were flashed!"); send(parent, cast(double)(0.078));

        send(parent, "Flashing splash_a partition...");
        runCommand(full_fastboot ~ " flash splash_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "splash.img");
        send(parent, "splash_a partition were flashed!"); send(parent, cast(double)(0.088));

        send(parent, "Flashing system_a partition...");
        runCommand(full_fastboot ~ " flash system_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "system.img");
        send(parent, "system_a partition were flashed!"); send(parent, cast(double)(0.7825));

        send(parent, "Flashing systeminfo_a partition...");
        runCommand(full_fastboot ~ " flash systeminfo_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "systeminfo.img");
        send(parent, "systeminfo_a partition were flashed!");

        send(parent, "Flashing tz_a partition...");
        runCommand(full_fastboot ~ " flash tz_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "tz.img");
        send(parent, "tz_a partition were flashed!"); send(parent, cast(double)(0.79));

        send(parent, "Flashing vendor_a partition...");
        runCommand(full_fastboot ~ " flash vendor_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "vendor.img");
        send(parent, "vendor_a partition were flashed!"); send(parent, cast(double)(0.92));

        if(vbmeta == true) {
            send(parent, "Flashing vbmeta_a partition...");
            runCommand(full_fastboot ~ " flash vbmeta_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "vbmeta.img");
            send(parent, "vbmeta_a partition were flashed!");
        } 

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
        
        send(parent, "Setting \'A\' as active slot...");
        runCommand(full_fastboot ~ " --set-active=" ~ (is_b == true ? "b" : "a"));

        send(parent, "Factory reset");
        runCommand(full_fastboot ~ " -w");

        if(reboot) {
            send(parent, "Flashing done! Reboot phone...");
            runCommand(full_fastboot ~ " reboot");
        }
        else send(parent, "Flashing done!");

        send(parent, cast(double)(1.0));

        send(parent, cast(int)(-1));
    }

    public void startSVBFlashing(Tid parent, bool reboot, bool is_b) @trusted {
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

        // ~ (is_b == true ? "b " : "a ")

        send(parent, "Formatting system partition");
        runCommand(full_fastboot ~ " erase system_" ~ (is_b == true ? "b" : "a"));

        send(parent, "Formatting vendor partition");
        runCommand(full_fastboot ~ " erase vendor_" ~ (is_b == true ? "b" : "a"));

        send(parent, "Flashing boot_a partition...");
        runCommand(full_fastboot ~ " flash boot_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "boot.img");
        send(parent, "boot_a partition were flashed!"); send(parent, cast(double)(0.019));

        send(parent, "Flashing system_a partition...");
        runCommand(full_fastboot ~ " flash system_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "system.img");
        send(parent, "system_a partition were flashed!"); send(parent, cast(double)(0.7825));

        send(parent, "Flashing vendor_a partition...");
        runCommand(full_fastboot ~ " flash vendor_" ~ (is_b == true ? "b " : "a ") ~ rom ~ "vendor.img");
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

        send(parent, "Setting \'A\' as active slot...");
        runCommand(full_fastboot ~ " --set-active=" ~ (is_b == true ? "b" : "a"));

        send(parent, "Factory reset");
        runCommand(full_fastboot ~ " -w");

        if(reboot) {
            send(parent, "Flashing done! Reboot phone...");
            runCommand(full_fastboot ~ " reboot");
        }
        else send(parent, "Flashing done!");

        send(parent, cast(double)(1.0));

        send(parent, cast(int)(-1));
    }

    /// @brief Spawn shell command and wait when it close
    /// @param[in] cmd Command for spawn
    private void runCommand(string cmd) @trusted {
        Pid runned_p = spawnShell(cmd, std.stdio.stdin, File("adb_out.log", "a+"));
        wait(runned_p);
    }

    /// @brief adb ADB PATH
    private string adb;
    /// @brief rom ROM PATH
    private string rom;

    /// @brief rom_files Array of rom files names
    private string [] rom_files = [
        "abl.img", "bluetooth.img", "boot.img",
        "cda.img", "cmnlib64.img", "cmnlib.img",
        "devcfg.img", "dsp.img", "hidden.img",
        "hyp.img", "keymaster.img", "mdtp.img",
        "mdtpsecapp.img", "modem.img", "nvdef.img",
        "pmic.img", "rpm.img", "splash.img",
        "system.img", "systeminfo.img", "tz.img",
        "vendor.img", "xbl.img", "vbmeta.img"
    ];
}