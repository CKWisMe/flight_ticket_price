require "application_system_test_case"

class SearchRequestSubmissionTest < ApplicationSystemTestCase
  test "user submits a search request and sees status page" do
    visit root_path

    select "來回", from: "航程型態"
    fill_in "起飛機場", with: "TPE"
    fill_in "目的地機場", with: "NRT"
    fill_in "旅遊天數", with: 4
    select "TWD", from: "顯示幣別"
    click_button "開始搜尋"

    assert_text "搜尋已建立"
    assert_text "搜尋狀態"
    assert_text "來源狀態"
  end
end
