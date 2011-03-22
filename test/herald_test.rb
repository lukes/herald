require File.dirname(__FILE__) + '/helper'

class HeraldTest < TestCase
  
  test 'Passing a block' do
    assert Herald.watch {}
  end
  
  test 'lazy loading module' do
    
  end
  
end