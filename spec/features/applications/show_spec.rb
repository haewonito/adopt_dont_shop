require "rails_helper"

RSpec.describe "applications show page", type: :feature do
  describe "us1: as a visitor" do
    before(:each) do
      @application1 = Application.create!(name: "Sean Morris",
                                          street_address: "305 E Thunderbird Dr.",
                                          city: "Fort Collins",
                                          state: "CO",
                                          zip_code: "80525",
                                          )
      @shelter = Shelter.create(name: 'Aurora shelter', city: 'Aurora, CO', foster_program: false, rank: 9)
      @pet1 = Pet.create(adoptable: true, age: 1, breed: 'sphynx', name: 'Lucille Bald', shelter_id: @shelter.id)
      @pet2 = Pet.create(adoptable: true, age: 3, breed: 'doberman', name: 'Lobster', shelter_id: @shelter.id)
      @pet3 = Pet.create(adoptable: true, age: 2, breed: 'tuxido', name: 'Smokie', shelter_id: @shelter.id)

      visit "/applications/#{@application1.id}"
    end

    it "displays the name and address of the applicant" do
      expect(page).to have_content("Sean Morris")
      expect(page).to have_content("305 E Thunderbird")
      expect(page).to have_content("80525")
    end

    it "displays description and pets associated if exist" do
      expect(page).to have_content("Pets Under Consideration:")
      expect(page).to have_content("Status: In Progress")
    end

    it "searchs pets for the application" do
      expect(page).to have_content("Add a Pet to this Application")

      fill_in :pet_name, with: "smok"
      click_on "Submit Search"

      expect(current_path).to eq("/applications/#{@application1.id}")
      expect(page).to have_content("Smokie")

      click_on "Smokie"
      expect(current_path).to eq("/pets/#{@pet3.id}")
      expect(current_path).to_not eq("/pets/#{@pet2.id}")
    end

    it "adds a pet to an Application" do

      fill_in :pet_name, with: "smok"
      click_on "Submit Search"
      click_on "Adopt Smokie"

      expect(current_path).to eq("/applications/#{@application1.id}")

      within("#associated-pets-section") do
        expect(page).to have_content("#{@pet3.name}")
      end
    end

    it "Submit an Application" do
      fill_in :pet_name, with: "smok"
      click_on "Submit Search"
      click_on "Adopt Smokie"

      expect(page).to have_content("Describe Why You Would Make a Good Owner:")

      fill_in :application_description, with: "Because we are awesome."
      click_on "Final Submission"

      expect(current_path).to eq("/applications/#{@application1.id}")
      expect(page).to have_content("Status: Pending")
      expect(page).to have_content("Smokie")
      expect(page).to_not have_content("Add a Pet to this Application")
    end

    it "US7: cannot do final submit if there's no pet added to application" do
      expect(page).to_not have_content("Final Submission")
    end
  end
end
