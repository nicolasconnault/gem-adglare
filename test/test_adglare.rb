require 'minitest/autorun'
require 'adglare'

class AdglareTest < Minitest::Test

  def test_zonegroups_list
    adglare = Adglare.new public_key: 'bdWEM63WcF3c74PzCZVG9gcsv5nPtUFJa5FCvvEY', private_key: 'dWZnZ2dNvgV8eRRZc4P69bvF4cBvz4NfKhuUpNw8'
    results = adglare.zonegroups_list
    assert_equal "102242510", results.first["zgID"]
    assert_equal "Healthpoint AU Pharmacies", results.first["name"]
  end
end
