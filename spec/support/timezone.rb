# frozen_string_literal: true

# In order to make this work, you must use Time.zone.now in your specs
RSpec.configure do |config|
  config.around :example, :tz do |example|
    Time.use_zone(example.metadata[:tz]) { example.run }
  end
end
