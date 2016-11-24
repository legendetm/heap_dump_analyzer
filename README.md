# README

Setup database
```
createuser --createdb --login heap_dump_analyzer
rake db:setup
```
All heap dump files must contain unix timestamp e.g `heap-1479820044.dump`.

Move all ruby heap dump files into one folder (e.g. data) and run:
```
time rake import:dir DIR=data
rails s
```

# Resources
* https://gist.github.com/wvengen/f1097651c238b2f7f11d
* https://github.com/schneems/heapy/
