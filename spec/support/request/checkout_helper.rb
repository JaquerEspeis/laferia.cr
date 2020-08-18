module CheckoutHelper
  def have_checkout_details
    have_content "Your details"
  end

  def checkout_as_guest
    click_button "Checkout as guest"
  end

  def place_order
    find("button", text: "Place order now").click
  end

  def toggle_accordion(id)
    find("##{id} dd a").click
  end

  def toggle_details
    toggle_accordion :details
  end

  def fill_out_details
    within "#details" do
      fill_in "First Name", with: "Will"
      fill_in "Last Name", with: "Marshall"
      fill_in "Email", with: "test@test.com"
      fill_in "Phone", with: "0468363090"
    end
  end

  def fill_out_billing_address
    within "#billing" do
      fill_in "City", with: "Melbourne"
      fill_in "Postcode", with: "3066"
      fill_in "Address", with: "123 Your Head"
      select "Australia", from: "Country"
      select "Victoria", from: "State"
    end
  end

  def fill_out_form
    choose free_shipping.name
    choose check_without_fee.name

    fill_out_details
    check "Save as default billing address"

    fill_out_billing_address

    check "Shipping address same as billing address?"
    check "Save as default shipping address"
  end
end
