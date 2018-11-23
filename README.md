# thanksgiving

This is a [festival](http://www.cstr.ed.ac.uk/projects/festival/) based speech server
for [Emacspeak](http://emacspeak.sourceforge.net). Currently very alpha.

## How to use?

```
# First start festival in server mode.
festival --server
# start tksgiv will auto connect to port 1314
# currently port number is hard coded
./tksgiv
```

Currently only implemented a few of commands from http://tvraman.github.io/emacspeak/manual/TTS-Servers.html#TTS-Servers
such as `tts_say`, `q`, `d`, `l`.
