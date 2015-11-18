describe Delivery do
  it { is_expected.to have_property :id }
  it { is_expected.to have_property :start_date }

  it { is_expected.to belong_to :course }
end