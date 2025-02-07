#!/usr/bin/env python3

import argparse
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import GLib, Gtk
from GShaderPaper import GShaderPaper
import os

def load_shader(filename: str):
    print(f"Loading shader from file {filename}...")
    with open(filename) as f:
        shader_src = f.read()
    print(f"Loaded shader from file {filename}.")
    return shader_src


def check_shader_file():
    mtime = os.stat(filename).st_mtime
    if mtime != check_shader_file.file_mtime:
        print(f"Shader file {filename} changed")
        check_shader_file.file_mtime = mtime
        shader_src = load_shader(filename)
        win.update_fragment_shader(shader_src)
    return True


parser = argparse.ArgumentParser(
    # prog="ProgramName",
    # description="What the program does",
    # epilog="Text at the bottom of help",
)
parser.add_argument('filename', help='fragment shader file path')
args = parser.parse_args()

filename = args.filename

shader_src = load_shader(filename)

check_shader_file.file_mtime = os.stat(filename).st_mtime
GLib.timeout_add(1000.0, check_shader_file)

win = GShaderPaper(shader_src, 30)
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
