#!/usr/bin/env python3
"""Parse generated CSS in a separate process per GTK major version.

Usage: python3 check_gtk_css.py 3|4 OUTPUT_DIRECTORY
No display, profile changes or third-party Python packages required.
"""
import argparse
import ctypes as c
import ctypes.util
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('version', choices=('3', '4'))
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    libraries = [ctypes.util.find_library(name)
                 for name in ('gtk-' + args.version, 'gobject-2.0')]
    if not all(libraries):
        parser.exit(2, f'GTK {args.version} and GObject libraries are required\n')
    gtk, gobject = [c.CDLL(name) for name in libraries]

    class GError(c.Structure):
        _fields_ = [('domain', c.c_uint), ('code', c.c_int), ('message', c.c_char_p)]

    errors = []
    callback_type = c.CFUNCTYPE(None, c.c_void_p, c.c_void_p,
                                c.POINTER(GError), c.c_void_p)

    @callback_type
    def on_error(provider, section, error, data):
        errors.append(error.contents.message.decode())

    gtk.gtk_css_provider_new.restype = c.c_void_p
    gobject.g_signal_connect_data.argtypes = [c.c_void_p, c.c_char_p, callback_type,
                                             c.c_void_p, c.c_void_p, c.c_int]
    gobject.g_object_unref.argtypes = [c.c_void_p]
    load = gtk.gtk_css_provider_load_from_data
    load.argtypes = [c.c_void_p, c.c_char_p, c.c_ssize_t]
    if args.version == '3':
        load.argtypes.append(c.c_void_p)
        load.restype = c.c_int
    else:
        load.restype = None
    for mode in ('light', 'dark'):
        css = (args.output / f'gtk/{mode}/gtk-{args.version}.0.css').read_bytes()
        provider = gtk.gtk_css_provider_new()
        try:
            gobject.g_signal_connect_data(provider, b'parsing-error', on_error,
                                           None, None, 0)
            if args.version == '3':
                load(provider, css, len(css), None)
            else:
                load(provider, css, len(css))
        finally:
            gobject.g_object_unref(provider)
    print(f'GTK {args.version}:', errors or 'light/dark CSS parsed without errors or warnings')
    return int(bool(errors))


if __name__ == '__main__':
    raise SystemExit(main())
