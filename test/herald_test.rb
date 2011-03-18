class HeraldTest < TestCase
  
  test 'Passing a block' do
    assert Herald.watch {}
  end
  
end