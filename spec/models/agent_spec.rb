require 'rails_helper'

RSpec.describe Agent do
  it { is_expected.to respond_to(:first_name) }
  it { is_expected.to respond_to(:last_name) }
  #it { is_expected.to respond_to(:identified_by_authority) }
end
