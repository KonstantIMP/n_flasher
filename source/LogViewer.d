/// @file LogViewer.d
/// 
/// @brief Main program file
///
/// @license LGPLv3 (see LICENSE file)
/// @author KonstantIMP
/// @date 2021
module LogViewer;

import gtk.ScrolledWindow;
import gtk.TextBuffer;
import gtk.TextIter;
import gtk.TextMark;
import gtk.TextView;

import std.datetime;
import std.string;

import std.stdio;
import std.file;

import gtk.Builder;

import glib.c.types;
import gtk.c.types;

/// @brief Widget for log Viewing and writing
/// It is a composite widget
/// GtkScrolledWindow
/// |__ GtkTextView
class LogViewer : ScrolledWindow {
     /// @brief  Basic constructor for widget
    /// Init child widgets, build ui and connect signals
    public this(ref Builder _builder, string _wname) @trusted {
        super((cast(ScrolledWindow)(_builder.getObject(_wname))).getScrolledWindowStruct());
        log_viewer = new TextView();
        log_viewer.setEditable(false);

        TextIter end_iter = new TextIter();
        log_viewer.getBuffer().getEndIter(end_iter);
        log_viewer.getBuffer().createMark("last_line", end_iter, false);

        add(log_viewer);
    }

    /// @brief Make record. Write it to file and to TextView
    /// @param[in] record Message for writing
    public void makeRecord(string record) @trusted {
        string dt_str = Clock.currTime().toString();

        string rec_wt = "[ " ~ dt_str[0..dt_str.lastIndexOf('.')] ~ " ] " ~ record ~ "\n";

        if(log_file_path != "") {
            File * tmp = new File(log_file_path, "a+");
            tmp.write(rec_wt); tmp.close();
            tmp.destroy();
        }       

        log_viewer.getBuffer().setText(log_viewer.getBuffer().getText() ~ rec_wt);

        TextIter end_iter = new TextIter();
        log_viewer.getBuffer().getEndIter(end_iter);

        TextMark end_mark = log_viewer.getBuffer().getMark("last_line");

        log_viewer.getBuffer().moveMark(end_mark, end_iter);
        log_viewer.scrollToMark(end_mark, 0.0, false, 0.0, 0.0); 
    }

    /// @brief Getter for logFilePath
    @property string logFilePath() { return log_file_path; }
    /// @brief Setter for logFilePath
    @property string logFilePath(string path_value) { return log_file_path = path_value; }

    /// @brief Path to log file
    private string log_file_path;

    /// @brief Text view for record showing
    private TextView log_viewer;
}