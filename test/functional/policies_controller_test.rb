require 'test_helper'

class PoliciesControllerTest < ActionController::TestCase

  fixtures :all

  include AuthenticatedTestHelper

  def setup
    login_as(:datafile_owner)
  end

  test 'should show the preview permission when choosing public scope' do
    post :preview_permissions, :sharing_scope => 4, :access_type => 2, :resource_name => 'data_file'

    assert_response :success
    assert_select "p",:text=>"All visitors (including anonymous visitors with no login) can view summary and get contents",:count=>1
  end

  test 'should show the preview permission when choosing private scope' do
    post :preview_permissions, :sharing_scope => 0, :resource_name => 'data_file'

    assert_response :success
    assert_select "p",:text=>"You keep this Data file private (only visible to you)", :count=>1
  end

  test 'should show the preview permission when choosing network scope' do
    post :preview_permissions, :sharing_scope => Policy::ALL_SYSMO_USERS, :access_type => Policy::VISIBLE, :resource_name => 'data_file'

    assert_response :success
    assert_select "p", :text => "All the project members within the network can view summary only", :count => 1
  end

  test 'should show the preview permission when custom the permissions for Person, Project and FavouriteGroup' do
    contributor_types = ['Person', 'FavouriteGroup', 'Project']
    contributor_values = {}

    user = Factory(:user)
    login_as(user)

    #create a person and set access_type to Policy::MANAGING
    person =  Factory(:person_in_project)
    contributor_values['Person']= {person.id => {"access_type" => Policy::MANAGING}}

    #create a favourite group and members, set access_type to Policy::EDITING
    favorite_group = Factory(:favourite_group, :user => user)
    contributor_values['FavouriteGroup']= {favorite_group.id => {"access_type" => -1}}

    #create a project and members and set access_type to Policy::ACCESSIBLE
    project = Factory(:project)
    contributor_values['Project']= {project.id => {"access_type" => Policy::ACCESSIBLE}}

    post :preview_permissions, :sharing_scope => 0, :contributor_types => ActiveSupport::JSON.encode(contributor_types), :contributor_values => ActiveSupport::JSON.encode(contributor_values), :resource_name => 'data_file'

    assert_response :success
    assert_select "h2",:text=>"Additional fine-grained sharing permissions:", :count=>1

    assert_select 'p', :text=>"#{person.name} can manage", :count => 1
    assert_select 'p', :text=>"Members of Favourite group #{favorite_group.name} have individual access rights for each member", :count => 1
    assert_select 'p', :text=>"Members of Project #{project.name} can view summary and get contents", :count => 1
  end

  test 'should show the correct manager(contributor) when updating a study' do
    study = Factory(:study)
    contributor = study.contributor
    post :preview_permissions, :sharing_scope => Policy::EVERYONE, :access_type => Policy::VISIBLE, :is_new_file => "false", :contributor_id => contributor.user.id, :resource_name => 'study'

    assert_select "p",:text=>"#{contributor.name} can manage as an uploader", :count=>1
  end

  test 'when creating an item, can not publish the item if associate to it the project which has gatekeeper' do
      gatekeeper = Factory(:gatekeeper)
      a_person = Factory(:person)
      sample = Sample.new

      login_as(a_person.user)
      assert sample.can_manage?
      assert sample.can_publish?

      updated_can_publish = PoliciesController.new().updated_can_publish('sample', sample.id, gatekeeper.projects.first.id.to_s)
      assert !updated_can_publish
  end

  test 'when creating an item, can publish the item if associate to it the project which has no gatekeeper' do
        a_person = Factory(:person)
        sample = Sample.new

        login_as(a_person.user)
        assert sample.can_manage?
        assert sample.can_publish?

        updated_can_publish = PoliciesController.new().updated_can_publish('sample', sample.id, Factory(:project).id.to_s)
        assert updated_can_publish
    end

  test 'when updating an item, can not publish the item if associate to it the project which has gatekeeper' do
    gatekeeper = Factory(:gatekeeper)
    a_person = Factory(:person)
    sample = Factory(:sample, :policy => Factory(:policy))
    Factory(:permission, :contributor => a_person, :access_type => Policy::MANAGING, :policy => sample.policy)
    sample.reload

    login_as(a_person.user)
    assert sample.can_manage?
    assert sample.can_publish?

    updated_can_publish = PoliciesController.new().updated_can_publish('sample', sample.id, gatekeeper.projects.first.id.to_s)
    assert !updated_can_publish
  end

  test 'when updating an item, can publish the item if dissociate to it the project which has gatekeeper' do
        gatekeeper = Factory(:gatekeeper)
        a_person = Factory(:person)
        sample = Factory(:sample, :policy => Factory(:policy), :projects => gatekeeper.projects)
        Factory(:permission, :contributor => a_person, :access_type => Policy::MANAGING, :policy => sample.policy)
        sample.reload

        login_as(a_person.user)
        assert sample.can_manage?
        assert !sample.can_publish?

        updated_can_publish = PoliciesController.new().updated_can_publish('sample', sample.id, Factory(:project).id.to_s)
        assert updated_can_publish
  end

  test 'can publish assay without study' do
    a_person = Factory(:person)
    assay = Assay.new

    login_as(a_person.user)
    assert assay.can_manage?
    assert assay.can_publish?

    updated_can_publish = PoliciesController.new().updated_can_publish('assay', assay.id, '')
    assert updated_can_publish
  end

  test 'can not publish assay having project with gatekeeper' do
    gatekeeper = Factory(:gatekeeper)
    a_person = Factory(:person)
    assay = Assay.new
    assay.study = Factory(:study, :investigation => Factory(:investigation, :projects => gatekeeper.projects))

    login_as(a_person.user)
    assert assay.can_manage?
    assert !assay.can_publish?

    updated_can_publish = PoliciesController.new().updated_can_publish('assay', assay.id, assay.study.id.to_s)
    assert !updated_can_publish
  end

  test 'always can publish for the published item' do
          gatekeeper = Factory(:gatekeeper)
          a_person = Factory(:person)
          login_as(gatekeeper.user)
          sample = Factory(:sample, :contributor => gatekeeper.user, :policy => Factory(:public_policy), :projects => gatekeeper.projects)
          Factory(:permission, :contributor => a_person, :access_type => Policy::MANAGING, :policy => sample.policy)
          sample.reload

          login_as(a_person.user)
          assert sample.can_manage?
          assert sample.can_publish?

          updated_can_publish = PoliciesController.new().updated_can_publish('sample', sample.id, gatekeeper.projects.first.id.to_s)
          assert updated_can_publish
  end

  test 'should show the preview permission for resource without projects' do
    post :preview_permissions, :sharing_scope => 2, :access_type => Policy::VISIBLE, :project_access_type => Policy::ACCESSIBLE, :project_ids => '0', :resource_name => 'study'
    assert_response :success

    post :preview_permissions, :sharing_scope => 2, :access_type => Policy::VISIBLE, :project_access_type => Policy::ACCESSIBLE, :project_ids => '0', :resource_name => 'assay'
    assert_response :success

    post :preview_permissions, :sharing_scope => 2, :access_type => Policy::VISIBLE, :project_access_type => Policy::ACCESSIBLE, :project_ids => '0', :resource_name => 'sop'
    assert_response :success
  end
end