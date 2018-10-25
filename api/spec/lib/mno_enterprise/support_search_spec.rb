require 'rails_helper'

module MnoEnterprise
  describe SupportSearch do
    subject { described_class.new(params) }
    let(:params){ {} }
    let!(:organization) { build(:organization) }

    describe '#initialize' do
      subject { described_class.new(params).params }

      let(:params) do
        {
          org_search: {
            where: {
              external_id: ''
            }
          }.to_json,
        }
      end

      let(:expected_params) do
        {
          org_search: {
            "where" => {
              "external_id" => ''
            }
          },
          user_search: {
            "where" => nil
          }
        }
      end

      it { is_expected.to eq(expected_params) }
    end

    describe '#valid_search?' do
      context 'invalid searches' do
        subject(:valid_search) { described_class.new(params).authorized_search? }

        context 'no search' do
          it { is_expected.to eq(false) }
        end

          context 'blank attributes' do
            let(:params) do
              {
                org_search: {
                  where: {
                    external_id: ''
                  }
                }.to_json,
                user_search: {
                  where: {
                    'name.like' => '',
                    'surname.like' => ''
                  }
                }.to_json
              }
            end

          it { is_expected.to eq(false) }
        end

        context 'under 3 letters for first name, last name, and org name' do
          let(:params) do
            {
              org_search: {
                where: {
                  'name.like' => 'ab'
                }
              }.to_json,
              user_search: {
                where: {
                  'name.like' => 'ab',
                  'surname.like' => 'ab'
                }
              }.to_json
            }
          end

          it { is_expected.to eq(false) }
        end

        context 'under 4 letters for first name and last name' do
          let(:params) do
            {
              user_search: {
                where: {
                  'name.like' => 'abc',
                  'surname.like' => 'abd'
                }
              }.to_json
            }
          end

          it { is_expected.to eq(false) }
        end
      end
    end

    context 'valid searches' do
      subject(:valid_search) { described_class.new(params).authorized_search? }

      context 'exact search with a business external id' do
        let(:params) do
          {
            org_search: {
              where: {
                external_id: 1
              }
            }.to_json
          }
        end

        it { is_expected.to eq(true) }
      end

      context 'exact search with first name and last name and org name' do
        let(:params) do
          {
            org_search: {
              where: {
                name: 'hello'
              },
            }.to_json,
            user_search: {
              where: {
                name: 'hiya',
                surname: 'hello'
              }
            }.to_json
          }
        end

        it { is_expected.to eq(true) }
      end

      context 'partial search with a first name, last name, and org name with 3 or more characters' do
        let(:params) do
          {
            org_search: {
              where: {
                'name.like' => 'abc'
              }
            }.to_json,
            user_search: {
              where: {
                'name.like' => 'abc',
                'surname.like' => 'abc'
              }
            }.to_json
          }
        end

        it { is_expected.to eq(true) }
      end

      context 'partial search with a first name, and last name with 4 or more characters' do
        let(:params) do
          {
            user_search: {
              where: {
                'name.like' => 'abcd',
                'surname.like' => 'abcd'
              }
            }.to_json
          }
        end

        it { is_expected.to eq(true) }
      end

      context 'with a first name, and last name with 4 or more characters' do
        let(:params) do
          {
            user_search: {
              where: {
                'name.like' => 'abcd',
                'surname.like' => 'abcd'
              }
            }.to_json
          }
        end

        it { is_expected.to eq(true) }
      end
    end

    describe '#search' do
      subject(:search) { described_class.new(params).search }

      context 'with an #organization_external_id' do
        let(:params) do
          {
            org_search: {
              where: {
                external_id: external_id
              }
            }.to_json
          }
        end

        let(:external_id) { 1 }
        let(:external_id_filter){ { filter: { external_id: external_id } } }

        before { stub_api_v2(:get, "/organizations", [organization], [], external_id_filter) }

        it { expect(subject.first['id']).to eq(organization.id) }
      end

      context 'with partial search on Organization#name, User#name, and User#surname' do
        let(:organization_two) { build(:organization) }
        let(:returned_user) { build(:user, organizations: user_organizations) }
        let(:params) do
          {
            org_search: {
              where: {
                'name.like' => org_name
              }
            }.to_json,
            user_search: {
              where: {
                'name.like' => user_name,
                'surname.like' => surname
              }
            }.to_json
          }
        end

        let(:org_name) { 'Testing1234' }
        let(:user_name) { 'Jeffrey' }
        let(:surname) { 'Donut' }
        let(:external_id) { 1 }
        let(:user_organizations) { [organization, organization_two] }
        let(:org_filter){ { filter: { 'name.like' => org_name, 'id' => user_organizations.map(&:id) } } }
        let(:user_filter){ { filter: { 'name.like' => user_name, 'surname.like' => surname } } }

        before { stub_api_v2(:get, "/organizations", [organization], [], org_filter) }
        before { stub_api_v2(:get, "/users", [returned_user], [:organizations, :orga_relations], user_filter) }

        it { expect(subject.length).to eq(1) }
        it { expect(subject.first['id']).to eq(organization.id) }
      end

      context 'with partial search on User#name, and User#surname' do
        let(:returned_user) { build(:user, organizations: [organization]) }
        let(:params) do
          {
            user_search: {
              where: {
                'name.like' => user_name,
                'surname.like' => surname
              }
            }.to_json
          }
        end

        let(:user_name) { 'Jane' }
        let(:surname) { 'Doey' }
        let(:external_id) { 1 }
        let(:user_filter){ { filter: { 'name.like' => user_name, 'surname.like' => surname } } }

        before { stub_api_v2(:get, "/users", [returned_user], [:organizations, :orga_relations], user_filter) }

        it { expect(subject.first['id']).to eq(organization.id) }
      end

      context 'with exact search on User#name, and User#surname' do
        let(:returned_user) { build(:user, organizations: [organization]) }
        let(:params) do
          {
            user_search: {
              where: {
                'name' => user_name,
                'surname' => surname
              }
            }.to_json
          }
        end

        let(:user_name) { 'Jay' }
        let(:surname) { 'Doe' }
        let(:external_id) { 1 }
        let(:user_filter){ { filter: { 'name' => user_name, 'surname' => surname } } }

        before { stub_api_v2(:get, "/users", [returned_user], [:organizations, :orga_relations], user_filter) }

        it { expect(subject.first['id']).to eq(organization.id) }
      end

      context 'with unauthorized search' do
        it { is_expected.to eq([])}
      end
    end
  end
end
