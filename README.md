# README

## Setup database
```
createuser --createdb --login heap_dump_analyzer
rake db:setup
```

## Importing heap dumps
All heap dump files must contain unix timestamp e.g `heap-1479820044.dump`.

Move all heap dump files into one folder (e.g. data) and run:
```
time rake import:dir DIR=data
rails s
```

## Saving heap dumps

### Sidekiq
Create file `config/initializers/zz_trace_sidekiq.rb`

```ruby
if ENV['HEAP_DUMP']
  Sidekiq.logger.info 'allocations tracing enabled'
  HEAP_DUMP_DIR = Rails.root.join('tmp/sidekiq')
  Dir.mkdir(HEAP_DUMP_DIR) unless Dir.exist?(HEAP_DUMP_DIR)

  require 'objspace'
  ObjectSpace.trace_object_allocations_start

  def save_heap_dump(filename)
    GC.start
    ObjectSpace.dump_all(output: File.open("#{HEAP_DUMP_DIR}/#{filename}", 'w')).close
  end

  class SidekiqProfiler
    mattr_accessor :counter
    self.counter = 0
    JOBS = 1000 # Number of jobs to process before reporting

    class << self
      def synchronize(&block)
        @lock ||= Mutex.new
        @lock.synchronize(&block)
      end
    end

    def call(*_args)
      yield
    ensure
      self.class.synchronize do
        self.counter += 1
        return unless (counter % JOBS).zero?

        Sidekiq.logger.info "Reporting allocations after #{counter} jobs"
        save_heap_dump("heap-#{Process.pid}-#{Time.now.strftime('%s')}-#{counter}.dump")
      end
    end
  end

  Sidekiq.configure_server do |config|
    config.server_middleware do |chain|
      chain.insert_before Sidekiq::Middleware::Server::Logging, SidekiqProfiler
    end
  end
end
```
And run Sidekiq with env variable `HEAP_DUMP=true`
```
HEAP_DUMP=true sidekiq
```
## Hunting leaks

In web server context all objects can be divided into three groups:

1. **Statics.**
All loaded gems, esp. Rails, and application code. All this gets loaded once in production 
environment and doesn’t change.
2. **Slow dynamics.** 
There’s a certain amount of long-lived objects, e.g. cache of prepared SQL statements in 
ActiveRecord. This cache is per DB connection and is a maximum of 1000 statements by default. 
It will grow slowly, and total number of objects will increase until cache reaches full size 
(2000 strings * number of DB connections).
3. **Fast dynamics.** 
Objects created during request processing and response generation. When response is ready, 
all these objects can be freed.

If there are no leaks, heap size will oscillate.
After every major GC the number of objects is always back to the lowest.
Leaks will lead to low boundary increased over time. The `GC.stat[:heap_live_slots]`
figure reflects current heap size.

There may be leaks in C code, which are not included in `ObjectSpace` dumps, and therefore 
not visible when analyzing heap dumps.

## Resources
* https://gist.github.com/wvengen/f1097651c238b2f7f11d
* https://github.com/schneems/heapy/
* http://www.be9.io/2015/09/21/memory-leak/

## License

[MIT License](http://www.opensource.org/licenses/MIT)