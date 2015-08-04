require 'rails_helper'

RSpec.describe GenericFilesController do
  routes { Sufia::Engine.routes }

  before do
    @user = FactoryGirl.create(:depositor)
    sign_in @user
    @file = GenericFile.new(title: ['Blueberries for Sal'])
    @file.apply_depositor_metadata(@user.user_key)
    @file.save!
  end

  describe "edit" do
    it "includes genre" do
      get :edit, id: @file.id
      expect(response).to be_successful
      expect(assigns['form'].genre_string).to eq [""]
    end
  end

  describe "update" do
    it "changes to resource_type are independent from changes to genre" do
      patch :update, id: @file, generic_file: {
        resource_type: ['Image']
      }
      @file.reload
      expect(@file.resource_type).to eq ['Image']
      # why is it an empty string in the form but an empty array here??
      expect(@file.genre_string).to eq []

      patch :update, id: @file, generic_file: {
        genre_string: ['Photograph']
      }
      @file.reload
      expect(@file.resource_type).to eq ['Image']
      # why is it an empty string in the form but an empty array here??
      expect(@file.genre_string).to eq ['Photograph']
    end

    context "dates" do
      let(:ts_attributes) do
        {
          start: "2014",
          start_qualifier: "",
          finish: "",
          finish_qualifier: "",
          label: "",
          note: "",
        }
      end
      let(:time_span) { DateOfPublication.new(ts_attributes) }

      context "publication date" do
        context "creating a new date" do
          context "publication date data is provided" do
            it "persists the nested object" do
              patch :update, id: @file, generic_file: {
                date_of_publication_attributes: { "0" => ts_attributes },
                resource_type: ['Image']
              }

              @file.reload
              pub_date = @file.date_of_publication.first

              expect(@file.date_of_publication.count).to eq(1)
              expect(pub_date.start).to eq("2014")
              expect(pub_date).to be_persisted
            end
          end
          context "publication date data is not provided" do
            it "does not persist a nested object" do
              ts_attributes[:start] = ""
              patch :update, id: @file, generic_file: {
                date_of_publication_attributes: { "0" => ts_attributes },
                resource_type: ['Image']
              }
              @file.reload
              pub_date = @file.date_of_publication.first
              expect(@file.date_of_publication.count).to eq(0)
              expect(DateOfPublication.all.count).to eq 0
            end
          end
        end

        context "when the publication date already exists" do
          before do
            time_span.save!
            @file.date_of_publication << time_span
            @file.save!
          end

          it "allows deletion of the existing timespan" do
            @file.reload
            expect(@file.date_of_publication.count).to eq(1)

            patch :update, id: @file, generic_file: {
              date_of_publication_attributes: {
                "0" => { id: time_span.id, _destroy: "true" }
              }
            }
            @file.reload
            expect(@file.date_of_publication.count).to eq(0)
            #TODO: if we want the TimeSpan to be deleted entirely,
            #     we may need to define a new association in activefedora.
            #     see irc conversation 7/8/2015
            #expect(TimeSpan.all.count).to eq 0
          end
          # just documenting behavior here.. object is not reused.
          it "Creates a new TimeSpan object with same data" do
            file2 = GenericFile.new(title: ['Sal and Baby Bear'])
            file2.apply_depositor_metadata(@user.user_key)
            file2.save!
            patch :update, id: file2, generic_file: {
              date_of_publication_attributes: { "0" => ts_attributes },
            }
            expect(DateOfPublication.all.count).to eq 2
          end

          it "allows updating the existing timespan" do
            patch :update, id: @file, generic_file: {
              date_of_publication_attributes: {
                "0" => ts_attributes.merge(id: time_span.id, start: "1337", start_qualifier: "circa")
              },
            }

            @file.reload
            expect(@file.date_of_publication.count).to eq(1)
            pub_date = @file.date_of_publication.first

            expect(pub_date.id).to eq(time_span.id)
            expect(pub_date.start).to eq("1337")
            expect(pub_date.start_qualifier).to eq("circa")
          end
        end
      end
    end  # context dates
  end # update

end


