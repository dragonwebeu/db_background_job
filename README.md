# DbBackgroundJob

Provides methods to spawn a background process for ActiveRecord. It is recommended to use it with Threads if you have long-taking functions on the database side.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add db_background_job

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install db_background_job

## Usage

For example, we have a 500k list of items, lets create 50 extra database connections with Threads and Process to finish job faster on the database side.

```ruby
threads = []
# lets create 50 extra database connections
max_workers = 50
    
items&.each do |item|  
  if(Thread.list.count % max_workers != 0)
    thread = Thread.new do
      begin
        DbBackgroundJob.spawn_and_wait do
          # To something here
        end
      rescue => error
        Rails.logger.error error
      end
    end
    threads << thread
  else
    threads.each(&:join)
    thread = Thread.new do
      begin
        DbBackgroundJob.spawn_and_wait do
          # To Something here
        end
      rescue => error
        Rails.logger.error error
      end
    end
    threads << thread
  end
end
threads.each(&:join)
```

In another example, we have a list of items and a Postgres database function that contains heavy calculations and updates  ( `SELECT  update_and_calculate_sums(ARRAY[item_id])` ).
To avoid locks in the database we do for example 50(workers/extra sessions) with 250 batches/item_id. 


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dragonwebeu/db_background_job.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
