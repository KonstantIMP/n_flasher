module gtk.LogMaker;

import gtk.ScrolledWindow;
import gtk.TextBuffer;
import gtk.TextIter;
import gtk.TextMark;
import gtk.TextView;

import std.datetime;
import std.string;

import std.stdio;
import std.file;

class LogMaker : ScrolledWindow {
    public this(string log_path = "") @trusted {
        super(); log_file_path = log_path;

        log_viewer = new TextView();
        log_viewer.setEditable(false);

        TextIter end_iter = new TextIter();
        log_viewer.getBuffer().getEndIter(end_iter);
        log_viewer.getBuffer().createMark("last_line", end_iter, false);

        add(log_viewer);
    }

    public void make_record(string record) @trusted {
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

    public string getLogFilePath() @safe {
        return log_file_path;
    }

    public void setLogFilePath(string log_path) @safe {
        log_file_path = log_path;
    }

    private string log_file_path;

    private TextView log_viewer;
}