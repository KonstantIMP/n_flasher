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

extern (C) GObject * gtk_builder_get_object (GtkBuilder * builder, const char * name);

class LogViewer : ScrolledWindow {
    public this(ref Builder _builder, string _wname) @trusted {
        super(cast(GtkScrolledWindow *)gtk_builder_get_object(_builder.getBuilderStruct(), _wname.ptr));
        log_viewer = new TextView();
        log_viewer.setEditable(false);

        TextIter end_iter = new TextIter();
        log_viewer.getBuffer().getEndIter(end_iter);
        log_viewer.getBuffer().createMark("last_line", end_iter, false);

        add(log_viewer);
    }

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

    @property string logFilePath() { return log_file_path; }
    @property string logFilePath(string path_value) { return log_file_path = path_value; }

    private string log_file_path;

    private TextView log_viewer;
}