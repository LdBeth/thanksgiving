# thanksgiving

This is a [festival](http://www.cstr.ed.ac.uk/projects/festival/) based speech server
for [Emacspeak](http://emacspeak.sourceforge.net). Currently very alpha.

## How to use?

```
# First start festival in server mode.
festival --server
# start tksgiv will auto connect to port 1314
./tksgiv
# or
./tksgiv 127.0.0.1 1314
# type some commands, such as `tts_say Yes my lord'
# To quit, just Ctrl-D
```

If you'd like to use `tksgiv` with emacspeak, put following into somewhere in
your config:
```lisp
(setenv "DTK_PROGRAM" "path/to/tksgiv")
(load-file "<emacspeak-dir>/lisp/emacspeak-setup.el")
```

If it gets crazy use <kbd>C-e s</kbd> to shut it up.

Currently only implemented a few of commands from http://tvraman.github.io/emacspeak/manual/TTS-Servers.html#TTS-Servers
such as `tts_say`, `q`, `d`, `l`.
