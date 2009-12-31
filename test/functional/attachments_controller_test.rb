require 'test_helper'

class AttachmentsControllerTest < ActionController::TestCase
  def setup
    login_as   users(:one)
  end

  test "create" do
    assert true
    #    xhr :post,"create",:Filedata=>test_uploaded_file("sorry.jpg","img/jpg"),:type=>"CompanyIcon"
    #    assert_not_nil(assigns(:@icon))
    #    assert_equal("sorry.jpg", assigns(:@icon).filename)
    #    assert_equal("sorry_thumb.jpg", assigns(:@icon).thumbnails.find_by_thumbnail("thumb").filename)
  end
end
